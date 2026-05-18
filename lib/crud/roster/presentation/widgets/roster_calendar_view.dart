// lib/features/roster/presentation/widgets/roster_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';
import 'roster_day_detail_dialog.dart';

class RosterCalendarView extends StatelessWidget {
  final List<RosterEntity> rosters;
  final List<ShiftEntity> shifts;
  final List<Map<String, dynamic>> employees;
  final DateTime currentMonth;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;
  final Function(RosterEntity) onEditRoster;
  final Function(String) onDeleteRoster;

  const RosterCalendarView({
    super.key,
    required this.rosters,
    required this.shifts,
    required this.employees,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onEditRoster,
    required this.onDeleteRoster,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(currentMonth);
    final firstDayOffset = _getFirstDayOffset(currentMonth);

    return Column(
      children: [
        _buildWeekdayHeader(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.35,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayOffset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return _buildEmptyDay();
              }
              final date = DateTime(
                currentMonth.year,
                currentMonth.month,
                dayNumber,
              );
              final dayRosters = rosters
                  .where(
                    (r) =>
                        r.rosterDate.year == date.year &&
                        r.rosterDate.month == date.month &&
                        r.rosterDate.day == date.day,
                  )
                  .toList();
              return _buildDayCard(context, date, dayRosters);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = [
      {'name': 'SEN', 'color': Colors.black87},
      {'name': 'SEL', 'color': Colors.black87},
      {'name': 'RAB', 'color': Colors.black87},
      {'name': 'KAM', 'color': Colors.black87},
      {'name': 'JUM', 'color': Colors.green.shade700},
      {'name': 'SAB', 'color': Colors.orange.shade700},
      {'name': 'MING', 'color': Colors.red.shade700},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        border: const Border(bottom: BorderSide(color: Color(0xFFE8ECF0))),
      ),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Text(
                  day['name'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: day['color'] as Color,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DateTime date,
    List<RosterEntity> dayRosters,
  ) {
    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final isSaturday = date.weekday == 6;
    final isSunday = date.weekday == 7;
    final bool hasRosters = dayRosters.isNotEmpty;

    // Tentukan warna background berdasarkan hari dan ketersediaan jadwal
    Color getBackgroundColor() {
      if (isToday) return const Color(0xFFE3F2FD); // Biru sangat muda
      if (isSunday) return const Color(0xFFFFF3E0); // Cream untuk Minggu
      if (isSaturday) return const Color(0xFFF5F5F5); // Abu-abu muda untuk Sabtu
      if (!hasRosters) return const Color(0xFFFFF1F0); // Merah muda untuk kosong
      return Colors.white;
    }

    Color getBorderColor() {
      if (isToday) return const Color(0xFF01579B);
      if (isSunday) return Colors.orange.shade200;
      if (isSaturday) return Colors.grey.shade200;
      if (!hasRosters) return Colors.red.shade200;
      return Colors.grey.shade200;
    }

    // Kelompokkan roster berdasarkan shift
    final Map<String, List<RosterEntity>> groupedByShift = {};
    for (final roster in dayRosters) {
      final shiftId = roster.shiftId;
      if (!groupedByShift.containsKey(shiftId)) {
        groupedByShift[shiftId] = [];
      }
      groupedByShift[shiftId]!.add(roster);
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => RosterDayDetailDialog(
            date: date,
            rosters: dayRosters,
            shifts: shifts,
            employees: employees,
            onEditRoster: onEditRoster,
            onDeleteRoster: onDeleteRoster,
          ),
        );
        onDateSelected(date);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: getBorderColor(), width: isToday ? 2 : 1),
          boxShadow: [
            if (isToday)
              BoxShadow(
                color: const Color(0xFF01579B).withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tanggal - desain baru tanpa background hitam
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tanggal
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? const Color(0xFF01579B)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isToday ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // Badge jumlah pegawai
                  if (hasRosters)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF01579B).withOpacity(0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 10,
                            color: isToday
                                ? const Color(0xFF01579B)
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dayRosters.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? const Color(0xFF01579B)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Body - Tampilkan ringkasan per shift
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: groupedByShift.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule_sharp,
                              size: 18,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kosong',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: groupedByShift.entries.map((entry) {
                          final shiftId = entry.key;
                          final shiftRosters = entry.value;
                          final shift = shifts.firstWhere(
                            (s) => s.id == shiftId,
                            orElse: () => ShiftEntity(
                              id: '',
                              shiftName: 'Unknown',
                              startTime: const TimeOfDay(hour: 0, minute: 0),
                              endTime: const TimeOfDay(hour: 0, minute: 0),
                            ),
                          );
                          return _buildShiftSummary(shift, shiftRosters.length);
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftSummary(ShiftEntity shift, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: shift.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
              color: shift.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${_getShortShiftName(shift.shiftName)} • $count',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: shift.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk menyingkat nama shift
  String _getShortShiftName(String shiftName) {
    if (shiftName.toLowerCase().contains('pagi')) return 'Pagi';
    if (shiftName.toLowerCase().contains('siang')) return 'Siang';
    if (shiftName.toLowerCase().contains('malam')) return 'Malam';
    return shiftName.substring(0, 3);
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstDayOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday - 1;
  }
}