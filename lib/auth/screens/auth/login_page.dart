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

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _anonymousSignInWithEmail(String email) async {
    final normalizedEmail = email.toLowerCase();

    // mémoriser pour la Home (surveillant ou non)
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
      final appUsersRes = await supabase
          .from('app_users')
          .select('email')
          .eq('email', email);

      // 2) et dans guard_emails (surveillants)
      final guardsRes = await supabase
          .from('guard_emails')
          .select('email')
          .ilike('email', email); // insensible à la casse

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

  Future<void> _onSignUp() async {
    final rawEmail = emailController.text.trim();
    if (rawEmail.isEmpty) {
      setState(() {
        error = 'Merci de saisir un email pour créer un compte.';
      });
      return;
    }
    final email = rawEmail.toLowerCase();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 1) ajouter dans app_users
      await supabase.from('app_users').insert({
        'email': email,
      });

      // 2) connexion anonyme
      await _anonymousSignInWithEmail(email);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('duplicate key value')) {
        setState(() {
          error =
              'Un compte existe déjà avec cet email.\nUtilise "Se connecter".';
        });
      } else if (msg.contains('row-level security')) {
        setState(() {
          error =
              'Erreur de sécurité Supabase (RLS) sur app_users.\nVérifie bien la policy "app_users_all".';
        });
      } else {
        setState(() {
          error = 'Erreur création compte : $e';
        });
      }
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
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            if (error != null) ...[
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],

            // 🔵 Bouton SE CONNECTER → _onLogin
            PrimaryButton(
              text: 'Se connecter',
              onPressed: _onLogin,
            ),

            const SizedBox(height: 12),

            // 🟢 Bouton CRÉER UN COMPTE → _onSignUp
            PrimaryButton(
              text: 'Créer un compte',
              onPressed: _onSignUp,
            ),

            const SizedBox(height: 16),
            const Text(
              'Aucun mot de passe, aucune confirmation email.\n'
              'Ton email sert uniquement à te reconnaître et à savoir si tu es surveillant (table guard_emails) ou non.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
