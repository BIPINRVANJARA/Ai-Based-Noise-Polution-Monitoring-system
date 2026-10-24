import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noiseguard/services/firestore_service.dart';
import 'package:noiseguard/services/realtime_database_service.dart';
import 'package:noiseguard/models/noise_record.dart';

// Services
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final realtimeDbServiceProvider = Provider<RealtimeDatabaseService>((ref) => RealtimeDatabaseService());

// Ultra-fast Firebase Realtime Database stream (/telemetry/NG-ESP32-001)
final realtimeDbStreamProvider = StreamProvider<NoiseRecord?>((ref) {
  final rtdb = ref.watch(realtimeDbServiceProvider);
  return rtdb.getLiveNoiseStream('NG-ESP32-001');
});

// Real-time Firestore stream of noise records for NG-ESP32-001
final firestoreNoiseStreamProvider = StreamProvider<List<NoiseRecord>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.getNoiseStream('NG-ESP32-001');
});

// Unified Hybrid Provider: Prefers Realtime DB, falls back to Firestore
final currentNoiseProvider = Provider<AsyncValue<NoiseRecord>>((ref) {
  final rtdbAsync = ref.watch(realtimeDbStreamProvider);
  final firestoreAsync = ref.watch(firestoreNoiseStreamProvider);

  if (rtdbAsync.hasValue && rtdbAsync.value != null) {
    return AsyncValue.data(rtdbAsync.value!);
  }

  return firestoreAsync.whenData((records) {
    if (records.isNotEmpty) {
      return records.first;
    }
    return NoiseRecord(
      id: 'disconnected_state',
      deviceId: 'NG-ESP32-001',
      timestamp: DateTime.now(),
      noiseLevel: 0.0,
      source: 'Hardware Standby',
      confidence: 0.0,
      latitude: 23.0301,
      longitude: 72.5274,
      threshold: 65.0,
      violation: false,
      address: 'SG Highway, Ahmedabad',
    );
  });
});

// Computed MIN, AVG, MAX decibels
final noiseStatsProvider = Provider<Map<String, double>>((ref) {
  final realStream = ref.watch(firestoreNoiseStreamProvider);
  return realStream.when(
    data: (records) {
      if (records.isEmpty) {
        return {'min': 0.0, 'avg': 0.0, 'max': 0.0};
      }
      final validLevels = records
          .map((r) => r.noiseLevel)
          .where((l) => l > 0.0)
          .toList();

      if (validLevels.isEmpty) return {'min': 0.0, 'avg': 0.0, 'max': 0.0};
      
      double min = validLevels.reduce((a, b) => a < b ? a : b);
      double max = validLevels.reduce((a, b) => a > b ? a : b);
      double avg = validLevels.reduce((a, b) => a + b) / validLevels.length;
      return {'min': min, 'avg': avg, 'max': max};
    },
    loading: () => {'min': 0.0, 'avg': 0.0, 'max': 0.0},
    error: (_, __) => {'min': 0.0, 'avg': 0.0, 'max': 0.0},
  );
});

// Real historical noise records from Firestore
final noiseHistoryProvider = FutureProvider.family<List<NoiseRecord>, int>((ref, days) async {
  final firestore = ref.watch(firestoreServiceProvider);
  final now = DateTime.now();
  final from = now.subtract(Duration(days: days));
  return firestore.getHistoricalData('NG-ESP32-001', from, now);
});
