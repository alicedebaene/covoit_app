import 'package:covoit_app/auth/screens/auth/login_page.dart';
import 'package:covoit_app/auth/screens/common/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://egkyussobkkhfryubhfc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVna3l1c3NvYmtraGZyeXViaGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNzQ2ODYsImV4cCI6MjA3NTc1MDY4Nn0.kGJaLM_p41GdYcaVHjx9vQUeMl98ctdk0tjSDoi20Wc',
  );

 runApp(const CovoitApp());
}

class CovoitApp extends StatelessWidget {
  const CovoitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covoiturage Campus-Friche',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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