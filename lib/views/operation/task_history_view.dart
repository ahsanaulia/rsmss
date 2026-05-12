import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TaskHistoryView extends StatefulWidget {
  const TaskHistoryView({super.key});

  @override
  State<TaskHistoryView> createState() => _TaskHistoryViewState();
}

class _TaskHistoryViewState extends State<TaskHistoryView> {
  final supabase = Supabase.instance.client;

  String _calculateDuration(String? start, String? end) {
    if (start == null || end == null) return "-";
    DateTime startTime = DateTime.parse(start);
    DateTime endTime = DateTime.parse(end);
    Duration diff = endTime.difference(startTime);
    
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} Menit";
    } else {
      return "${diff.inHours} Jam ${diff.inMinutes % 60} Menit";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text("TASK HISTORY", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: userId == null 
        ? const Center(child: Text("User tidak ditemukan"))
        : StreamBuilder<List<Map<String, dynamic>>>(
            // PERBAIKAN DI SINI: Filter eq dan order dimasukkan ke dalam method .stream()
            stream: supabase
                .from('tasks')
                .stream(primaryKey: ['id'])
                .eq('assignee_id', userId)
                .order('completed_at'), // Stream defaultnya Descending jika primary key atau col diatur
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // Filter status 'done' secara manual di aplikasi karena .stream() terbatas filternya
              final tasks = (snapshot.data ?? [])
                  .where((t) => t['status'] == 'done')
                  .toList();

              if (tasks.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _buildHistoryCard(tasks[index]);
                },
              );
            },
          ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> task) {
    final outcome = task['task_outcome'] ?? 'success';
    Color outcomeColor = outcome == 'success' ? Colors.green : Colors.red;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: outcomeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  outcome.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: outcomeColor
                  ),
                ),
              ),
              Text(
                task['completed_at'] != null 
                  ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(task['completed_at']))
                  : "-",
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            task['object_name'] ?? "No Name",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Colors.blue),
              const SizedBox(width: 5),
              Text(
                "Durasi: ${_calculateDuration(task['started_at'], task['completed_at'])}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Note: Menggunakan FutureBuilder untuk narik nama Kamar karena Stream tidak dukung Join
          _buildRoomInfo(task['from_room_id'], task['to_room_id']),
          
          if (task['completion_notes'] != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!)
              ),
              child: Text(
                "Notes: ${task['completion_notes']}",
                style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            )
          ]
        ],
      ),
    );
  }

  // Widget tambahan untuk ambil nama room
  Widget _buildRoomInfo(String fromId, String toId) {
    return FutureBuilder(
      future: Future.wait([
        supabase.from('rooms').select('room_name').eq('id', fromId).maybeSingle(),
        supabase.from('rooms').select('room_name').eq('id', toId).maybeSingle(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        String fromName = "Loading...";
        String toName = "Loading...";
        
        if (snapshot.hasData) {
          fromName = snapshot.data![0]?['room_name'] ?? "Unknown";
          toName = snapshot.data![1]?['room_name'] ?? "Unknown";
        }

        return Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.redAccent),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                "Dari: $fromName ke $toName", 
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
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
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "Belum ada riwayat pekerjaan.",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}