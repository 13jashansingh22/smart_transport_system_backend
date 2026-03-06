import 'package:flutter/material.dart';

import 'auth/driver_login.dart';
import 'auth/conductor_login.dart';
import 'auth/passenger_login.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget roleButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(18),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            side:
                BorderSide(color: colorScheme.primary.withValues(alpha: 0.35)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => screen,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Role"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bus,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                "Smart Transport Professional Access",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                "Select your dashboard: Passenger, Driver, Conductor, or Admin.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 28),
              roleButton(
                context,
                "Passenger",
                Icons.person,
                const PassengerLoginScreen(),
              ),
              roleButton(
                context,
                "Driver",
                Icons.drive_eta,
                const DriverLoginScreen(),
              ),
              roleButton(
                context,
                "Conductor",
                Icons.confirmation_number,
                const ConductorLoginScreen(),
              ),
              roleButton(
                context,
                "Admin",
                Icons.admin_panel_settings,
                const _AdminRedirectScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminRedirectScreen extends StatelessWidget {
  const _AdminRedirectScreen();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/admin-control');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
