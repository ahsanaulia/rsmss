// lib/models/gps_tracked_employee.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'gps_location_record.dart';

class GpsTrackedEmployee {
  final String profileId;
  final String fullName;
  final String? unitCode;
  final String? shiftName;
  final List<GpsLocationRecord> allRecords;     // 10 record asli
  final List<GpsLocationRecord> sampledPoints;  // 3 titik sample (start, middle, end)
  final List<LatLng> pathLine;                  // Garis hasil road routing (full polyline)
  final Color markerColor;
  final DateTime lastUpdated;

  GpsTrackedEmployee({
    required this.profileId,
    required this.fullName,
    this.unitCode,
    this.shiftName,
    required this.allRecords,
    required this.sampledPoints,
    required this.pathLine,
    required this.markerColor,
    required this.lastUpdated,
  });

  // Titik start (terlama)
  GpsLocationRecord? get startPoint =>
      sampledPoints.isNotEmpty ? sampledPoints.first : null;

  // Titik middle (tengah)
  GpsLocationRecord? get middlePoint =>
      sampledPoints.length >= 2 ? sampledPoints[1] : null;

  // Titik end (terbaru)
  GpsLocationRecord? get endPoint =>
      sampledPoints.isNotEmpty ? sampledPoints.last : null;

  // Apakah masih aktif (record terbaru < 30 menit yang lalu)
  bool get isActive {
    if (allRecords.isEmpty) return false;
    final lastRecord = allRecords.last;
    return DateTime.now().difference(lastRecord.recordedAt).inMinutes < 30;
  }

  // Status online/offline
  String get status => isActive ? 'ONLINE' : 'OFFLINE';
  
  Color get statusColor => isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280);

  // Jumlah total titik yang berhasil di-routing (untuk validasi)
  int get routedPointsCount => pathLine.length;

  // Apakah routing berhasil (pathLine tidak kosong)
  bool get hasValidRoute => pathLine.length >= 2;

  // Total jarak berdasarkan road routing (dalam meter)
  Future<double> getTotalDistanceInMeters() async {
    // Ini akan dihitung di service, bukan di model
    // Model hanya menyimpan data, perhitungan dilakukan di service
    return 0;
  }

  @override
  String toString() {
    return 'GpsTrackedEmployee(name: $fullName, points: ${sampledPoints.length}, routed: ${pathLine.length})';
  }
}

// Data untuk waypoint di detail sheet
class GpsWaypoint {
  final int index;
  final LatLng position;
  final DateTime timestamp;
  final double? distanceFromPrev;   // meter
  final int? durationFromPrev;      // menit
  final String? locationHint;

  GpsWaypoint({
    required this.index,
    required this.position,
    required this.timestamp,
    this.distanceFromPrev,
    this.durationFromPrev,
    this.locationHint,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get formattedDistance {
    if (distanceFromPrev == null) return '-';
    if (distanceFromPrev! >= 1000) {
      return '${(distanceFromPrev! / 1000).toStringAsFixed(2)} km';
    }
    return '${distanceFromPrev!.toInt()} m';
  }

  String get formattedDuration {
    if (durationFromPrev == null) return '-';
    if (durationFromPrev! >= 60) {
      final hours = durationFromPrev! ~/ 60;
      final minutes = durationFromPrev! % 60;
      return '$hours jam $minutes menit';
    }
    return '$durationFromPrev menit';
  }

  @override
  String toString() {
    return 'GpsWaypoint($index: $formattedTime, distance: $formattedDistance)';
  }
}

// Data ringkasan tracking
class GpsTrackingSummary {
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final double avgSpeedKph;
  final DateTime startTime;
  final DateTime endTime;

  GpsTrackingSummary({
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.avgSpeedKph,
    required this.startTime,
    required this.endTime,
  });

  String get formattedTotalDistance {
    if (totalDistanceKm >= 1) {
      return '${totalDistanceKm.toStringAsFixed(1)} km';
    }
    return '${(totalDistanceKm * 1000).toInt()} m';
  }

  String get formattedTotalDuration {
    if (totalDurationMinutes >= 60) {
      final hours = totalDurationMinutes ~/ 60;
      final minutes = totalDurationMinutes % 60;
      if (minutes == 0) return '$hours jam';
      return '$hours jam $minutes menit';
    }
    return '$totalDurationMinutes menit';
  }

  String get formattedAvgSpeed {
    return '${avgSpeedKph.toStringAsFixed(1)} km/jam';
  }

  String get formattedTimeRange {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - '
           '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}