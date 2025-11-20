import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:covoit_app/service/supabase_client.dart';

class GuardTripsPage extends StatefulWidget {
  const GuardTripsPage({super.key});

  @override
  State<GuardTripsPage> createState() => _GuardTripsPageState();
}

class _GuardTripsPageState extends State<GuardTripsPage> {
  bool loading = true;
  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final data = await supabase
          .from('trajets')
          .select(
            '''
            id,
            heure_depart,
            statut,
            nb_places,
            driver_email,
            driver_prenom,
            driver_nom,
            driver_telephone
            ''',
          )
          .order('heure_depart', ascending: false);

      setState(() {
        trips = List<Map<String, dynamic>>.from(data as List);
        loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement trajets (guard) : $e');
      setState(() => loading = false);
    }
  }

  Future<void> _showPassengersSheet(Map<String, dynamic> trip) async {
    final tripId = trip['id']; // uuid ou string → on ne caste pas

    List<Map<String, dynamic>> passengers = [];
    String? errorMsg;

    try {
      final data = await supabase
          .from('reservations')
          .select(
            '''
            passenger_prenom,
            passenger_nom,
            passenger_email,
            passenger_telephone
            ''',
          )
          .eq('trajet_id', tripId);

      passengers = List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      // Si RLS / colonne / autre erreur → on la garde pour l'afficher
      errorMsg = e.toString();
      debugPrint('Erreur chargement passagers (guard) : $e');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        // 1) Erreur Supabase
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

        // 2) Aucun passager
        if (passengers.isEmpty) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: Text('Aucun passager pour ce trajet'),
            ),
          );
        }

        // 3) Liste des passagers
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

          final driverPrenom = trip['driver_prenom'] ?? '';
          final driverNom = trip['driver_nom'] ?? '';
          final driverEmail = trip['driver_email'] ?? '';
          final driverTel = trip['driver_telephone'] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Haut de la carte : conducteur + oeil
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
                            if (driverEmail.isNotEmpty) Text('📧 $driverEmail'),
                            if (driverTel.isNotEmpty) Text('📞 $driverTel'),
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
