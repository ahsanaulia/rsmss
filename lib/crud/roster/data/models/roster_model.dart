// lib/features/roster/data/models/roster_model.dart
import 'package:flutter/material.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/enums/attendance_status.dart' as attendance;
import '../../domain/enums/approval_status.dart' as approval;
import '../../domain/enums/wellbeing_risk_level.dart' as wellbeing;

// Alias untuk enum yang digunakan
typedef AttendanceStatus = attendance.AttendanceStatus;
typedef ApprovalStatus = approval.ApprovalStatus;
typedef WellbeingRiskLevel = wellbeing.WellbeingRiskLevel;

class RosterModel extends RosterEntity {
  const RosterModel({
    required super.id,
    required super.profileId,
    super.profileName,
    super.employeeId,
    required super.shiftId,
    super.shiftName,
    super.shiftCode,
    super.shiftStartTime,
    super.shiftEndTime,
    required super.rosterDate,
    super.scheduledStart,
    super.scheduledEnd,
    super.isDayOff,
    super.isOvertimePlanned,
    super.isEmergencyShift,
    super.isOnCall,
    super.aiGenerated,
    super.aiConfidenceScore,
    super.aiReason,
    super.predictedFatigueScore,
    super.predictedWorkloadScore,
    super.predictedStressScore,
    super.wellbeingRiskLevel,
    super.approvalStatus,
    super.approvedBy,
    super.approvedByName,
    super.approvedAt,
    super.rejectionReason,
    super.actualCheckIn,
    super.actualCheckOut,
    super.attendanceStatus,
    super.totalWorkMinutes,
    super.overtimeMinutes,
    super.latenessMinutes,
    super.earlyLeaveMinutes,
    super.notes,
    super.locationName,
    super.locationRoomId,
    super.locationRoomName,
    super.requiredEquipment,
    super.specialInstructions,
    super.leaveRequestId,
    super.qualificationRequired,
    super.minScoreRequired,
    super.createdBy,
    super.createdByName,
    super.createdAt,
    super.updatedAt,
  });

  factory RosterModel.fromJson(Map<String, dynamic> json) {
    // Parse time helper
    TimeOfDay? _parseTimeOfDay(String? timeString) {
      if (timeString == null || timeString.isEmpty) return null;
      final parts = timeString.split(':');
      if (parts.length < 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return RosterModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      profileName: json['profile']?['full_name'],
      employeeId: json['profile']?['employee_id'],
      shiftId: json['shift_id']?.toString() ?? '',
      shiftName: json['shift']?['shift_name'],
      shiftCode: json['shift']?['shift_code'],
      shiftStartTime: _parseTimeOfDay(json['shift']?['start_time']),
      shiftEndTime: _parseTimeOfDay(json['shift']?['end_time']),
      rosterDate: json['roster_date'] != null
          ? DateTime.parse(json['roster_date'])
          : DateTime.now(),
      scheduledStart: json['scheduled_start'] != null
          ? DateTime.parse(json['scheduled_start'])
          : null,
      scheduledEnd: json['scheduled_end'] != null
          ? DateTime.parse(json['scheduled_end'])
          : null,
      isDayOff: json['is_day_off'] ?? false,
      isOvertimePlanned: json['is_overtime_planned'] ?? false,
      isEmergencyShift: json['is_emergency_shift'] ?? false,
      isOnCall: json['is_on_call'] ?? false,
      aiGenerated: json['ai_generated'] ?? false,
      aiConfidenceScore: json['ai_confidence_score'] != null
          ? (json['ai_confidence_score'] as num).toDouble()
          : null,
      aiReason: json['ai_reason'],
      predictedFatigueScore: json['predicted_fatigue_score'] != null
          ? (json['predicted_fatigue_score'] as num).toDouble()
          : null,
      predictedWorkloadScore: json['predicted_workload_score'] != null
          ? (json['predicted_workload_score'] as num).toDouble()
          : null,
      predictedStressScore: json['predicted_stress_score'] != null
          ? (json['predicted_stress_score'] as num).toDouble()
          : null,
      wellbeingRiskLevel: wellbeing.WellbeingRiskLevel.fromValue(json['wellbeing_risk_level']),
      approvalStatus: approval.ApprovalStatus.fromValue(json['approval_status'] ?? 'pending'),
      approvedBy: json['approved_by']?.toString(),
      approvedByName: json['approved_by_profile']?['full_name'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      actualCheckIn: json['actual_check_in'] != null
          ? DateTime.parse(json['actual_check_in'])
          : null,
      actualCheckOut: json['actual_check_out'] != null
          ? DateTime.parse(json['actual_check_out'])
          : null,
      attendanceStatus: attendance.AttendanceStatus.fromValue(json['attendance_status'] ?? 'scheduled'),
      totalWorkMinutes: json['total_work_minutes'],
      overtimeMinutes: json['overtime_minutes'] ?? 0,
      latenessMinutes: json['lateness_minutes'] ?? 0,
      earlyLeaveMinutes: json['early_leave_minutes'] ?? 0,
      notes: json['notes'],
      locationName: json['location_name'],
      locationRoomId: json['location_room_id']?.toString(),
      locationRoomName: json['location_room']?['room_name'],
      requiredEquipment: json['required_equipment'] != null
          ? List<String>.from(json['required_equipment'])
          : [],
      specialInstructions: json['special_instructions'],
      leaveRequestId: json['leave_request_id']?.toString(),
      qualificationRequired: json['qualification_required'] != null
          ? List<String>.from(json['qualification_required'])
          : [],
      minScoreRequired: json['min_score_required'] != null
          ? (json['min_score_required'] as num).toDouble()
          : null,
      createdBy: json['created_by']?.toString(),
      createdByName: json['created_by_profile']?['full_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'shift_id': shiftId,
      'roster_date': rosterDate.toIso8601String().split('T').first,
      'scheduled_start': scheduledStart?.toIso8601String(),
      'scheduled_end': scheduledEnd?.toIso8601String(),
      'is_day_off': isDayOff,
      'is_overtime_planned': isOvertimePlanned,
      'is_emergency_shift': isEmergencyShift,
      'is_on_call': isOnCall,
      'ai_generated': aiGenerated,
      'ai_confidence_score': aiConfidenceScore,
      'ai_reason': aiReason,
      'predicted_fatigue_score': predictedFatigueScore,
      'predicted_workload_score': predictedWorkloadScore,
      'predicted_stress_score': predictedStressScore,
      'wellbeing_risk_level': wellbeingRiskLevel.value,
      'approval_status': approvalStatus.value,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'actual_check_in': actualCheckIn?.toIso8601String(),
      'actual_check_out': actualCheckOut?.toIso8601String(),
      'attendance_status': attendanceStatus.value,
      'total_work_minutes': totalWorkMinutes,
      'overtime_minutes': overtimeMinutes,
      'lateness_minutes': latenessMinutes,
      'early_leave_minutes': earlyLeaveMinutes,
      'notes': notes,
      'location_name': locationName,
      'location_room_id': locationRoomId,
      'required_equipment': requiredEquipment,
      'special_instructions': specialInstructions,
      'leave_request_id': leaveRequestId,
      'qualification_required': qualificationRequired,
      'min_score_required': minScoreRequired,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}