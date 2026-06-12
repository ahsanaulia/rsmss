// lib/services/gps_tracking_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../models/gps_location_record.dart';
import '../models/gps_tracked_employee.dart';

class GpsTrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil daftar pegawai (untuk dropdown)
  Future<List<Map<String, dynamic>>> getEmployees() async {
    final response = await _supabase
        .from('profiles')
        .select('id, full_name, employee_id, unit_code, role')
        .eq('is_active', true)
        .order('full_name');

    return response;
  }

  // Ambil 10 record terbaru untuk satu pegawai di tanggal tertentu
  Future<List<GpsLocationRecord>> getLast10Locations(
    String profileId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('employee_location_tracking')
        .select('''
          id,
          profile_id,
          latitude,
          longitude,
          accuracy,
          speed,
          recorded_at,
          profiles!employee_location_tracking_profile_id_fkey (
            full_name,
            unit_code
          )
        ''')
        .eq('profile_id', profileId)
        .gte('recorded_at', startOfDay.toIso8601String())
        .lt('recorded_at', endOfDay.toIso8601String())
        .order('recorded_at', ascending: false)
        .limit(10);

    return response.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      return GpsLocationRecord(
        id: json['id'].toString(),
        profileId: json['profile_id'].toString(),
        fullName: profile?['full_name'] ?? 'Unknown',
        unitCode: profile?['unit_code'],
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        accuracy: json['accuracy']?.toDouble(),
        speed: json['speed']?.toDouble(),
        recordedAt: DateTime.parse(json['recorded_at']),
      );
    }).toList();
  }

  // SAMPLING 3 TITIK (start, middle, end) dari 10 record
  List<GpsLocationRecord> sample3Points(List<GpsLocationRecord> records) {
    if (records.isEmpty) return [];
    if (records.length == 1) return records;
    if (records.length == 2) return records;
    if (records.length == 3) return records;

    // Urutkan dari terlama ke terbaru
    final sorted = records.reversed.toList();
    
    final start = sorted.first;      // titik terlama
    final end = sorted.last;         // titik terbaru
    final middle = sorted[sorted.length ~/ 2]; // titik tengah

    return [start, middle, end];
  }

  // Buat garis prediksi dari 3 titik sample (dengan routing)
  // Method ini hanya untuk fallback jika routing gagal
  List<LatLng> buildPathFromSamples(List<GpsLocationRecord> sampledPoints) {
    if (sampledPoints.length < 2) {
      return sampledPoints.map((p) => p.latLng).toList();
    }
    return sampledPoints.map((p) => p.latLng).toList();
  }

  // Hitung jarak antar dua titik (Haversine formula) - untuk fallback
  double haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371000; // Radius bumi dalam meter
    final dLat = (p2.latitude - p1.latitude) * (3.14159 / 180);
    final dLon = (p2.longitude - p1.longitude) * (3.14159 / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * (3.14159 / 180)) *
            cos(p2.latitude * (3.14159 / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Spread marker jika terlalu dekat
  LatLng spreadMarker(LatLng original, int index, double radiusInMeters) {
    const double metersPerDegreeLat = 111319.9;
    final double rad = (index * 0.5) * (radiusInMeters / metersPerDegreeLat);
    final double angle = index * 45 * (3.14159 / 180);
    return LatLng(
      original.latitude + rad * cos(angle),
      original.longitude + rad * sin(angle),
    );
  }

  // Generate warna random untuk marker (dengan brightness yang cukup)
  Color generateRandomColor(int index) {
    final hues = [
      0, 30, 60, 120, 180, 210, 240, 270, 300, 330,
      15, 45, 75, 135, 165, 195, 225, 255, 285, 315
    ];
    final hue = hues[index % hues.length];
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.7, 0.6).toColor();
  }
}