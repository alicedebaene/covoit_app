import 'package:covoit_app/service/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  /// Raccourci pratique
  GoTrueClient get _auth => supabase.auth;

  /// Session en cours (null si déconnecté)
  Session? get session => _auth.currentSession;

  /// Utilisateur en cours (null si déconnecté)
  User? get currentUser => _auth.currentUser;

  /// Connexion email+mot de passe (si tu l'utilises encore ailleurs)
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (res.session == null) {
        throw const AuthException('Aucune session retournée.');
      }
      return res;
    } on AuthException catch (e) {
      // Erreur Supabase explicite
      throw Exception('Connexion impossible : ${e.message}');
    } catch (e) {
      // Autre erreur
      throw Exception('Connexion impossible : $e');
    }
  }

  /// Inscription email+mot de passe (si tu l'utilises encore ailleurs)
  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (res.user == null) {
        throw const AuthException('Aucun utilisateur retourné.');
      }
      return res;
    } on AuthException catch (e) {
      throw Exception('Inscription impossible : ${e.message}');
    } catch (e) {
      throw Exception('Inscription impossible : $e');
    }
  }

  /// ✅ Connexion anonyme (ce que tu utilises dans tes pages Login/SignUp)
  Future<AuthResponse> signInAnonymously() async {
    try {
      final res = await _auth.signInAnonymously();
      if (res.user == null) {
        throw const AuthException('Aucun utilisateur retourné.');
      }
      return res;
    } on AuthException catch (e) {
      throw Exception('Connexion anonyme impossible : ${e.message}');
    } catch (e) {
      throw Exception('Connexion anonyme impossible : $e');
    }
  }

  /// Déconnexion
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    try {
      await _auth.signOut(scope: scope);
    } catch (e) {
      throw Exception('Déconnexion impossible : $e');
    }
  }

  /// Écouter les changements d'auth (utile pour AuthGate)
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
}

final authService = AuthService();
