import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/bus_routes_repository.dart';
import '../services/smart_transport_ai_service.dart';

class PassengerScreen extends StatelessWidget {
  const PassengerScreen({super.key});

  Future<void> _triggerSos(BuildContext context) async {
    final service = SmartTransportAIService.instance;
    final selected = BusRoutesRepository.allRoutes.first;

    double latitude = 28.6139;
    double longitude = 77.2090;
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (_) {}

    final payload = service.createEmergencyPayload(
      role: 'passenger',
      busId: selected.id,
      latitude: latitude,
      longitude: longitude,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SOS sent (${payload['status']}) • Bus ${payload['busId']}',
          ),
        ),
      );
    }
  }

  Widget _navTile(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _quickCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required String route}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _quickCall(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri);
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calling not supported on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Command Center'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/chatbot'),
            icon: const Icon(Icons.smart_toy),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.directions_bus, color: colorScheme.primary),
                title: const Text('Passenger Navigation'),
                subtitle: const Text('Features arranged in sequence'),
              ),
              const Divider(),
              _navTile(context, Icons.location_on, '1. Live GPS Tracking',
                  '/trackbus'),
              _navTile(
                  context, Icons.alt_route, '2. Routes & Stops', '/routes'),
              _navTile(context, Icons.schedule, '3. Schedule', '/schedule'),
              _navTile(context, Icons.confirmation_number, '4. QR Ticketing',
                  '/tickets'),
              _navTile(context, Icons.notifications, '5. Real-Time Alerts',
                  '/alerts'),
              _navTile(context, Icons.auto_awesome, '6. AI Features',
                  '/ai-features'),
              _navTile(context, Icons.receipt, '7. Digital Ticket Booking',
                  '/tickets'),
              _navTile(context, Icons.event_seat, '8. Smart Seat Availability',
                  '/tickets'),
              _navTile(
                  context, Icons.mic, '9. Voice Assistant', '/ai-features'),
              _navTile(context, Icons.offline_bolt, '10. Offline Mode',
                  '/ai-features'),
              _navTile(context, Icons.feedback, '11. Feedback & Ratings',
                  '/ai-features'),
              _navTile(context, Icons.receipt, '12. My Tickets', '/mytickets'),
              _navTile(context, Icons.history, '13. History', '/history'),
              _navTile(context, Icons.person, '14. Profile', '/profile'),
              _navTile(context, Icons.help, '15. Help', '/help'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _triggerSos(context),
        icon: const Icon(Icons.warning),
        label: const Text('SOS'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF28120F),
              colorScheme.surface,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Professional Main Screen',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Use side menu for sequential features or open quick cards below.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<String>(
                      valueListenable:
                          SmartTransportAIService.instance.selectedLanguage,
                      builder: (_, language, __) {
                        return DropdownButtonFormField<String>(
                          key: ValueKey(language),
                          initialValue: language,
                          decoration: const InputDecoration(
                            labelText: 'Multi-language Support',
                          ),
                          items: SmartTransportAIService.instance
                              .supportedLanguages()
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              SmartTransportAIService
                                  .instance.selectedLanguage.value = value;
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _quickCard(
              context,
              title: 'Live GPS Bus Tracking',
              subtitle: 'Track current bus movement and ETA on map.',
              icon: Icons.location_searching,
              route: '/trackbus',
            ),
            _quickCard(
              context,
              title: 'AI Arrival Prediction',
              subtitle: 'Traffic + historical delay based prediction.',
              icon: Icons.analytics,
              route: '/ai-features',
            ),
            _quickCard(
              context,
              title: 'QR Ticket & Seat Availability',
              subtitle: 'Generate secure QR ticket and check live seats.',
              icon: Icons.qr_code_2,
              route: '/tickets',
            ),
            _quickCard(
              context,
              title: 'Real-Time Notifications',
              subtitle: 'Arrival, delay and route-change alerts.',
              icon: Icons.notifications_active,
              route: '/alerts',
            ),
            _quickCard(
              context,
              title: 'Nearby Stops & Route Search',
              subtitle:
                  'Use GPS to detect nearest stop and search routes/stops.',
              icon: Icons.near_me,
              route: '/routes',
            ),
            _quickCard(
              context,
              title: 'Feedback, Voice & Offline',
              subtitle:
                  'Feedback analytics, voice assistant and offline route info.',
              icon: Icons.record_voice_over,
              route: '/ai-features',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Safety & Quick Call',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _quickCall(context, '100'),
                            icon: const Icon(Icons.local_police),
                            label: const Text('Police'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _quickCall(context, '108'),
                            icon: const Icon(Icons.emergency),
                            label: const Text('Ambulance'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
