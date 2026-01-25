import 'package:covoit_app/guard/guard_home_page.dart';
import 'package:covoit_app/passenger/passenger_home_page.dart';
import 'package:flutter/material.dart';
import 'package:covoit_app/auth/screens/common/driver/parking_status.dart';
import 'package:covoit_app/service/auth_services/auth_service.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/service/session_store.dart';

import 'driver/driver_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  bool isGuard = false;
  String? emailUsed;

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _checkGuard();
  }

  Future<void> _checkGuard() async {
    try {
      final email = currentLoginEmail?.toLowerCase();
      if (email == null || email.isEmpty) {
        setState(() {
          loading = false;
          isGuard = false;
          emailUsed = email;
        });
        return;
      }

      // On vérifie directement dans guard_emails
      final res = await supabase
          .from('guard_emails')
          .select('email')
          .eq('email', email);

      final guard = (res as List).isNotEmpty;

      if (!mounted) return;
      setState(() {
        isGuard = guard;
        emailUsed = email;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        isGuard = false;
      });
    }
  }

  void _logout() {
    authService.signOut();
    currentLoginEmail = null;
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

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _primarySoft.withOpacity(0.75),
        border: Border(top: BorderSide(color: _primarySoft)),
      ),
      child: const Text(
        'Ovalies 2026 - Covoiturage officiel 🏉',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🛡️ Surveillant
    if (isGuard) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Espace surveillant',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),
          iconTheme: const IconThemeData(color: _text),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Se déconnecter',
            ),
          ],
        ),
        bottomNavigationBar: _footer(),
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
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                'Covoiturage Ovalies 🏉',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: _text,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Du campus à Elispace, merci pour votre aide 👮‍♂️',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _text.withOpacity(0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (emailUsed != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _primarySoft.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _primarySoft),
                                  ),
                                  child: Text(
                                    'Connecté en tant que surveillant :\n$emailUsed',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _text,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        _actionCard(
                          icon: Icons.local_police_outlined,
                          title: 'Surveillant parking',
                          subtitle: 'Scanner / valider les QR à l’entrée et sortie.',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GuardHomePage(),
                              ),
                            );
                          },
                          accent: _green,
                        ),

                        const Spacer(),

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

    // 🚗 Utilisateur normal : Conducteur + Passager + Parking
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ovalink',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: _text,
          ),
        ),
        iconTheme: const IconThemeData(color: _text),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      bottomNavigationBar: _footer(),
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
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                    'OVALINK 🏉',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                      color: _text,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.favorite,
                                  color: _green.withOpacity(0.9),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Du campus aux Ovalies, ensemble 💛',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _text,
                              ),
                            ),
                            if (emailUsed != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Connecté avec : $emailUsed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _text.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _actionCard(
                        icon: Icons.directions_car_filled,
                        title: 'Conducteur',
                        subtitle: 'Créer un trajet, gérer tes trajets et ton QR.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DriverHomePage(),
                            ),
                          );
                        },
                        accent: _green,
                      ),
                      const SizedBox(height: 10),

                      _actionCard(
                        icon: Icons.local_parking_outlined,
                        title: 'Voir état du parking',
                        subtitle: 'Places totales et disponibles en direct.',
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
                        icon: Icons.person_outline,
                        title: 'Passager',
                        subtitle: 'Réserver un trajet et suivre tes réservations.',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PassengerHomePage(),
                            ),
                          );
                        },
                        accent: _text,
                      ),

                      const Spacer(),

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
