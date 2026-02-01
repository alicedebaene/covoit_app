import 'package:covoit_app/models/parking.dart';
import 'package:covoit_app/service/parking_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class ParkingStatusPage extends StatefulWidget {
  const ParkingStatusPage({super.key});

  @override
  State<ParkingStatusPage> createState() => _ParkingStatusPageState();
}

class _ParkingStatusPageState extends State<ParkingStatusPage> {
  bool loading = true;
  Parking? parking;
  String? error;

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final p = await parkingService.getFirstParking();
      setState(() {
        parking = p;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
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

  Widget _chip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _primarySoft.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _primarySoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _text.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _text.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    // Cas erreur / pas de parking
    if (parking == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'État du parking',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),
          iconTheme: const IconThemeData(color: _text),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Text(
                error ?? 'Erreur de chargement',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final p = parking!;
    final int total = p.placesTotales;
    final int dispo = p.placesDisponibles;

    final double ratio = total <= 0 ? 0 : (dispo / total).clamp(0.0, 1.0);

    final Color statusColor = ratio >= 0.5
        ? _green
        : (ratio >= 0.2 ? _primary : Colors.red);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'État du parking',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: _text,
          ),
        ),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
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
                            border: Border.all(color: _primary, width: 1.5),
                          ),
                          child: const Text(
                            'PARKING',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: _text,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.local_parking,
                            color: statusColor.withOpacity(0.9)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tire vers le bas pour rafraîchir.',
                      style: TextStyle(
                        color: _text.withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                          icon: Icons.event_available,
                          text: '$dispo disponibles',
                        ),
                        _chip(
                          icon: Icons.format_list_numbered,
                          text: '$total au total',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Stats + jauge
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Disponibilité',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 12,
                        backgroundColor: _primarySoft.withOpacity(0.55),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Places disponibles',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _text.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '$dispo / $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.25)),
                      ),
                      child: Text(
                        ratio >= 0.5
                            ? 'Parking plutôt OK ✅'
                            : (ratio >= 0.2
                                ? 'Parking qui se remplit ⚠️'
                                : 'Parking presque plein 🚫'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _text.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
