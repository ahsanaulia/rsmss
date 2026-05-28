import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TodoModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int? durationMinutes;
  final String? targetUnitId;
  final String? targetPositionId;
  final String? targetShiftId;
  final DateTime todoDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String sourceType;
  final String? sourceId;
  final String? sourceTable;
  final Map<String, dynamic>? sourceData;
  final bool isActive;
  final DateTime? expiredAt;
  final int displayOrder;
  final bool isMandatory;
  final String priority; // low, normal, high, urgent
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields (untuk tampilan)
  final String? targetUnitName;
  final String? targetPositionName;
  final String? targetShiftName;
  final String? createdByName;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.durationMinutes,
    this.targetUnitId,
    this.targetPositionId,
    this.targetShiftId,
    required this.todoDate,
    this.startTime,
    this.endTime,
    this.sourceType = 'admin_input',
    this.sourceId,
    this.sourceTable,
    this.sourceData,
    this.isActive = true,
    this.expiredAt,
    this.displayOrder = 0,
    this.isMandatory = true,
    this.priority = 'normal',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.targetUnitName,
    this.targetPositionName,
    this.targetShiftName,
    this.createdByName,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      targetUnitId: json['target_unit_id'] as String?,
      targetPositionId: json['target_position_id'] as String?,
      targetShiftId: json['target_shift_id'] as String?,
      todoDate: DateTime.parse(json['todo_date'] as String),
      startTime: json['start_time'] != null
          ? TodoModel.timeFromString(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? TodoModel.timeFromString(json['end_time'] as String)
          : null,
      sourceType: json['source_type'] as String? ?? 'admin_input',
      sourceId: json['source_id'] as String?,
      sourceTable: json['source_table'] as String?,
      sourceData: json['source_data'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'] as String)
          : null,
      displayOrder: json['display_order'] as int? ?? 0,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      priority: json['priority'] as String? ?? 'normal',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      targetUnitName: json['target_unit_name'] as String?,
      targetPositionName: json['target_position_name'] as String?,
      targetShiftName: json['target_shift_name'] as String?,
      createdByName: json['created_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'target_unit_id': targetUnitId,
      'target_position_id': targetPositionId,
      'target_shift_id': targetShiftId,
      'todo_date': todoDate.toIso8601String().split('T').first,
      'start_time': startTime != null ? TodoModel.timeToString(startTime!) : null,
      'end_time': endTime != null ? TodoModel.timeToString(endTime!) : null,
      'source_type': sourceType,
      'source_id': sourceId,
      'source_table': sourceTable,
      'source_data': sourceData,
      'is_active': isActive,
      'expired_at': expiredAt?.toIso8601String(),
      'display_order': displayOrder,
      'is_mandatory': isMandatory,
      'priority': priority,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Konversi String (HH:MM:SS) ke TimeOfDay
  static TimeOfDay timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Konversi TimeOfDay ke String (HH:MM:SS)
  static String timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    String? targetUnitId,
    String? targetPositionId,
    String? targetShiftId,
    DateTime? todoDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? sourceType,
    String? sourceId,
    String? sourceTable,
    Map<String, dynamic>? sourceData,
    bool? isActive,
    DateTime? expiredAt,
    int? displayOrder,
    bool? isMandatory,
    String? priority,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? targetUnitName,
    String? targetPositionName,
    String? targetShiftName,
    String? createdByName,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetUnitId: targetUnitId ?? this.targetUnitId,
      targetPositionId: targetPositionId ?? this.targetPositionId,
      targetShiftId: targetShiftId ?? this.targetShiftId,
      todoDate: todoDate ?? this.todoDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      sourceTable: sourceTable ?? this.sourceTable,
      sourceData: sourceData ?? this.sourceData,
      isActive: isActive ?? this.isActive,
      expiredAt: expiredAt ?? this.expiredAt,
      displayOrder: displayOrder ?? this.displayOrder,
      isMandatory: isMandatory ?? this.isMandatory,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetUnitName: targetUnitName ?? this.targetUnitName,
      targetPositionName: targetPositionName ?? this.targetPositionName,
      targetShiftName: targetShiftName ?? this.targetShiftName,
      createdByName: createdByName ?? this.createdByName,
    );
  }

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.blue;
      case 'normal':
        return Colors.green;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Rendah';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'Tinggi';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        durationMinutes,
        targetUnitId,
        targetPositionId,
        targetShiftId,
        todoDate,
        startTime,
        endTime,
        sourceType,
        sourceId,
        sourceTable,
        sourceData,
        isActive,
        expiredAt,
        displayOrder,
        isMandatory,
        priority,
        createdBy,
        createdAt,
        updatedAt,
        targetUnitName,
        targetPositionName,
        targetShiftName,
        createdByName,
      ];
}