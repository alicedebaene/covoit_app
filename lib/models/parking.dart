class Parking {
  final String id;
  final String name;
  final int placesTotales;
  final int placesDisponibles;

  Parking({
    required this.id,
    required this.name,
    required this.placesTotales,
    required this.placesDisponibles,
  });

  factory Parking.fromMap(Map<String, dynamic> map) {
    return Parking(
      id: map['id'] as String,
      name: map['name'] as String,
      placesTotales: map['places_totales'] as int,
      placesDisponibles: map['places_disponibles'] as int,
    );
  }
}
