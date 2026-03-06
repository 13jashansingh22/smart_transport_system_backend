import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../models/bus_routes_repository.dart';
import '../services/smart_transport_ai_service.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final service = SmartTransportAIService.instance;

  ll.LatLng location = const ll.LatLng(28.6139, 77.2090);
  bool tracking = false;
  String selectedRouteId = BusRoutesRepository.allRoutes.first.id;
  int passengerCount = 0;
  String busStatus = 'Running';
  int drivingMinutes = 0;
  double eyeClosureScore = 0.8;
  double steeringVariation = 0.4;
  double trafficFactor = 0.2;

  @override
  Widget build(BuildContext context) {
    final route = BusRoutesRepository.getRouteById(selectedRouteId) ??
        BusRoutesRepository.allRoutes.first;
    final isFatigued = service.detectDriverFatigue(
      drivingMinutes: drivingMinutes,
      eyeClosureScore: eyeClosureScore,
      steeringVariation: steeringVariation,
    );

    final bestRoute = service.optimizeRoute(
      routes: BusRoutesRepository.allRoutes.take(12).toList(),
      trafficFactor: trafficFactor,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Smart Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/help'),
            icon: const Icon(Icons.help),
          ),
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
              const ListTile(
                leading: Icon(Icons.drive_eta),
                title: Text('Driver Navigation'),
                subtitle: Text('Professional sequence menu'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('1. Driver Dashboard'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('2. Passenger Tracking View'),
                onTap: () => Navigator.pushNamed(context, '/trackbus'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('3. Alerts'),
                onTap: () => Navigator.pushNamed(context, '/alerts'),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('4. Help'),
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final payload = service.createEmergencyPayload(
            role: 'driver',
            busId: route.id,
            latitude: location.latitude,
            longitude: location.longitude,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SOS sent: ${payload['status']}'),
            ),
          );
        },
        child: const Icon(Icons.warning),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: location, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: Color(0xFFFF3D00),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Live GPS Bus Tracking: ${tracking ? 'Running' : 'Stopped'}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => tracking = true);
                            service.shareDriverLocation(
                              busId: route.id,
                              location: gmaps.LatLng(
                                  location.latitude, location.longitude),
                            );
                            service.addTripHistory(
                              driverId: 'D-101',
                              routeId: route.id,
                              status: 'Duty Started',
                            );
                          },
                          child: const Text('Start Trip'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => tracking = false);
                            service.addTripHistory(
                              driverId: 'D-101',
                              routeId: route.id,
                              status: 'Duty Stopped',
                            );
                          },
                          child: const Text('Stop Trip'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedRouteId),
                    initialValue: selectedRouteId,
                    decoration:
                        const InputDecoration(labelText: 'Assigned Route'),
                    items: BusRoutesRepository.allRoutes
                        .take(20)
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(
                                '${r.routeNumber} • ${r.source} → ${r.destination}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedRouteId = value);
                    },
                  ),
                  const Divider(height: 20),
                  Text(
                      'Real-time Navigation Route: ${route.source} → ${route.destination}'),
                  Text('Bus Status Update: $busStatus'),
                  DropdownButtonFormField<String>(
                    key: ValueKey(busStatus),
                    initialValue: busStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Running', child: Text('Running')),
                      DropdownMenuItem(
                          value: 'Delayed', child: Text('Delayed')),
                      DropdownMenuItem(
                          value: 'Stopped', child: Text('Stopped')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => busStatus = value);
                      service.updateBusStatus(busId: route.id, status: value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Passenger Count Monitoring: $passengerCount'),
                  Slider(
                    value: passengerCount.toDouble(),
                    min: 0,
                    max: 80,
                    onChanged: (v) =>
                        setState(() => passengerCount = v.round()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      service.publishRouteChange(
                        routeNumber: route.routeNumber,
                        note: 'Temporary diversion due to traffic congestion',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Route change notification sent.')),
                      );
                    },
                    child: const Text('Send Route Change Notification'),
                  ),
                  const Divider(height: 20),
                  Text(
                      'Driver Fatigue Detection: ${isFatigued ? 'ALERT' : 'Normal'}'),
                  Text('Driving Minutes: $drivingMinutes'),
                  Slider(
                    value: drivingMinutes.toDouble(),
                    min: 0,
                    max: 600,
                    onChanged: (v) =>
                        setState(() => drivingMinutes = v.round()),
                  ),
                  Text(
                      'Eye Closure Score: ${eyeClosureScore.toStringAsFixed(2)}'),
                  Slider(
                    value: eyeClosureScore,
                    min: 0,
                    max: 2,
                    onChanged: (v) => setState(() => eyeClosureScore = v),
                  ),
                  const Divider(height: 20),
                  Text(
                    'AI Crowd Detection: ${service.crowdPercentage(route.id)}% occupied${service.isCrowded(route.id) ? ' (Overcrowded)' : ''}',
                  ),
                  Text(
                      'Smart Seat Availability: ${service.availableSeats(route.id)} seats free'),
                  const Divider(height: 20),
                  Text('Smart Route Optimization'),
                  Text('Traffic Load: ${(trafficFactor * 100).round()}%'),
                  Slider(
                    value: trafficFactor,
                    min: 0,
                    max: 1,
                    onChanged: (v) => setState(() => trafficFactor = v),
                  ),
                  Text(
                      'Suggested Fastest Route: ${bestRoute.routeNumber} • ${bestRoute.source} → ${bestRoute.destination}'),
                  const Divider(height: 20),
                  Text('Trip History Tracking'),
                  ...service.getTripHistory().take(4).map(
                        (item) => Text(
                          '${item['status'] ?? item['type']} • ${item['routeId'] ?? ''}',
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
