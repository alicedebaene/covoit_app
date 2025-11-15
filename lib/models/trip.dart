// lib/models/trip.dart

class Trip {
  final String id;
  final String conducteurId;
  final String parkingId;
  final DateTime heureDepart;
  final String statut;
  final String qrToken;
  final int nbPlaces;

  Trip({
    required this.id,
    required this.conducteurId,
    required this.parkingId,
    required this.heureDepart,
    required this.statut,
    required this.qrToken,
    required this.nbPlaces,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      conducteurId: map['conducteur_id'] as String,
      parkingId: map['parking_id'] as String,
      heureDepart: DateTime.parse(map['heure_depart'] as String),
      statut: map['statut'] as String,
      qrToken: map['qr_token'] as String,
      nbPlaces: map['nb_places'] as int? ?? 1,
    );
  }
}
