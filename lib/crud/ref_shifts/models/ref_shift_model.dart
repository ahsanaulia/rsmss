import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefShiftModel extends Equatable {
  final String? id;
  final String shiftName;
  final String startTime;
  final String endTime;
  // final String? appId;
  final String? shiftCode;
  final String? description;
  final bool? isCrossDay;
  final int? breakDurationMinutes;
  final int? toleranceLateMinutes;
  final int? toleranceEarlyLeaveMinutes;
  final int? minimumWorkMinutes;
  final int? maximumOvertimeMinutes;
  final double? fatigueWeight;
  final String? riskLevel;
  final bool? requiresMedicalFit;
  final bool? requiresSupervisor;
  final bool? requiresCheckinPhoto;
  final bool? requiresLocationValidation;
  final double? aiPriorityWeight;
  final bool? wellbeingMonitoringEnabled;
  final bool? autoAssignAllowed;
  final String? colorHex;
  final String? iconName;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Untuk display (join data)
  // final String? appName;

  const RefShiftModel({
    this.id,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    // this.appId,
    this.shiftCode,
    this.description,
    this.isCrossDay,
    this.breakDurationMinutes,
    this.toleranceLateMinutes,
    this.toleranceEarlyLeaveMinutes,
    this.minimumWorkMinutes,
    this.maximumOvertimeMinutes,
    this.fatigueWeight,
    this.riskLevel,
    this.requiresMedicalFit,
    this.requiresSupervisor,
    this.requiresCheckinPhoto,
    this.requiresLocationValidation,
    this.aiPriorityWeight,
    this.wellbeingMonitoringEnabled,
    this.autoAssignAllowed,
    this.colorHex,
    this.iconName,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    // this.appName,
  });

  factory RefShiftModel.empty() {
    return const RefShiftModel(
      shiftName: '',
      startTime: '08:00:00',
      endTime: '17:00:00',
    );
  }

  factory RefShiftModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefShiftModel.fromJson: $json');

    return RefShiftModel(
      id: json['id'] as String?,
      shiftName: json['shift_name'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '08:00:00',
      endTime: json['end_time'] as String? ?? '17:00:00',
      // appId: json['app_id'] as String?,
      shiftCode: json['shift_code'] as String?,
      description: json['description'] as String?,
      isCrossDay: json['is_cross_day'] as bool? ?? false,
      breakDurationMinutes: json['break_duration_minutes'] as int? ?? 60,
      toleranceLateMinutes: json['tolerance_late_minutes'] as int? ?? 15,
      toleranceEarlyLeaveMinutes: json['tolerance_early_leave_minutes'] as int? ?? 15,
      minimumWorkMinutes: json['minimum_work_minutes'] as int? ?? 480,
      maximumOvertimeMinutes: json['maximum_overtime_minutes'] as int? ?? 240,
      fatigueWeight: json['fatigue_weight'] != null ? (json['fatigue_weight'] as num).toDouble() : 1.0,
      riskLevel: json['risk_level'] as String? ?? 'normal',
      requiresMedicalFit: json['requires_medical_fit'] as bool? ?? false,
      requiresSupervisor: json['requires_supervisor'] as bool? ?? false,
      requiresCheckinPhoto: json['requires_checkin_photo'] as bool? ?? false,
      requiresLocationValidation: json['requires_location_validation'] as bool? ?? true,
      aiPriorityWeight: json['ai_priority_weight'] != null ? (json['ai_priority_weight'] as num).toDouble() : 1.0,
      wellbeingMonitoringEnabled: json['wellbeing_monitoring_enabled'] as bool? ?? true,
      autoAssignAllowed: json['auto_assign_allowed'] as bool? ?? true,
      colorHex: json['color_hex'] as String? ?? '#2196F3',
      iconName: json['icon_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      // appName: json['apps_config'] != null
      //     ? (json['apps_config'] as Map<String, dynamic>)['client_name'] as String?
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'shift_name': shiftName.trim(),
      'start_time': startTime,
      'end_time': endTime,
      // if (appId != null) 'app_id': appId,
      if (shiftCode != null && shiftCode!.isNotEmpty) 'shift_code': shiftCode,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (isCrossDay != null) 'is_cross_day': isCrossDay,
      if (breakDurationMinutes != null) 'break_duration_minutes': breakDurationMinutes,
      if (toleranceLateMinutes != null) 'tolerance_late_minutes': toleranceLateMinutes,
      if (toleranceEarlyLeaveMinutes != null) 'tolerance_early_leave_minutes': toleranceEarlyLeaveMinutes,
      if (minimumWorkMinutes != null) 'minimum_work_minutes': minimumWorkMinutes,
      if (maximumOvertimeMinutes != null) 'maximum_overtime_minutes': maximumOvertimeMinutes,
      if (fatigueWeight != null) 'fatigue_weight': fatigueWeight,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (requiresMedicalFit != null) 'requires_medical_fit': requiresMedicalFit,
      if (requiresSupervisor != null) 'requires_supervisor': requiresSupervisor,
      if (requiresCheckinPhoto != null) 'requires_checkin_photo': requiresCheckinPhoto,
      if (requiresLocationValidation != null) 'requires_location_validation': requiresLocationValidation,
      if (aiPriorityWeight != null) 'ai_priority_weight': aiPriorityWeight,
      if (wellbeingMonitoringEnabled != null) 'wellbeing_monitoring_enabled': wellbeingMonitoringEnabled,
      if (autoAssignAllowed != null) 'auto_assign_allowed': autoAssignAllowed,
      if (colorHex != null && colorHex!.isNotEmpty) 'color_hex': colorHex,
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
      if (isActive != null) 'is_active': isActive,
    };
  }

  RefShiftModel copyWith({
    String? id,
    String? shiftName,
    String? startTime,
    String? endTime,
    String? appId,
    String? shiftCode,
    String? description,
    bool? isCrossDay,
    int? breakDurationMinutes,
    int? toleranceLateMinutes,
    int? toleranceEarlyLeaveMinutes,
    int? minimumWorkMinutes,
    int? maximumOvertimeMinutes,
    double? fatigueWeight,
    String? riskLevel,
    bool? requiresMedicalFit,
    bool? requiresSupervisor,
    bool? requiresCheckinPhoto,
    bool? requiresLocationValidation,
    double? aiPriorityWeight,
    bool? wellbeingMonitoringEnabled,
    bool? autoAssignAllowed,
    String? colorHex,
    String? iconName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    // String? appName,
  }) {
    return RefShiftModel(
      id: id ?? this.id,
      shiftName: shiftName ?? this.shiftName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      // appId: appId ?? this.appId,
      shiftCode: shiftCode ?? this.shiftCode,
      description: description ?? this.description,
      isCrossDay: isCrossDay ?? this.isCrossDay,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      toleranceLateMinutes: toleranceLateMinutes ?? this.toleranceLateMinutes,
      toleranceEarlyLeaveMinutes: toleranceEarlyLeaveMinutes ?? this.toleranceEarlyLeaveMinutes,
      minimumWorkMinutes: minimumWorkMinutes ?? this.minimumWorkMinutes,
      maximumOvertimeMinutes: maximumOvertimeMinutes ?? this.maximumOvertimeMinutes,
      fatigueWeight: fatigueWeight ?? this.fatigueWeight,
      riskLevel: riskLevel ?? this.riskLevel,
      requiresMedicalFit: requiresMedicalFit ?? this.requiresMedicalFit,
      requiresSupervisor: requiresSupervisor ?? this.requiresSupervisor,
      requiresCheckinPhoto: requiresCheckinPhoto ?? this.requiresCheckinPhoto,
      requiresLocationValidation: requiresLocationValidation ?? this.requiresLocationValidation,
      aiPriorityWeight: aiPriorityWeight ?? this.aiPriorityWeight,
      wellbeingMonitoringEnabled: wellbeingMonitoringEnabled ?? this.wellbeingMonitoringEnabled,
      autoAssignAllowed: autoAssignAllowed ?? this.autoAssignAllowed,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // appName: appName ?? this.appName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shiftName,
        startTime,
        endTime,
        // appId,
        shiftCode,
        description,
        isCrossDay,
        breakDurationMinutes,
        toleranceLateMinutes,
        toleranceEarlyLeaveMinutes,
        minimumWorkMinutes,
        maximumOvertimeMinutes,
        fatigueWeight,
        riskLevel,
        requiresMedicalFit,
        requiresSupervisor,
        requiresCheckinPhoto,
        requiresLocationValidation,
        aiPriorityWeight,
        wellbeingMonitoringEnabled,
        autoAssignAllowed,
        colorHex,
        iconName,
        isActive,
        createdAt,
        updatedAt,
        // appName,
      ];
}