import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noiseguard/models/device.dart';
import 'package:noiseguard/providers/noise_provider.dart';

final devicesProvider = StreamProvider<List<DeviceModel>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.getDevices();
});

final selectedDeviceProvider = StateProvider<DeviceModel?>((ref) {
  final devicesAsync = ref.watch(devicesProvider);
  return devicesAsync.when(
    data: (devices) => devices.isNotEmpty ? devices.first : null,
    loading: () => null,
    error: (_, __) => null,
  );
});
