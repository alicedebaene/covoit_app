import 'package:flutter/material.dart';
import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/reservation_service.dart';
import 'package:covoit_app/widgets/loading_indicator.dart';

class TripPassengersPage extends StatefulWidget {
  final Trip trip;

  const TripPassengersPage({super.key, required this.trip});

  @override
  State<TripPassengersPage> createState() => _TripPassengersPageState();
}

class _TripPassengersPageState extends State<TripPassengersPage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> passengers = [];

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
      final list =
          await reservationService.getPassengersForTrip(widget.trip.id);
      setState(() {
        passengers = list;
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

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} à $h:$m';
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

  String _displayName(String prenom, String nom) {
    final full = ('$prenom $nom').trim();
    return full.isEmpty ? 'Passager' : full;
  }

  String _initials(String prenom, String nom) {
    final p = prenom.trim();
    final n = nom.trim();
    String i1 = p.isNotEmpty ? p.characters.first : '';
    String i2 = n.isNotEmpty ? n.characters.first : '';
    final out = (i1 + i2).toUpperCase().trim();
    return out.isEmpty ? 'P' : out;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: LoadingIndicator());
    }

    final dateString = _formatDateTime(widget.trip.heureDepart);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Passagers',
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
                                'TRAJET',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: _text,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.groups_outlined,
                                color: _green.withOpacity(0.9)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Passagers du trajet du $dateString',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(icon: Icons.refresh, text: 'Tire pour rafraîchir'),
                            _chip(
                              icon: Icons.people_alt_outlined,
                              text: '${passengers.length} passager(s)',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Erreur
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

                  // Empty state
                  if (passengers.isEmpty && error == null) ...[
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aucun passager pour le moment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Quand quelqu’un réserve, tu verras ses coordonnées ici.',
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

                  // Liste passagers
                  ...passengers.map((p) {
                    final prenom = (p['passenger_prenom'] ?? '') as String;
                    final nom = (p['passenger_nom'] ?? '') as String;
                    final tel = (p['passenger_telephone'] ?? '') as String;
                    final email = (p['passenger_email'] ?? '') as String;

                    final name = _displayName(prenom, nom);
                    final initials = _initials(prenom, nom);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _primarySoft, width: 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar initiales
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _primarySoft.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _primarySoft),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _text,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: _text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (tel.isNotEmpty || email.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (tel.isNotEmpty)
                                        _chip(icon: Icons.phone_outlined, text: tel),
                                      if (email.isNotEmpty)
                                        _chip(icon: Icons.mail_outline, text: email),
                                    ],
                                  ),
                                ] else ...[
                                  Text(
                                    'Aucune coordonnée enregistrée pour ce passager.',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: _text.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // espace pour le décor bas
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
