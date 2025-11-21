import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/reservation_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
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

  // -------- Réservation --------

  Future<void> _reserve(Trip trip) async {
    try {
      await reservationService.reserveSeat(trip.id);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réservation : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trajets disponibles')),
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
              const Text('Aucun trajet disponible pour le moment.'),
            ...trips.map(_buildTripCard),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final date = DateFormat('dd/MM à HH:mm').format(trip.heureDepart);

    final depart = trip.depart;
    final arrivee = trip.arrivee;
    final remaining = trip.remainingPlaces; // getter du modèle

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trajet du $date',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            if (depart.isNotEmpty && arrivee.isNotEmpty) ...[
              Text('Trajet : $depart → $arrivee'),
              const SizedBox(height: 4),
              _gpsLink('Départ ($depart)', depart),
              _gpsLink('Arrivée ($arrivee)', arrivee),
              const SizedBox(height: 4),
            ],

            Text('Places restantes : $remaining / ${trip.nbPlaces}'),
            const SizedBox(height: 4),
            Text(
              'Conducteur : ${trip.driverPrenom ?? ''} ${trip.driverNom ?? ''}',
            ),
            if (trip.driverTelephone != null &&
                trip.driverTelephone!.isNotEmpty)
              Text('Téléphone conducteur : ${trip.driverTelephone}'),
            if (trip.driverEmail != null && trip.driverEmail!.isNotEmpty)
              Text('Email conducteur : ${trip.driverEmail}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _reserve(trip),
                child: const Text('Réserver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
