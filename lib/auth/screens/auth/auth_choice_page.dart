import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'package:covoit_app/widgets/animated_bottom_cars.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  static const Color _bg = Color(0xFFFCFDC9);
  static const Color _primarySoft = Color(0xFFFDF6C2);
  static const Color _green = Color(0xFF1DCA68);
  static const Color _text = Color(0xFF1E1E1E);

  static const Color _bluePastel = Color(0xFF8ECDF4);
  static const Color _bluePastelSoft = Color(0xFFEAF6FD);

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
          style: TextStyle(fontWeight: FontWeight.w900, color: _text),
        ),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: SafeArea(
        child: Stack(
          children: [
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
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _primarySoft,
                            borderRadius: BorderRadius.circular(999),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _button(
                          text: 'Se connecter',
                          bg: _bluePastel,
                          fg: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _button(
                          text: 'Créer un compte',
                          bg: _bluePastelSoft,
                          fg: _text,
                          border: _bluePastel,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
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
            const AnimatedBottomCars(
              height: _bottomImageHeight,
              opacity: 0.9,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _button({
    required String text,
    required Color bg,
    required Color fg,
    Color? border,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border != null
                ? BorderSide(color: border, width: 1.6)
                : BorderSide.none,
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
