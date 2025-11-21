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
    _parking:
        'https://maps.app.goo.gl/fWSvYDKn4Xv2xkU67?g_st=ipc', // Parking CMA
    _campus:
        'https://maps.app.goo.gl/nKrGxmG7KHbmvewy5?g_st=ipc', // Campus
    _camping:
        'https://maps.app.goo.gl/UCYuXx5zeEuNR2Rq6?g_st=ipc', // Camping
  };

  /// Valeurs choisies dans les menus
  String _depart = _campus;
  String _arrivee = _parking;

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    final dtText = selectedDateTime == null
        ? 'Aucune date/heure choisie'
        : '${selectedDateTime!.day}/${selectedDateTime!.month} '
            '${selectedDateTime!.hour.toString().padLeft(2, '0')}:'
            '${selectedDateTime!.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un trajet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choix du trajet :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                // Départ
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _depart,
                    decoration: const InputDecoration(labelText: 'Départ'),
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
                IconButton(
                  onPressed: () {
                    setState(() {
                      final tmp = _depart;
                      _depart = _arrivee;
                      _arrivee = tmp;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz),
                ),
                // Arrivée
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _arrivee,
                    decoration: const InputDecoration(labelText: 'Arrivée'),
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
            const SizedBox(height: 4),

            _gpsLink('Départ $_depart', _depart),
            _gpsLink('Arrivée $_arrivee', _arrivee),

            const SizedBox(height: 16),
            Text(dtText),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: const Text('Choisir date & heure'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nbPlacesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de places disponibles dans la voiture',
              ),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTrip,
                child: const Text('Créer le trajet'),
              ),
              
            ),
          ],
        ),
      ),
    );
  }
}
