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
    final theme = Theme.of(context);

    final dateString =
        '${trip.heureDepart.day.toString().padLeft(2, '0')}/'
        '${trip.heureDepart.month.toString().padLeft(2, '0')} '
        '${trip.heureDepart.hour.toString().padLeft(2, '0')}:'
        '${trip.heureDepart.minute.toString().padLeft(2, '0')}';

    final depart = trip.depart;
    final arrivee = trip.arrivee;

    final remaining = trip.remainingPlaces;
    final total = trip.nbPlaces;

    final statut = trip.statut;

    Color statusColor() {
      switch (statut.toLowerCase()) {
        case 'termine':
          return Colors.grey;
        case 'annule':
          return Colors.red;
        case 'en_cours':
        case 'actif':
          return const Color(0xFF1DCA68); // vert Ovalink
        default:
          return Colors.orange;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Ligne 1 : Date + chevron ───
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Trajet du $dateString',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black54,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ─── Ligne 2 : Trajet ───
              if (depart.isNotEmpty && arrivee.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$depart → $arrivee',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // ─── Ligne 3 : Places + statut ───
              Row(
                children: [
                  // Places
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color:
                            theme.colorScheme.secondary.withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      '🧍 $remaining / $total places',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor().withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: statusColor().withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      statut,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: statusColor(),
                      ),
                    ),
                  ),
                ],
              ),

              // ─── Ligne 4 : Conducteur (si présent) ───
              if ((trip.driverPrenom ?? '').isNotEmpty ||
                  (trip.driverNom ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Conducteur : '
                        '${(trip.driverPrenom ?? '').trim()} '
                        '${(trip.driverNom ?? '').trim()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
