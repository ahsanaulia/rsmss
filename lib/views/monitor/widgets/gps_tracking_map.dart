// lib/views/monitor/widgets/gps_tracking_map.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/gps_tracked_employee.dart';
import '../../../services/gps_tracking_service.dart';

class GpsTrackingMap extends StatelessWidget {
  final List<GpsTrackedEmployee> trackedEmployees;
  final Function(GpsTrackedEmployee) onMarkerTap;

  const GpsTrackingMap({
    super.key,
    required this.trackedEmployees,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    // Debug print
    print('📊 TRACKED EMPLOYEES: ${trackedEmployees.length}');
    for (var emp in trackedEmployees) {
      print('  - ${emp.fullName}: ${emp.sampledPoints.length} titik, ${emp.pathLine.length} polyline');
    }

    // Kumpulkan semua titik untuk menentukan center map
    final allPoints = <LatLng>[];
    for (final employee in trackedEmployees) {
      for (final point in employee.sampledPoints) {
        allPoints.add(point.latLng);
      }
    }

    LatLng? center;
    double? zoom;

    if (allPoints.isNotEmpty) {
      double sumLat = 0, sumLng = 0;
      for (final point in allPoints) {
        sumLat += point.latitude;
        sumLng += point.longitude;
      }
      center = LatLng(sumLat / allPoints.length, sumLng / allPoints.length);
      zoom = 14.0;
    } else {
      center = const LatLng(-6.200000, 106.816666);
      zoom = 12.0;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rsmss.iot.rsmss',
          additionalOptions: const {
            'attribution': '© OpenStreetMap contributors',
          },
        ),
        // SATU PolylineLayer untuk SEMUA pegawai
        PolylineLayer(
          polylines: trackedEmployees
              .where((e) => e.pathLine.length >= 2)
              .map((employee) => Polyline(
                    points: employee.pathLine,
                    color: employee.markerColor,
                    strokeWidth: 4,
                  ))
              .toList(),
        ),
        // MarkerLayer untuk SEMUA marker
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    final Map<String, int> pointCount = {};
    final service = GpsTrackingService();

    print('🟢 Building markers for ${trackedEmployees.length} employees');

    for (final employee in trackedEmployees) {
      print('  - ${employee.fullName}: ${employee.sampledPoints.length} points');
      
      final sampledPoints = employee.sampledPoints;
      if (sampledPoints.isEmpty) continue;

      for (int i = 0; i < sampledPoints.length; i++) {
        final point = sampledPoints[i];
        final isStart = i == 0;
        final isEnd = i == sampledPoints.length - 1;

        final key = '${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}';
        final count = pointCount.putIfAbsent(key, () => 0);
        pointCount[key] = count + 1;

        LatLng position = point.latLng;
        if (count > 0) {
          position = service.spreadMarker(position, count, 5);
        }

        Color markerColor;
        IconData markerIcon;
        if (isStart) {
          markerColor = Colors.green;
          markerIcon = Icons.play_arrow;
        } else if (isEnd) {
          markerColor = Colors.red;
          markerIcon = Icons.stop;
        } else {
          markerColor = employee.markerColor;
          markerIcon = Icons.circle;
        }

        markers.add(
          Marker(
            width: 36,
            height: 36,
            point: position,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => onMarkerTap(employee),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: markerColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(markerIcon, color: Colors.white, size: 14),
                  ),
                  Positioned(
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getLabel(i, sampledPoints.length),
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    print('✅ Total markers: ${markers.length}');
    return markers;
  }

  String _getLabel(int index, int total) {
    if (index == 0) return 'START';
    if (index == total - 1) return 'END';
    return 'MID';
  }
}