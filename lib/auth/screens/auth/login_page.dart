import 'package:flutter/material.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/widgets/primary_button.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

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

  Future<void> _onContinue() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // 1. Connexion anonyme → pas de mot de passe, pas de confirmation email
      final authResponse = await supabase.auth.signInAnonymously();
      final user = authResponse.user;

      if (user == null) {
        throw Exception('Impossible de créer une session utilisateur');
      }

      // 2. Enregistrer l'email saisi dans la table profiles (pour les rôles, guards, etc.)
      final email = emailController.text.trim();
      if (email.isNotEmpty) {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'email': email,
        });
      }

      // L'AuthGate dans main.dart va détecter la session et rediriger vers HomePage.
    } catch (e) {
      setState(() {
        error = e.toString();
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
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (surveillant ou étudiant)',
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
            PrimaryButton(
              text: 'Continuer',
              onPressed: _onContinue,
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucun mot de passe, aucune confirmation email.\n'
              'Ton email sert uniquement à savoir si tu es surveillant ou non.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
