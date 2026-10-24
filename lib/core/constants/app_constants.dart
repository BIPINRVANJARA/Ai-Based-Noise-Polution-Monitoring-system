class AppConstants {
  static const String appName = 'NoiseGuard';
  static const String appVersion = '3.0';
  static const String appTagline = 'AI-Powered Smart Noise Intelligence';
  static const String demoDeviceId = 'NG-DEMO-001';
  static const double maxDbLevel = 120.0;
  static const double minDbLevel = 30.0;
  static const int updateIntervalMs = 2000;
  static const List<String> noiseSourceClasses = [
    'Traffic',
    'Horn',
    'Construction',
    'Factory',
    'Crowd',
    'DJ',
    'Train',
    'Aircraft',
    'Siren'
  ];
  static const double defaultLatitude = 23.0225;
  static const double defaultLongitude = 72.5714;
  static const String geminiApiKey = 'AIzaSyDmgi5K0kqzrFWbU2MP3zzA7lZTYe_DRA0';
  static const String geminiModel = 'gemini-1.5-flash';
}

