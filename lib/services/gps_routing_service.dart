// lib/services/gps_routing_service.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GpsRoutingService {
  static const String baseUrl = 'https://router.project-osrm.org';

  // Ambil rute jalan antara dua titik (return full polyline)
  Future<List<LatLng>> getRoute(LatLng from, LatLng to) async {
    final url = Uri.parse(
      '$baseUrl/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          if (geometry != null && geometry['coordinates'] != null) {
            return _decodeCoordinates(geometry['coordinates']);
          }
        }
      }
    } catch (e) {
      print('OSRM error: $e');
    }

    // Fallback: garis lurus jika routing gagal
    return [from, to];
  }

  // Hitung jarak real berdasarkan jalan (return dalam meter)
  Future<double> getRealDistance(LatLng from, LatLng to) async {
    final url = Uri.parse(
      '$baseUrl/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?overview=false',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'][0]['distance'] as num).toDouble();
        }
      }
    } catch (e) {
      print('OSRM distance error: $e');
    }

    // Fallback: haversine distance
    return _haversineDistance(from, to);
  }

  List<LatLng> _decodeCoordinates(List coordinates) {
    return coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  }

  double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371000;
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
}