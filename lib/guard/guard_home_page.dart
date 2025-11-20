import 'package:covoit_app/guard/guard_trips_page.dart';
import 'package:covoit_app/guard/parking_status_page.dart';
import 'package:flutter/material.dart';
import 'scan_qr_page.dart';

class GuardHomePage extends StatelessWidget {
  const GuardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surveillant parking')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scanner un QR'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScanQrPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_parking),
                label: const Text('Voir état du parking'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                     builder: (_) => const ParkingStatusPage(),

                    ),
                  );
                },
              ),
            ),
                        const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.trip_origin),
                label: const Text('Voir trajets'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardTripsPage(),
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
