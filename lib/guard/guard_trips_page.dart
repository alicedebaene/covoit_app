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

  @override
  void initState() {
    super.initState();
    _loadTrips();
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
      builder: (context) {
        if (errorMsg != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Erreur lors du chargement des passagers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(errorMsg!),
              ],
            ),
          );
        }

        if (passengers.isEmpty) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: Text('Aucun passager pour ce trajet'),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Passagers du trajet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: passengers.length,
                  itemBuilder: (context, index) {
                    final p = passengers[index];
                    final prenom = p['passenger_prenom'] ?? '';
                    final nom = p['passenger_nom'] ?? '';
                    final email = p['passenger_email'] ?? '';
                    final tel = p['passenger_telephone'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• $prenom $nom',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (email.isNotEmpty) Text('📧 $email'),
                          if (tel.isNotEmpty) Text('📞 $tel'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tous les trajets')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];

          final dateHeure =
              DateTime.tryParse(trip['heure_depart'] as String? ?? '');
          final dateStr = dateHeure == null
              ? 'Date inconnue'
              : DateFormat('dd/MM/yyyy – HH:mm').format(dateHeure);

          final statut = trip['statut'] as String? ?? 'inconnu';
          final nbPlaces = trip['nb_places'] ?? 0;

          final depart = (trip['depart'] ?? '') as String;
          final arrivee = (trip['arrivee'] ?? '') as String;

          final driverEmailRaw = (trip['driver_email'] ?? '') as String;
          final driverEmail = driverEmailRaw.toLowerCase();
          final driver = driversByEmail[driverEmail];

          final driverPrenom = driver?['prenom'] ?? '';
          final driverNom = driver?['nom'] ?? '';
          final driverTel = driver?['telephone'] ?? '';
          final permisUrl = (driver?['permis_url'] ?? '').toString();
          final carPlate = driver?['car_plate'] ?? '';
          final carModel = driver?['car_model'] ?? '';
          final carColor = driver?['car_color'] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Haut : conducteur + bouton oeil
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🚗 Conducteur : $driverPrenom $driverNom',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (driverEmailRaw.isNotEmpty)
                              Text('📧 $driverEmailRaw'),
                            if (driverTel.toString().isNotEmpty)
                              Text('📞 $driverTel'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye),
                        tooltip: 'Voir les passagers',
                        onPressed: () => _showPassengersSheet(trip),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lieux + GPS
                  if (depart.isNotEmpty && arrivee.isNotEmpty) ...[
                    Text('Trajet : $depart → $arrivee'),
                    const SizedBox(height: 4),
                    _gpsLink('Départ ($depart)', depart),
                    _gpsLink('Arrivée ($arrivee)', arrivee),
                    const SizedBox(height: 8),
                  ],

                  // Photo permis
                  if (permisUrl.isNotEmpty) ...[
                    const Text(
                      'Permis du conducteur :',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        permisUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'Impossible de charger la photo du permis',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Infos voiture
                  const Text(
                    'Véhicule :',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (carPlate.toString().isNotEmpty)
                    Text('🚘 Plaque : $carPlate'),
                  if (carModel.toString().isNotEmpty)
                    Text('📄 Modèle : $carModel'),
                  if (carColor.toString().isNotEmpty)
                    Text('🎨 Couleur : $carColor'),
                  const SizedBox(height: 12),

                  // Infos trajet
                  Text('📅 Départ : $dateStr'),
                  Text('🪪 Statut : $statut'),
                  Text('🧍 Places annoncées : $nbPlaces'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
