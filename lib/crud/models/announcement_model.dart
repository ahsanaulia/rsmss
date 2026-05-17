import 'package:flutter/material.dart';

class AnnouncementModel {
  final String id;
  final String senderId;
  final String? senderName;
  final String title;
  final String content;
  final String priority;
  final DateTime createdAt;
  final DateTime? expiresAt;
  
  // Targeting fields
  final String? targetRole;
  final String? targetUnitId;
  final String? targetUnitName;
  final String? targetPositionId;
  final String? targetPositionName;
  final String? targetProfileId;
  final String? targetProfileName;
  final String? targetBuildingId;
  final String? targetBuildingName;
  final String? targetFloorId;
  final String? targetFloorName;
  final String? targetRoomId;
  final String? targetRoomName;
  final String? targetPermissionAsset;
  final String? targetPermissionStock;
  final bool? targetFlexibleRoster;
  final String? targetWellbeingRisk;
  final int? targetJoinYearStart;
  final int? targetJoinYearEnd;
  final String? targetSituation;
  final String? targetGender;
  final int? targetRatingTakeCountMin;
  final int? targetRatingTakeCountMax;
  final int? targetIntSequenceMin;
  final int? targetIntSequenceMax;
  final double? targetFatigueScoreMin;
  final double? targetFatigueScoreMax;

  AnnouncementModel({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    this.expiresAt,
    this.targetRole,
    this.targetUnitId,
    this.targetUnitName,
    this.targetPositionId,
    this.targetPositionName,
    this.targetProfileId,
    this.targetProfileName,
    this.targetBuildingId,
    this.targetBuildingName,
    this.targetFloorId,
    this.targetFloorName,
    this.targetRoomId,
    this.targetRoomName,
    this.targetPermissionAsset,
    this.targetPermissionStock,
    this.targetFlexibleRoster,
    this.targetWellbeingRisk,
    this.targetJoinYearStart,
    this.targetJoinYearEnd,
    this.targetSituation,
    this.targetGender,
    this.targetRatingTakeCountMin,
    this.targetRatingTakeCountMax,
    this.targetIntSequenceMin,
    this.targetIntSequenceMax,
    this.targetFatigueScoreMin,
    this.targetFatigueScoreMax,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
  return AnnouncementModel(
    id: json['id']?.toString() ?? '',
    senderId: json['sender_id']?.toString() ?? '',
    senderName: json['sender']?['full_name'],           // ← dari alias 'sender'
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    priority: json['priority'] ?? 'normal',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    expiresAt: json['expires_at'] != null
        ? DateTime.parse(json['expires_at'])
        : null,
    targetRole: json['target_role'],
    targetUnitId: json['target_unit_id']?.toString(),
    targetUnitName: json['target_unit']?['unit_name'],
    targetPositionId: json['target_position_id']?.toString(),
    targetPositionName: json['target_position']?['position_name'],
    targetProfileId: json['target_profile_id']?.toString(),
    targetProfileName: json['target_profile']?['full_name'],  // ← dari alias 'target_profile'
    targetBuildingId: json['target_building_id']?.toString(),
    targetBuildingName: json['target_building']?['function_name'],
    targetFloorId: json['target_floor_id']?.toString(),
    targetFloorName: json['target_floor']?['floor_alias'],    // ← floor_alias
    targetRoomId: json['target_room_id']?.toString(),
    targetRoomName: json['target_room']?['room_name'],
    targetPermissionAsset: json['target_permission_asset'],
    targetPermissionStock: json['target_permission_stock'],
    targetFlexibleRoster: json['target_flexible_roster'],
    targetWellbeingRisk: json['target_wellbeing_risk'],
    targetJoinYearStart: json['target_join_year_start'],
    targetJoinYearEnd: json['target_join_year_end'],
    targetSituation: json['target_situation'],
    targetGender: json['target_gender'],
    targetRatingTakeCountMin: json['target_rating_take_count_min'],
    targetRatingTakeCountMax: json['target_rating_take_count_max'],
    targetIntSequenceMin: json['target_int_sequence_min'],
    targetIntSequenceMax: json['target_int_sequence_max'],
    targetFatigueScoreMin: json['target_fatigue_score_min'] != null
        ? (json['target_fatigue_score_min'] as num).toDouble()
        : null,
    targetFatigueScoreMax: json['target_fatigue_score_max'] != null
        ? (json['target_fatigue_score_max'] as num).toDouble()
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'title': title,
      'content': content,
      'priority': priority,
      'expires_at': expiresAt?.toIso8601String(),
      'target_role': targetRole,
      'target_unit_id': targetUnitId,
      'target_position_id': targetPositionId,
      'target_profile_id': targetProfileId,
      'target_building_id': targetBuildingId,
      'target_floor_id': targetFloorId,
      'target_room_id': targetRoomId,
      'target_permission_asset': targetPermissionAsset,
      'target_permission_stock': targetPermissionStock,
      'target_flexible_roster': targetFlexibleRoster,
      'target_wellbeing_risk': targetWellbeingRisk,
      'target_join_year_start': targetJoinYearStart,
      'target_join_year_end': targetJoinYearEnd,
      'target_situation': targetSituation,
      'target_gender': targetGender,
      'target_rating_take_count_min': targetRatingTakeCountMin,
      'target_rating_take_count_max': targetRatingTakeCountMax,
      'target_int_sequence_min': targetIntSequenceMin,
      'target_int_sequence_max': targetIntSequenceMax,
      'target_fatigue_score_min': targetFatigueScoreMin,
      'target_fatigue_score_max': targetFatigueScoreMax,
    };
  }

  String get priorityLabel {
    switch (priority) {
      case 'normal': return 'Normal';
      case 'urgent': return 'Urgent';
      case 'emergency': return 'Emergency';
      default: return priority;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'normal': return Colors.blue;
      case 'urgent': return Colors.orange;
      case 'emergency': return Colors.red;
      default: return Colors.grey;
    }
  }

  String get targetDisplayText {
    final List<String> targets = [];
    
    if (targetProfileId != null) {
      return 'Pegawai: ${targetProfileName ?? targetProfileId}';
    }
    if (targetRole != null) {
      targets.add('Role: $targetRole');
    }
    if (targetUnitName != null) {
      targets.add('Unit: $targetUnitName');
    }
    if (targetPositionName != null) {
      targets.add('Posisi: $targetPositionName');
    }
    if (targetBuildingName != null) {
      targets.add('Gedung: $targetBuildingName');
    }
    if (targetPermissionAsset != null) {
      targets.add('Asset: ${targetPermissionAsset == 'initial' ? 'Initial' : 'Inspection'}');
    }
    if (targetPermissionStock != null) {
      targets.add('Stock: ${targetPermissionStock == 'initial' ? 'Initial' : 'Opname'}');
    }
    if (targetWellbeingRisk != null) {
      targets.add('Wellbeing: $targetWellbeingRisk');
    }
    if (targetFatigueScoreMin != null || targetFatigueScoreMax != null) {
      final min = targetFatigueScoreMin ?? 0;
      final max = targetFatigueScoreMax ?? 10;
      targets.add('Fatigue: $min - $max');
    }
    
    if (targets.isEmpty) return 'Semua Pegawai';
    return targets.join(', ');
  }

  // Tambahkan di dalam class AnnouncementModel
AnnouncementModel copyWith({
  String? id,
  String? senderId,
  String? senderName,
  String? title,
  String? content,
  String? priority,
  DateTime? createdAt,
  DateTime? expiresAt,
  String? targetRole,
  String? targetUnitId,
  String? targetUnitName,
  String? targetPositionId,
  String? targetPositionName,
  String? targetProfileId,
  String? targetProfileName,
  String? targetBuildingId,
  String? targetBuildingName,
  String? targetFloorId,
  String? targetFloorName,
  String? targetRoomId,
  String? targetRoomName,
  String? targetPermissionAsset,
  String? targetPermissionStock,
  bool? targetFlexibleRoster,
  String? targetWellbeingRisk,
  int? targetJoinYearStart,
  int? targetJoinYearEnd,
  String? targetSituation,
  String? targetGender,
  int? targetRatingTakeCountMin,
  int? targetRatingTakeCountMax,
  int? targetIntSequenceMin,
  int? targetIntSequenceMax,
  double? targetFatigueScoreMin,
  double? targetFatigueScoreMax,
}) {
  return AnnouncementModel(
    id: id ?? this.id,
    senderId: senderId ?? this.senderId,
    senderName: senderName ?? this.senderName,
    title: title ?? this.title,
    content: content ?? this.content,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    targetRole: targetRole ?? this.targetRole,
    targetUnitId: targetUnitId ?? this.targetUnitId,
    targetUnitName: targetUnitName ?? this.targetUnitName,
    targetPositionId: targetPositionId ?? this.targetPositionId,
    targetPositionName: targetPositionName ?? this.targetPositionName,
    targetProfileId: targetProfileId ?? this.targetProfileId,
    targetProfileName: targetProfileName ?? this.targetProfileName,
    targetBuildingId: targetBuildingId ?? this.targetBuildingId,
    targetBuildingName: targetBuildingName ?? this.targetBuildingName,
    targetFloorId: targetFloorId ?? this.targetFloorId,
    targetFloorName: targetFloorName ?? this.targetFloorName,
    targetRoomId: targetRoomId ?? this.targetRoomId,
    targetRoomName: targetRoomName ?? this.targetRoomName,
    targetPermissionAsset: targetPermissionAsset ?? this.targetPermissionAsset,
    targetPermissionStock: targetPermissionStock ?? this.targetPermissionStock,
    targetFlexibleRoster: targetFlexibleRoster ?? this.targetFlexibleRoster,
    targetWellbeingRisk: targetWellbeingRisk ?? this.targetWellbeingRisk,
    targetJoinYearStart: targetJoinYearStart ?? this.targetJoinYearStart,
    targetJoinYearEnd: targetJoinYearEnd ?? this.targetJoinYearEnd,
    targetSituation: targetSituation ?? this.targetSituation,
    targetGender: targetGender ?? this.targetGender,
    targetRatingTakeCountMin: targetRatingTakeCountMin ?? this.targetRatingTakeCountMin,
    targetRatingTakeCountMax: targetRatingTakeCountMax ?? this.targetRatingTakeCountMax,
    targetIntSequenceMin: targetIntSequenceMin ?? this.targetIntSequenceMin,
    targetIntSequenceMax: targetIntSequenceMax ?? this.targetIntSequenceMax,
    targetFatigueScoreMin: targetFatigueScoreMin ?? this.targetFatigueScoreMin,
    targetFatigueScoreMax: targetFatigueScoreMax ?? this.targetFatigueScoreMax,
  );
}
}