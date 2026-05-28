// lib/insights/profiles/models/shift_attendance_model.dart

class LateEmployeeShift {
  final String profileId;
  final String fullName;
  final String? avatarUrl;
  final String? unitCode;
  final int lateMinutes;
  final DateTime checkIn;
  final String? shiftName;

  LateEmployeeShift({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
    this.unitCode,
    required this.lateMinutes,
    required this.checkIn,
    this.shiftName,
  });
}

class OvershiftEmployee {
  final String profileId;
  final String fullName;
  final String? avatarUrl;
  final String? unitCode;
  final String taskId;
  final String taskName;
  final String taskStatus;
  final DateTime taskCreatedAt;
  final String expectedShiftName;
  final String actualShiftName;

  OvershiftEmployee({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
    this.unitCode,
    required this.taskId,
    required this.taskName,
    required this.taskStatus,
    required this.taskCreatedAt,
    required this.expectedShiftName,
    required this.actualShiftName,
  });

  String get durationSinceCreated {
    final diff = DateTime.now().difference(taskCreatedAt);
    if (diff.inHours > 0) return '${diff.inHours} jam ${diff.inMinutes % 60} menit';
    return '${diff.inMinutes} menit';
  }
}

class ShiftAttendanceSummary {
  final String shiftId;
  final String shiftName;
  final String shiftStart;
  final String shiftEnd;
  final int hadir;
  final int tidakHadir;
  final int terlambat;
  final int bertugas;
  final int cuti;
  final List<LateEmployeeShift> lateEmployees;
  final List<OvershiftEmployee> overshiftEmployees;

  ShiftAttendanceSummary({
    required this.shiftId,
    required this.shiftName,
    required this.shiftStart,
    required this.shiftEnd,
    required this.hadir,
    required this.tidakHadir,
    required this.terlambat,
    required this.bertugas,
    required this.cuti,
    required this.lateEmployees,
    required this.overshiftEmployees,
  });

  int get totalScheduled => hadir + tidakHadir + cuti;
  
  String get shiftIcon {
    if (shiftName.contains('Pagi')) return '🌅';
    if (shiftName.contains('Siang')) return '🌞';
    if (shiftName.contains('Malam')) return '🌙';
    return '🕒';
  }
}

class RecentCheckIn {
  final String profileId;
  final String fullName;
  final String? avatarUrl;
  final String? unitCode;
  final DateTime checkIn;
  final String? shiftName;
  final String? address;

  RecentCheckIn({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
    this.unitCode,
    required this.checkIn,
    this.shiftName,
    this.address,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(checkIn);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class AttendanceOverview {
  final List<ShiftAttendanceSummary> shifts;
  final List<RecentCheckIn> recentCheckIns;
  final Map<String, int> employeesBySituation;

  AttendanceOverview({
    required this.shifts,
    required this.recentCheckIns,
    required this.employeesBySituation,
  });
}