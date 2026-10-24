import 'package:cloud_firestore/cloud_firestore.dart';

class NoiseRecord {
  final String id;
  final double noiseLevel;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String source;
  final double confidence;
  final double threshold;
  final bool violation;
  final String deviceId;
  final String? address;
  final double? spectralCentroid;
  final double? spectralRolloff;
  final double? spectralFlatness;
  final double? lowBandEnergy;
  final double? midBandEnergy;
  final double? highBandEnergy;
  final double? zcr;
  final double? crestFactor;

  NoiseRecord({
    required this.id,
    required this.noiseLevel,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.confidence,
    required this.threshold,
    required this.violation,
    required this.deviceId,
    this.address,
    this.spectralCentroid,
    this.spectralRolloff,
    this.spectralFlatness,
    this.lowBandEnergy,
    this.midBandEnergy,
    this.highBandEnergy,
    this.zcr,
    this.crestFactor,
  });

  // Extract ESP32 boot millis or Epoch millis for 100% accurate chronological sorting
  int get sequenceId {
    final match = RegExp(r'rec_(\d+)').firstMatch(id);
    if (match != null) {
      final val = int.tryParse(match.group(1)!);
      if (val != null) return val;
    }
    return timestamp.millisecondsSinceEpoch;
  }

  factory NoiseRecord.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('fields') && json['fields'] is Map<String, dynamic>) {
      data = _flattenFirestoreRestFields(json['fields'] as Map<String, dynamic>);
    }

    final String rawId = (data['id'] ?? json['id'] ?? '').toString();

    DateTime parsedTimestamp = DateTime.now();
    final rawTimestamp = data['timestamp'];

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is String && rawTimestamp.isNotEmpty && rawTimestamp != 'null') {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      final match = RegExp(r'rec_(\d+)').firstMatch(rawId);
      if (match != null) {
        final millis = int.tryParse(match.group(1)!);
        if (millis != null && millis > 1600000000000) {
          parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(millis);
        }
      }
    }

    return NoiseRecord(
      id: rawId.isEmpty ? 'rec_${DateTime.now().millisecondsSinceEpoch}' : rawId,
      noiseLevel: _toDouble(data['noiseLevel']) ?? 0.0,
      timestamp: parsedTimestamp,
      latitude: _toDouble(data['latitude']) ?? 23.0301,
      longitude: _toDouble(data['longitude']) ?? 72.5274,
      source: (data['source'] ?? 'Ambient').toString(),
      confidence: _toDouble(data['confidence']) ?? 0.90,
      threshold: _toDouble(data['threshold']) ?? 65.0,
      violation: data['violation'] == true || data['violation'] == 'true',
      deviceId: (data['deviceId'] ?? 'NG-ESP32-001').toString(),
      address: data['address']?.toString(),
      spectralCentroid: _toDouble(data['spectralCentroid']),
      spectralRolloff: _toDouble(data['spectralRolloff']),
      spectralFlatness: _toDouble(data['spectralFlatness']),
      lowBandEnergy: _toDouble(data['lowBandEnergy']),
      midBandEnergy: _toDouble(data['midBandEnergy']),
      highBandEnergy: _toDouble(data['highBandEnergy']),
      zcr: _toDouble(data['zcr']),
      crestFactor: _toDouble(data['crestFactor']),
    );
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  static Map<String, dynamic> _flattenFirestoreRestFields(Map<String, dynamic> fields) {
    final Map<String, dynamic> flat = {};
    fields.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        if (val.containsKey('stringValue')) flat[key] = val['stringValue'];
        else if (val.containsKey('doubleValue')) flat[key] = val['doubleValue'];
        else if (val.containsKey('integerValue')) flat[key] = val['integerValue'];
        else if (val.containsKey('booleanValue')) flat[key] = val['booleanValue'];
        else if (val.containsKey('timestampValue')) flat[key] = val['timestampValue'];
      }
    });
    return flat;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noiseLevel': noiseLevel,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'source': source,
      'confidence': confidence,
      'threshold': threshold,
      'violation': violation,
      'deviceId': deviceId,
      'address': address,
      if (spectralCentroid != null) 'spectralCentroid': spectralCentroid,
      if (spectralRolloff != null) 'spectralRolloff': spectralRolloff,
      if (spectralFlatness != null) 'spectralFlatness': spectralFlatness,
      if (lowBandEnergy != null) 'lowBandEnergy': lowBandEnergy,
      if (midBandEnergy != null) 'midBandEnergy': midBandEnergy,
      if (highBandEnergy != null) 'highBandEnergy': highBandEnergy,
      if (zcr != null) 'zcr': zcr,
      if (crestFactor != null) 'crestFactor': crestFactor,
    };
  }

  NoiseRecord copyWith({
    String? id,
    double? noiseLevel,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? source,
    double? confidence,
    double? threshold,
    bool? violation,
    String? deviceId,
    String? address,
    double? spectralCentroid,
    double? spectralRolloff,
    double? spectralFlatness,
    double? lowBandEnergy,
    double? midBandEnergy,
    double? highBandEnergy,
    double? zcr,
    double? crestFactor,
  }) {
    return NoiseRecord(
      id: id ?? this.id,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      threshold: threshold ?? this.threshold,
      violation: violation ?? this.violation,
      deviceId: deviceId ?? this.deviceId,
      address: address ?? this.address,
      spectralCentroid: spectralCentroid ?? this.spectralCentroid,
      spectralRolloff: spectralRolloff ?? this.spectralRolloff,
      spectralFlatness: spectralFlatness ?? this.spectralFlatness,
      lowBandEnergy: lowBandEnergy ?? this.lowBandEnergy,
      midBandEnergy: midBandEnergy ?? this.midBandEnergy,
      highBandEnergy: highBandEnergy ?? this.highBandEnergy,
      zcr: zcr ?? this.zcr,
      crestFactor: crestFactor ?? this.crestFactor,
    );
  }
}
