import 'package:noiseguard/core/constants/noise_thresholds.dart';

class DeviceModel {
  final String deviceId;
  final String name;
  final String status;
  final double batteryLevel;
  final String firmwareVersion;
  final DateTime lastSeen;
  final double latitude;
  final double longitude;
  final String? assignedArea;
  final AreaType areaType;

  DeviceModel({
    required this.deviceId,
    required this.name,
    required this.status,
    required this.batteryLevel,
    required this.firmwareVersion,
    required this.lastSeen,
    required this.latitude,
    required this.longitude,
    this.assignedArea,
    required this.areaType,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      batteryLevel: (json['batteryLevel'] as num).toDouble(),
      firmwareVersion: json['firmwareVersion'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      assignedArea: json['assignedArea'] as String?,
      areaType: AreaType.values.firstWhere(
        (e) => e.name == json['areaType'],
        orElse: () => AreaType.residential,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'name': name,
      'status': status,
      'batteryLevel': batteryLevel,
      'firmwareVersion': firmwareVersion,
      'lastSeen': lastSeen.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'assignedArea': assignedArea,
      'areaType': areaType.name,
    };
  }

  DeviceModel copyWith({
    String? deviceId,
    String? name,
    String? status,
    double? batteryLevel,
    String? firmwareVersion,
    DateTime? lastSeen,
    double? latitude,
    double? longitude,
    String? assignedArea,
    AreaType? areaType,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSeen: lastSeen ?? this.lastSeen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      assignedArea: assignedArea ?? this.assignedArea,
      areaType: areaType ?? this.areaType,
    );
  }
}
