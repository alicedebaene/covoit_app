// lib/service/reservation_service.dart
import 'package:covoit_app/models/trip.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/service/session_store.dart'; // currentLoginEmail

class ReservationService {
  /// Compat avec le code existant :
  /// - available_trips_page.dart appelle reserveTrip(trip)
  Future<void> reserveTrip(Trip trip) async {
    await reserveSeat(trip.id);
  }

  /// Réserver une place sur un trajet donné (par id de trajet)
  Future<void> reserveSeat(String trajetId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    // Email de la personne actuellement connectée
    final currentEmail = (currentLoginEmail ?? '').trim().toLowerCase();

    // 1) Récupérer le trajet
    final tripRow = await supabase
        .from('trajets')
        .select()
        .eq('id', trajetId)
        .single();

    final trip = Trip.fromMap(tripRow as Map<String, dynamic>);

    // 🚫 Interdire de réserver son propre trajet par email
    final driverEmail = (trip.driverEmail ?? '').toLowerCase();
    if (currentEmail.isNotEmpty &&
        driverEmail.isNotEmpty &&
        currentEmail == driverEmail) {
      throw Exception(
        'Tu es le conducteur de ce trajet, tu ne peux pas réserver une place dessus.',
      );
    }

    // 🚫 Interdiction aussi par id (si même session anonyme)
    if (trip.conducteurId == user.id) {
      throw Exception(
        'Tu es le conducteur de ce trajet, tu ne peux pas réserver une place dessus.',
      );
    }

    // 2) Empêcher double réservation
    // IMPORTANT : ne pas vérifier uniquement passager_id car l'id anonyme peut changer
    // si la personne se reconnecte → elle pourrait réserver 2 fois avec le même email.
    dynamic existingRes;
    if (currentEmail.isNotEmpty) {
      existingRes = await supabase
          .from('reservations')
          .select('id')
          .eq('trajet_id', trajetId)
          .or('passager_id.eq.${user.id},passenger_email.eq.$currentEmail');
    } else {
      existingRes = await supabase
          .from('reservations')
          .select('id')
          .eq('trajet_id', trajetId)
          .eq('passager_id', user.id);
    }

    if ((existingRes as List).isNotEmpty) {
      throw Exception('Tu as déjà une réservation sur ce trajet.');
    }

    // 3) Vérifier qu’il reste des places (en comptant les réservations)
    final res = await supabase
        .from('reservations')
        .select('id')
        .eq('trajet_id', trajetId);

    final nbReservations = (res as List).length;

    if (nbReservations >= trip.nbPlaces) {
      throw Exception('Plus de places disponibles sur ce trajet.');
    }

    // 4) Récupérer les infos de contact du passager via app_users (par email)
    String? passengerEmail = currentEmail.isEmpty ? null : currentEmail;
    String? prenom;
    String? nom;
    String? telephone;

    if (passengerEmail != null && passengerEmail.isNotEmpty) {
      final rows = await supabase
          .from('app_users')
          .select('email, prenom, nom, telephone')
          .eq('email', passengerEmail);

      if (rows is List && rows.isNotEmpty) {
        final userInfo = rows.first as Map<String, dynamic>;
        passengerEmail = (userInfo['email'] as String?) ?? passengerEmail;
        prenom = userInfo['prenom'] as String?;
        nom = userInfo['nom'] as String?;
        telephone = userInfo['telephone'] as String?;
      }
    }

    // 5) Insérer la réservation
    await supabase.from('reservations').insert({
      'trajet_id': trajetId,
      'passager_id': user.id, // historique
      'passenger_email': passengerEmail, // IMPORTANT pour bloquer doublon par email
      'passenger_prenom': prenom,
      'passenger_nom': nom,
      'passenger_telephone': telephone,
    });
  }

  /// Trajets disponibles pour un passager
  Future<List<Trip>> getAvailableTrips() async {
    final currentEmail = (currentLoginEmail ?? '').toLowerCase();

    final response = await supabase
        .from('trajets')
        .select()
        .neq('statut', 'termine')
        .neq('statut', 'annule')
        .order('heure_depart', ascending: true);

    final allTrips = (response as List)
        .map((e) => Trip.fromMap(e as Map<String, dynamic>))
        .toList();

    if (currentEmail.isEmpty) {
      return allTrips;
    }

    final filtered = allTrips.where((trip) {
      final driverEmail = (trip.driverEmail ?? '').toLowerCase();
      return driverEmail != currentEmail;
    }).toList();

    return filtered;
  }

  /// Trajets sur lesquels je suis passager (via passenger_email)
  Future<List<Trip>> getMyReservations() async {
    final currentEmail = (currentLoginEmail ?? '').toLowerCase();
    if (currentEmail.isEmpty) {
      throw Exception('Email utilisateur inconnu (reconnecte-toi).');
    }

    final res = await supabase
        .from('reservations')
        .select('trajets(*)')
        .eq('passenger_email', currentEmail);

    final list = (res as List)
        .map((e) => Trip.fromMap(e['trajets'] as Map<String, dynamic>))
        .toList();

    return list;
  }

  /// Liste des passagers d'un trajet (pour le conducteur)
  Future<List<Map<String, dynamic>>> getPassengersForTrip(String trajetId) async {
    final currentEmail = (currentLoginEmail ?? '').toLowerCase();
    if (currentEmail.isEmpty) {
      throw Exception('Email utilisateur inconnu (reconnecte-toi).');
    }

    final tripRow = await supabase
        .from('trajets')
        .select()
        .eq('id', trajetId)
        .single();

    final trip = Trip.fromMap(tripRow as Map<String, dynamic>);
    final driverEmail = (trip.driverEmail ?? '').toLowerCase();

    if (driverEmail != currentEmail) {
      throw Exception('Tu n\'es pas le conducteur de ce trajet.');
    }

    final res = await supabase
        .from('reservations')
        .select(
          'passenger_email, passenger_prenom, passenger_nom, passenger_telephone, created_at',
        )
        .eq('trajet_id', trajetId)
        .order('created_at', ascending: true);

    final list = (res as List).map((e) => e as Map<String, dynamic>).toList();
    return list;
  }

  /// ✅ NOUVEAU : Compter les réservations par trajet (pour calculer les places restantes côté UI)
  Future<Map<String, int>> getReservationCountsForTrips(List<String> trajetIds) async {
    if (trajetIds.isEmpty) return {};

    final res = await supabase
        .from('reservations')
        .select('trajet_id')
        .inFilter('trajet_id', trajetIds);

    final counts = <String, int>{};
    for (final row in (res as List)) {
      final id = (row as Map<String, dynamic>)['trajet_id']?.toString();
      if (id == null) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }
}

final reservationService = ReservationService();
