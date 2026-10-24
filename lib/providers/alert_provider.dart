import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noiseguard/models/alert.dart';
import 'package:noiseguard/providers/noise_provider.dart';

final alertsProvider = StreamProvider<List<AlertModel>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.getAlerts('NG-ESP32-001');
});

final unresolvedAlertCountProvider = Provider<int>((ref) {
  final alertsAsync = ref.watch(alertsProvider);
  return alertsAsync.when(
    data: (alerts) => alerts.where((alert) => !alert.resolved).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
