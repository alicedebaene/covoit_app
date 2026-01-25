import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/service/session_store.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final plateController = TextEditingController();
  final modelController = TextEditingController();
  final colorController = TextEditingController();

  String? permisUrl;
  bool loading = true;
  String? error;

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    plateController.dispose();
    modelController.dispose();
    colorController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentData() async {
    try {
      final email = currentLoginEmail;
      if (email == null) {
        setState(() {
          loading = false;
          error = 'Utilisateur non identifié.';
        });
        return;
      }

      final res = await supabase
          .from('app_users')
          .select('permis_url, car_plate, car_model, car_color')
          .eq('email', email);

      if (res is List && res.isNotEmpty) {
        final data = res.first as Map<String, dynamic>;
        permisUrl = data['permis_url'] as String?;
        plateController.text = (data['car_plate'] ?? '') as String;
        modelController.text = (data['car_model'] ?? '') as String;
        colorController.text = (data['car_color'] ?? '') as String;
      }
    } catch (e) {
      error = 'Erreur chargement profil : $e';
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _pickAndUploadPermis() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) return;

      final fileName =
          'permis_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      await supabase.storage.from('permis').uploadBinary(
            fileName,
            bytes,
          );

      final publicUrl = supabase.storage.from('permis').getPublicUrl(fileName);

      setState(() {
        permisUrl = publicUrl;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur envoi permis : $e';
      });
    }
  }

  Future<void> _save() async {
    final plate = plateController.text.trim();
    final model = modelController.text.trim();
    final color = colorController.text.trim();

    if (permisUrl == null || plate.isEmpty || model.isEmpty || color.isEmpty) {
      setState(() {
        error =
            'Merci de choisir une photo de permis et de remplir plaque, modèle et couleur.';
      });
      return;
    }

    final email = currentLoginEmail;
    if (email == null) {
      setState(() {
        error = 'Utilisateur non identifié.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await supabase.from('app_users').update({
        'permis_url': permisUrl,
        'car_plate': plate,
        'car_model': model,
        'car_color': color,
      }).eq('email', email);

      if (!mounted) return;
      Navigator.of(context).pop(); // retour à la page précédente
    } catch (e) {
      setState(() {
        error = 'Erreur enregistrement : $e';
      });
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _primarySoft, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Infos conducteur',
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

            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header card
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
                                    'PROFIL CONDUCTEUR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                      color: _text,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.badge_outlined,
                                  color: _green.withOpacity(0.9),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ajoute tes infos voiture pour pouvoir créer un trajet.',
                              style: TextStyle(
                                color: _text.withOpacity(0.75),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Permis card
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Photo du permis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _pickAndUploadPermis,
                              icon: const Icon(Icons.photo_camera),
                              label: Text(
                                permisUrl == null
                                    ? 'Ajouter une photo'
                                    : 'Modifier la photo du permis',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _text,
                                side: BorderSide(color: _primarySoft, width: 2),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                backgroundColor: _primarySoft.withOpacity(0.35),
                              ),
                            ),
                            if (permisUrl != null) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Photo enregistrée',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Fields card
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Infos voiture',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: plateController,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                label: 'Plaque d’immatriculation',
                                hint: 'AA-123-BB',
                                icon: Icons.confirmation_number_outlined,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: modelController,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                label: 'Modèle de la voiture',
                                hint: 'Clio 4, 208, Tesla Model 3…',
                                icon: Icons.directions_car_outlined,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: colorController,
                              textInputAction: TextInputAction.done,
                              decoration: _fieldDecoration(
                                label: 'Couleur de la voiture',
                                hint: 'Bleu foncé, gris, noir…',
                                icon: Icons.palette_outlined,
                              ),
                              onSubmitted: (_) => _save(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Error bubble
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
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Save button
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _primarySoft, width: 2),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Enregistrer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: _text,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // espace pour décor bas
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
