import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFA3E635);
  static const Color primaryDark = Color(0xFF84CC16);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFF1E1E2C);
  static const Color surfaceLight = Color(0xFF2A2A3C);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF2A2A3C);
  static const Color safe = Color(0xFF22C55E);
  static const Color moderate = Color(0xFFFBBF24);
  static const Color high = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color cardShadow = Color(0x1A000000);

  static Color noiseColor(double db) {
    if (db < 55) return safe;
    if (db < 75) return moderate;
    if (db < 85) return high;
    return danger;
  }
}
