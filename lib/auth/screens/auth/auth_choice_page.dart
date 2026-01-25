import 'package:flutter/material.dart';
import 'package:covoit_app/widgets/primary_button.dart';

import 'login_page.dart';
import 'sign_up_page.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

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
            // --- Décor voitures bas (à activer quand l'asset est en place) ---
            // Place l'image dans: assets/images/cars_border.png
            // et déclare-la dans pubspec.yaml
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

            // --- Contenu ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: _primarySoft,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Petit badge "Ovalink"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
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
                            'OVALINK',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: _text,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Bienvenue sur Ovalink',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
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

                        const SizedBox(height: 20),

                        // Bouton Se connecter (logique inchangée)
                        PrimaryButton(
                          text: 'Se connecter',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Bouton Créer un compte (même widget pour ne pas toucher aux composants)
                        PrimaryButton(
                          text: 'Créer un compte',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // Petit accent vert (DA)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
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
          ],
        ),
      ),
    );
  }
}
