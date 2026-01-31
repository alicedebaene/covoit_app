import 'package:flutter/material.dart';

import 'login_page.dart';
import 'sign_up_page.dart';

// ✅ widgets communs
import 'package:covoit_app/widgets/animated_bottom_cars.dart';
import 'package:covoit_app/widgets/ovalink_logo_badge.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  // === Palette (Charte Ovalink + bleu pastel) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  // Bleu pastel
  static const Color _bluePastel = Color(0xFF8ECDF4);
  static const Color _bluePastelSoft = Color(0xFFEAF6FD);

  // Hauteur du décor animé
  static const double _bottomImageHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Connexion',
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
            // =====================
            // CONTENU
            // =====================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                _bottomImageHeight + 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _primarySoft, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // =====================
                        // LOGO BIEN VISIBLE
                        // =====================
                        const OvalinkLogoBadge(
                          size: 160, // 🔥 plus grand = bien visible
                        ),

                        const SizedBox(height: 14),

                        // Badge texte
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _primarySoft,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _bluePastel,
                              width: 1.6,
                            ),
                          ),
                          child: const Text(
                            'OVALINK',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                              color: _text,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Bienvenue sur Ovalink',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Du campus aux Ovalies, ensemble !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            color: _text.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =====================
                        // BOUTONS
                        // =====================
                        _PastelButton(
                          text: 'Se connecter',
                          backgroundColor: _bluePastel,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        _PastelButton(
                          text: 'Créer un compte',
                          backgroundColor: _bluePastelSoft,
                          foregroundColor: _text,
                          borderColor: _bluePastel,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // Accent vert
                        Container(
                          width: 78,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =====================
            // FONDU AU-DESSUS DES VOITURES
            // =====================
            Positioned(
              left: 0,
              right: 0,
              bottom: _bottomImageHeight - 18,
              height: 24,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _bg,
                        _bg.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =====================
            // VOITURES ANIMÉES
            // =====================
            const AnimatedBottomCars(
              height: _bottomImageHeight,
              opacity: 0.90,
              secondsPerLoop: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _PastelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _PastelButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.6)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
