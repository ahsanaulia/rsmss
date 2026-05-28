// lib/insights/profiles/models/profile_attendance_model.dart
class AttendanceModel {
  final String id;
  final String profileId;
  final String? shiftId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? locationCheckInId;
  final String status;
  final bool isOvertime;
  final bool isAvailable;
  final String? notes;
  final double? lat;
  final double? long;
  final String? addressAtCheckIn;
  final bool isTrackingActive;

  AttendanceModel({
    required this.id,
    required this.profileId,
    this.shiftId,
    required this.checkIn,
    this.checkOut,
    this.locationCheckInId,
    required this.status,
    required this.isOvertime,
    required this.isAvailable,
    this.notes,
    this.lat,
    this.long,
    this.addressAtCheckIn,
    required this.isTrackingActive,
  });

  bool get isPresent => checkOut == null;
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'].toString(),
      profileId: json['profile_id'].toString(),
      shiftId: json['shift_id']?.toString(),
      checkIn: json['check_in'] != null
          ? DateTime.parse(json['check_in'])
          : DateTime.now(),
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'])
          : null,
      locationCheckInId: json['location_check_in']?.toString(),
      status: json['status'] ?? 'present',
      isOvertime: json['is_overtime'] ?? false,
      isAvailable: json['is_available'] ?? true,
      notes: json['notes'],
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      addressAtCheckIn: json['address_at_check_in'],
      isTrackingActive: json['is_tracking_active'] ?? false,
    );
  }
}

class AttendanceSummary {
  final int presentToday;
  final int absentToday;
  final int onLeaveToday;
  final int lateToday;
  final double attendanceRateThisMonth;
  final List<LateEmployee> lateEmployeesToday;
  final List<AttendanceModel> recentCheckIns;

  AttendanceSummary({
    required this.presentToday,
    required this.absentToday,
    required this.onLeaveToday,
    required this.lateToday,
    required this.attendanceRateThisMonth,
    required this.lateEmployeesToday,
    required this.recentCheckIns,
  });
}

class LateEmployee {
  final String profileId;
  final String fullName;
  final String? avatarUrl;
  final String? unitCode;
  final int lateMinutes;
  final DateTime checkIn;

  LateEmployee({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
    this.unitCode,
    required this.lateMinutes,
    required this.checkIn,
  });
}

class LocationSummary {
  final Map<String, int> employeesByLocation;
  final Map<String, int> employeesByUnit;

  LocationSummary({
    required this.employeesByLocation,
    required this.employeesByUnit,
  });
}