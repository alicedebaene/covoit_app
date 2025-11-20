import 'package:flutter/material.dart';
import 'package:covoit_app/service/trip_service.dart';
import 'package:covoit_app/auth/screens/common/driver/trip_qr_page.dart';
import 'package:covoit_app/auth/screens/common/driver/my_trips_page.dart';
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

  // Sens du trajet
  String depart = "Campus";
  String arrivee = "Parking CMA";

  void _invertDirection() {
    setState(() {
      final oldDepart = depart;
      depart = arrivee;
      arrivee = oldDepart;
    });
  }

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
    // Vérif date
    if (selectedDateTime == null) {
      setState(() => error = 'Choisis une date/heure');
      return;
    }

    // Vérif nb places
    final parsed = int.tryParse(nbPlacesController.text);
    if (parsed == null || parsed <= 0) {
      setState(() => error = 'Nombre de places invalide');
      return;
    }
    nbPlaces = parsed;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Création du trajet (aller OU retour)
      final trip = await tripService.createTrip(
        heureDepart: selectedDateTime!,
        nbPlaces: nbPlaces,
        depart: depart,
        arrivee: arrivee,
      );

      if (!mounted) return;

      // 🟢 Cas 1 : Aller -> on montre le QR
      if (depart != 'Parking CMA') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TripQrPage(trip: trip),
          ),
        );
        return;
      }

      // 🔵 Cas 2 : Retour (Parking CMA -> …)
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Trajet retour créé'),
            content: const Text(
              'Ton trajet retour depuis le parking a bien été créé.\n\n'
              'Pour sortir du parking, le surveillant doit scanner le même QR code '
              'que pour ton trajet aller.\n\n'
              'Les passagers pourront réserver ce trajet retour dans l\'onglet passager.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // On renvoie le conducteur vers ses trajets
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MyTripsPage(),
        ),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) {
        setState(() => loading = false);
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
          '${selectedDateTime!.hour.toString().padLeft(2, "0")}:'
          '${selectedDateTime!.minute.toString().padLeft(2, "0")}';

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un trajet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Choix du trajet ---
            const Text(
              'Choix du trajet :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: depart,
                    decoration: const InputDecoration(labelText: 'Départ'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Campus',
                        child: Text('Campus'),
                      ),
                      DropdownMenuItem(
                        value: 'Camping',
                        child: Text('Camping'),
                      ),
                      DropdownMenuItem(
                        value: 'Parking CMA',
                        child: Text('Parking CMA'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => depart = val);
                    },
                  ),
                ),
                IconButton(
                  onPressed: _invertDirection,
                  icon: const Icon(Icons.swap_horiz, size: 30),
                  tooltip: 'Inverser trajet (retour)',
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: arrivee,
                    decoration: const InputDecoration(labelText: 'Arrivée'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Parking CMA',
                        child: Text('Parking CMA'),
                      ),
                      DropdownMenuItem(
                        value: 'Campus',
                        child: Text('Campus'),
                      ),
                      DropdownMenuItem(
                        value: 'Camping',
                        child: Text('Camping'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => arrivee = val);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Date / heure ---
            Text(dtText),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: const Text('Choisir date & heure'),
            ),
            const SizedBox(height: 16),

            // --- Nb places ---
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
