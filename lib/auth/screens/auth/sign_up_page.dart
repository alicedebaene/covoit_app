import 'package:flutter/material.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/widgets/primary_button.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:covoit_app/service/session_store.dart'; // currentLoginEmail

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final telephoneController = TextEditingController();

  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    telephoneController.text = '+33 ';
  }

  @override
  void dispose() {
    emailController.dispose();
    prenomController.dispose();
    nomController.dispose();
    telephoneController.dispose();
    super.dispose();
  }

  Future<void> _anonymousSignInWithEmail(String email) async {
    final normalizedEmail = email.toLowerCase();

    currentLoginEmail = normalizedEmail;

    await supabase.auth.signOut();

    final authResponse = await supabase.auth.signInAnonymously();
    final user = authResponse.user;
    if (user == null) {
      throw Exception('Impossible de créer une session utilisateur');
    }
  }

  Future<void> _onSignUp() async {
    final rawEmail = emailController.text.trim();
    final prenom = prenomController.text.trim();
    final nom = nomController.text.trim();
    final telephone = telephoneController.text.trim();

    final telSansEspaces = telephone.replaceAll(' ', '');
    final telephoneValide = telSansEspaces.length > 3; // +33 + au moins 1 chiffre

    if (rawEmail.isEmpty ||
        prenom.isEmpty ||
        nom.isEmpty ||
        !telephoneValide) {
      setState(() {
        error =
            'Merci de remplir email, prénom, nom et téléphone (+33 …) pour créer un compte.';
      });
      return;
    }

    final email = rawEmail.toLowerCase();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await supabase.from('app_users').insert({
        'email': email,
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
      });

      await _anonymousSignInWithEmail(email);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('duplicate key value')) {
        setState(() {
          error =
              'Un compte existe déjà avec cet email.\nUtilise plutôt "Se connecter".';
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
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
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
            const SizedBox(height: 8),
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: telephoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone (format +33 X XX XX XX XX)',
              ),
              onChanged: (value) {
                if (!value.startsWith('+33 ')) {
                  telephoneController.text = '+33 ';
                  telephoneController.selection = TextSelection.fromPosition(
                    TextPosition(offset: telephoneController.text.length),
                  );
                }
              },
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
              text: 'Créer un compte',
              onPressed: _onSignUp,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun mot de passe, aucune confirmation email.\n'
              'Tes infos seront visibles par conducteur/passager lors des réservations.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
