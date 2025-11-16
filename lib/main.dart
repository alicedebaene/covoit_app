import 'package:covoit_app/auth/screens/auth/login_page.dart';
import 'package:covoit_app/auth/screens/common/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://egkyussobkkhfryubhfc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVna3l1c3NvYmtraGZyeXViaGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNzQ2ODYsImV4cCI6MjA3NTc1MDY4Nn0.kGJaLM_p41GdYcaVHjx9vQUeMl98ctdk0tjSDoi20Wc',
  );

  runApp(const CovoitApp());
}

class CovoitApp extends StatelessWidget {
  const CovoitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 Thème Ovalies
    final theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      primaryColor: const Color(0xFF0057A3),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0057A3),
        primary: const Color(0xFF0057A3),
        secondary: const Color(0xFFFFC93C),
        background: const Color(0xFFF5F7FB),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0057A3),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0057A3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0057A3),
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF4B5563),
        ),
      ),
    );

    return MaterialApp(
      title: 'Covoit Ovalies',
      theme: theme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final currentSession = snapshot.data?.session ?? session;
        if (currentSession == null) {
          return const LoginPage();
        } else {
          return const HomePage();
        }
      },
    );
  }
}
