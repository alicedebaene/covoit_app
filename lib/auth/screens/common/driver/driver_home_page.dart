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

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

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

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? accent,
    bool outlined = false,
  }) {
    final Color a = accent ?? _green;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : _primarySoft.withOpacity(0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: outlined ? _primarySoft : _primarySoft,
            width: 2,
          ),
          boxShadow: outlined
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Espace conducteur',
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
                      // Header card
                      Container(
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
                        child: Row(
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
                                'CONDUCTEUR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: _text,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.directions_car_filled,
                              color: _green.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Etat de vérification (si checkingProfile)
                      if (checkingProfile) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: _primarySoft, width: 2),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Vérification de tes infos conducteur...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _text.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Actions
                      _actionCard(
                        icon: Icons.add_road_outlined,
                        title: 'Créer un trajet',
                        subtitle:
                            'Propose un covoiturage vers les Ovalies (QR à l’aller).',
                        onTap: checkingProfile ? null : _goToCreateTrip,
                        accent: _green,
                      ),
                      const SizedBox(height: 10),
                      _actionCard(
                        icon: Icons.list_alt_outlined,
                        title: 'Mes trajets',
                        subtitle: 'Voir tes trajets, places restantes et QR.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MyTripsPage(),
                            ),
                          );
                        },
                        accent: _text,
                        outlined: true,
                      ),
                      const SizedBox(height: 10),
                      _actionCard(
                        icon: Icons.badge_outlined,
                        title: 'Mes infos conducteur',
                        subtitle:
                            'Permis, plaque, modèle et couleur de ta voiture.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DriverProfilePage(),
                            ),
                          );
                        },
                        accent: _primary,
                        outlined: true,
                      ),

                      const Spacer(),

                      // Petit accent DA en bas
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
