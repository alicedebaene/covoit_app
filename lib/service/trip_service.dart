import 'package:uuid/uuid.dart';

import '../models/trip.dart';
import 'parking_service.dart';
import 'supabase_client.dart';
import 'package:covoit_app/service/session_store.dart'; // pour currentLoginEmail

class TripService {
  final _uuid = const Uuid();

  /// Création d'un trajet (conducteur)
  Future<Trip> createTrip({
    required DateTime heureDepart,
    required int nbPlaces,
    required String depart,   // <-- nouveau paramètre
    required String arrivee,  // <-- nouveau paramètre
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // On prend le premier parking (Elispace)
    final parking = await parkingService.getFirstParking();

    final qrToken = _uuid.v4();

    // Infos conducteur depuis app_users via l'email
    String? email = currentLoginEmail?.toLowerCase();
    String? prenom;
    String? nom;
    String? telephone;

    if (email != null && email.isNotEmpty) {
      final userInfo = await supabase
          .from('app_users')
          .select('email, prenom, nom, telephone')
          .eq('email', email)
          .maybeSingle();

      if (userInfo != null) {
        email = (userInfo['email'] as String?) ?? email;
        prenom = userInfo['prenom'] as String?;
        nom = userInfo['nom'] as String?;
        telephone = userInfo['telephone'] as String?;
      }
    }

    final response = await supabase.from('trajets').insert({
      'conducteur_id': user.id, // on garde pour l'historique
      'parking_id': parking.id,
      'heure_depart': heureDepart.toUtc().toIso8601String(),
      'statut': 'reserve',
      'qr_token': qrToken,
      'nb_places': nbPlaces,
      'driver_email': email,
      'driver_prenom': prenom,
      'driver_nom': nom,
      'driver_telephone': telephone,

      // 🔽 NOUVEAU : enregistrement du sens du trajet
      'depart': depart,
      'arrivee': arrivee,
    }).select().single();

    return Trip.fromMap(response as Map<String, dynamic>);
  }

  /// Tous les trajets créés par l'utilisateur actuel (via email)
  Future<List<Trip>> getMyTrips() async {
    final email = currentLoginEmail?.toLowerCase();
    if (email == null || email.isEmpty) {
      throw Exception('Email utilisateur inconnu (reconnecte-toi).');
    }

    final response = await supabase
        .from('trajets')
        .select()
        .eq('driver_email', email)
        .order('heure_depart', ascending: false);

    final list = (response as List)
        .map((e) => Trip.fromMap(e as Map<String, dynamic>))
        .toList();

    return list;
  }

  /// Scan QR pour surveillant
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
