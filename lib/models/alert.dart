class AlertModel {
  final String alertId;
  final double noiseLevel;
  final Duration duration;
  final double latitude;
  final double longitude;
  final String source;
  final bool resolved;
  final DateTime createdAt;
  final String deviceId;
  final String? address;
  final double? confidence;
  final double? spectralCentroid;
  final double? spectralRolloff;
  final double? spectralFlatness;
  final double? lowBandEnergy;
  final double? midBandEnergy;
  final double? highBandEnergy;
  final double? zcr;
  final double? crestFactor;

  AlertModel({
    required this.alertId,
    required this.noiseLevel,
    required this.duration,
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.resolved,
    required this.createdAt,
    required this.deviceId,
    this.address,
    this.confidence,
    this.spectralCentroid,
    this.spectralRolloff,
    this.spectralFlatness,
    this.lowBandEnergy,
    this.midBandEnergy,
    this.highBandEnergy,
    this.zcr,
    this.crestFactor,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('fields') && json['fields'] is Map<String, dynamic>) {
      data = _flattenFirestoreRestFields(json['fields'] as Map<String, dynamic>);
    }

    final rawId = (data['alertId'] ?? data['id'] ?? json['alertId'] ?? json['id'] ?? '').toString();

    DateTime parsedCreatedAt = DateTime.now();
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    final durationSec = (data['durationSeconds'] ?? data['duration'] ?? 10) as num;

    return AlertModel(
      alertId: rawId.isEmpty ? 'alt_${DateTime.now().millisecondsSinceEpoch}' : rawId,
      noiseLevel: _toDouble(data['noiseLevel']) ?? 0.0,
      duration: Duration(seconds: durationSec.toInt()),
      latitude: _toDouble(data['latitude']) ?? 23.0301,
      longitude: _toDouble(data['longitude']) ?? 72.5274,
      source: (data['source'] ?? 'General Noise').toString(),
      resolved: data['resolved'] == true || data['resolved'] == 'true',
      createdAt: parsedCreatedAt,
      deviceId: (data['deviceId'] ?? 'NG-ESP32-001').toString(),
      address: data['address']?.toString(),
      confidence: _toDouble(data['confidence']),
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
      'alertId': alertId,
      'noiseLevel': noiseLevel,
      'durationSeconds': duration.inSeconds,
      'latitude': latitude,
      'longitude': longitude,
      'source': source,
      'resolved': resolved,
      'createdAt': createdAt.toIso8601String(),
      'deviceId': deviceId,
      'address': address,
      'confidence': confidence,
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

  AlertModel copyWith({
    String? alertId,
    double? noiseLevel,
    Duration? duration,
    double? latitude,
    double? longitude,
    String? source,
    bool? resolved,
    DateTime? createdAt,
    String? deviceId,
    String? address,
    double? confidence,
    double? spectralCentroid,
    double? spectralRolloff,
    double? spectralFlatness,
    double? lowBandEnergy,
    double? midBandEnergy,
    double? highBandEnergy,
    double? zcr,
    double? crestFactor,
  }) {
    return AlertModel(
      alertId: alertId ?? this.alertId,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      duration: duration ?? this.duration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      address: address ?? this.address,
      confidence: confidence ?? this.confidence,
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
