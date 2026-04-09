import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/eta_service.dart';

class BusLiveStatusCard extends StatelessWidget {
  const BusLiveStatusCard({
    super.key,
    this.busDocumentId = 'bus_1',
    this.distanceKm,
    this.delayMinutes = 0,
  });

  static final Stream<int> _uiTicker =
      Stream<int>.periodic(const Duration(seconds: 1), (tick) => tick);

  final String busDocumentId;
  final double? distanceKm;
  final int delayMinutes;

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('buses').doc(busDocumentId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorState(
            message: 'Failed to load live bus updates. ${snapshot.error}',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }

        final document = snapshot.data;
        if (document == null || !document.exists) {
          return const _ErrorState(
            message: 'Live data is not available for bus_1 yet.',
          );
        }

        final data = document.data();
        if (data == null) {
          return const _ErrorState(
            message: 'Live document exists but has no readable fields.',
          );
        }

        final latitude = _readDouble(data['latitude']);
        final longitude = _readDouble(data['longitude']);
        final speedMps = _readDouble(data['speed']);
        final lastUpdatedMillis = _readInt(data['lastUpdatedMillis']);
        final timestamp = _readTimestamp(data['timestamp']);

        final effectiveTimestamp = lastUpdatedMillis != null
            ? Timestamp.fromMillisecondsSinceEpoch(lastUpdatedMillis)
            : timestamp;

        final speedKmh = speedMps != null ? speedMps * 3.6 : null;
        final etaMinutes = (speedMps != null && distanceKm != null)
            ? EtaService.calculateEtaMinutes(
                distanceKm: distanceKm!,
                speedMps: speedMps,
                delayMinutes: delayMinutes,
              )
            : null;
        final lastUpdatedTime = _resolveLastUpdated(
          millis: lastUpdatedMillis,
          timestamp: timestamp,
        );

        return StreamBuilder<int>(
          stream: _uiTicker,
          builder: (context, _) {
            final status = effectiveTimestamp != null
                ? getBusStatus(effectiveTimestamp)
                : 'OFFLINE';

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_bus_rounded,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Live Bus Status ($busDocumentId)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _statusChip(context, status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dataRow(
                      context,
                      label: 'Latitude',
                      value: latitude?.toStringAsFixed(6) ?? 'N/A',
                    ),
                    _dataRow(
                      context,
                      label: 'Longitude',
                      value: longitude?.toStringAsFixed(6) ?? 'N/A',
                    ),
                    _dataRow(
                      context,
                      label: 'Speed',
                      value: speedKmh != null
                          ? '${speedKmh.toStringAsFixed(2)} km/h'
                          : 'N/A',
                    ),
                    _dataRow(
                      context,
                      label: 'ETA',
                      value: etaMinutes != null
                          ? '$etaMinutes min'
                          : 'N/A (set distanceKm)',
                    ),
                    _dataRow(
                      context,
                      label: 'Status',
                      value: status,
                    ),
                    _dataRow(
                      context,
                      label: 'Last Updated',
                      value: lastUpdatedTime != null
                          ? _formatDateTime(lastUpdatedTime)
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _dataRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  static Widget _statusChip(BuildContext context, String status) {
    final normalized = status.trim().toLowerCase();

    Color color;
    switch (normalized) {
      case 'online':
        color = Colors.green;
        break;
      case 'delayed':
        color = Colors.orange;
        break;
      case 'offline':
        color = Colors.red;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  static String getBusStatus(Timestamp timestamp) {
    final updatedAt = timestamp.toDate();
    final ageSeconds = DateTime.now().difference(updatedAt).inSeconds;

    if (ageSeconds > 20) {
      return 'OFFLINE';
    }
    if (ageSeconds > 10) {
      return 'DELAYED';
    }
    return 'ONLINE';
  }

  static double? _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static Timestamp? _readTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value;
    }
    return null;
  }

  static DateTime? _resolveLastUpdated({
    required int? millis,
    required Timestamp? timestamp,
  }) {
    if (millis != null && millis > 0) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return timestamp?.toDate();
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final year = local.year;
    final month = twoDigits(local.month);
    final day = twoDigits(local.day);
    final hour = twoDigits(local.hour);
    final minute = twoDigits(local.minute);
    final second = twoDigits(local.second);

    return '$year-$month-$day $hour:$minute:$second';
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Loading live bus data...')),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
