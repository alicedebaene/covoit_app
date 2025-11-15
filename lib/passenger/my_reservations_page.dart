import 'package:flutter/material.dart';
import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/reservation_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
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
      final list = await reservationService.getMyReservations();
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (trips.isEmpty && error == null)
              const Text('Aucune réservation pour le moment'),
            ...trips.map((trip) {
              final dateString =
                  '${trip.heureDepart.day}/${trip.heureDepart.month} '
                  '${trip.heureDepart.hour.toString().padLeft(2, '0')}:'
                  '${trip.heureDepart.minute.toString().padLeft(2, '0')}';
              return Card(
                child: ListTile(
                  title: Text('Trajet du $dateString'),
                  subtitle:
                      Text('Places totales : ${trip.nbPlaces}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
