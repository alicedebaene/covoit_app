import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widgets/loading_indicator.dart';
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
        message = (action == 'entree'
                ? 'Entrée validée'
                : 'Sortie validée') +
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un QR")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),

          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (message != null)
                  Text(message!,
                      style:
                          const TextStyle(color: Colors.green, fontSize: 16)),
                if (error != null)
                  Text(error!,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 16)),
                if (!_processing)
                  const Text("Scannez un QR code",
                      style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
