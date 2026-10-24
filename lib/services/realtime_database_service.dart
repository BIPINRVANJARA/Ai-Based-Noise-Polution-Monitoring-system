import 'package:firebase_database/firebase_database.dart';
import 'package:noiseguard/models/noise_record.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Real-time Database stream for instant sub-10ms decibel updates
  Stream<NoiseRecord?> getLiveNoiseStream(String deviceId) {
    return _db.ref('telemetry/$deviceId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) {
        return null;
      }
      final map = Map<String, dynamic>.from(data);
      if (!map.containsKey('id')) {
        map['id'] = 'rt_${DateTime.now().millisecondsSinceEpoch}';
      }
      return NoiseRecord.fromJson(map);
    });
  }

  // Push telemetry payload to Realtime Database
  Future<void> updateTelemetry(NoiseRecord record) async {
    await _db.ref('telemetry/${record.deviceId}').set(record.toJson());
  }
}
