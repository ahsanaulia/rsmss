import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String typeId;
  final String? typeName;
  final String assigneeId;
  final String? assigneeName;
  final String objectName;
  final String? fromRoomId;
  final String? fromRoomName;
  final String? toRoomId;
  final String? toRoomName;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? createdById;
  final String? createdByName;
  final String? taskOutcome;
  final String? completionNotes;
  final String? assetId;
  final String? assetName;
  final String? stockId;
  final String? stockName;
  final String? relatedProfileId;
  final String? relatedProfileName;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;
  final String? rejectionReason;
  final int? slaMinutes;
  final int? estimatedDurationMinutes;
  final int? actualDurationMinutes;
  final bool requiresConfirmation;
  final bool requiresPhotoProof;
  final bool requiresQrValidation;
  final String? proofPhotoUrl;
  final String? employeeFeedback;
  final int? employeeRating;

  TaskModel({
    required this.id,
    required this.typeId,
    this.typeName,
    required this.assigneeId,
    this.assigneeName,
    required this.objectName,
    this.fromRoomId,
    this.fromRoomName,
    this.toRoomId,
    this.toRoomName,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.createdById,
    this.createdByName,
    this.taskOutcome,
    this.completionNotes,
    this.assetId,
    this.assetName,
    this.stockId,
    this.stockName,
    this.relatedProfileId,
    this.relatedProfileName,
    this.acceptedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.rejectionReason,
    this.slaMinutes,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    this.requiresConfirmation = false,
    this.requiresPhotoProof = false,
    this.requiresQrValidation = false,
    this.proofPhotoUrl,
    this.employeeFeedback,
    this.employeeRating,
  });

  // lib/crud/models/task_model.dart

factory TaskModel.fromJson(Map<String, dynamic> json) {
  // Ambil assignee name dari foreign key yang benar
  String? assigneeName;
  
  // Coba beberapa kemungkinan struktur foreign key
  if (json['profiles'] != null) {
    // Struktur: profiles (single object)
    assigneeName = json['profiles']['full_name'];
  } else if (json['profiles_assignee'] != null) {
    // Struktur: profiles_assignee (single object)
    assigneeName = json['profiles_assignee']['full_name'];
  } else if (json['assignee_profile'] != null) {
    assigneeName = json['assignee_profile']['full_name'];
  }
  
  // Ambil created_by name
  String? createdByName;
  if (json['profiles_created'] != null) {
    createdByName = json['profiles_created']['full_name'];
  } else if (json['creator_profile'] != null) {
    createdByName = json['creator_profile']['full_name'];
  }
  
  // Ambil related profile name
  String? relatedProfileName;
  if (json['profiles_related'] != null) {
    relatedProfileName = json['profiles_related']['full_name'];
  }
  
  // Ambil task type name
  String? typeName;
  if (json['ref_task_types'] != null) {
    typeName = json['ref_task_types']['task_type_name'];
  } else if (json['task_type'] != null) {
    typeName = json['task_type']['task_type_name'];
  }

  return TaskModel(
    id: json['id']?.toString() ?? '',
    typeId: json['type_id']?.toString() ?? '',
    typeName: typeName,
    assigneeId: json['assignee_id']?.toString() ?? '',
    assigneeName: assigneeName,
    objectName: json['object_name'] ?? '',
    fromRoomId: json['from_room_id']?.toString(),
    fromRoomName: json['rooms_from_room']?['room_name'],
    toRoomId: json['to_room_id']?.toString(),
    toRoomName: json['rooms_to_room']?['room_name'],
    status: json['status'] ?? 'pending',
    priority: json['priority'] ?? 'normal',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    startedAt: json['started_at'] != null
        ? DateTime.parse(json['started_at'])
        : null,
    completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'])
        : null,
    createdById: json['created_by']?.toString(),
    createdByName: createdByName,
    taskOutcome: json['task_outcome'],
    completionNotes: json['completion_notes'],
    assetId: json['asset_id']?.toString(),
    assetName: json['assets_asset']?['asset_name'],
    stockId: json['stock_id']?.toString(),
    stockName: json['stocks_stock']?['stock_name'],
    relatedProfileId: json['related_profile_id']?.toString(),
    relatedProfileName: relatedProfileName,
    acceptedAt: json['accepted_at'] != null
        ? DateTime.parse(json['accepted_at'])
        : null,
    rejectedAt: json['rejected_at'] != null
        ? DateTime.parse(json['rejected_at'])
        : null,
    cancelledAt: json['cancelled_at'] != null
        ? DateTime.parse(json['cancelled_at'])
        : null,
    rejectionReason: json['rejection_reason'],
    slaMinutes: json['sla_minutes'],
    estimatedDurationMinutes: json['estimated_duration_minutes'],
    actualDurationMinutes: json['actual_duration_minutes'],
    requiresConfirmation: json['requires_confirmation'] ?? false,
    requiresPhotoProof: json['requires_photo_proof'] ?? false,
    requiresQrValidation: json['requires_qr_validation'] ?? false,
    proofPhotoUrl: json['proof_photo_url'],
    employeeFeedback: json['employee_feedback'],
    employeeRating: json['employee_rating'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_id': typeId,
      'assignee_id': assigneeId,
      'object_name': objectName,
      'from_room_id': fromRoomId,
      'to_room_id': toRoomId,
      'status': status,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_by': createdById,
      'task_outcome': taskOutcome,
      'completion_notes': completionNotes,
      'asset_id': assetId,
      'stock_id': stockId,
      'related_profile_id': relatedProfileId,
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'sla_minutes': slaMinutes,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'requires_confirmation': requiresConfirmation,
      'requires_photo_proof': requiresPhotoProof,
      'requires_qr_validation': requiresQrValidation,
      'proof_photo_url': proofPhotoUrl,
      'employee_feedback': employeeFeedback,
      'employee_rating': employeeRating,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? typeId,
    String? typeName,
    String? assigneeId,
    String? assigneeName,
    String? objectName,
    String? fromRoomId,
    String? fromRoomName,
    String? toRoomId,
    String? toRoomName,
    String? status,
    String? priority,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? createdById,
    String? createdByName,
    String? taskOutcome,
    String? completionNotes,
    String? assetId,
    String? assetName,
    String? stockId,
    String? stockName,
    String? relatedProfileId,
    String? relatedProfileName,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? cancelledAt,
    String? rejectionReason,
    int? slaMinutes,
    int? estimatedDurationMinutes,
    int? actualDurationMinutes,
    bool? requiresConfirmation,
    bool? requiresPhotoProof,
    bool? requiresQrValidation,
    String? proofPhotoUrl,
    String? employeeFeedback,
    int? employeeRating,
  }) {
    return TaskModel(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      objectName: objectName ?? this.objectName,
      fromRoomId: fromRoomId ?? this.fromRoomId,
      fromRoomName: fromRoomName ?? this.fromRoomName,
      toRoomId: toRoomId ?? this.toRoomId,
      toRoomName: toRoomName ?? this.toRoomName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      taskOutcome: taskOutcome ?? this.taskOutcome,
      completionNotes: completionNotes ?? this.completionNotes,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      relatedProfileId: relatedProfileId ?? this.relatedProfileId,
      relatedProfileName: relatedProfileName ?? this.relatedProfileName,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      slaMinutes: slaMinutes ?? this.slaMinutes,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      requiresPhotoProof: requiresPhotoProof ?? this.requiresPhotoProof,
      requiresQrValidation: requiresQrValidation ?? this.requiresQrValidation,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      employeeFeedback: employeeFeedback ?? this.employeeFeedback,
      employeeRating: employeeRating ?? this.employeeRating,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'accepted': return 'Diterima';
      case 'in_progress': return 'Proses';
      case 'done': return 'Selesai';
      case 'rejected': return 'Ditolak';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'in_progress': return Colors.purple;
      case 'done': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      default: return Colors.grey;
    }
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
}