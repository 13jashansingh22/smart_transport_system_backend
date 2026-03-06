import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/bus_route.dart';
import '../../models/bus_routes_repository.dart';
import '../../services/smart_transport_ai_service.dart';

class AIFeaturesScreen extends StatefulWidget {
  const AIFeaturesScreen({super.key});

  @override
  State<AIFeaturesScreen> createState() => _AIFeaturesScreenState();
}

class _AIFeaturesScreenState extends State<AIFeaturesScreen> {
  final service = SmartTransportAIService.instance;
  final TextEditingController voiceController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();

  BusRoute selectedRoute = BusRoutesRepository.allRoutes.first;
  double trafficFactor = 0.25;
  int selectedRating = 4;
  String voiceResponse = 'Ask: arrival, seat, route, or SOS';

  @override
  void initState() {
    super.initState();
    service.startNotificationFeed();
  }

  @override
  void dispose() {
    voiceController.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final eta = service.predictArrivalMinutes(
      route: selectedRoute,
      trafficFactor: trafficFactor,
      historicalDelays: const [2, 5, 3, 4],
    );
    final optimized = service.optimizeRoute(
      routes: BusRoutesRepository.allRoutes.take(10).toList(),
      trafficFactor: trafficFactor,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('AI Smart Features')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _card(
            title: 'AI Bus Arrival Prediction',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(selectedRoute.id),
                  initialValue: selectedRoute.id,
                  decoration: const InputDecoration(labelText: 'Select Route'),
                  items: BusRoutesRepository.allRoutes
                      .take(20)
                      .map((r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(
                                '${r.routeNumber} • ${r.source} → ${r.destination}'),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() {
                      selectedRoute =
                          BusRoutesRepository.getRouteById(id) ?? selectedRoute;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text('Traffic Load: ${(trafficFactor * 100).round()}%'),
                Slider(
                  value: trafficFactor,
                  min: 0,
                  max: 1,
                  onChanged: (v) => setState(() => trafficFactor = v),
                ),
                Text('Predicted ETA: $eta minutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                        )),
              ],
            ),
          ),
          _card(
            title: 'Smart Route Optimization',
            child: Text(
              'Fastest suggested route: ${optimized.routeNumber} (${optimized.source} → ${optimized.destination})',
            ),
          ),
          _card(
            title: 'Smart Bus Stop Detection',
            child: Builder(
              builder: (_) {
                final stop = service.nearestStop(
                  userLocation: const LatLng(28.6139, 77.2090),
                  route: selectedRoute,
                );
                return Text(
                  stop == null
                      ? 'No nearby stop detected'
                      : 'Nearest stop: ${stop.stopName} (ETA point: ${stop.arrivalMinutes} min)',
                );
              },
            ),
          ),
          _card(
            title: 'Voice Assistant Support',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: voiceController,
                  decoration: const InputDecoration(
                    labelText: 'Type voice command simulation',
                    hintText: 'e.g. next arrival',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      voiceResponse =
                          service.processVoiceCommand(voiceController.text);
                    });
                  },
                  child: const Text('Run Voice Assistant'),
                ),
                const SizedBox(height: 8),
                Text(voiceResponse),
              ],
            ),
          ),
          _card(
            title: 'Offline Mode Support',
            child: ValueListenableBuilder<bool>(
              valueListenable: service.offlineMode,
              builder: (_, isOffline, __) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(isOffline
                        ? 'Offline mode ON: route & stop cache active'
                        : 'Offline mode OFF: live sync active'),
                  ),
                  Switch(
                    value: isOffline,
                    onChanged: (v) => service.offlineMode.value = v,
                  ),
                ],
              ),
            ),
          ),
          _card(
            title: 'Passenger Feedback Analytics',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  key: ValueKey(selectedRating),
                  initialValue: selectedRating,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  items: [1, 2, 3, 4, 5]
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text('$r Star')))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRating = v ?? 4),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback',
                    hintText: 'good service / late bus / crowd issue ...',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    service.submitFeedback(
                      rating: selectedRating,
                      comment: feedbackController.text,
                    );
                    setState(() {});
                  },
                  child: const Text('Submit Feedback'),
                ),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final analytics = service.feedbackAnalytics();
                  return Text(
                    'Total: ${analytics['count']} • Avg: ${(analytics['averageRating'] as double).toStringAsFixed(1)} • Positive: ${analytics['positive']} • Negative: ${analytics['negative']}',
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
