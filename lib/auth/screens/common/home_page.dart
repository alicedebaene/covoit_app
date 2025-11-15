import 'package:covoit_app/guard/guard_home_page.dart';
import 'package:covoit_app/passenger/passenger_home_page.dart';
import 'package:flutter/material.dart';
import 'package:covoit_app/service/auth_services/auth_service.dart';
import 'package:covoit_app/service/role_service.dart';

import 'driver/driver_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  bool isGuard = false;

  @override
  void initState() {
    super.initState();
    _checkGuard();
  }

  Future<void> _checkGuard() async {
    try {
      final value = await roleService.isCurrentUserGuard();
      if (!mounted) return;
      setState(() {
        isGuard = value;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isGuard = false;
        loading = false;
      });
    }
  }

  void _logout() {
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🛡️ Cas 1 : utilisateur surveillant → un seul bouton
    if (isGuard) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Covoiturage Campus → Elispace'),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
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
          ),
        ),
      );
    }

    // 🚗 Cas 2 : utilisateur "normal" → Conducteur + Passager, PAS Surveillant
    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage Campus → Elispace'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Qui êtes-vous ?',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
