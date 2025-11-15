import 'package:flutter/material.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/widgets/primary_button.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

import 'package:covoit_app/service/session_store.dart'; // <-- important

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
    final rawEmail = emailController.text.trim();

    if (rawEmail.isEmpty) {
      setState(() {
        error = 'Merci de saisir un email.';
      });
      return;
    }

    // On normalise en minuscules
    final email = rawEmail.toLowerCase();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // On sauvegarde tout de suite l'email utilisé pour cette session
      currentLoginEmail = email;

      // On se déconnecte au cas où il reste une ancienne session
      await supabase.auth.signOut();

      // Connexion anonyme (pas de mot de passe, pas de confirmation)
      final authResponse = await supabase.auth.signInAnonymously();
      final user = authResponse.user;

      if (user == null) {
        throw Exception('Impossible de créer une session utilisateur');
      }

      // Si tu veux garder la table profiles pour d'autres cas, tu peux la remplir ici
      // mais ce n'est plus nécessaire pour savoir si l'utilisateur est surveillant.
      // await supabase.from('profiles').upsert({'id': user.id, 'email': email});

      // L'AuthGate va détecter la session et t'envoyer vers HomePage.
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
              keyboardType: TextInputType.emailAddress,
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
