import 'package:flutter/material.dart';
import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/reservation_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class TripPassengersPage extends StatefulWidget {
  final Trip trip;

  const TripPassengersPage({super.key, required this.trip});

  @override
  State<TripPassengersPage> createState() => _TripPassengersPageState();
}

class _TripPassengersPageState extends State<TripPassengersPage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> passengers = [];

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
      final list =
          await reservationService.getPassengersForTrip(widget.trip.id);
      setState(() {
        passengers = list;
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

    final dateString =
        '${widget.trip.heureDepart.day}/${widget.trip.heureDepart.month} '
        '${widget.trip.heureDepart.hour.toString().padLeft(2, '0')}:'
        '${widget.trip.heureDepart.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text('Passagers du trajet du $dateString')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (passengers.isEmpty && error == null)
              const Text('Aucun passager pour le moment.'),
            ...passengers.map((p) {
              final prenom = (p['passenger_prenom'] ?? '') as String;
              final nom = (p['passenger_nom'] ?? '') as String;
              final tel = (p['passenger_telephone'] ?? '') as String;
              final email = (p['passenger_email'] ?? '') as String;

              return Card(
                child: ListTile(
                  title: Text(
                    (prenom + ' ' + nom).trim().isEmpty
                        ? 'Passager'
                        : (prenom + ' ' + nom).trim(),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tel.isNotEmpty) Text('Téléphone : $tel'),
                      if (email.isNotEmpty) Text('Email : $email'),
                      if (tel.isEmpty && email.isEmpty)
                        const Text(
                          'Aucune coordonnée enregistrée pour ce passager.',
                          style: TextStyle(fontStyle: FontStyle.italic),
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
