// lib/service/trip_service.dart
import 'package:uuid/uuid.dart';

import '../models/trip.dart';
import '../models/parking.dart';
import 'parking_service.dart';
import 'supabase_client.dart';

class TripService {
  final _uuid = const Uuid();

Future<Trip> createTrip(
  DateTime heureDepart,
  int nbPlaces,
) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // On prend le premier parking (Elispace)
    final parking = await parkingService.getFirstParking();

    final qrToken = _uuid.v4();

    final response = await supabase.from('trajets').insert({
      'conducteur_id': user.id,
      'parking_id': parking.id,
      'heure_depart': heureDepart.toUtc().toIso8601String(),
      'statut': 'reserve',
      'qr_token': qrToken,
      'nb_places': nbPlaces,
    }).select().single();

    return Trip.fromMap(response as Map<String, dynamic>);
  }

  Future<List<Trip>> getMyTrips() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final response = await supabase
        .from('trajets')
        .select()
        .eq('conducteur_id', user.id)
        .order('created_at', ascending: false);

    final list = (response as List)
        .map((e) => Trip.fromMap(e as Map<String, dynamic>))
        .toList();

    return list;
  }

  Future<Map<String, dynamic>> scanQr(String token) async {
    final response = await supabase
        .from('trajets')
        .select()
        .eq('qr_token', token)
        .single();

    final trip = Trip.fromMap(response as Map<String, dynamic>);

    final parking = await parkingService.getParkingById(trip.parkingId);

    if (trip.statut == 'reserve') {
      // ENTRÉE
      if (parking.placesDisponibles <= 0) {
        throw Exception('Parking complet, impossible d\'entrer');
      }

      await supabase
          .from('trajets')
          .update({'statut': 'au_parking'}).eq('id', trip.id);

      await supabase.from('parking').update({
        'places_disponibles': parking.placesDisponibles - 1,
      }).eq('id', parking.id);

      await supabase.from('scans').insert({
        'trajet_id': trip.id,
        'type': 'entree',
      });

      final updatedParking = await parkingService.getParkingById(parking.id);

      return {
        'action': 'entree',
        'parking': updatedParking,
      };
    } else if (trip.statut == 'au_parking') {
      // SORTIE
      await supabase
          .from('trajets')
          .update({'statut': 'termine'}).eq('id', trip.id);

      await supabase.from('parking').update({
        'places_disponibles': parking.placesDisponibles + 1,
      }).eq('id', parking.id);

      await supabase.from('scans').insert({
        'trajet_id': trip.id,
        'type': 'sortie',
      });

      final updatedParking = await parkingService.getParkingById(parking.id);

      return {
        'action': 'sortie',
        'parking': updatedParking,
      };
    } else {
      throw Exception('Trajet déjà terminé ou annulé');
    }
  }
}

final tripService = TripService();
