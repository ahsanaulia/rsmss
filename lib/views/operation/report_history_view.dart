import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ReportHistoryView extends StatefulWidget {
  const ReportHistoryView({super.key});

  @override
  State<ReportHistoryView> createState() => _ReportHistoryViewState();
}

class _ReportHistoryViewState extends State<ReportHistoryView> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text("REPORT HISTORY", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: userId == null 
        ? const Center(child: Text("Sesi berakhir, silakan login ulang"))
        : StreamBuilder<List<Map<String, dynamic>>>(
            // Stream mengambil laporan terbaru berdasarkan reporter_id
            stream: supabase
                .from('tasks_reports')
                .stream(primaryKey: ['id'])
                .eq('reporter_id', userId)
                .order('created_at'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final reports = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return _buildReportCard(reports[index]);
                },
              );
            },
          ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final urgency = report['urgency_level'] ?? 'normal';
    Color urgencyColor = urgency == 'urgent' || urgency == 'emergency' 
        ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Urgency & Waktu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgency.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: urgencyColor
                  ),
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(report['created_at'])),
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20),

          // Detail Task & Jenis Tugas (Mengambil data dari tabel tasks & ref_task_types)
          _buildTaskAndTypeInfo(report['task_id']),

          const SizedBox(height: 10),
          
          // Deskripsi Laporan
          Text(
            "Laporan:",
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(
            report['description'] ?? "-",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
          
          const SizedBox(height: 12),

          // Lokasi Laporan (At Room)
          _buildLocationInfo(report['at_room_id']),
        ],
      ),
    );
  }

  // Mengambil informasi Task Name dan Task Type Name secara join manual
  Widget _buildTaskAndTypeInfo(String taskId) {
    return FutureBuilder(
      future: supabase
          .from('tasks')
          .select('object_name, ref_task_types(task_type_name)')
          .eq('id', taskId)
          .single(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 20);
        
        final data = snapshot.data as Map<String, dynamic>;
        final taskName = data['object_name'] ?? "Unknown Task";
        final typeName = data['ref_task_types']?['task_type_name'] ?? "General";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              "Jenis Tugas: $typeName",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
    );
  }

  // Mengambil informasi nama ruangan berdasarkan at_room_id
  Widget _buildLocationInfo(String? roomId) {
    if (roomId == null) return const SizedBox();

    return FutureBuilder(
      future: supabase.from('rooms').select('room_name').eq('id', roomId).maybeSingle(),
      builder: (context, snapshot) {
        String roomName = snapshot.hasData ? snapshot.data!['room_name'] : "...";
        
        return Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
            const SizedBox(width: 5),
            Text(
              "Dilaporkan di: $roomName",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
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
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "Belum ada riwayat laporan.",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}