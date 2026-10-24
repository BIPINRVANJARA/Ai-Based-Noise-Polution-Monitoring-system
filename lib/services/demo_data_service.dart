import 'dart:async';
import 'dart:math';
import 'package:noiseguard/models/noise_record.dart';
import 'package:noiseguard/models/alert.dart';
import 'package:noiseguard/models/device.dart';
import 'package:noiseguard/models/daily_summary.dart';
import 'package:noiseguard/core/constants/noise_thresholds.dart';

class DemoDataService {
  Timer? _timer;
  final StreamController<NoiseRecord> _noiseStreamController = StreamController<NoiseRecord>.broadcast();
  
  Stream<NoiseRecord> get noiseStream => _noiseStreamController.stream;
  
  double _currentDb = 55.0;
  String _currentSource = 'Traffic';
  double _currentConfidence = 0.85;
  final Random _random = Random();
  
  final List<Map<String, dynamic>> _locations = [
    {'name': 'SG Highway', 'lat': 23.0301, 'lng': 72.5274},
    {'name': 'Maninagar', 'lat': 23.0005, 'lng': 72.6007},
    {'name': 'Satellite', 'lat': 23.0172, 'lng': 72.5271},
    {'name': 'Ellis Bridge', 'lat': 23.0258, 'lng': 72.5651},
    {'name': 'Navrangpura', 'lat': 23.0396, 'lng': 72.5577},
    {'name': 'Vastrapur', 'lat': 23.0318, 'lng': 72.5290},
    {'name': 'Paldi', 'lat': 23.0122, 'lng': 72.5654},
    {'name': 'Ashram Road', 'lat': 23.0278, 'lng': 72.5810},
    {'name': 'Bodakdev', 'lat': 23.0447, 'lng': 72.5017},
    {'name': 'Thaltej', 'lat': 23.0544, 'lng': 72.4992},
  ];

  final List<String> _sources = ['Traffic', 'Horn', 'Construction', 'Factory', 'Crowd', 'DJ', 'Train', 'Aircraft', 'Siren'];

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _noiseStreamController.add(_generateReading());
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    stop();
    _noiseStreamController.close();
  }

  NoiseRecord _generateReading([DateTime? time]) {
    final DateTime now = time ?? DateTime.now();
    final int hour = now.hour;
    
    // Base level adjustments based on time of day
    double targetDb = 55.0;
    if (hour >= 8 && hour <= 10) {
      targetDb = 75.0; // Morning rush
    } else if (hour >= 17 && hour <= 20) {
      targetDb = 80.0; // Evening rush
    } else if (hour >= 22 || hour <= 6) {
      targetDb = 45.0; // Night
    } else {
      targetDb = 65.0; // Regular day
    }

    // Random walk
    _currentDb += (_random.nextDouble() * 10 - 5);
    // Tend towards target
    _currentDb += (targetDb - _currentDb) * 0.1;
    _currentDb = _currentDb.clamp(35.0, 105.0);

    // Source determination based on dB range
    if (_currentDb < 50) {
      _currentSource = _random.nextBool() ? 'Crowd' : 'Traffic';
    } else if (_currentDb < 65) {
      _currentSource = ['Traffic', 'Crowd', 'Train'][_random.nextInt(3)];
    } else if (_currentDb < 80) {
      _currentSource = ['Traffic', 'Horn', 'Construction', 'Factory'][_random.nextInt(4)];
    } else if (_currentDb < 90) {
      _currentSource = ['Construction', 'Horn', 'Factory', 'DJ'][_random.nextInt(4)];
    } else {
      _currentSource = ['DJ', 'Siren', 'Aircraft', 'Horn'][_random.nextInt(4)];
    }

    _currentConfidence = 0.75 + (_random.nextDouble() * 0.24);
    
    final location = _locations[_random.nextInt(_locations.length)];
    
    final threshold = 65.0;
    final isViolation = _currentDb > threshold;

    return NoiseRecord(
      id: 'demo_${now.millisecondsSinceEpoch}',
      deviceId: 'NG-DEMO-001',
      timestamp: now,
      noiseLevel: _currentDb,
      source: _currentSource,
      confidence: _currentConfidence,
      latitude: (location['lat'] as double),
      longitude: (location['lng'] as double),
      address: location['name'] as String,
      threshold: threshold,
      violation: isViolation,
    );
  }

  List<NoiseRecord> generateHistoricalData(int days) {
    List<NoiseRecord> records = [];
    DateTime now = DateTime.now();
    DateTime start = now.subtract(Duration(days: days));
    
    // Reset current dB for consistent historical generation
    double savedDb = _currentDb;
    _currentDb = 55.0;
    
    for (DateTime current = start; current.isBefore(now); current = current.add(const Duration(minutes: 15))) {
      records.add(_generateReading(current));
    }
    
    _currentDb = savedDb;
    return records;
  }

  List<AlertModel> generateAlerts(int count) {
    List<AlertModel> alerts = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final location = _locations[_random.nextInt(_locations.length)];
      final dbLevel = 75.0 + _random.nextDouble() * 25.0;
      final source = ['Construction', 'Horn', 'DJ', 'Siren', 'Factory'][_random.nextInt(5)];
      alerts.add(
        AlertModel(
          alertId: 'alert_$i',
          deviceId: 'NG-DEMO-001',
          createdAt: now.subtract(Duration(hours: _random.nextInt(72))),
          noiseLevel: dbLevel,
          address: location['name'] as String,
          latitude: (location['lat'] as double),
          longitude: (location['lng'] as double),
          source: source,
          resolved: i > count ~/ 3, // First third are unresolved
          duration: Duration(minutes: 5 + _random.nextInt(55)),
          confidence: 0.78 + _random.nextDouble() * 0.21,
        )
      );
    }
    // Sort by date descending
    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return alerts;
  }

  DailySummary generateDailySummary(DateTime date) {
    final avgDb = 58.0 + _random.nextDouble() * 12;
    final maxDb = 85.0 + _random.nextDouble() * 15;
    final minDb = 35.0 + _random.nextDouble() * 10;
    final violations = 5 + _random.nextInt(25);
    final totalReadings = 96; // Every 15 min for 24 hours

    final Map<String, int> distribution = {};
    for (final source in _sources) {
      distribution[source] = _random.nextInt(30) + 1;
    }

    // Find top source
    final topEntry = distribution.entries.reduce((a, b) => a.value > b.value ? a : b);

    final summaryText = 'Highest recorded noise was ${maxDb.toStringAsFixed(1)} dB at '
        'SG Highway around 6:30 PM. ${topEntry.key} contributed to '
        '${(topEntry.value * 100 / distribution.values.reduce((a, b) => a + b)).toStringAsFixed(0)}% '
        'of readings. Average noise level was ${avgDb.toStringAsFixed(1)} dB. '
        'Construction noise peaked during 2:00-4:00 PM near Maninagar. '
        'Total of $violations violations were recorded throughout the day.';

    return DailySummary(
      date: date,
      avgNoise: avgDb,
      maxNoise: maxDb,
      minNoise: minDb,
      totalReadings: totalReadings,
      violations: violations,
      peakHour: '6:00 PM - 7:00 PM',
      sourceDistribution: distribution,
      aiSummary: summaryText,
    );
  }

  List<DeviceModel> getDevices() {
    return [
      DeviceModel(
        deviceId: 'NG-DEMO-001',
        name: 'ESP32 - SG Highway',
        status: 'online',
        batteryLevel: 87.0,
        firmwareVersion: '2.1.3',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
        latitude: 23.0301,
        longitude: 72.5274,
        assignedArea: 'SG Highway',
        areaType: AreaType.commercial,
      ),
      DeviceModel(
        deviceId: 'NG-DEMO-002',
        name: 'ESP32 - Maninagar',
        status: 'online',
        batteryLevel: 92.0,
        firmwareVersion: '2.1.3',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        latitude: 23.0005,
        longitude: 72.6007,
        assignedArea: 'Maninagar',
        areaType: AreaType.residential,
      ),
      DeviceModel(
        deviceId: 'NG-DEMO-003',
        name: 'ESP32 - Satellite',
        status: 'offline',
        batteryLevel: 12.0,
        firmwareVersion: '2.0.8',
        lastSeen: DateTime.now().subtract(const Duration(hours: 3)),
        latitude: 23.0172,
        longitude: 72.5271,
        assignedArea: 'Satellite',
        areaType: AreaType.commercial,
      ),
    ];
  }
}
