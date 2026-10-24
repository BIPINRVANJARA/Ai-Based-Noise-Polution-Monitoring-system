import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noiseguard/core/constants/noise_thresholds.dart';

final selectedAreaTypeProvider = StateProvider<AreaType>((ref) => AreaType.residential);

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

final thresholdProvider = Provider<double>((ref) {
  final areaType = ref.watch(selectedAreaTypeProvider);
  return NoiseThresholds.dayLimits[areaType] ?? 55.0;
});
