import 'package:covoit_app/guard/guard_trips_page.dart';
import 'package:covoit_app/guard/parking_status_page.dart';
import 'package:flutter/material.dart';
import 'scan_qr_page.dart';

class GuardHomePage extends StatelessWidget {
  const GuardHomePage({super.key});

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? accent,
  }) {
    final Color a = accent ?? _green;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _primarySoft.withOpacity(0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _primarySoft, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: a.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: a.withOpacity(0.35)),
              ),
              child: Icon(icon, color: a),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _text.withOpacity(0.72),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: _text.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _primarySoft, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Surveillant parking',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: _text,
          ),
        ),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Décor voitures bas (si l’asset existe)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.95,
                  child: Image.asset(
                    'assets/images/cars_border.png',
                    fit: BoxFit.cover,
                    height: 70,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 70),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primarySoft,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Text(
                                    'SURVEILLANT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                      color: _text,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.shield_outlined,
                                  color: _green.withOpacity(0.9),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Contrôle parking Ovalies 🏉',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Scanne les QR des conducteurs et consulte l’état du parking.',
                              style: TextStyle(
                                color: _text.withOpacity(0.75),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Actions
                      _actionCard(
                        icon: Icons.qr_code_scanner,
                        title: 'Scanner un QR',
                        subtitle:
                            'Valider un conducteur à l’entrée ou à la sortie.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ScanQrPage(),
                            ),
                          );
                        },
                        accent: _green,
                      ),
                      const SizedBox(height: 10),

                      _actionCard(
                        icon: Icons.local_parking_outlined,
                        title: 'Voir état du parking',
                        subtitle:
                            'Places totales et disponibles en temps réel.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ParkingStatusPage(),
                            ),
                          );
                        },
                        accent: _primary,
                      ),
                      const SizedBox(height: 10),

                      _actionCard(
                        icon: Icons.trip_origin_outlined,
                        title: 'Voir trajets',
                        subtitle:
                            'Liste des trajets et conducteurs attendus.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GuardTripsPage(),
                            ),
                          );
                        },
                        accent: _text,
                      ),

                      const Spacer(),

                      // Petit accent DA
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 78,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      // espace pour décor bas
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
