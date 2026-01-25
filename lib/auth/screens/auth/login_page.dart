import 'package:flutter/material.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/widgets/primary_button.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:covoit_app/service/session_store.dart'; // currentLoginEmail

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  bool loading = false;
  String? error;

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _anonymousSignInWithEmail(String email) async {
    final normalizedEmail = email.toLowerCase();

    // mémoriser pour le reste de l'appli
    currentLoginEmail = normalizedEmail;

    // vider ancienne session
    await supabase.auth.signOut();

    // connexion anonyme
    final authResponse = await supabase.auth.signInAnonymously();
    final user = authResponse.user;

    if (user == null) {
      throw Exception('Impossible de créer une session utilisateur');
    }
  }

  Future<void> _onLogin() async {
    final rawEmail = emailController.text.trim();
    if (rawEmail.isEmpty) {
      setState(() {
        error = 'Merci de saisir un email.';
      });
      return;
    }
    final email = rawEmail.toLowerCase();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 1) chercher l'email dans app_users
      final appUsersRes =
          await supabase.from('app_users').select('email').eq('email', email);

      // 2) et dans guard_emails (surveillants)
      final guardsRes = await supabase
          .from('guard_emails')
          .select('email')
          .ilike('email', email);

      final existsInAppUsers = (appUsersRes as List).isNotEmpty;
      final existsInGuards = (guardsRes as List).isNotEmpty;

      if (!existsInAppUsers && !existsInGuards) {
        throw Exception(
          'Aucun compte trouvé avec cet email.\n'
          'Utilise "Créer un compte" ou demande à l’admin de t’ajouter comme surveillant.',
        );
      }

      // OK → connexion anonyme
      await _anonymousSignInWithEmail(email);
      // L’AuthGate détectera la session et redirigera vers HomePage.
    } catch (e) {
      setState(() {
        error = 'Connexion impossible : $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Se connecter',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Petit badge
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _primarySoft,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: _primary, width: 1.5),
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
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Rentre ton email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'On vérifie que ton compte existe, puis on te connecte.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            color: _text.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Champ email stylé (fonction identique)
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onLogin(),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'ex: prenom.nom@etu.univ.fr',
                            filled: true,
                            fillColor: _primarySoft.withOpacity(0.55),
                            prefixIcon: const Icon(Icons.mail_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: _primarySoft),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: _primarySoft),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: _green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Erreur en bulle (plus propre)
                        if (error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Bouton (on garde ton composant)
                        PrimaryButton(
                          text: 'Se connecter',
                          onPressed: _onLogin,
                        ),

                        const SizedBox(height: 10),

                        // Petit accent vert (DA)
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
