enum AreaType { hospital, school, residential, commercial, industrial, silence }

class NoiseThresholds {
  static const Map<AreaType, double> dayLimits = {
    AreaType.hospital: 50.0,
    AreaType.school: 55.0,
    AreaType.residential: 55.0,
    AreaType.commercial: 65.0,
    AreaType.industrial: 75.0,
    AreaType.silence: 50.0,
  };

  static const Map<AreaType, double> nightLimits = {
    AreaType.hospital: 40.0,
    AreaType.school: 45.0,
    AreaType.residential: 45.0,
    AreaType.commercial: 55.0,
    AreaType.industrial: 65.0,
    AreaType.silence: 40.0,
  };

  static String categoryName(double db) {
    if (db < 45) return 'Quiet';
    if (db < 55) return 'Moderate';
    if (db < 70) return 'Loud';
    if (db < 85) return 'Very Loud';
    return 'Dangerous';
  }

  static String categoryEmoji(double db) {
    if (db < 55) return '🟢';
    if (db < 70) return '🟡';
    if (db < 85) return '🟠';
    return '🔴';
  }
}
