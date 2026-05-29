// ============================================================
// MODEL: Asset
// Mewakili tabel 'assets' di Supabase dengan semua relasi
// ============================================================

import 'package:flutter/material.dart';

/// Model untuk Aset Rumah Sakit
class Asset {
  // === Primary & Identitas ===
  final String id;
  final String rfidTagId;
  final String assetName;
  final String? fotoUrl;
  final String? qrcodeUrl;
  
  // === Klasifikasi ===
  final String? typeId;
  final String? typeName;
  final String? subCategoryName;
  final String? categoryName;
  
  // === Kondisi Aset ===
  final String statusCondition;
  final int levelContaminated;
  final bool isDangerous;
  final String? handlingInstruction;
  
  // === Perawatan ===
  final String? maintenancePattern;
  final int? inspectionDayOfMonth;
  final DateTime? lastInspectionAt;
  final DateTime? nextInspectionAt;
  
  // === Status Operasional ===
  final bool isActive;
  final String? description;
  
  // === Lokasi ===
  final String? lastRoomId;
  final String? lastRoomName;
  final String? lastDetectorId;
  final DateTime? lastDetectedAt;
  final String? lastMovementStatus;
  
  // === Assignment ===
  final String? lastUsedBy;
  final String? lastUsedByName;
  final DateTime? lastAssignedAt;
  
  // === Inspeksi ===
  final String? lastInspectionId;
  final String? lastInspectionResult;
  final String? lastInspectionNotes;
  final String? lastActionTaken;
  final String? lastRecommendation;
  
  // === Metadata ===
  final String? registeredBy;
  final String? registeredByName;
  final DateTime registeredAt;
  final String? updatedBy;
  final String? updatedByName;
  final DateTime updatedAt;

  // === Tingkat Bahaya (Danger Level) ===
  final String? dangerLevelId;
  final String? dangerLevelName;
  final String? dangerLevelCode;
  final String? dangerColor;

  const Asset({
    required this.id,
    required this.rfidTagId,
    required this.assetName,
    this.fotoUrl,
    this.qrcodeUrl,
    this.typeId,
    this.typeName,
    this.subCategoryName,
    this.categoryName,
    this.statusCondition = 'Good',
    this.levelContaminated = 0,
    this.isDangerous = false,
    this.handlingInstruction,
    this.maintenancePattern,
    this.inspectionDayOfMonth,
    this.lastInspectionAt,
    this.nextInspectionAt,
    this.isActive = true,
    this.description,
    this.lastRoomId,
    this.lastRoomName,
    this.lastDetectorId,
    this.lastDetectedAt,
    this.lastMovementStatus,
    this.lastUsedBy,
    this.lastUsedByName,
    this.lastAssignedAt,
    this.lastInspectionId,
    this.lastInspectionResult,
    this.lastInspectionNotes,
    this.lastActionTaken,
    this.lastRecommendation,
    this.registeredBy,
    this.registeredByName,
    required this.registeredAt,
    this.updatedBy,
    this.updatedByName,
    required this.updatedAt,
    this.dangerLevelId,
    this.dangerLevelName,
    this.dangerLevelCode,
    this.dangerColor,
  });

  /// Empty asset untuk initial form (create new asset)
  factory Asset.empty() {
    return Asset(
      id: '',
      rfidTagId: '',
      assetName: '',
      registeredAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dangerLevelId: null,
      dangerLevelName: null,
      dangerLevelCode: null,
      dangerColor: null,
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      rfidTagId: json['rfid_tag_id'] as String,
      assetName: json['asset_name'] as String,
      fotoUrl: json['foto_url'] as String?,
      qrcodeUrl: json['qrcode_url'] as String?,
      typeId: json['type_id'] as String?,
      typeName: json['type_name'] as String?,
      subCategoryName: json['sub_category_name'] as String?,
      categoryName: json['category_name'] as String?,
      statusCondition: json['status_condition'] as String? ?? 'Good',
      levelContaminated: json['level_contaminated'] as int? ?? 0,
      isDangerous: json['is_dangerous'] as bool? ?? false,
      handlingInstruction: json['handling_instruction'] as String?,
      maintenancePattern: json['maintenance_pattern'] as String?,
      inspectionDayOfMonth: json['inspection_day_of_month'] as int?,
      lastInspectionAt: json['last_inspection_at'] != null
          ? DateTime.parse(json['last_inspection_at'] as String)
          : null,
      nextInspectionAt: json['next_inspection_at'] != null
          ? DateTime.parse(json['next_inspection_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
      lastRoomId: json['last_room_id'] as String?,
      lastRoomName: json['room_name'] as String?,
      lastDetectorId: json['last_detector_id'] as String?,
      lastDetectedAt: json['last_detected_at'] != null
          ? DateTime.parse(json['last_detected_at'] as String)
          : null,
      lastMovementStatus: json['last_movement_status'] as String?,
      lastUsedBy: json['last_used_by'] as String?,
      lastUsedByName: json['last_used_by_name'] as String?,
      lastAssignedAt: json['last_assigned_at'] != null
          ? DateTime.parse(json['last_assigned_at'] as String)
          : null,
      lastInspectionId: json['last_inspection_id'] as String?,
      lastInspectionResult: json['last_inspection_result'] as String?,
      lastInspectionNotes: json['last_inspection_notes'] as String?,
      lastActionTaken: json['last_action_taken'] as String?,
      lastRecommendation: json['last_recommendation'] as String?,
      registeredBy: json['registered_by'] as String?,
      registeredByName: json['registered_by_name'] as String?,
      registeredAt: DateTime.parse(json['registered_at'] as String),
      updatedBy: json['updated_by'] as String?,
      updatedByName: json['updated_by_name'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Danger Level
      dangerLevelId: json['danger_level_id'] as String?,
      dangerLevelName: json['danger_level_name'] as String?,
      dangerLevelCode: json['danger_level_code'] as String?,
      dangerColor: json['danger_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rfid_tag_id': rfidTagId,
      'asset_name': assetName,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (typeId != null) 'type_id': typeId,
      'status_condition': statusCondition,
      'level_contaminated': levelContaminated,
      'is_dangerous': isDangerous,
      if (handlingInstruction != null) 'handling_instruction': handlingInstruction,
      if (maintenancePattern != null) 'maintenance_pattern': maintenancePattern,
      if (inspectionDayOfMonth != null) 'inspection_day_of_month': inspectionDayOfMonth,
      'is_active': isActive,
      if (description != null) 'description': description,
      if (lastRoomId != null) 'last_room_id': lastRoomId,
      if (dangerLevelId != null) 'danger_level_id': dangerLevelId,
      if (updatedBy != null) 'updated_by': updatedBy,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForCreate(String userId) {
    return {
      'rfid_tag_id': rfidTagId,
      'asset_name': assetName,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (typeId != null) 'type_id': typeId,
      'status_condition': statusCondition,
      'level_contaminated': levelContaminated,
      'is_dangerous': isDangerous,
      if (handlingInstruction != null) 'handling_instruction': handlingInstruction,
      if (maintenancePattern != null) 'maintenance_pattern': maintenancePattern,
      if (inspectionDayOfMonth != null) 'inspection_day_of_month': inspectionDayOfMonth,
      'is_active': isActive,
      if (description != null) 'description': description,
      if (lastRoomId != null) 'last_room_id': lastRoomId,
      if (dangerLevelId != null) 'danger_level_id': dangerLevelId,
      'registered_by': userId,
      'registered_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Asset copyWith({
    String? id,
    String? rfidTagId,
    String? assetName,
    String? fotoUrl,
    String? qrcodeUrl,
    String? typeId,
    String? typeName,
    String? subCategoryName,
    String? categoryName,
    String? statusCondition,
    int? levelContaminated,
    bool? isDangerous,
    String? handlingInstruction,
    String? maintenancePattern,
    int? inspectionDayOfMonth,
    DateTime? lastInspectionAt,
    DateTime? nextInspectionAt,
    bool? isActive,
    String? description,
    String? lastRoomId,
    String? lastRoomName,
    String? lastDetectorId,
    DateTime? lastDetectedAt,
    String? lastMovementStatus,
    String? lastUsedBy,
    String? lastUsedByName,
    DateTime? lastAssignedAt,
    String? lastInspectionId,
    String? lastInspectionResult,
    String? lastInspectionNotes,
    String? lastActionTaken,
    String? lastRecommendation,
    String? registeredBy,
    String? registeredByName,
    DateTime? registeredAt,
    String? updatedBy,
    String? updatedByName,
    DateTime? updatedAt,
    String? dangerLevelId,
    String? dangerLevelName,
    String? dangerLevelCode,
    String? dangerColor,
  }) {
    return Asset(
      id: id ?? this.id,
      rfidTagId: rfidTagId ?? this.rfidTagId,
      assetName: assetName ?? this.assetName,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      qrcodeUrl: qrcodeUrl ?? this.qrcodeUrl,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      categoryName: categoryName ?? this.categoryName,
      statusCondition: statusCondition ?? this.statusCondition,
      levelContaminated: levelContaminated ?? this.levelContaminated,
      isDangerous: isDangerous ?? this.isDangerous,
      handlingInstruction: handlingInstruction ?? this.handlingInstruction,
      maintenancePattern: maintenancePattern ?? this.maintenancePattern,
      inspectionDayOfMonth: inspectionDayOfMonth ?? this.inspectionDayOfMonth,
      lastInspectionAt: lastInspectionAt ?? this.lastInspectionAt,
      nextInspectionAt: nextInspectionAt ?? this.nextInspectionAt,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      lastRoomId: lastRoomId ?? this.lastRoomId,
      lastRoomName: lastRoomName ?? this.lastRoomName,
      lastDetectorId: lastDetectorId ?? this.lastDetectorId,
      lastDetectedAt: lastDetectedAt ?? this.lastDetectedAt,
      lastMovementStatus: lastMovementStatus ?? this.lastMovementStatus,
      lastUsedBy: lastUsedBy ?? this.lastUsedBy,
      lastUsedByName: lastUsedByName ?? this.lastUsedByName,
      lastAssignedAt: lastAssignedAt ?? this.lastAssignedAt,
      lastInspectionId: lastInspectionId ?? this.lastInspectionId,
      lastInspectionResult: lastInspectionResult ?? this.lastInspectionResult,
      lastInspectionNotes: lastInspectionNotes ?? this.lastInspectionNotes,
      lastActionTaken: lastActionTaken ?? this.lastActionTaken,
      lastRecommendation: lastRecommendation ?? this.lastRecommendation,
      registeredBy: registeredBy ?? this.registeredBy,
      registeredByName: registeredByName ?? this.registeredByName,
      registeredAt: registeredAt ?? this.registeredAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
      updatedAt: updatedAt ?? this.updatedAt,
      dangerLevelId: dangerLevelId ?? this.dangerLevelId,
      dangerLevelName: dangerLevelName ?? this.dangerLevelName,
      dangerLevelCode: dangerLevelCode ?? this.dangerLevelCode,
      dangerColor: dangerColor ?? this.dangerColor,
    );
  }

  @override
  String toString() {
    return 'Asset(id: $id, rfidTagId: $rfidTagId, assetName: $assetName, statusCondition: $statusCondition)';
  }
}

/// Helper untuk level kontaminasi (0-5)
class ContaminationLevel {
  static const int min = 0;
  static const int max = 5;
  
  static String getLabel(int level) {
    switch (level) {
      case 0: return 'Bersih (Tidak Terkontaminasi)';
      case 1: return 'Risiko Rendah';
      case 2: return 'Terkontaminasi Ringan';
      case 3: return 'Terkontaminasi Sedang';
      case 4: return 'Terkontaminasi Berat';
      case 5: return 'Kritis (Bahaya)';
      default: return 'Tidak diketahui';
    }
  }
  
  static Color getColor(int level) {
    switch (level) {
      case 0: return Colors.green;
      case 1: return Colors.lightGreen;
      case 2: return Colors.yellow;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }
}