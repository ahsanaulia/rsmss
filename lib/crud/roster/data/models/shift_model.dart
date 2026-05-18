// // lib/features/roster/data/models/shift_model.dart
// import '../../domain/entities/shift_entity.dart';
// import 'package:flutter/material.dart';

// class ShiftModel extends ShiftEntity {
//   const ShiftModel({
//     required super.id,
//     required super.shiftName,
//     super.shiftCode,
//     required super.startTime,
//     required super.endTime,
//     super.description,
//     super.isCrossDay,
//     super.breakDurationMinutes,
//     super.toleranceLateMinutes,
//     super.toleranceEarlyLeaveMinutes,
//     super.minimumWorkMinutes,
//     super.maximumOvertimeMinutes,
//     super.fatigueWeight,
//     super.riskLevel,
//     super.isActive,
//     super.colorHex,
//   });

//   factory ShiftModel.fromJson(Map<String, dynamic> json) {
//     return ShiftModel(
//       id: json['id'].toString(),
//       shiftName: json['shift_name'] ?? '',
//       shiftCode: json['shift_code'] ?? '',
//       startTime: _parseTimeOfDay(json['start_time'].toString()),
//       endTime: _parseTimeOfDay(json['end_time'].toString()),
//       description: json['description'],
//       isCrossDay: json['is_cross_day'] ?? false,
//       breakDurationMinutes: json['break_duration_minutes'],
//       toleranceLateMinutes: json['tolerance_late_minutes'],
//       toleranceEarlyLeaveMinutes: json['tolerance_early_leave_minutes'],
//       minimumWorkMinutes: json['minimum_work_minutes'],
//       maximumOvertimeMinutes: json['maximum_overtime_minutes'],
//       fatigueWeight: json['fatigue_weight'] != null
//           ? (json['fatigue_weight'] as num).toDouble()
//           : null,
//       riskLevel: json['risk_level'],
//       isActive: json['is_active'] ?? true,
//       colorHex: json['color_hex'],
//     );
//   }
// }

// TimeOfDay _parseTimeOfDay(String timeString) {
//   final parts = timeString.split(':');
//   final hour = int.parse(parts[0]);
//   final minute = int.parse(parts[1]);
//   return TimeOfDay(hour: hour, minute: minute);
// }