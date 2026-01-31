import 'package:flutter/material.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/widgets/primary_button.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:covoit_app/service/session_store.dart'; // currentLoginEmail
import 'package:covoit_app/widgets/animated_bottom_cars.dart';

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

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  // ✅ Bleu pastel pour les boutons
  static const Color _bluePastel = Color(0xFF8ECDF4);

  // ✅ Hauteur du décor en bas
  static const double _bottomImageHeight = 80;

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

    if (rawEmail.isEmpty || prenom.isEmpty || nom.isEmpty || !telephoneValide) {
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
      // L’AuthGate détectera la session et redirigera vers HomePage.
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

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _primarySoft.withOpacity(0.55),
      prefixIcon: icon == null ? null : Icon(icon),
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
        borderSide: const BorderSide(color: _green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Créer un compte',
          style: TextStyle(fontWeight: FontWeight.w900, color: _text),
        ),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ contenu scrollable + marge pour l’animation en bas
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                _bottomImageHeight + 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                              border: Border.all(
                                color: _bluePastel,
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
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tes infos pour covoiturer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pas de mot de passe : on te reconnaît via ton email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            color: _text.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'Email',
                            hint: 'ex: prenom.nom@etu.univ.fr',
                            icon: Icons.mail_outline,
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: prenomController,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'Prénom',
                            hint: 'ex: Léa',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: nomController,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'Nom',
                            hint: 'ex: Martin',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: telephoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          decoration: _fieldDecoration(
                            label: 'Téléphone',
                            hint: 'format +33 X XX XX XX XX',
                            icon: Icons.phone_outlined,
                          ).copyWith(
                            helperText: 'Le champ doit commencer par “+33 ”.',
                          ),
                          onChanged: (value) {
                            if (!value.startsWith('+33 ')) {
                              telephoneController.text = '+33 ';
                              telephoneController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: telephoneController.text.length),
                              );
                            }
                          },
                          onSubmitted: (_) => _onSignUp(),
                        ),

                        const SizedBox(height: 12),

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
                                const Icon(Icons.error_outline, color: Colors.red),
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

                        Theme(
                          data: Theme.of(context).copyWith(
                            elevatedButtonTheme: ElevatedButtonThemeData(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _bluePastel,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          child: PrimaryButton(
                            text: 'Créer un compte',
                            onPressed: _onSignUp,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primarySoft.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _primarySoft),
                          ),
                          child: Text(
                            'Aucun mot de passe, aucune confirmation email.\n'
                            'Tes infos seront visibles par conducteur/passager lors des réservations.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _text.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

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

            // ✅ voitures animées en bas
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
