import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/supabase_client.dart';

class ReservationService {
  Future<void> reserveSeat(String trajetId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // Vérifier si déjà réservé
    final existing = await supabase
        .from('reservations')
        .select('id')
        .eq('trajet_id', trajetId)
        .eq('passager_id', user.id);

    if ((existing as List).isNotEmpty) {
      throw Exception('Tu as déjà une réservation sur ce trajet');
    }

    // Compter les réservations actuelles
    final res = await supabase
        .from('reservations')
        .select('id')
        .eq('trajet_id', trajetId);
    final nbReservations = (res as List).length;

    // Récupérer le trajet pour connaître nb_places
    final tripMap = await supabase
        .from('trajets')
        .select()
        .eq('id', trajetId)
        .single();

    final trip = Trip.fromMap(tripMap as Map<String, dynamic>);

    if (nbReservations >= trip.nbPlaces) {
      throw Exception('Plus de places disponibles sur ce trajet');
    }

    // Insérer la réservation
    await supabase.from('reservations').insert({
      'trajet_id': trajetId,
      'passager_id': user.id,
    });
  }

  Future<List<Trip>> getAvailableTrips() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final response = await supabase
        .from('trajets')
        .select()
        .gt('heure_depart', nowIso)
        .eq('statut', 'reserve');

    final list = (response as List)
        .map((e) => Trip.fromMap(e as Map<String, dynamic>))
        .toList();

    return list;
  }

  Future<List<Trip>> getMyReservations() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final res = await supabase
        .from('reservations')
        .select('trajets(*)')
        .eq('passager_id', user.id);

    final list = (res as List)
        .map((e) => Trip.fromMap(e['trajets'] as Map<String, dynamic>))
        .toList();

    return list;
  }
}

final reservationService = ReservationService();
