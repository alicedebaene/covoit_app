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

      final publicUrl =
          supabase.storage.from('permis').getPublicUrl(fileName);

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

    if (permisUrl == null ||
        plate.isEmpty ||
        model.isEmpty ||
        color.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Infos conducteur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Permis
            Text(
              'Photo du permis',
              style: Theme.of(context).textTheme.titleMedium,
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
            ),
            if (permisUrl != null) ...[
              const SizedBox(height: 8),
              Text(
                'Photo enregistrée ✅',
                style: TextStyle(color: Colors.green[700]),
              ),
            ],
            const SizedBox(height: 24),

            // Plaque
            TextField(
              controller: plateController,
              decoration: const InputDecoration(
                labelText: 'Plaque d’immatriculation',
                hintText: 'AA-123-BB',
              ),
            ),
            const SizedBox(height: 12),

            // Modèle
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Modèle de la voiture',
                hintText: 'Clio 4, 208, Tesla Model 3...',
              ),
            ),
            const SizedBox(height: 12),

            // Couleur
            TextField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: 'Couleur de la voiture',
                hintText: 'Bleu foncé, gris, noir...',
              ),
            ),
            const SizedBox(height: 20),

            if (error != null) ...[
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
            ],

            ElevatedButton(
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
