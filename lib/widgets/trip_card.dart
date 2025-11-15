import 'package:flutter/material.dart';
import '../models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${trip.heureDepart.day}/${trip.heureDepart.month} ${trip.heureDepart.hour.toString().padLeft(2, '0')}:${trip.heureDepart.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        title: Text('Trajet du $dateString'),
        subtitle: Text('Statut : ${trip.statut}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
