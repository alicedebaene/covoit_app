import 'package:covoit_app/guard/guard_home_page.dart';
import 'package:covoit_app/passenger/passenger_home_page.dart';
import 'package:flutter/material.dart';

import 'package:covoit_app/service/auth_services/auth_service.dart';
import 'package:covoit_app/service/supabase_client.dart';
import 'package:covoit_app/service/session_store.dart';

import 'driver/driver_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  bool isGuard = false;
  String? emailUsed;

  @override
  void initState() {
    super.initState();
    _checkGuard();
  }

  Future<void> _checkGuard() async {
    try {
      final email = currentLoginEmail?.toLowerCase();
      if (email == null || email.isEmpty) {
        setState(() {
          loading = false;
          isGuard = false;
          emailUsed = email;
        });
        return;
      }

      // On vérifie directement dans guard_emails
      final res = await supabase
          .from('guard_emails')
          .select('email')
          .eq('email', email);

      final guard = (res as List).isNotEmpty;

      if (!mounted) return;
      setState(() {
        isGuard = guard;
        emailUsed = email;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        isGuard = false;
      });
    }
  }

  void _logout() {
    authService.signOut();
    currentLoginEmail = null;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🛡️ Surveillant : un seul bouton
    if (isGuard) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Covoiturage Ovalies - Surveillant'),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF0057A3),
          child: const Text(
            'Ovalies 2025 - Covoiturage officiel 🏉',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Covoiturage Ovalies 🏉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Du campus à Elispace, merci pour votre aide 👮‍♂️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                if (emailUsed != null)
                  Text(
                    'Connecté en tant que surveillant :\n$emailUsed',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shield),
                    label: const Text('Surveillant parking'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GuardHomePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🚗 Utilisateur normal : Conducteur + Passager
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ovalink'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        color: const Color(0xFF0057A3),
        child: const Text(
          'Ovalies 2025 - Covoiturage officiel 🏉',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ovalink 🏉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Du campus aux Ovalies, ensemble 💛',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Conducteur'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverHomePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Passager'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PassengerHomePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (emailUsed != null)
                Text(
                  'Connecté avec : $emailUsed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
