import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../service/trip_service.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  bool _processing = false;
  String? message;
  String? error;

  final MobileScannerController cameraController = MobileScannerController();

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue == null) return;

    setState(() {
      _processing = true;
      message = null;
      error = null;
    });

    try {
      final result = await tripService.scanQr(rawValue);
      final action = result['action'];
      final parking = result['parking'];

      setState(() {
        message = (action == 'entree' ? 'Entrée validée' : 'Sortie validée') +
            ' — Places restantes : ${parking.placesDisponibles}';
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _processing = false;
          });
        }
      });
    }
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statusBubble({
    required IconData icon,
    required String text,
    required Color color,
    Color? bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _text.withOpacity(0.85),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Scanner un QR",
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Zone caméra dans une carte
                  Expanded(
                    flex: 3,
                    child: _card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: cameraController,
                              onDetect: _onDetect,
                            ),

                            // Overlay viseur
                            IgnorePointer(
                              child: Center(
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: _processing ? _primary : _green,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 18,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Bandeau haut (info)
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.88),
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: _primarySoft, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _processing
                                          ? Icons.hourglass_top_rounded
                                          : Icons.qr_code_scanner,
                                      color: _text.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _processing
                                            ? 'Validation en cours…'
                                            : 'Place le QR dans le cadre',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: _text.withOpacity(0.85),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Panneau bas
                  Expanded(
                    flex: 1,
                    child: _card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Badge
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _primarySoft,
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: _primary, width: 1.5),
                              ),
                              child: const Text(
                                'SURVEILLANT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: _text,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (message != null)
                            _statusBubble(
                              icon: Icons.check_circle,
                              text: message!,
                              color: _green,
                            )
                          else if (error != null)
                            _statusBubble(
                              icon: Icons.error_outline,
                              text: error!,
                              color: Colors.red,
                            )
                          else
                            _statusBubble(
                              icon: Icons.info_outline,
                              text: _processing
                                  ? 'Merci de patienter…'
                                  : 'Scannez un QR code pour valider une entrée/sortie.',
                              color: _text.withOpacity(0.8),
                              bg: _primarySoft.withOpacity(0.35),
                            ),

                          const SizedBox(height: 10),

                          // Petit hint
                          Text(
                            'Astuce : évite les reflets, rapproche le QR.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _text.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // espace pour décor bas
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
