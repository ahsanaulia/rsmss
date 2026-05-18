// lib/features/roster/domain/entities/shift_entity.dart
import 'package:flutter/material.dart';

class ShiftEntity {
  final String id;
  final String shiftName;
  final String shiftCode;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? description;
  final bool isCrossDay;
  final int? breakDurationMinutes;
  final int? toleranceLateMinutes;
  final int? toleranceEarlyLeaveMinutes;
  final int? minimumWorkMinutes;
  final int? maximumOvertimeMinutes;
  final double? fatigueWeight;
  final String? riskLevel;
  final bool isActive;
  final String? colorHex;

  const ShiftEntity({
    required this.id,
    required this.shiftName,
    this.shiftCode = '',
    required this.startTime,
    required this.endTime,
    this.description,
    this.isCrossDay = false,
    this.breakDurationMinutes,
    this.toleranceLateMinutes,
    this.toleranceEarlyLeaveMinutes,
    this.minimumWorkMinutes,
    this.maximumOvertimeMinutes,
    this.fatigueWeight,
    this.riskLevel,
    this.isActive = true,
    this.colorHex,
  });

  String get displayTime {
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  Color get color {
    if (colorHex != null && colorHex!.isNotEmpty) {
      final hex = colorHex!.replaceFirst('#', '');
      return Color(int.parse('0xFF$hex'));
    }
    // Default colors based on shift name
    final lowerName = shiftName.toLowerCase();
    if (lowerName.contains('pagi')) return const Color(0xFF4CAF50);
    if (lowerName.contains('siang')) return const Color(0xFFFF9800);
    if (lowerName.contains('malam')) return const Color(0xFF2196F3);
    return Colors.grey;
  }

  /// Factory constructor untuk membuat ShiftEntity dari JSON (dari Supabase)
  factory ShiftEntity.fromJson(Map<String, dynamic> json) {
    return ShiftEntity(
      id: json['id']?.toString() ?? '',
      shiftName: json['shift_name'] ?? '',
      shiftCode: json['shift_code'] ?? '',
      startTime: _parseTimeOfDay(json['start_time']?.toString() ?? '00:00:00'),
      endTime: _parseTimeOfDay(json['end_time']?.toString() ?? '00:00:00'),
      description: json['description'],
      isCrossDay: json['is_cross_day'] ?? false,
      breakDurationMinutes: json['break_duration_minutes'],
      toleranceLateMinutes: json['tolerance_late_minutes'],
      toleranceEarlyLeaveMinutes: json['tolerance_early_leave_minutes'],
      minimumWorkMinutes: json['minimum_work_minutes'],
      maximumOvertimeMinutes: json['maximum_overtime_minutes'],
      fatigueWeight: json['fatigue_weight'] != null
          ? (json['fatigue_weight'] as num).toDouble()
          : null,
      riskLevel: json['risk_level'],
      isActive: json['is_active'] ?? true,
      colorHex: json['color_hex'],
    );
  }

  /// Method untuk konversi ShiftEntity ke JSON (untuk insert/update ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift_name': shiftName,
      'shift_code': shiftCode,
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
      'description': description,
      'is_cross_day': isCrossDay,
      'break_duration_minutes': breakDurationMinutes,
      'tolerance_late_minutes': toleranceLateMinutes,
      'tolerance_early_leave_minutes': toleranceEarlyLeaveMinutes,
      'minimum_work_minutes': minimumWorkMinutes,
      'maximum_overtime_minutes': maximumOvertimeMinutes,
      'fatigue_weight': fatigueWeight,
      'risk_level': riskLevel,
      'is_active': isActive,
      'color_hex': colorHex,
    };
  }

  /// CopyWith method untuk membuat salinan dengan perubahan tertentu
  ShiftEntity copyWith({
    String? id,
    String? shiftName,
    String? shiftCode,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? description,
    bool? isCrossDay,
    int? breakDurationMinutes,
    int? toleranceLateMinutes,
    int? toleranceEarlyLeaveMinutes,
    int? minimumWorkMinutes,
    int? maximumOvertimeMinutes,
    double? fatigueWeight,
    String? riskLevel,
    bool? isActive,
    String? colorHex,
  }) {
    return ShiftEntity(
      id: id ?? this.id,
      shiftName: shiftName ?? this.shiftName,
      shiftCode: shiftCode ?? this.shiftCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      isCrossDay: isCrossDay ?? this.isCrossDay,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      toleranceLateMinutes: toleranceLateMinutes ?? this.toleranceLateMinutes,
      toleranceEarlyLeaveMinutes: toleranceEarlyLeaveMinutes ?? this.toleranceEarlyLeaveMinutes,
      minimumWorkMinutes: minimumWorkMinutes ?? this.minimumWorkMinutes,
      maximumOvertimeMinutes: maximumOvertimeMinutes ?? this.maximumOvertimeMinutes,
      fatigueWeight: fatigueWeight ?? this.fatigueWeight,
      riskLevel: riskLevel ?? this.riskLevel,
      isActive: isActive ?? this.isActive,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  String toString() {
    return 'ShiftEntity(id: $id, shiftName: $shiftName, startTime: ${_formatTimeOfDay(startTime)}, endTime: ${_formatTimeOfDay(endTime)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// HELPER FUNCTIONS (diletakkan di luar class)
// ============================================================

/// Helper function untuk format TimeOfDay ke string (HH:MM)
String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Helper function untuk parse string ke TimeOfDay
/// Mendukung format: "07:00:00" atau "07:00"
TimeOfDay _parseTimeOfDay(String timeString) {
  // Hapus detik jika ada (format HH:MM:SS -> ambil HH:MM)
  String cleanTime = timeString;
  if (timeString.contains(':') && timeString.split(':').length >= 2) {
    final parts = timeString.split(':');
    cleanTime = '${parts[0]}:${parts[1]}';
  }
  
  final parts = cleanTime.split(':');
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return TimeOfDay(hour: hour, minute: minute);
}