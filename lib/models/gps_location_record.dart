// lib/models/gps_location_record.dart

import 'package:latlong2/latlong.dart';

class GpsLocationRecord {
  final String id;
  final String profileId;
  final String fullName;
  final String? unitCode;
  final String? shiftName;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final DateTime recordedAt;
  final String? currentSituation;
  final String? currentAssignment;

  GpsLocationRecord({
    required this.id,
    required this.profileId,
    required this.fullName,
    this.unitCode,
    this.shiftName,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    required this.recordedAt,
    this.currentSituation,
    this.currentAssignment,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory GpsLocationRecord.fromJson(Map<String, dynamic> json) {
    return GpsLocationRecord(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? 'Unknown',
      unitCode: json['unit_code'] ?? json['unitCode'],
      shiftName: json['shift_name'] ?? json['shiftName'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      speed: json['speed']?.toDouble(),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.now(),
      currentSituation: json['current_situation'],
      currentAssignment: json['current_assignment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'full_name': fullName,
      'unit_code': unitCode,
      'shift_name': shiftName,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'recorded_at': recordedAt.toIso8601String(),
      'current_situation': currentSituation,
      'current_assignment': currentAssignment,
    };
  }

  // Format waktu untuk display
  String get formattedTime {
    return '${recordedAt.hour.toString().padLeft(2, '0')}:${recordedAt.minute.toString().padLeft(2, '0')}';
  }

  // Format tanggal untuk display
  String get formattedDate {
    return '${recordedAt.day}/${recordedAt.month}/${recordedAt.year}';
  }

  @override
  String toString() {
    return 'GpsLocationRecord(profileId: $profileId, lat: $latitude, lng: $longitude, time: $formattedTime)';
  }
}