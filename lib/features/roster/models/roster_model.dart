import 'package:flutter/material.dart';

class RosterModel {
  final String id;
  final String profileId;
  final String shiftId;
  final String shiftName;
  final String shiftCode;
  final DateTime rosterDate;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String? locationName;
  final String? locationRoomId;
  final List<String> requiredEquipment;
  final String? specialInstructions;
  final String attendanceStatus;
  final double? predictedFatigueScore;
  final String? wellbeingRiskLevel;
  final bool isDayOff;
  
  // Field baru dari tabel employee_shift_rosters yang sudah diperluas
  final bool isOvertimePlanned;
  final bool isEmergencyShift;
  final bool isOnCall;
  final bool aiGenerated;
  final double? aiConfidenceScore;
  final String? aiReason;
  final double? predictedWorkloadScore;
  final double? predictedStressScore;
  final String approvalStatus;
  final String? rejectionReason;
  final DateTime? actualCheckIn;
  final DateTime? actualCheckOut;
  final int? totalWorkMinutes;
  final int overtimeMinutes;
  final int latenessMinutes;
  final int earlyLeaveMinutes;
  final String? notes;
  final String? leaveRequestId;
  final List<String> qualificationRequired;
  final double? minScoreRequired;

  RosterModel({
    required this.id,
    required this.profileId,
    required this.shiftId,
    required this.shiftName,
    required this.shiftCode,
    required this.rosterDate,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.locationName,
    this.locationRoomId,
    this.requiredEquipment = const [],
    this.specialInstructions,
    this.attendanceStatus = 'scheduled',
    this.predictedFatigueScore,
    this.wellbeingRiskLevel,
    this.isDayOff = false,
    this.isOvertimePlanned = false,
    this.isEmergencyShift = false,
    this.isOnCall = false,
    this.aiGenerated = false,
    this.aiConfidenceScore,
    this.aiReason,
    this.predictedWorkloadScore,
    this.predictedStressScore,
    this.approvalStatus = 'pending',
    this.rejectionReason,
    this.actualCheckIn,
    this.actualCheckOut,
    this.totalWorkMinutes,
    this.overtimeMinutes = 0,
    this.latenessMinutes = 0,
    this.earlyLeaveMinutes = 0,
    this.notes,
    this.leaveRequestId,
    this.qualificationRequired = const [],
    this.minScoreRequired,
  });

  factory RosterModel.fromJson(Map<String, dynamic> json) {
    return RosterModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      shiftId: json['shift_id']?.toString() ?? '',
      shiftName: json['ref_shifts']?['shift_name'] ?? json['shift_name'] ?? '-',
      shiftCode: json['ref_shifts']?['shift_code'] ?? json['shift_code'] ?? '-',
      rosterDate: json['roster_date'] != null
          ? DateTime.parse(json['roster_date'])
          : DateTime.now(),
      scheduledStart: json['scheduled_start'] != null
          ? DateTime.parse(json['scheduled_start'])
          : DateTime.now(),
      scheduledEnd: json['scheduled_end'] != null
          ? DateTime.parse(json['scheduled_end'])
          : DateTime.now(),
      locationName: json['location_name'],
      locationRoomId: json['location_room_id']?.toString(),
      requiredEquipment: json['required_equipment'] != null
          ? List<String>.from(json['required_equipment'])
          : [],
      specialInstructions: json['special_instructions'],
      attendanceStatus: json['attendance_status'] ?? 'scheduled',
      predictedFatigueScore: json['predicted_fatigue_score'] != null
          ? (json['predicted_fatigue_score'] as num).toDouble()
          : null,
      wellbeingRiskLevel: json['wellbeing_risk_level'],
      isDayOff: json['is_day_off'] ?? false,
      isOvertimePlanned: json['is_overtime_planned'] ?? false,
      isEmergencyShift: json['is_emergency_shift'] ?? false,
      isOnCall: json['is_on_call'] ?? false,
      aiGenerated: json['ai_generated'] ?? false,
      aiConfidenceScore: json['ai_confidence_score'] != null
          ? (json['ai_confidence_score'] as num).toDouble()
          : null,
      aiReason: json['ai_reason'],
      predictedWorkloadScore: json['predicted_workload_score'] != null
          ? (json['predicted_workload_score'] as num).toDouble()
          : null,
      predictedStressScore: json['predicted_stress_score'] != null
          ? (json['predicted_stress_score'] as num).toDouble()
          : null,
      approvalStatus: json['approval_status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      actualCheckIn: json['actual_check_in'] != null
          ? DateTime.parse(json['actual_check_in'])
          : null,
      actualCheckOut: json['actual_check_out'] != null
          ? DateTime.parse(json['actual_check_out'])
          : null,
      totalWorkMinutes: json['total_work_minutes'],
      overtimeMinutes: json['overtime_minutes'] ?? 0,
      latenessMinutes: json['lateness_minutes'] ?? 0,
      earlyLeaveMinutes: json['early_leave_minutes'] ?? 0,
      notes: json['notes'],
      leaveRequestId: json['leave_request_id']?.toString(),
      qualificationRequired: json['qualification_required'] != null
          ? List<String>.from(json['qualification_required'])
          : [],
      minScoreRequired: json['min_score_required'] != null
          ? (json['min_score_required'] as num).toDouble()
          : null,
    );
  }

  String get formattedTime {
    final start = scheduledStart;
    final end = scheduledEnd;
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final date = rosterDate;
    return '${date.day}/${date.month}/${date.year}';
  }

  String get dayName {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[rosterDate.weekday - 1];
  }

  Color get fatigueColor {
    final score = predictedFatigueScore ?? 0;
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    if (score <= 8) return Colors.orange.shade800;
    return Colors.red;
  }

  String get fatigueLabel {
    final score = predictedFatigueScore ?? 0;
    if (score <= 3) return 'Rendah';
    if (score <= 6) return 'Sedang';
    if (score <= 8) return 'Tinggi';
    return 'Kritis';
  }

  Color get approvalStatusColor {
    switch (approvalStatus.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get approvalStatusLabel {
    switch (approvalStatus.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu';
      default:
        return approvalStatus;
    }
  }

  String get attendanceStatusLabel {
    switch (attendanceStatus.toLowerCase()) {
      case 'checked_in':
        return 'Sudah Check-in';
      case 'checked_out':
        return 'Sudah Check-out';
      case 'late':
        return 'Terlambat';
      case 'absent':
        return 'Tidak Hadir';
      default:
        return 'Terjadwal';
    }
  }

  Color get attendanceStatusColor {
    switch (attendanceStatus.toLowerCase()) {
      case 'checked_in':
        return Colors.blue;
      case 'checked_out':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isExpired {
    return rosterDate.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return rosterDate.year == now.year &&
        rosterDate.month == now.month &&
        rosterDate.day == now.day;
  }

  bool get canCheckIn {
    if (isDayOff) return false;
    if (attendanceStatus == 'checked_in' || attendanceStatus == 'checked_out') return false;
    if (approvalStatus != 'approved') return false;
    
    final now = DateTime.now();
    final checkInDeadline = scheduledStart.add(const Duration(minutes: 30));
    return now.isAfter(scheduledStart.subtract(const Duration(minutes: 30))) &&
           now.isBefore(checkInDeadline);
  }

  bool get canCheckOut {
    if (attendanceStatus != 'checked_in') return false;
    
    final now = DateTime.now();
    return now.isAfter(scheduledEnd.subtract(const Duration(minutes: 15)));
  }
}

class TodayRosterResult {
  final RosterModel? todayRoster;
  final RosterModel? nextRoster;
  final bool isFlexibleRoster;
  final RosterModel? defaultShift;

  TodayRosterResult({
    this.todayRoster,
    this.nextRoster,
    required this.isFlexibleRoster,
    this.defaultShift,
  });

  bool get hasRoster => todayRoster != null || defaultShift != null;
  
  RosterModel get displayTodayRoster => todayRoster ?? defaultShift!;
}