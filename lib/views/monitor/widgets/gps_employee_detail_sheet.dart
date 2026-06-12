// lib/views/monitor/widgets/gps_employee_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/gps_tracked_employee.dart';
import '../../../models/gps_location_record.dart';
import '../../../services/gps_tracking_service.dart';
import '../../../services/gps_routing_service.dart';

class GpsEmployeeDetailSheet extends StatefulWidget {
  final GpsTrackedEmployee employee;

  const GpsEmployeeDetailSheet({super.key, required this.employee});

  @override
  State<GpsEmployeeDetailSheet> createState() => _GpsEmployeeDetailSheetState();
}

class _GpsEmployeeDetailSheetState extends State<GpsEmployeeDetailSheet> {
  late Future<Map<String, dynamic>> _summaryFuture;
  late Future<List<Map<String, dynamic>>> _segmentDetailsFuture;
  final GpsRoutingService _routingService = GpsRoutingService();
  final GpsTrackingService _trackingService = GpsTrackingService();

  @override
  void initState() {
    super.initState();
    _summaryFuture = _calculateSummary();
    _segmentDetailsFuture = _calculateSegmentDetails();
  }

  Future<Map<String, dynamic>> _calculateSummary() async {
    final points = widget.employee.sampledPoints;
    if (points.length < 2) {
      return {
        'totalDistanceKm': 0.0,
        'totalDurationMinutes': 0,
        'avgSpeedKph': 0.0,
        'startTime': points.isNotEmpty ? points.first.recordedAt : DateTime.now(),
        'endTime': points.isNotEmpty ? points.last.recordedAt : DateTime.now(),
      };
    }

    double totalDistanceMeters = 0;
    
    // Hitung jarak segment 1 (start → middle)
    if (points.length >= 2) {
      final dist1 = await _routingService.getRealDistance(
        points[0].latLng,
        points[1].latLng,
      );
      totalDistanceMeters += dist1;
    }
    
    // Hitung jarak segment 2 (middle → end)
    if (points.length >= 3) {
      final dist2 = await _routingService.getRealDistance(
        points[1].latLng,
        points[2].latLng,
      );
      totalDistanceMeters += dist2;
    }

    final totalDurationMinutes = points.last.recordedAt.difference(points.first.recordedAt).inMinutes;
    final totalDistanceKm = totalDistanceMeters / 1000;
    final avgSpeedKph = totalDurationMinutes > 0 
        ? (totalDistanceKm / (totalDurationMinutes / 60)) 
        : 0.0;

    return {
      'totalDistanceKm': totalDistanceKm,
      'totalDistanceMeters': totalDistanceMeters,
      'totalDurationMinutes': totalDurationMinutes,
      'avgSpeedKph': avgSpeedKph,
      'startTime': points.first.recordedAt,
      'endTime': points.last.recordedAt,
    };
  }

  Future<List<Map<String, dynamic>>> _calculateSegmentDetails() async {
    final points = widget.employee.sampledPoints;
    final List<Map<String, dynamic>> segments = [];
    
    for (int i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      
      final distance = await _routingService.getRealDistance(from.latLng, to.latLng);
      final duration = to.recordedAt.difference(from.recordedAt).inMinutes;
      final speed = duration > 0 ? (distance / 1000) / (duration / 60) : 0.0;
      
      segments.add({
        'segment': i + 1,
        'from': from,
        'to': to,
        'distanceMeters': distance,
        'durationMinutes': duration,
        'speedKph': speed,
      });
    }
    
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              const Divider(height: 0),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final summary = snapshot.data ?? {};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildSummaryStats(summary),
                          const SizedBox(height: 16),
                          _buildSegmentDetails(),
                          const SizedBox(height: 16),
                          _buildWaypointsList(),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.employee.markerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.person, color: widget.employee.markerColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.employee.fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (widget.employee.unitCode != null)
                      Text(
                        '${widget.employee.unitCode} • ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.employee.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.employee.status,
                        style: TextStyle(color: widget.employee.statusColor, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(Map<String, dynamic> summary) {
    return Row(
      children: [
        _buildStatCard(
          'Total Jarak',
          _formatDistance(summary['totalDistanceMeters'] ?? 0),
          Icons.route,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Waktu Tempuh',
          _formatDuration(summary['totalDurationMinutes'] ?? 0),
          Icons.timer,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Kecepatan',
          _formatSpeed(summary['avgSpeedKph'] ?? 0),
          Icons.speed,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentDetails() {
    return FutureBuilder(
      future: _segmentDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final segments = snapshot.data ?? [];
        if (segments.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Detail Per Segmen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...segments.map((segment) => _buildSegmentTile(segment)),
          ],
        );
      },
    );
  }

  Widget _buildSegmentTile(Map<String, dynamic> segment) {
    final from = segment['from'] as GpsLocationRecord;
    final to = segment['to'] as GpsLocationRecord;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: segment['segment'] == 1 ? Colors.green : widget.employee.markerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${segment['segment']}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${from.formattedTime} → ${to.formattedTime}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '📏 ${_formatDistance(segment['distanceMeters'])}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              Expanded(
                child: Text(
                  '⏱️ ${_formatDuration(segment['durationMinutes'])}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              Expanded(
                child: Text(
                  '⚡ ${_formatSpeed(segment['speedKph'])}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointsList() {
    final points = widget.employee.sampledPoints;
    if (points.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📍 Titik Lokasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: points.length,
          separatorBuilder: (_, __) => const Divider(height: 8),
          itemBuilder: (context, index) {
            final point = points[index];
            final isStart = index == 0;
            final isEnd = index == points.length - 1;
            return _buildWaypointTile(point, index + 1, isStart, isEnd);
          },
        ),
      ],
    );
  }

  Widget _buildWaypointTile(GpsLocationRecord point, int number, bool isStart, bool isEnd) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isStart ? Colors.green : (isEnd ? Colors.red : Colors.grey.shade200),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: (isStart || isEnd) ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${point.formattedTime} - ${point.formattedDate}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours jam';
      return '$hours jam $mins menit';
    }
    return '$minutes menit';
  }

  String _formatSpeed(double kph) {
    if (kph < 1) return '${(kph * 1000).toInt()} m/jam';
    return '${kph.toStringAsFixed(1)} km/jam';
  }
}