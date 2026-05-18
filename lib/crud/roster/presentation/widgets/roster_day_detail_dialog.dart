// lib/features/roster/presentation/widgets/roster_day_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';

class RosterDayDetailDialog extends StatelessWidget {
  final DateTime date;
  final List<RosterEntity> rosters;
  final List<ShiftEntity> shifts;
  final List<Map<String, dynamic>> employees;
  final Function(RosterEntity) onEditRoster;
  final Function(String) onDeleteRoster;

  const RosterDayDetailDialog({
    super.key,
    required this.date,
    required this.rosters,
    required this.shifts,
    required this.employees,
    required this.onEditRoster,
    required this.onDeleteRoster,
  });

  String getEmployeeName(String profileId) {
    final employee = employees.firstWhere(
      (e) => e['id'].toString() == profileId,
      orElse: () => {'full_name': 'Tidak diketahui', 'employee_id': '-'},
    );
    return employee['full_name'] ?? 'Tidak diketahui';
  }

  String getEmployeeId(String profileId) {
    final employee = employees.firstWhere(
      (e) => e['id'].toString() == profileId,
      orElse: () => {'employee_id': '-'},
    );
    return employee['employee_id']?.toString() ?? '-';
  }

  ShiftEntity getShift(String shiftId) {
    return shifts.firstWhere(
      (s) => s.id == shiftId,
      orElse: () => ShiftEntity(
        id: '',
        shiftName: 'Tidak diketahui',
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 0, minute: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan roster berdasarkan shift
    final Map<String, List<RosterEntity>> groupedByShift = {};
    for (final roster in rosters) {
      final shiftId = roster.shiftId;
      if (!groupedByShift.containsKey(shiftId)) {
        groupedByShift[shiftId] = [];
      }
      groupedByShift[shiftId]!.add(roster);
    }

    final bool hasData = rosters.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== HEADER ====================
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF01579B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF01579B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE', 'id').format(date),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy', 'id').format(date),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // ==================== STATISTIK ====================
            if (hasData) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${rosters.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                          Text(
                            'Total Pegawai',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${groupedByShift.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                          Text(
                            'Shift',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ==================== DAFTAR PEGAWAI PER SHIFT (JIKA ADA DATA) ====================
            if (hasData)
              Expanded(
                child: ListView(
                  children: groupedByShift.entries.map((entry) {
                    final shiftId = entry.key;
                    final shiftRosters = entry.value;
                    final shift = getShift(shiftId);
                    return _buildShiftGroup(context, shift, shiftRosters);
                  }).toList(),
                ),
              ),

            // ==================== EMPTY STATE (JIKA TIDAK ADA DATA) ====================
            if (!hasData)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada jadwal',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada pegawai yang dijadwalkan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tombol tambah jadwal cepat
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog
                          // Trigger add new roster
                          // TODO: Panggil fungsi untuk tambah jadwal
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Jadwal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01579B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ==================== TOMBOL TUTUP ====================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasData ? const Color(0xFF01579B) : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasData ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftGroup(BuildContext context, ShiftEntity shift, List<RosterEntity> shiftRosters) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shift
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: shift.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: shift.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.shiftName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: shift.color,
                        ),
                      ),
                      Text(
                        shift.displayTime,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: shift.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${shiftRosters.length} pegawai',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: shift.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Pegawai
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shiftRosters.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final roster = shiftRosters[index];
              return _buildEmployeeRow(context, roster);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(BuildContext context, RosterEntity roster) {
    final employeeName = getEmployeeName(roster.profileId);
    final employeeId = getEmployeeId(roster.profileId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: roster.statusColor.withOpacity(0.2),
            child: Text(
              employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: roster.statusColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info Pegawai
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: $employeeId',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roster.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              roster.displayStatus,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: roster.statusColor,
              ),
            ),
          ),

          // Action Buttons (Edit/Hapus)
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pop(context); // Tutup dialog
                onEditRoster(roster);
              } else if (value == 'delete') {
                Navigator.pop(context); // Tutup dialog
                _confirmDelete(context, roster);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Color(0xFF01579B)),
                    SizedBox(width: 8),
                    Text('Edit Jadwal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Jadwal'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RosterEntity roster) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Yakin ingin menghapus jadwal untuk ${getEmployeeName(roster.profileId)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteRoster(roster.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}