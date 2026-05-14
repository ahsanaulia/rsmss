import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';

class AttendanceHistoryTab extends StatefulWidget {
  final String userId;
  const AttendanceHistoryTab({super.key, required this.userId});

  @override
  State<AttendanceHistoryTab> createState() => _AttendanceHistoryTabState();
}

class _AttendanceHistoryTabState extends State<AttendanceHistoryTab> {
  final ReportService _service = ReportService();
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAttendanceHistory(widget.userId);
      setState(() {
        _attendances = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present': return 'Hadir';
      case 'late': return 'Terlambat';
      case 'absent': return 'Absen';
      case 'excused': return 'Izin';
      default: return status;
    }
  }

  Color _getFatigueColor(double? score) {
    if (score == null) return Colors.grey;
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    if (score <= 8) return Colors.deepOrange;
    return Colors.red;
  }

  String _getFatigueLabel(double? score) {
    if (score == null) return 'Tidak ada';
    if (score <= 3) return 'Rendah';
    if (score <= 6) return 'Sedang';
    if (score <= 8) return 'Tinggi';
    return 'Kritis';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attendances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Belum ada riwayat kehadiran",
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendances.length,
      itemBuilder: (context, index) {
        final attendance = _attendances[index];
        final shift = attendance['ref_shifts'] as Map<String, dynamic>?;
        final roster = attendance['employee_shift_rosters'] as Map<String, dynamic>?;
        final checkIn = attendance['check_in'] != null
            ? DateTime.parse(attendance['check_in'])
            : null;
        final checkOut = attendance['check_out'] != null
            ? DateTime.parse(attendance['check_out'])
            : null;
        final fatigueScore = roster != null
            ? (roster['predicted_fatigue_score'] as num?)?.toDouble()
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
                // Tanggal dan Status
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: checkOut != null ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(checkIn).split(' ')[0],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(attendance['status'] ?? 'present'),
                        style: GoogleFonts.poppins(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Shift Info
                if (shift != null)
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        shift['shift_name'] ?? '-',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shift['start_time'] != null && shift['end_time'] != null
                            ? '(${shift['start_time']} - ${shift['end_time']})'
                            : '',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),

                // Check-in / Check-out
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.login_rounded, size: 14, color: Colors.blue.shade600),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(checkIn).split(' ')[1],
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 14, color: Colors.orange.shade600),
                          const SizedBox(width: 4),
                          Text(
                            checkOut != null ? _formatDateTime(checkOut).split(' ')[1] : '-',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fatigue Score
                if (fatigueScore != null)
                  Row(
                    children: [
                      Icon(Icons.battery_alert, size: 14, color: _getFatigueColor(fatigueScore)),
                      const SizedBox(width: 4),
                      Text(
                        "Fatigue: ${_getFatigueLabel(fatigueScore)}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _getFatigueColor(fatigueScore),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          roster?['location_name'] ?? '-',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                // Overtime & Lateness
                if ((attendance['lateness_minutes'] ?? 0) > 0 ||
                    (attendance['overtime_minutes'] ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 12,
                      children: [
                        if ((attendance['lateness_minutes'] ?? 0) > 0)
                          Text(
                            "Terlambat ${attendance['lateness_minutes']} menit",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.red.shade600,
                            ),
                          ),
                        if ((attendance['overtime_minutes'] ?? 0) > 0)
                          Text(
                            "Lembur ${attendance['overtime_minutes']} menit",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.green.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}