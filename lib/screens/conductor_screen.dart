import 'package:flutter/material.dart';

import '../models/bus_routes_repository.dart';
import '../services/smart_transport_ai_service.dart';

class ConductorScreen extends StatefulWidget {
  const ConductorScreen({super.key});

  @override
  State<ConductorScreen> createState() => _ConductorScreenState();
}

class _ConductorScreenState extends State<ConductorScreen> {
  final service = SmartTransportAIService.instance;
  final qrController = TextEditingController();
  final walkInPassengerController =
      TextEditingController(text: 'Walk-in Passenger');

  String routeId = BusRoutesRepository.allRoutes.first.id;
  String verifyResult = 'Waiting for scan';
  int seatToToggle = 1;

  @override
  void dispose() {
    qrController.dispose();
    walkInPassengerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = BusRoutesRepository.getRouteById(routeId) ??
        BusRoutesRepository.allRoutes.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductor Smart Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/help'),
            icon: const Icon(Icons.help),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                leading: Icon(Icons.confirmation_number),
                title: Text('Conductor Navigation'),
                subtitle: Text('Professional sequence menu'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('1. QR Verification'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.event_seat),
                title: const Text('2. Seat Availability'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('3. Crowd Detection'),
                onTap: () => Navigator.pop(context),
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
            role: 'conductor',
            busId: route.id,
            latitude: 28.6139,
            longitude: 77.2090,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SOS sent: ${payload['status']}')),
          );
        },
        child: const Icon(Icons.warning),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(routeId),
            initialValue: routeId,
            decoration: const InputDecoration(labelText: 'Current Route'),
            items: BusRoutesRepository.allRoutes
                .take(20)
                .map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                          '${r.routeNumber} • ${r.source} → ${r.destination}'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => routeId = value ?? routeId),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QR Code Ticket Verification',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: qrController,
                    decoration: const InputDecoration(
                      labelText: 'Scan/Enter QR Ticket ID',
                      hintText: 'TKT-xxxxxxxxxxxx-12',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final ok = service.verifyQrTicket(qrController.text);
                      setState(() => verifyResult =
                          ok ? 'Ticket Verified' : 'Invalid Ticket');
                    },
                    child: const Text('Scan & Verify'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: walkInPassengerController,
                    decoration: const InputDecoration(
                      labelText: 'Generate New Ticket - Passenger Name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final ticket = service.generateQrTicket(
                        passengerName:
                            walkInPassengerController.text.trim().isEmpty
                                ? 'Walk-in Passenger'
                                : walkInPassengerController.text.trim(),
                        routeId: route.id,
                        seatNumber: seatToToggle,
                      );
                      setState(() {
                        verifyResult = 'Ticket generated: ${ticket.ticketId}';
                      });
                    },
                    child: const Text('Generate New Ticket'),
                  ),
                  const SizedBox(height: 8),
                  Text(verifyResult),
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
                  Text('Smart Seat Availability System',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Occupied: ${service.occupiedSeats(route.id)} / 40'),
                  Text('Available: ${service.availableSeats(route.id)} / 40'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('Seat: $seatToToggle')),
                      Expanded(
                        flex: 3,
                        child: Slider(
                          value: seatToToggle.toDouble(),
                          min: 1,
                          max: 40,
                          divisions: 39,
                          onChanged: (value) =>
                              setState(() => seatToToggle = value.round()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            service.occupySeat(route.id, seatToToggle);
                            setState(() {});
                          },
                          child: const Text('Mark Occupied'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            service.vacateSeat(route.id, seatToToggle);
                            setState(() {});
                          },
                          child: const Text('Mark Available'),
                        ),
                      ),
                    ],
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
                  Text('Passenger Ticket List',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...service.ticketsForRoute(route.id).take(6).map(
                        (ticket) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.confirmation_number),
                          title: Text(ticket.ticketId),
                          subtitle: Text(
                              '${ticket.passengerName} • Seat ${ticket.seatNumber}'),
                        ),
                      ),
                  if (service.ticketsForRoute(route.id).isEmpty)
                    const Text('No passenger tickets yet for this route.'),
                  const Divider(height: 20),
                  Text('Trip Ticket Reports',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (_) {
                      final report = service.ticketReport(route.id);
                      return Text(
                        'Tickets: ${report['tickets']} • Seats: ${report['uniqueSeats']} • Revenue: ₹${report['estimatedRevenue']}',
                      );
                    },
                  ),
                  const Divider(height: 20),
                  Text('Ticket History Tracking',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...service.getTripHistory().take(4).map(
                        (item) => Text(
                            '${item['type'] ?? item['status']} • ${item['ticketId'] ?? ''}'),
                      ),
                  const Divider(height: 20),
                  Text('AI Crowd Detection',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Crowd Level: ${service.crowdPercentage(route.id)}%'),
                  Text(
                    service.isCrowded(route.id)
                        ? 'Alert sent to authorities: bus overcrowded'
                        : 'Bus crowd under safe threshold',
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
