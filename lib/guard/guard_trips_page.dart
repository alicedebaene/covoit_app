import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoit_app/service/supabase_client.dart';

class GuardTripsPage extends StatefulWidget {
  const GuardTripsPage({super.key});

  @override
  State<GuardTripsPage> createState() => _GuardTripsPageState();
}

class _GuardTripsPageState extends State<GuardTripsPage> {
  bool loading = true;

  /// Liste brute des trajets (table `trajets`)
  List<Map<String, dynamic>> trips = [];

  /// email -> infos conducteur (table `app_users`)
  Map<String, Map<String, dynamic>> driversByEmail = {};

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  // -------- UI helpers --------

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _primarySoft, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _chip({
    required IconData icon,
    required String text,
    Color? fg,
    Color? bg,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg ?? _primarySoft.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _primarySoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: (fg ?? _text).withOpacity(0.85)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: (fg ?? _text).withOpacity(0.85),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }

  // -------- GPS helpers --------

  String? _gpsUrlFor(String? place) {
    if (place == null) return null;
    switch (place) {
      case 'Parking CMA':
        return 'https://maps.app.goo.gl/fWSvYDKn4Xv2xkU67?g_st=ipc';
      case 'Campus':
        return 'https://maps.app.goo.gl/nKrGxmG7KHbmvewy5?g_st=ipc';
      case 'Camping':
        return 'https://maps.app.goo.gl/UCYuXx5zeEuNR2Rq6?g_st=ipc';
      default:
        return null;
    }
  }

  Future<void> _openGps(String? place) async {
    final url = _gpsUrlFor(place);
    if (url == null) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir la carte.')),
      );
    }
  }

  Widget _gpsLink(String label, String? place) {
    final url = _gpsUrlFor(place);
    if (url == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _openGps(place),
        icon: const Icon(Icons.pin_drop),
        label: Text('$label (ouvrir dans Maps)'),
        style: TextButton.styleFrom(
          foregroundColor: _green,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // -------- Chargement trajets + conducteurs --------

  Future<void> _loadTrips() async {
    try {
      // trajets avec départ / arrivée
      final tripData = await supabase
          .from('trajets')
          .select(
            'id, heure_depart, statut, nb_places, driver_email, depart, arrivee',
          )
          .order('heure_depart', ascending: false);

      final tripsList = List<Map<String, dynamic>>.from(tripData as List);

      final Map<String, Map<String, dynamic>> drivers = {};

      for (final t in tripsList) {
        final emailRaw = (t['driver_email'] ?? '') as String;
        final email = emailRaw.toLowerCase().trim();

        if (email.isEmpty) continue;
        if (drivers.containsKey(email)) continue;

        try {
          final userData = await supabase
              .from('app_users')
              .select(
                'email, prenom, nom, telephone, permis_url, car_plate, car_model, car_color',
              )
              .eq('email', email)
              .maybeSingle();

          if (userData != null) {
            drivers[email] =
                Map<String, dynamic>.from(userData as Map<String, dynamic>);
          }
        } catch (e) {
          debugPrint('Erreur chargement app_users pour $email : $e');
        }
      }

      setState(() {
        trips = tripsList;
        driversByEmail = drivers;
        loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement trajets (guard) : $e');
      setState(() => loading = false);
    }
  }

  Future<void> _showPassengersSheet(Map<String, dynamic> trip) async {
    final tripId = trip['id'];

    List<Map<String, dynamic>> passengers = [];
    String? errorMsg;

    try {
      final data = await supabase
          .from('reservations')
          .select(
            'passenger_prenom, passenger_nom, passenger_email, passenger_telephone',
          )
          .eq('trajet_id', tripId);

      passengers = List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      errorMsg = e.toString();
      debugPrint('Erreur chargement passagers (guard) : $e');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: _bg,
      builder: (context) {
        if (errorMsg != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Erreur lors du chargement des passagers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(errorMsg!),
                ],
              ),
            ),
          );
        }

        if (passengers.isEmpty) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: Text(
                'Aucun passager pour ce trajet',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _primarySoft, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Passagers du trajet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: passengers.length,
                    itemBuilder: (context, index) {
                      final p = passengers[index];
                      final prenom = (p['passenger_prenom'] ?? '').toString();
                      final nom = (p['passenger_nom'] ?? '').toString();
                      final email = (p['passenger_email'] ?? '').toString();
                      final tel = (p['passenger_telephone'] ?? '').toString();

                      final name = ('$prenom $nom').trim().isEmpty
                          ? 'Passager'
                          : ('$prenom $nom').trim();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primarySoft.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _primarySoft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (email.isNotEmpty)
                                  _chip(
                                    icon: Icons.mail_outline,
                                    text: email,
                                  ),
                                if (tel.isNotEmpty)
                                  _chip(
                                    icon: Icons.phone_outlined,
                                    text: tel,
                                  ),
                                if (email.isEmpty && tel.isEmpty)
                                  Text(
                                    'Aucune coordonnée.',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                      color: _text.withOpacity(0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String statut) {
    final s = statut.toLowerCase().trim();
    if (s.contains('valide') || s.contains('ok') || s.contains('term')) {
      return _green;
    }
    if (s.contains('annul') || s.contains('refus') || s.contains('ko')) {
      return Colors.red;
    }
    return _primary; // par défaut
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tous les trajets',
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

            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _card(
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
                                border:
                                    Border.all(color: _primary, width: 1.5),
                              ),
                              child: const Text(
                                'SURVEILLANT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: _text,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.list_alt_outlined,
                                color: _green.withOpacity(0.9)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Trajets enregistrés : ${trips.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ouvre un trajet pour voir le conducteur, son véhicule, le permis et les passagers.',
                          style: TextStyle(
                            color: _text.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final trip = trips[index - 1];

                final dateHeure =
                    DateTime.tryParse(trip['heure_depart'] as String? ?? '');
                final dateStr = dateHeure == null
                    ? 'Date inconnue'
                    : DateFormat('dd/MM/yyyy – HH:mm').format(dateHeure);

                final statut = (trip['statut'] as String? ?? 'inconnu').trim();
                final nbPlaces = trip['nb_places'] ?? 0;

                final depart = (trip['depart'] ?? '') as String;
                final arrivee = (trip['arrivee'] ?? '') as String;

                final driverEmailRaw = (trip['driver_email'] ?? '') as String;
                final driverEmail = driverEmailRaw.toLowerCase().trim();
                final driver = driversByEmail[driverEmail];

                final driverPrenom = (driver?['prenom'] ?? '').toString();
                final driverNom = (driver?['nom'] ?? '').toString();
                final driverTel = (driver?['telephone'] ?? '').toString();
                final permisUrl = (driver?['permis_url'] ?? '').toString();
                final carPlate = (driver?['car_plate'] ?? '').toString();
                final carModel = (driver?['car_model'] ?? '').toString();
                final carColor = (driver?['car_color'] ?? '').toString();

                final statusColor = _statusColor(statut);

                return _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top row: conducteur + button passagers
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Conducteur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _text.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${driverPrenom.isEmpty && driverNom.isEmpty ? 'Inconnu' : '$driverPrenom $driverNom'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: _text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (driverEmailRaw.isNotEmpty)
                                      _chip(
                                        icon: Icons.mail_outline,
                                        text: driverEmailRaw,
                                      ),
                                    if (driverTel.isNotEmpty)
                                      _chip(
                                        icon: Icons.phone_outlined,
                                        text: driverTel,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _chip(
                            icon: Icons.remove_red_eye_outlined,
                            text: 'Passagers',
                            fg: _text,
                            bg: _primary,
                            onTap: () => _showPassengersSheet(trip),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Trajet + badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(
                            icon: Icons.schedule,
                            text: dateStr,
                          ),
                          _chip(
                            icon: Icons.event_seat_outlined,
                            text: '$nbPlaces place(s)',
                          ),
                          _chip(
                            icon: Icons.verified_outlined,
                            text: statut.isEmpty ? 'inconnu' : statut,
                            fg: statusColor,
                            bg: statusColor.withOpacity(0.12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (depart.isNotEmpty && arrivee.isNotEmpty) ...[
                        Text(
                          'Trajet : $depart → $arrivee',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _gpsLink('Départ ($depart)', depart),
                        _gpsLink('Arrivée ($arrivee)', arrivee),
                        const SizedBox(height: 8),
                      ],

                      // Permis
                      if (permisUrl.isNotEmpty) ...[
                        const Text(
                          'Permis du conducteur',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: _primarySoft, width: 2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Image.network(
                              permisUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Impossible de charger la photo du permis',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Voiture
                      const Text(
                        'Véhicule',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (carPlate.isNotEmpty)
                            _chip(
                              icon: Icons.confirmation_number_outlined,
                              text: carPlate,
                            ),
                          if (carModel.isNotEmpty)
                            _chip(
                              icon: Icons.directions_car_outlined,
                              text: carModel,
                            ),
                          if (carColor.isNotEmpty)
                            _chip(
                              icon: Icons.palette_outlined,
                              text: carColor,
                            ),
                          if (carPlate.isEmpty && carModel.isEmpty && carColor.isEmpty)
                            Text(
                              'Aucune info véhicule.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: _text.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
