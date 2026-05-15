import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _trackingTimer;
  bool _isTracking = false;
  String? _currentSessionId;
  String? _currentProfileId;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  bool get isTracking => _isTracking;

  void startTracking({
    required String profileId,
    required String sessionId,
    bool immediate = true,
  }) {
    if (_isTracking) {
      if (_currentSessionId != sessionId) {
        stopTracking();
      } else {
        return;
      }
    }

    _currentProfileId = profileId;
    _currentSessionId = sessionId;
    _isTracking = true;

    print("📍 START TRACKING: profile=$profileId, session=$sessionId");

    if (immediate) {
      _sendLocationUpdate();
    }

    _trackingTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) => _sendLocationUpdate(),
    );
  }

  void stopTracking() {
    if (!_isTracking) return;

    print("🛑 STOP TRACKING");
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _currentSessionId = null;
    _currentProfileId = null;
  }

  Future<void> _sendLocationUpdate() async {
    if (!_isTracking) return;
    if (_currentProfileId == null || _currentSessionId == null) return;

    try {
      final position = await _getCurrentPosition();
      if (position == null) return;

      final address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final deviceInfo = await _getDeviceInfo();

      await _supabase.from('employee_location_tracking').insert({
        'profile_id': _currentProfileId,
        'session_id': _currentSessionId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'altitude': position.altitude,
        'is_moving': position.speed > 0.5,
        'recorded_at': DateTime.now().toIso8601String(),
        'device_info': deviceInfo,
      });

      print("📍 LOCATION SENT: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error sending location: $e");
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks[0];
        return "${p.street != null ? '${p.street}, ' : ''}${p.subLocality != null ? '${p.subLocality}, ' : ''}${p.locality ?? ''}".trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'device_model': androidInfo.model,
        'os_version': androidInfo.version.release,
        'manufacturer': androidInfo.manufacturer,
        'app_version': '1.0.0',
      };
    } catch (e) {
      return {'device_model': 'Unknown', 'app_version': '1.0.0'};
    }
  }
}

final trackingService = TrackingService();