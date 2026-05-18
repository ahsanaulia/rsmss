// lib/features/roster/presentation/widgets/roster_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';

class RosterCard extends StatelessWidget {
  final RosterEntity roster;
  final List<ShiftEntity> shifts;
  final List<Map<String, dynamic>> employees;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool compact;

  const RosterCard({
    super.key,
    required this.roster,
    required this.shifts,
    required this.employees,
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
  });

  String _getEmployeeName(String? profileId) {
    if (profileId == null) return '-';
    final employee = employees.firstWhere(
      (e) => e['id'].toString() == profileId,
      orElse: () => {},
    );
    return employee['full_name'] ?? '-';
  }

  String _getShiftName(String shiftId) {
    final shift = shifts.firstWhere(
      (s) => s.id == shiftId,
      orElse: () => ShiftEntity(
        id: '',
        shiftName: '-',
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 0, minute: 0),
      ),
    );
    return shift.shiftName;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: roster.statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 10,
              decoration: BoxDecoration(
                color: roster.priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _getShiftName(roster.shiftId),
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: roster.priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEmployeeName(roster.profileId),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  _getShiftName(roster.shiftId),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                if (roster.displayShiftTime.isNotEmpty)
                  Text(
                    roster.displayShiftTime,
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                  ),
                if (roster.isDayOff)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Libur',
                      style: GoogleFonts.poppins(fontSize: 9, color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roster.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roster.displayStatus,
                  style: GoogleFonts.poppins(fontSize: 9, color: roster.statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF01579B)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}