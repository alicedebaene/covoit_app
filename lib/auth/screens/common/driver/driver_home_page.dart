import 'package:flutter/material.dart';

import 'create_trip_page.dart';
import 'my_trips_page.dart';
import 'driver_profile_page.dart';

import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/service/session_store.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool checkingProfile = false;

  /// Vérifie si le conducteur a rempli : permis + plaque + modèle + couleur
  Future<bool> _isDriverProfileComplete() async {
    final email = currentLoginEmail;
    if (email == null) return false;

    final res = await supabase
        .from('app_users')
        .select('permis_url, car_plate, car_model, car_color')
        .eq('email', email);

    if (res is! List || res.isEmpty) return false;

    final data = res.first as Map<String, dynamic>;

    bool filled(String key) =>
        (data[key] != null && data[key].toString().trim().isNotEmpty);

    return filled('permis_url') &&
        filled('car_plate') &&
        filled('car_model') &&
        filled('car_color');
  }

  /// Action à lancer quand on veut créer un trajet
  Future<void> _goToCreateTrip() async {
    setState(() => checkingProfile = true);

    final complete = await _isDriverProfileComplete();

    if (!mounted) return;

    setState(() => checkingProfile = false);

    if (!complete) {
      // profil incomplet → on propose de compléter
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Infos conducteur manquantes'),
            content: const Text(
              'Avant de créer un trajet, tu dois ajouter :\n'
              '• la photo de ton permis\n'
              '• ta plaque d\'immatriculation\n'
              '• le modèle de ta voiture\n'
              '• la couleur de ta voiture',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Plus tard'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DriverProfilePage(),
                    ),
                  );
                },
                child: const Text('Compléter maintenant'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Profil OK → on va sur la page création de trajet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateTripPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace conducteur')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (checkingProfile) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Vérification de tes infos conducteur...'),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_car),
                label: const Text('Créer un trajet'),
                onPressed: checkingProfile ? null : _goToCreateTrip,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Mes trajets'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyTripsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.badge),
                label: const Text('Mes infos conducteur'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DriverProfilePage(),
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
