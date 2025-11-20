import 'package:flutter/material.dart';
import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/trip_service.dart';
import 'package:covoit_app/auth/screens/common/driver/trip_qr_page.dart';
import 'package:covoit_app/auth/screens/common/driver/trip_passengers_page.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  bool loading = true;
  String? error;
  List<Trip> trips = [];

  /// sens choisi par le conducteur sur cette page
  /// "campus_to_cma" ou "cma_to_campus"
  String selectedDirection = 'campus_to_cma';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final list = await tripService.getMyTrips();
      setState(() {
        trips = list;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes trajets (Conducteur)')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
           
   
            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (trips.isEmpty && error == null)
              const Text('Tu n\'as encore créé aucun trajet.'),

            ...trips.map((trip) {
              final dateString =
                  '${trip.heureDepart.day}/${trip.heureDepart.month} '
                  '${trip.heureDepart.hour.toString().padLeft(2, '0')}'
                  ':${trip.heureDepart.minute.toString().padLeft(2, '0')}';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trajet du $dateString',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TripQrPage(trip: trip),
                                ),
                              );
                            },
                            child: const Text('Voir QR Code'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TripPassengersPage(trip: trip),
                                ),
                              );
                            },
                            child: const Text('Voir les passagers'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
