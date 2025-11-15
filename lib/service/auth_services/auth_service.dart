import 'package:covoit_app/service/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService {
  Future<void> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw Exception('Connexion impossible');
    }
  }

  Future<void> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Inscription impossible');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

final authService = AuthService();
