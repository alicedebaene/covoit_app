import 'package:flutter/material.dart';
import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/reservation_service.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class AvailableTripsPage extends StatefulWidget {
  const AvailableTripsPage({super.key});

  @override
  State<AvailableTripsPage> createState() => _AvailableTripsPageState();
}

class _AvailableTripsPageState extends State<AvailableTripsPage> {
  bool loading = true;
  String? error;
  List<Trip> trips = [];

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
      final list = await reservationService.getAvailableTrips();
      setState(() {
        trips = list;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<int> _countReservations(String trajetId) async {
    final res = await supabase
        .from('reservations')
        .select('id')
        .eq('trajet_id', trajetId);
    return (res as List).length;
  }

  Future<void> _reserve(Trip trip) async {
    try {
      await reservationService.reserveSeat(trip.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place réservée !')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trajets disponibles')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            ...trips.map(
              (trip) => FutureBuilder<int>(
                future: _countReservations(trip.id),
                builder: (context, snapshot) {
                  final reserv = snapshot.data ?? 0;
                  final restantes = trip.nbPlaces - reserv;

                  // Si plus de places → on n'affiche pas ce trajet
                  if (restantes <= 0) {
                    return const SizedBox.shrink();
                  }

                  final dateString =
                      '${trip.heureDepart.day}/${trip.heureDepart.month} '
                      '${trip.heureDepart.hour.toString().padLeft(2, '0')}:'
                      '${trip.heureDepart.minute.toString().padLeft(2, '0')}';

                  return Card(
                    child: ListTile(
                      title: Text('Trajet du $dateString'),
                      subtitle: Text(
                          'Places restantes : $restantes / ${trip.nbPlaces}'),
                      trailing: ElevatedButton(
                        onPressed: () => _reserve(trip),
                        child: const Text('Réserver'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
