// lib/providers/gps_tracking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gps_tracking_service.dart';
import '../services/gps_routing_service.dart';
import '../models/gps_location_record.dart';
import '../models/gps_tracked_employee.dart';
import 'package:latlong2/latlong.dart';

final gpsTrackingServiceProvider = Provider<GpsTrackingService>((ref) {
  return GpsTrackingService();
});

final gpsRoutingServiceProvider = Provider<GpsRoutingService>((ref) {
  return GpsRoutingService();
});

// Provider untuk daftar pegawai
final gpsEmployeesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(gpsTrackingServiceProvider);
  return await service.getEmployees();
});

// Provider untuk status loading routing
final gpsRoutingLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk tracking data per pegawai
final gpsTrackingDataProvider = FutureProvider.family
    .autoDispose<List<GpsLocationRecord>, ({String profileId, DateTime date})>(
  (ref, params) async {
    final service = ref.read(gpsTrackingServiceProvider);
    return await service.getLast10Locations(params.profileId, params.date);
  },
);

class GpsTrackingNotifier extends StateNotifier<List<GpsTrackedEmployee>> {
  GpsTrackingNotifier() : super([]);

  final GpsTrackingService _service = GpsTrackingService();
  final GpsRoutingService _routingService = GpsRoutingService();

  Future<void> loadTrackingData({
    required List<String> profileIds,
    required DateTime date,
    required Function(double) onProgress,
  }) async {
    final List<GpsTrackedEmployee> trackedEmployees = [];
    final maxEmployees = profileIds.length > 3 ? 3 : profileIds.length;

    for (int i = 0; i < maxEmployees; i++) {
      final profileId = profileIds[i];
      onProgress((i + 1) / maxEmployees);
      
      final records = await _service.getLast10Locations(profileId, date);
      if (records.isEmpty) continue;

      // Sample 3 titik (start, middle, end)
      final sampledPoints = _service.sample3Points(records);
      if (sampledPoints.length < 2) {
        // Jika kurang dari 2 titik, tetap tampilkan tapi tanpa polyline
        trackedEmployees.add(
          GpsTrackedEmployee(
            profileId: profileId,
            fullName: records.first.fullName,
            unitCode: records.first.unitCode,
            allRecords: records,
            sampledPoints: sampledPoints,
            pathLine: [],
            markerColor: _service.generateRandomColor(i),
            lastUpdated: DateTime.now(),
          ),
        );
        continue;
      }

      // Bangun path dengan road routing untuk 2 segment
      final List<LatLng> fullPath = [];
      
      try {
        // Segment 1: start → middle
        final segment1 = await _routingService.getRoute(
          sampledPoints[0].latLng,
          sampledPoints[1].latLng,
        );
        fullPath.addAll(segment1);
        
        // Segment 2: middle → end
        final segment2 = await _routingService.getRoute(
          sampledPoints[1].latLng,
          sampledPoints[2].latLng,
        );
        fullPath.addAll(segment2);
        
        // Hapus duplikasi titik sambung
        final uniquePath = <LatLng>[];
        for (final point in fullPath) {
          if (uniquePath.isEmpty || uniquePath.last.latitude != point.latitude || uniquePath.last.longitude != point.longitude) {
            uniquePath.add(point);
          }
        }
        
        trackedEmployees.add(
          GpsTrackedEmployee(
            profileId: profileId,
            fullName: records.first.fullName,
            unitCode: records.first.unitCode,
            allRecords: records,
            sampledPoints: sampledPoints,
            pathLine: uniquePath,
            markerColor: _service.generateRandomColor(i),
            lastUpdated: DateTime.now(),
          ),
        );
      } catch (e) {
        // Fallback ke garis lurus jika routing gagal
        trackedEmployees.add(
          GpsTrackedEmployee(
            profileId: profileId,
            fullName: records.first.fullName,
            unitCode: records.first.unitCode,
            allRecords: records,
            sampledPoints: sampledPoints,
            pathLine: _service.buildPathFromSamples(sampledPoints),
            markerColor: _service.generateRandomColor(i),
            lastUpdated: DateTime.now(),
          ),
        );
      }
    }

    state = trackedEmployees;
  }

  void clear() {
    state = [];
  }
}

final gpsTrackingProvider =
    StateNotifierProvider<GpsTrackingNotifier, List<GpsTrackedEmployee>>(
  (ref) => GpsTrackingNotifier(),
);