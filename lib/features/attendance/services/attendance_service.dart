import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Cek apakah sudah ada attendance aktif (belum checkout)
  Future<ActiveAttendanceModel?> getActiveAttendance(String profileId) async {
    final response = await _supabase
        .from('attendance')
        .select()
        .eq('profile_id', profileId)
        .filter('check_out', 'is', null)  // ← Perbaikan: .is_ diganti .isNull
        .maybeSingle();

    if (response == null) return null;
    return ActiveAttendanceModel.fromJson(response);
  }

  /// Ambil daftar shift
  Future<List<ShiftModel>> getShifts() async {
    final response = await _supabase
        .from('ref_shifts')
        .select()
        .order('start_time', ascending: true);

    return List<ShiftModel>.from(response.map((x) => ShiftModel.fromJson(x)));
  }

  /// Ambil lokasi GPS dan alamat
  Future<LocationInfo> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String address = "Koordinat: ${position.latitude}, ${position.longitude}";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks[0];
        address = "${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}".trim();
        if (address.isEmpty || address == ",") {
          address = "Koordinat: ${position.latitude}, ${position.longitude}";
        }
      }
    } catch (_) {}

    return LocationInfo(position: position, address: address);
  }

  /// Ambil kamera depan
  Future<CameraDescription> getFrontCamera() async {
    final cameras = await availableCameras();
    return cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
  }

  /// Check-in
  Future<void> checkIn({
    required String profileId,
    required String shiftId,
    required DateTime checkInTime,
    required LocationInfo location,
    required String sessionId,
  }) async {
    await _supabase.from('attendance').insert({
      'profile_id': profileId,
      'shift_id': shiftId,
      'check_in': checkInTime.toIso8601String(),
      'lat': location.position.latitude,
      'long': location.position.longitude,
      'address_at_check_in': location.address,
      'status': 'present',
      'is_available': true,
      'is_tracking_active': true,
      'session_id': sessionId,
      'notes': 'Check In via Android',
    });
  }

  /// Check-out
  Future<void> checkOut({
    required String attendanceId,
    required DateTime checkOutTime,
  }) async {
    await _supabase.from('attendance').update({
      'check_out': checkOutTime.toIso8601String(),
      'is_available': false,
      'is_tracking_active': false,
    }).eq('id', attendanceId);
  }
}