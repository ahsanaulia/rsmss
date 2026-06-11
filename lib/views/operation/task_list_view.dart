import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'task_detail_page.dart';
import '../../services/sound_notification_service.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final supabase = Supabase.instance.client;
  final SoundNotificationService _soundService = SoundNotificationService();
  Set<String> _previousTaskIds = {};

  String _formatDateTime(String? timestamp) {
    if (timestamp == null) return "-";
    try {
      DateTime dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(dt);
    } catch (e) {
      return timestamp;
    }
  }

  String _getStatusText(String status, AppLocalizations localizations) {
    switch (status.toLowerCase()) {
      case 'pending':
        return localizations.task_statusPending ?? "PENDING";
      case 'accepted':
        return localizations.task_statusAccepted ?? "ACCEPTED";
      case 'done':
        return localizations.task_statusDone ?? "DONE";
      default:
        return status.toUpperCase();
    }
  }

  Stream<List<Map<String, dynamic>>> _getTasksStream() {
    final userId = supabase.auth.currentUser?.id;

    return supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('assignee_id', userId ?? '')
        .asyncMap((data) async {
          var tasks = data
              .where((t) => t['status'].toString().toLowerCase() != 'done')
              .toList();
          if (tasks.isEmpty) return [];

          final Set<String> uniqueIds = {};
          for (var t in tasks) {
            if (t['from_room_id'] != null)
              uniqueIds.add(t['from_room_id'].toString());
            if (t['to_room_id'] != null)
              uniqueIds.add(t['to_room_id'].toString());
          }

          if (uniqueIds.isNotEmpty) {
            try {
              final roomsData = await supabase
                  .from('rooms')
                  .select('id, room_name')
                  .inFilter('id', uniqueIds.toList());

              if (roomsData != null) {
                final Map<String, String> roomMap = {
                  for (var r in roomsData)
                    r['id'].toString(): r['room_name'].toString(),
                };

                for (var i = 0; i < tasks.length; i++) {
                  tasks[i]['from_room_name'] =
                      roomMap[tasks[i]['from_room_id'].toString()] ??
                      'Lokasi A';
                  tasks[i]['to_room_name'] =
                      roomMap[tasks[i]['to_room_id'].toString()] ?? 'Lokasi B';
                }
              }
            } catch (e) {
              debugPrint("Error Fetch Rooms: $e");
            }
          }

          tasks.sort((a, b) {
            const sW = {'pending': 0, 'accepted': 1};
            const pW = {'emergency': 0, 'urgent': 1, 'normal': 2};
            int sComp = (sW[a['status'].toString().toLowerCase()] ?? 2)
                .compareTo(sW[b['status'].toString().toLowerCase()] ?? 2);
            if (sComp != 0) return sComp;
            return (pW[a['priority'].toString().toLowerCase()] ?? 3).compareTo(
              pW[b['priority'].toString().toLowerCase()] ?? 3,
            );
          });

          return tasks;
        });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Center(
                child: Text(
                  localizations?.task_title ?? "DAFTAR TUGAS",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF01579B),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF01579B)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "${localizations?.task_error ?? "Error: "}${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final tasks = snapshot.data ?? [];
                final currentTaskIds = tasks
                    .map((t) => t['id'].toString())
                    .toSet();
                final newTaskIds = currentTaskIds.difference(_previousTaskIds);

                for (final newId in newTaskIds) {
                  final newTask = tasks.firstWhere(
                    (t) => t['id'].toString() == newId,
                  );
                  final priority =
                      newTask['priority']?.toString().toLowerCase() ?? 'normal';

                  if (priority == 'urgent' || priority == 'emergency') {
                    _soundService.playNotificationSound(newId, type: 'task');
                  }
                }

                _previousTaskIds = currentTaskIds;
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      localizations?.task_empty ?? "Antrian Kosong 🚀",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 120),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) =>
                      _buildGlassTaskCard(tasks[index], localizations),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTaskCard(Map<String, dynamic> task, AppLocalizations? localizations) {
    final priority = task['priority']?.toString().toLowerCase() ?? 'normal';
    final status = task['status']?.toString().toLowerCase() ?? 'pending';
    final isActive = status == 'accepted';
    final createdAt = task['created_at']?.toString();
    final statusText = _getStatusText(status, localizations ?? 
        (throw Exception('Localizations null')));
    
    // Gunakan fallback jika localizations null
    final fromLabel = localizations?.task_from ?? "DARI";
    final toLabel = localizations?.task_to ?? "KE";
    final defaultFromRoom = localizations?.task_defaultFromRoom ?? "Lokasi A";
    final defaultToRoom = localizations?.task_defaultToRoom ?? "Lokasi B";
    final defaultTitle = localizations?.task_defaultTitle ?? "Task";

    Color pColor = priority == 'emergency'
        ? Colors.redAccent
        : (priority == 'urgent'
              ? Colors.orangeAccent
              : const Color(0xFF01579B));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isActive
                    ? pColor
                    : Colors.white.withValues(alpha: 0.3),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailPage(task: task),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _badge(
                            Icons.access_time,
                            _formatDateTime(createdAt),
                            Colors.black26,
                          ),
                          _badge(
                            isActive ? Icons.bolt : Icons.timer_outlined,
                            statusText,
                            pColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        task['object_name'] ?? defaultTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _locationRow(
                        Icons.radio_button_off,
                        fromLabel,
                        task['from_room_name'] ?? defaultFromRoom,
                      ),
                      const SizedBox(height: 8),
                      _locationRow(
                        Icons.location_on,
                        toLabel,
                        task['to_room_name'] ?? defaultToRoom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow(IconData icon, String label, String room) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF01579B).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(
            color: Colors.black45,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            room,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}