import 'package:covoit_app/models/parking.dart';
import 'package:covoit_app/service/parking_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';


class ParkingStatusPage extends StatefulWidget {
  const ParkingStatusPage({super.key});

  @override
  State<ParkingStatusPage> createState() => _ParkingStatusPageState();
}

class _ParkingStatusPageState extends State<ParkingStatusPage> {
  bool loading = true;
  Parking? parking;
  String? error;

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final p = await parkingService.getFirstParking();
      setState(() {
        parking = p;
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
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (parking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('État du parking')),
        body: Center(
          child: Text(error ?? 'Erreur de chargement'),
        ),
      );
    }

    final p = parking!;

    return Scaffold(
      appBar: AppBar(title: const Text('État du parking')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              p.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Places totales : ${p.placesTotales}'),
            Text('Places disponibles : ${p.placesDisponibles}'),
          ],
        ),
      ),
    );
  }
}
