import 'package:flutter/material.dart';
import 'create_trip_page.dart';
import 'my_trips_page.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace conducteur')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateTripPage(),
                    ),
                  );
                },
                child: const Text('Créer un trajet'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyTripsPage(),
                    ),
                  );
                },
                child: const Text('Mes trajets'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
