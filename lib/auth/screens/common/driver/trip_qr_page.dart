import 'package:covoit_app/models/trip.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TripQrPage extends StatelessWidget {
  final Trip trip;

  const TripQrPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${trip.heureDepart.day}/${trip.heureDepart.month} '
        '${trip.heureDepart.hour.toString().padLeft(2, '0')}:'
        '${trip.heureDepart.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('QR code du trajet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Trajet du $dateString'),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: QrImageView(
                  data: trip.qrToken,
                  size: 250,
                ),
              ),
            ),
            const Text(
              'À présenter au surveillant du parking à l’entrée ET à la sortie',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
