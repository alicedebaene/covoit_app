import 'package:flutter/material.dart';

import 'package:covoit_app/service/trip_service.dart';
import 'package:covoit_app/auth/screens/common/driver/trip_qr_page.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  DateTime? selectedDateTime;
  bool loading = false;
  String? error;

  int nbPlaces = 1;
  final nbPlacesController = TextEditingController(text: '1');

  @override
  void dispose() {
    nbPlacesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      initialDate: now,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createTrip() async {
    if (selectedDateTime == null) {
      setState(() {
        error = 'Choisis une date/heure';
      });
      return;
    }

    final parsed = int.tryParse(nbPlacesController.text);
    if (parsed == null || parsed <= 0) {
      setState(() {
        error = 'Nombre de places invalide';
      });
      return;
    }
    nbPlaces = parsed;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 🔴 ICI : plus de paramètres nommés
      final trip = await tripService.createTrip(
        selectedDateTime!,
        nbPlaces,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TripQrPage(trip: trip),
        ),
      );
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

    final dtText = selectedDateTime == null
        ? 'Aucune date/heure choisie'
        : '${selectedDateTime!.day}/${selectedDateTime!.month} '
          '${selectedDateTime!.hour.toString().padLeft(2, '0')}:'
          '${selectedDateTime!.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un trajet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(dtText),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: const Text('Choisir date & heure'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nbPlacesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de places disponibles dans la voiture',
              ),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTrip,
                child: const Text('Créer et générer QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
