import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noiseguard/models/noise_record.dart';
import 'package:noiseguard/models/alert.dart';
import 'package:noiseguard/models/device.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Listen directly to in-place live telemetry document (100% immune to sorting & legacy doc bugs)
  Stream<List<NoiseRecord>> getNoiseStream(String deviceId) {
    return _db.collection('noise_records')
        .doc(deviceId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return [];
          }
          final data = Map<String, dynamic>.from(snapshot.data()!);
          data['id'] = snapshot.id;
          return [NoiseRecord.fromJson(data)];
        });
  }

  Future<void> addNoiseRecord(NoiseRecord record) async {
    await _db.collection('noise_records').doc(record.id).set(record.toJson());
  }

  Stream<List<AlertModel>> getAlerts(String deviceId) {
    return _db.collection('alerts')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) {
            final data = doc.data();
            data['alertId'] = doc.id;
            return AlertModel.fromJson(data);
          }).toList();

          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Future<void> addAlert(AlertModel alert) async {
    await _db.collection('alerts').doc(alert.alertId).set(alert.toJson());
  }

  Future<void> resolveAlert(String alertId) async {
    await _db.collection('alerts').doc(alertId).update({'resolved': true});
  }

  Stream<List<DeviceModel>> getDevices() {
    return _db.collection('devices')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['deviceId'] = doc.id;
            return DeviceModel.fromJson(data);
          }).toList();
        });
  }

  Future<void> updateDevice(DeviceModel device) async {
    await _db.collection('devices').doc(device.deviceId).set(device.toJson());
  }

  Future<List<NoiseRecord>> getHistoricalData(String deviceId, DateTime from, DateTime to) async {
    final query = await _db.collection('noise_records').get();

    final records = query.docs.map((doc) {
      final data = doc.data();
      if (!data.containsKey('id') || data['id'] == null || data['id'].toString().isEmpty) {
        data['id'] = doc.id;
      }
      return NoiseRecord.fromJson(data);
    }).toList();

    records.sort((a, b) => b.sequenceId.compareTo(a.sequenceId));
    return records;
  }
}
