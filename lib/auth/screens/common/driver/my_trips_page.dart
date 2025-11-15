import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/trip_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:covoit_app/widgets/trip_card.dart';
import 'package:flutter/material.dart';
import 'trip_qr_page.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  bool loading = true;
  List<Trip> trips = [];
  String? error;

  Future<void> _loadTrips() async {
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
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes trajets')),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (trips.isEmpty && error == null)
              const Text('Aucun trajet pour le moment'),
            ...trips.map(
              (t) => TripCard(
                trip: t,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripQrPage(trip: t),
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
