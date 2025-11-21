class Trip {
  final String id;
  final String parkingId;
  final String? conducteurId;

  final DateTime heureDepart;
  final String statut;

  final int nbPlaces;
  final int? placesRestantes; // peut être null si non calculé en SQL

  // Infos conducteur
  final String? driverEmail;
  final String? driverPrenom;
  final String? driverNom;
  final String? driverTelephone;

  // Trajet (Campus / Camping / Parking CMA)
  final String depart;
  final String arrivee;

  // 🔥 QR code
  final String qrToken;

  Trip({
    required this.id,
    required this.parkingId,
    this.conducteurId,
    required this.heureDepart,
    required this.statut,
    required this.nbPlaces,
    this.placesRestantes,
    this.driverEmail,
    this.driverPrenom,
    this.driverNom,
    this.driverTelephone,
    required this.depart,
    required this.arrivee,
    required this.qrToken,
  });

  /// Nombre de places restantes avec valeur de secours
  int get remainingPlaces => placesRestantes ?? nbPlaces;

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: (map['id'] ?? '') as String,
      parkingId: (map['parking_id'] ?? '') as String,
      conducteurId: map['conducteur_id'] as String?,
      heureDepart: DateTime.parse(map['heure_depart'] as String),
      statut: (map['statut'] ?? 'inconnu') as String,
      nbPlaces: (map['nb_places'] ?? 0) as int,
      placesRestantes: map['places_restantes'] as int?, // optionnel

      driverEmail: map['driver_email'] as String?,
      driverPrenom: map['driver_prenom'] as String?,
      driverNom: map['driver_nom'] as String?,
      driverTelephone: map['driver_telephone'] as String?,

      depart: (map['depart'] ?? '') as String,
      arrivee: (map['arrivee'] ?? '') as String,

      // 🔥 récupère la colonne `qr_token` de la table `trajets`
      qrToken: (map['qr_token'] ?? '') as String,
    );
  }
}
