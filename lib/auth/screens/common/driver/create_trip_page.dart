import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoit_app/service/trip_service.dart';
import 'package:covoit_app/auth/screens/common/driver/trip_qr_page.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  DateTime? selectedDateTime;
  bool loading = false;
  String? error;

  int nbPlaces = 1;
  final nbPlacesController = TextEditingController(text: '1');

  /// Lieux possibles
  static const _campus = 'Campus';
  static const _parking = 'Parking CMA';
  static const _camping = 'Camping';

  /// URLs Google Maps associées
  static const Map<String, String> _gpsUrls = {
    _parking: 'https://maps.app.goo.gl/fWSvYDKn4Xv2xkU67?g_st=ipc', // Parking CMA
    _campus: 'https://maps.app.goo.gl/nKrGxmG7KHbmvewy5?g_st=ipc', // Campus
    _camping: 'https://maps.app.goo.gl/UCYuXx5zeEuNR2Rq6?g_st=ipc', // Camping
  };

  /// Valeurs choisies dans les menus
  String _depart = _campus;
  String _arrivee = _parking;

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  @override
  void dispose() {
    nbPlacesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      initialDate: now,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createTrip() async {
    if (selectedDateTime == null) {
      setState(() => error = 'Choisis une date/heure');
      return;
    }

    final parsed = int.tryParse(nbPlacesController.text);
    if (parsed == null || parsed <= 0) {
      setState(() => error = 'Nombre de places invalide');
      return;
    }
    nbPlaces = parsed;

    final depart = _depart;
    final arrivee = _arrivee;

    // 🔁 Trajet retour si départ = Parking CMA
    final bool isReturnTrip = depart == _parking;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 🟢 plus de paramètre isReturnTrip ici
      final trip = await tripService.createTrip(
        heureDepart: selectedDateTime!,
        nbPlaces: nbPlaces,
        depart: depart,
        arrivee: arrivee,
      );

      if (!mounted) return;

      if (!isReturnTrip) {
        // ALLER → on affiche le QR
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TripQrPage(trip: trip),
          ),
        );
      } else {
        // RETOUR → pas de QR
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _openGps(String place) async {
    final url = _gpsUrls[place];
    if (url == null) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir la carte.')),
      );
    }
  }

  Widget _gpsLink(String label, String place) {
    final url = _gpsUrls[place];
    if (url == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _openGps(place),
        icon: const Icon(Icons.pin_drop),
        label: Text('$label (ouvrir dans Maps)'),
        style: TextButton.styleFrom(
          foregroundColor: _green,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _primarySoft.withOpacity(0.55),
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primarySoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primarySoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _green, width: 2),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} à $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    final dtText = selectedDateTime == null
        ? 'Aucune date/heure choisie'
        : _formatDateTime(selectedDateTime!);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Créer un trajet',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: _text,
          ),
        ),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Décor voitures bas (si l’asset existe)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.95,
                  child: Image.asset(
                    'assets/images/cars_border.png',
                    fit: BoxFit.cover,
                    height: 70,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 70),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bandeau titre / explication
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _primarySoft, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primarySoft,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Text(
                                    'TRAJET',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                      color: _text,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.directions_car_filled,
                                  color: _green.withOpacity(0.85),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Choix du trajet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Définis le départ, l’arrivée, l’heure et le nombre de places.',
                              style: TextStyle(
                                color: _text.withOpacity(0.75),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Carte - départ/arrivée + swap + GPS
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _primarySoft, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _depart,
                                    decoration: _fieldDecoration(
                                      label: 'Départ',
                                      icon: Icons.my_location,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: _campus,
                                        child: Text(_campus),
                                      ),
                                      DropdownMenuItem(
                                        value: _parking,
                                        child: Text(_parking),
                                      ),
                                      DropdownMenuItem(
                                        value: _camping,
                                        child: Text(_camping),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() => _depart = v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: _primarySoft.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _primarySoft),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Inverser départ / arrivée',
                                    onPressed: () {
                                      setState(() {
                                        final tmp = _depart;
                                        _depart = _arrivee;
                                        _arrivee = tmp;
                                      });
                                    },
                                    icon: const Icon(Icons.swap_horiz),
                                    color: _text,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _arrivee,
                                    decoration: _fieldDecoration(
                                      label: 'Arrivée',
                                      icon: Icons.flag_outlined,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: _campus,
                                        child: Text(_campus),
                                      ),
                                      DropdownMenuItem(
                                        value: _parking,
                                        child: Text(_parking),
                                      ),
                                      DropdownMenuItem(
                                        value: _camping,
                                        child: Text(_camping),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() => _arrivee = v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _gpsLink('Départ $_depart', _depart),
                            _gpsLink('Arrivée $_arrivee', _arrivee),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Carte - date/heure + places
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _primarySoft, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Date
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _primarySoft.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _primarySoft),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: _green.withOpacity(0.85),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      dtText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _text,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _pickDateTime,
                                    style: TextButton.styleFrom(
                                      foregroundColor: _text,
                                      backgroundColor: _primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Choisir',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Places
                            TextField(
                              controller: nbPlacesController,
                              keyboardType: TextInputType.number,
                              decoration: _fieldDecoration(
                                label: 'Places disponibles',
                                icon: Icons.event_seat_outlined,
                              ).copyWith(
                                helperText:
                                    'Indique le nombre de places libres dans ta voiture.',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Erreur en bulle
                      if (error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Bouton action (dans une carte sticky visuelle)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _primarySoft, width: 2),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _createTrip,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Créer le trajet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: _text,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // espace pour le décor bas
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
