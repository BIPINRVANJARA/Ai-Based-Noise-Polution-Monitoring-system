import 'package:flutter/material.dart';
import 'package:noiseguard/core/theme/app_colors.dart';
import 'package:noiseguard/core/constants/noise_thresholds.dart';

class NoiseUtils {
  static Color getNoiseColor(double db) {
    return AppColors.noiseColor(db);
  }

  static String getNoiseCategory(String source) {
    return source; // Simplistic category mapping for sources
  }

  static IconData getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'traffic':
        return Icons.directions_car;
      case 'horn':
        return Icons.campaign;
      case 'construction':
        return Icons.construction;
      case 'factory':
        return Icons.factory;
      case 'crowd':
        return Icons.groups;
      case 'dj':
        return Icons.speaker;
      case 'train':
        return Icons.train;
      case 'aircraft':
        return Icons.flight;
      case 'siren':
        return Icons.warning;
      default:
        return Icons.volume_up;
    }
  }

  static String formatDb(double db) {
    return '${db.toStringAsFixed(1)} dB';
  }

  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }

  static bool isViolation(double db, AreaType area, {bool isNight = false}) {
    final limit = isNight
        ? NoiseThresholds.nightLimits[area] ?? 100.0
        : NoiseThresholds.dayLimits[area] ?? 100.0;
    return db > limit;
  }
}
