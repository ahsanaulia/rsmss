// lib/features/roster/domain/entities/roster_entity.dart
import 'package:flutter/material.dart';
import '../enums/attendance_status.dart' as attendance;
import '../enums/approval_status.dart' as approval;
import '../enums/wellbeing_risk_level.dart' as wellbeing;

// Gunakan alias untuk menghindari konflik
typedef AttendanceStatus = attendance.AttendanceStatus;
typedef ApprovalStatus = approval.ApprovalStatus;
typedef WellbeingRiskLevel = wellbeing.WellbeingRiskLevel;

class RosterEntity {
  final String id;
  final String profileId;
  final String? profileName;
  final String? employeeId;
  final String shiftId;
  final String? shiftName;
  final String? shiftCode;
  final TimeOfDay? shiftStartTime;
  final TimeOfDay? shiftEndTime;
  final DateTime rosterDate;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final bool isDayOff;
  final bool isOvertimePlanned;
  final bool isEmergencyShift;
  final bool isOnCall;
  final bool aiGenerated;
  final double? aiConfidenceScore;
  final String? aiReason;
  final double? predictedFatigueScore;
  final double? predictedWorkloadScore;
  final double? predictedStressScore;
  final WellbeingRiskLevel wellbeingRiskLevel;
  final ApprovalStatus approvalStatus;
  final String? approvedBy;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? actualCheckIn;
  final DateTime? actualCheckOut;
  final AttendanceStatus attendanceStatus;
  final int? totalWorkMinutes;
  final int overtimeMinutes;
  final int latenessMinutes;
  final int earlyLeaveMinutes;
  final String? notes;
  final String? locationName;
  final String? locationRoomId;
  final String? locationRoomName;
  final List<String> requiredEquipment;
  final String? specialInstructions;
  final String? leaveRequestId;
  final List<String> qualificationRequired;
  final double? minScoreRequired;
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RosterEntity({
    required this.id,
    required this.profileId,
    this.profileName,
    this.employeeId,
    required this.shiftId,
    this.shiftName,
    this.shiftCode,
    this.shiftStartTime,
    this.shiftEndTime,
    required this.rosterDate,
    this.scheduledStart,
    this.scheduledEnd,
    this.isDayOff = false,
    this.isOvertimePlanned = false,
    this.isEmergencyShift = false,
    this.isOnCall = false,
    this.aiGenerated = false,
    this.aiConfidenceScore,
    this.aiReason,
    this.predictedFatigueScore,
    this.predictedWorkloadScore,
    this.predictedStressScore,
    this.wellbeingRiskLevel = WellbeingRiskLevel.low,
    this.approvalStatus = ApprovalStatus.pending,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.rejectionReason,
    this.actualCheckIn,
    this.actualCheckOut,
    this.attendanceStatus = AttendanceStatus.scheduled,
    this.totalWorkMinutes,
    this.overtimeMinutes = 0,
    this.latenessMinutes = 0,
    this.earlyLeaveMinutes = 0,
    this.notes,
    this.locationName,
    this.locationRoomId,
    this.locationRoomName,
    this.requiredEquipment = const [],
    this.specialInstructions,
    this.leaveRequestId,
    this.qualificationRequired = const [],
    this.minScoreRequired,
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  String get displayShiftTime {
    if (shiftStartTime == null || shiftEndTime == null) return '';
    final start = _formatTimeOfDay(shiftStartTime!);
    final end = _formatTimeOfDay(shiftEndTime!);
    return '$start - $end';
  }

  String get displayStatus {
    if (isDayOff) return 'Libur';
    if (attendanceStatus != AttendanceStatus.scheduled) {
      return attendanceStatus.label;
    }
    return 'Terjadwal';
  }

  Color get statusColor {
    if (isDayOff) return Colors.blue;
    return attendanceStatus.color;
  }

  Color get priorityColor {
    switch (approvalStatus) {
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
      case ApprovalStatus.pending:
        return Colors.orange;
    }
  }

  RosterEntity copyWith({
    String? id,
    String? profileId,
    String? profileName,
    String? employeeId,
    String? shiftId,
    String? shiftName,
    String? shiftCode,
    TimeOfDay? shiftStartTime,
    TimeOfDay? shiftEndTime,
    DateTime? rosterDate,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    bool? isDayOff,
    bool? isOvertimePlanned,
    bool? isEmergencyShift,
    bool? isOnCall,
    bool? aiGenerated,
    double? aiConfidenceScore,
    String? aiReason,
    double? predictedFatigueScore,
    double? predictedWorkloadScore,
    double? predictedStressScore,
    WellbeingRiskLevel? wellbeingRiskLevel,
    ApprovalStatus? approvalStatus,
    String? approvedBy,
    String? approvedByName,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? actualCheckIn,
    DateTime? actualCheckOut,
    AttendanceStatus? attendanceStatus,
    int? totalWorkMinutes,
    int? overtimeMinutes,
    int? latenessMinutes,
    int? earlyLeaveMinutes,
    String? notes,
    String? locationName,
    String? locationRoomId,
    String? locationRoomName,
    List<String>? requiredEquipment,
    String? specialInstructions,
    String? leaveRequestId,
    List<String>? qualificationRequired,
    double? minScoreRequired,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RosterEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
      employeeId: employeeId ?? this.employeeId,
      shiftId: shiftId ?? this.shiftId,
      shiftName: shiftName ?? this.shiftName,
      shiftCode: shiftCode ?? this.shiftCode,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
      rosterDate: rosterDate ?? this.rosterDate,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      isDayOff: isDayOff ?? this.isDayOff,
      isOvertimePlanned: isOvertimePlanned ?? this.isOvertimePlanned,
      isEmergencyShift: isEmergencyShift ?? this.isEmergencyShift,
      isOnCall: isOnCall ?? this.isOnCall,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      aiConfidenceScore: aiConfidenceScore ?? this.aiConfidenceScore,
      aiReason: aiReason ?? this.aiReason,
      predictedFatigueScore: predictedFatigueScore ?? this.predictedFatigueScore,
      predictedWorkloadScore: predictedWorkloadScore ?? this.predictedWorkloadScore,
      predictedStressScore: predictedStressScore ?? this.predictedStressScore,
      wellbeingRiskLevel: wellbeingRiskLevel ?? this.wellbeingRiskLevel,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      actualCheckIn: actualCheckIn ?? this.actualCheckIn,
      actualCheckOut: actualCheckOut ?? this.actualCheckOut,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      totalWorkMinutes: totalWorkMinutes ?? this.totalWorkMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      latenessMinutes: latenessMinutes ?? this.latenessMinutes,
      earlyLeaveMinutes: earlyLeaveMinutes ?? this.earlyLeaveMinutes,
      notes: notes ?? this.notes,
      locationName: locationName ?? this.locationName,
      locationRoomId: locationRoomId ?? this.locationRoomId,
      locationRoomName: locationRoomName ?? this.locationRoomName,
      requiredEquipment: requiredEquipment ?? this.requiredEquipment,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      leaveRequestId: leaveRequestId ?? this.leaveRequestId,
      qualificationRequired: qualificationRequired ?? this.qualificationRequired,
      minScoreRequired: minScoreRequired ?? this.minScoreRequired,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Helper function untuk format TimeOfDay
String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

// Helper function untuk parse string ke TimeOfDay
TimeOfDay _parseTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}