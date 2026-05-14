import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';

class IncidentHistoryTab extends StatefulWidget {
  final String userId;
  const IncidentHistoryTab({super.key, required this.userId});

  @override
  State<IncidentHistoryTab> createState() => _IncidentHistoryTabState();
}

class _IncidentHistoryTabState extends State<IncidentHistoryTab> {
  final ReportService _service = ReportService();
  List<Map<String, dynamic>> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getIncidentHistory(widget.userId);
      setState(() {
        _incidents = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'LOW': return Colors.green;
      case 'MEDIUM': return Colors.orange;
      case 'HIGH': return Colors.deepOrange;
      case 'CRITICAL': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'reported': return 'Dilaporkan';
      case 'investigating': return 'Diselidiki';
      case 'resolved': return 'Selesai';
      case 'closed': return 'Ditutup';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Belum ada laporan insiden",
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _incidents.length,
      itemBuilder: (context, index) {
        final incident = _incidents[index];
        final category = incident['ref_incident_categories'] as Map<String, dynamic>?;
        final room = incident['rooms'] as Map<String, dynamic>?;
        final severity = incident['severity'] ?? 'MEDIUM';
        final status = incident['status'] ?? 'reported';
        final occurredAt = incident['occurred_at'] != null
            ? DateTime.parse(incident['occurred_at'])
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(severity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incident['title'] ?? 'Tanpa Judul',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(severity).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        severity,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getSeverityColor(severity),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (category != null)
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        category['name'] ?? '-',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  incident['description'] ?? '',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (room != null)
                      Row(
                        children: [
                          Icon(Icons.room, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            room['room_name'] ?? '-',
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  occurredAt != null
                      ? '${occurredAt.day}/${occurredAt.month}/${occurredAt.year} ${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}'
                      : '-',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}