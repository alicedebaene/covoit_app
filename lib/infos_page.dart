import 'package:flutter/material.dart';

class InfosPage extends StatelessWidget {
  const InfosPage({super.key});

  // Palette pastel (cohérente avec Ovalink)
  static const Color _bgTop = Color(0xFFFCFDC9); // beige
  static const Color _bgBottom = Color(0xFFEAF6FD); // bleu très clair
  static const Color _text = Color(0xFF1E1E1E);
  static const Color _bluePastel = Color(0xFF8ECDF4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ✅ fond pastel stylé
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _bluePastel.withOpacity(0.45), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      const Text(
                        'Crédits',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ✅ Texte EXACT demandé
                      const Text(
                        'Par l\'édition des 31èmes\n'
                        'Ovalies\n\n'
                        'Conception :\n'
                        '• Jade Dupont\n'
                        '• Alice Debaene\n\n'
                        'Direction Artistique:\n'
                        '• Catinka Balland\n'
                        '• Camille Duhem\n'
                        '• Alice Lenormant\n\n'
                        'Développement:\n'
                        '• Alice Debaene\n\n'
                        'Remerciement :\n'
                        '• Joan Simonin\n'
                        '• Florentine Meunier\n'
                        '• Adrien Rouge',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: _text,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Bouton Fermer (comme sur la capture)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: _bluePastel,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          child: const Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
