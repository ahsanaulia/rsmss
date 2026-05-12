import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryView extends StatefulWidget {
  const AttendanceHistoryView({super.key});

  @override
  State<AttendanceHistoryView> createState() => _AttendanceHistoryViewState();
}

class _AttendanceHistoryViewState extends State<AttendanceHistoryView> {
  final supabase = Supabase.instance.client;

  // Menghitung durasi kerja dari check-in sampai check-out
  String _calculateWorkDuration(String checkInStr, String? checkOutStr) {
    if (checkOutStr == null) return "Masih Bertugas";
    
    DateTime start = DateTime.parse(checkInStr);
    DateTime end = DateTime.parse(checkOutStr);
    Duration diff = end.difference(start);
    
    return "${diff.inHours}j ${diff.inMinutes % 60}m";
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text("ATTENDANCE HISTORY", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: userId == null 
        ? const Center(child: Text("Sesi berakhir"))
        : StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('attendance')
                .stream(primaryKey: ['id'])
                .eq('profile_id', userId)
                .order('check_in'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final logs = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return _buildAttendanceCard(logs[index]);
                },
              );
            },
          ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> log) {
    final bool isOvertime = log['is_overtime'] ?? false;
    final String status = log['status'] ?? 'present';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Indikator Status (Samping)
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: status == 'present' ? Colors.green : Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, dd MMM yyyy').format(DateTime.parse(log['check_in'])),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (isOvertime)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text("Lembur", style: GoogleFonts.poppins(fontSize: 9, color: Colors.purple, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _timeColumn("Check In", log['check_in']),
                        _timeColumn("Check Out", log['check_out']),
                        _durationColumn("Durasi Kerja", _calculateWorkDuration(log['check_in'], log['check_out'])),
                      ],
                    ),
                    const Divider(height: 25),
                    
                    // Informasi Shift & Lokasi
                    _buildShiftAndLocation(log['shift_id'], log['location_check_in']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(String label, String? timeStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        Text(
          timeStr != null ? DateFormat('HH:mm').format(DateTime.parse(timeStr)) : "--:--",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _durationColumn(String label, String duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        Text(
          duration,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
        ),
      ],
    );
  }

  Widget _buildShiftAndLocation(String? shiftId, String? roomId) {
    return FutureBuilder(
      future: Future.wait([
        if (shiftId != null) supabase.from('ref_shifts').select('shift_name').eq('id', shiftId).maybeSingle(),
        if (roomId != null) supabase.from('rooms').select('room_name').eq('id', roomId).maybeSingle(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        String shiftName = "Umum";
        String roomName = "Luar Area";

        if (snapshot.hasData) {
          // Logic mapping data dari Future.wait
          if (shiftId != null && snapshot.data![0] != null) shiftName = snapshot.data![0]['shift_name'];
          if (roomId != null) {
             var roomData = shiftId != null ? snapshot.data![1] : snapshot.data![0];
             if (roomData != null) roomName = roomData['room_name'];
          }
        }

        return Row(
          children: [
            Icon(Icons.access_time_filled, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(shiftName, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
            const SizedBox(width: 15),
            Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Expanded(
              child: Text(roomName, 
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "Belum ada catatan kehadiran.",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}