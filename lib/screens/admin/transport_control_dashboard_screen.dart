import 'package:flutter/material.dart';

import '../../models/bus_routes_repository.dart';
import '../../services/smart_transport_ai_service.dart';

class TransportControlDashboardScreen extends StatefulWidget {
  const TransportControlDashboardScreen({super.key});

  @override
  State<TransportControlDashboardScreen> createState() =>
      _TransportControlDashboardScreenState();
}

class _TransportControlDashboardScreenState
    extends State<TransportControlDashboardScreen> {
  final service = SmartTransportAIService.instance;
  final routeNameController = TextEditingController();
  final scheduleController = TextEditingController();
  bool emergencyControlEnabled = true;
  late List<String> managedRoutes;
  final List<String> managedSchedules = <String>[];

  final List<Map<String, dynamic>> mockDrivers = [
    {
      'id': 'D-101',
      'name': 'A. Sharma',
      'status': 'On Trip',
      'fatigue': 'Normal'
    },
    {
      'id': 'D-102',
      'name': 'R. Singh',
      'status': 'On Trip',
      'fatigue': 'Warning'
    },
    {
      'id': 'D-103',
      'name': 'M. Kumar',
      'status': 'Standby',
      'fatigue': 'Normal'
    },
  ];

  @override
  void initState() {
    super.initState();
    service.startNotificationFeed();
    managedRoutes = BusRoutesRepository.allRoutes
        .take(12)
        .map((e) => '${e.routeNumber} (${e.source}→${e.destination})')
        .toList();
    managedSchedules.addAll([
      '101 • 08:00 AM',
      '204 • 09:15 AM',
      '309 • 10:05 AM',
    ]);
  }

  @override
  void dispose() {
    routeNameController.dispose();
    scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routes = BusRoutesRepository.allRoutes;
    final activeRoutes = routes.where((r) => r.isActive).length;
    final analytics = service.feedbackAnalytics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Control Dashboard'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Admin Navigation'),
                subtitle: Text('Monitor buses, drivers, and routes'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('1. Dashboard Overview'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.route),
                title: const Text('2. Live Route Monitoring'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('3. Driver Monitoring'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('4. Control Alerts'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('5. Passenger Panel View'),
                onTap: () => Navigator.pushNamed(context, '/passenger'),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard(
                  'Total Buses', '${routes.length}', Icons.directions_bus),
              _metricCard('Active Routes', '$activeRoutes', Icons.alt_route),
              _metricCard(
                  'Avg Rating',
                  (analytics['averageRating'] as double).toStringAsFixed(1),
                  Icons.star),
              _metricCard(
                  'Feedback Count', '${analytics['count']}', Icons.reviews),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route Management',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: routeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Add Bus Route',
                      hintText: 'e.g. 555 (City A→City B)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final value = routeNameController.text.trim();
                            if (value.isEmpty) return;
                            setState(() {
                              managedRoutes.insert(0, value);
                              routeNameController.clear();
                            });
                          },
                          child: const Text('Add Route'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...managedRoutes.take(6).map(
                        (routeItem) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.route),
                          title: Text(routeItem),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() => managedRoutes.remove(routeItem));
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      ),
                  const Divider(height: 20),
                  Text('Live Route Monitoring',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...routes.take(8).map(
                        (r) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.route),
                          title: Text(
                              '${r.routeNumber} • ${r.source} → ${r.destination}'),
                          subtitle: Text(
                              'ETA base: ${r.estimatedMinutes} min • Fare: ₹${r.fare}'),
                          trailing: Text(r.isActive ? 'Active' : 'Inactive'),
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Driver Monitoring',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...mockDrivers.map(
                    (d) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.badge),
                      title: Text('${d['id']} • ${d['name']}'),
                      subtitle: Text('Status: ${d['status']}'),
                      trailing: Text('${d['fatigue']}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Schedule Management',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: scheduleController,
                    decoration: const InputDecoration(
                      labelText: 'Add Bus Schedule',
                      hintText: 'e.g. 420 • 06:45 PM',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final value = scheduleController.text.trim();
                      if (value.isEmpty) return;
                      setState(() {
                        managedSchedules.insert(0, value);
                        scheduleController.clear();
                      });
                    },
                    child: const Text('Add Schedule'),
                  ),
                  const SizedBox(height: 8),
                  ...managedSchedules.take(5).map((s) => Text('• $s')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Control Room Alerts',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<AppNotification>>(
                    valueListenable: service.notifications,
                    builder: (_, items, __) {
                      if (items.isEmpty) {
                        return const Text('Waiting for incoming alerts...');
                      }
                      return Column(
                        children: items.take(6).map((item) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.notifications_active),
                            title: Text(item.title),
                            subtitle: Text(item.message),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const Divider(height: 20),
                  Text('Delay Monitoring System',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  ...service.notifications.value
                      .where((n) => n.title.toLowerCase().contains('delay'))
                      .take(3)
                      .map((n) => Text('• ${n.message}')),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Control Emergency Alerts',
                          style: Theme.of(context).textTheme.titleSmall),
                      Switch(
                        value: emergencyControlEnabled,
                        onChanged: (value) {
                          setState(() => emergencyControlEnabled = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final analytics = service.feedbackAnalytics();
                      final demand = service.predictPassengerDemand(
                        hour: DateTime.now().hour,
                        isWeekend: DateTime.now().weekday >= 6,
                        historicalAvg: 42,
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Transport Report'),
                            content: Text(
                              'Routes: ${managedRoutes.length}\nSchedules: ${managedSchedules.length}\nFeedback Avg: ${(analytics['averageRating'] as double).toStringAsFixed(1)}\nPredicted Demand: $demand passengers',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Generate Report & Statistics'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: Theme.of(context).textTheme.titleMedium),
                    Text(title, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
