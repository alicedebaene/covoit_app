import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/reservation_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableTripsPage extends StatefulWidget {
  const AvailableTripsPage({super.key});

  @override
  State<AvailableTripsPage> createState() => _AvailableTripsPageState();
}

class _AvailableTripsPageState extends State<AvailableTripsPage> {
  bool loading = true;
  String? error;
  List<Trip> trips = [];

  // === Palette (Charte Ovalink) ===
  static const Color _bg = Color(0xFFFCFDC9); // beige fond
  static const Color _primary = Color(0xFFFFD65F); // jaune principal
  static const Color _primarySoft = Color(0xFFFDF6C2); // jaune clair
  static const Color _green = Color(0xFF1DCA68); // vert
  static const Color _text = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final list = await reservationService.getAvailableTrips();
      setState(() {
        trips = list;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // -------- GPS helpers --------

  String? _gpsUrlFor(String? place) {
    if (place == null) return null;
    switch (place) {
      case 'Parking CMA':
        return 'https://maps.app.goo.gl/fWSvYDKn4Xv2xkU67?g_st=ipc';
      case 'Campus':
        return 'https://maps.app.goo.gl/nKrGxmG7KHbmvewy5?g_st=ipc';
      case 'Camping':
        return 'https://maps.app.goo.gl/UCYuXx5zeEuNR2Rq6?g_st=ipc';
      default:
        return null;
    }
  }

  Future<void> _openGps(String? place) async {
    final url = _gpsUrlFor(place);
    if (url == null) return;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir la carte.')),
      );
    }
  }

  Widget _gpsLink(String label, String? place) {
    final url = _gpsUrlFor(place);
    if (url == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _openGps(place),
        icon: const Icon(Icons.pin_drop),
        label: Text('$label (ouvrir dans Maps)'),
        style: TextButton.styleFrom(
          foregroundColor: _green,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // -------- Réservation --------

  Future<void> _reserve(Trip trip) async {
    try {
      await reservationService.reserveSeat(trip.id);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réservation : $e')),
      );
    }
  }

  // -------- UI helpers --------

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _chip({
    required IconData icon,
    required String text,
    Color? fg,
    Color? bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg ?? _primarySoft.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _primarySoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: (fg ?? _text).withOpacity(0.85)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: (fg ?? _text).withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Color _availabilityColor(int remaining, int total) {
    if (total <= 0) return _primary;
    final ratio = remaining / total;
    if (ratio >= 0.5) return _green;
    if (ratio >= 0.2) return _primary;
    return Colors.red;
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
          'Trajets disponibles',
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

            RefreshIndicator(
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
                                'PASSAGER',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: _text,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.directions_car_filled,
                                color: _green.withOpacity(0.9)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Trajets trouvés : ${trips.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choisis un trajet et réserve une place.',
                          style: TextStyle(
                            color: _text.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(icon: Icons.refresh, text: 'Tire pour rafraîchir'),
                            _chip(icon: Icons.map_outlined, text: 'GPS dispo'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withOpacity(0.25)),
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

                  if (trips.isEmpty && error == null) ...[
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aucun trajet disponible',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Reviens un peu plus tard ou rafraîchis la liste.',
                            style: TextStyle(
                              color: _text.withOpacity(0.75),
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],

                  ...trips.map(_buildTripCard),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final date = DateFormat('dd/MM à HH:mm').format(trip.heureDepart);

    final depart = trip.depart;
    final arrivee = trip.arrivee;
    final remaining = trip.remainingPlaces;
    final total = trip.nbPlaces;

    final availabilityColor = _availabilityColor(remaining, total);

    final driverName =
        ('${trip.driverPrenom ?? ''} ${trip.driverNom ?? ''}').trim();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Trajet du $date',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _text,
                  ),
                ),
              ),
              _chip(
                icon: Icons.event_seat_outlined,
                text: '$remaining / $total',
                fg: availabilityColor,
                bg: availabilityColor.withOpacity(0.12),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (depart.isNotEmpty && arrivee.isNotEmpty) ...[
            Text(
              'Trajet : $depart → $arrivee',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _text,
              ),
            ),
            const SizedBox(height: 4),
            _gpsLink('Départ ($depart)', depart),
            _gpsLink('Arrivée ($arrivee)', arrivee),
            const SizedBox(height: 6),
          ],

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (driverName.isNotEmpty)
                _chip(icon: Icons.person_outline, text: driverName),
              if (trip.driverTelephone != null && trip.driverTelephone!.isNotEmpty)
                _chip(icon: Icons.phone_outlined, text: trip.driverTelephone!),
              if (trip.driverEmail != null && trip.driverEmail!.isNotEmpty)
                _chip(icon: Icons.mail_outline, text: trip.driverEmail!),
              if (driverName.isEmpty &&
                  (trip.driverTelephone == null || trip.driverTelephone!.isEmpty) &&
                  (trip.driverEmail == null || trip.driverEmail!.isEmpty))
                Text(
                  'Infos conducteur indisponibles.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: _text.withOpacity(0.7),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: remaining <= 0 ? null : () => _reserve(trip),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(remaining <= 0 ? 'Complet' : 'Réserver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: _text,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
