import 'dart:io';

class AssetInspectionInputModel {
  final String assetId;
  final String inspectedBy;
  final String? inspectionType;
  final String? inspectionResult;
  final String? conditionStatus;
  final int? contaminationLevel;
  final String? notes;
  final String? actionTaken;
  final String? recommendation;
  final DateTime? nextInspectionAt;
  final File? photo;
  final int? inspectionDurationMinutes;

  AssetInspectionInputModel({
    required this.assetId,
    required this.inspectedBy,
    this.inspectionType,
    this.inspectionResult,
    this.conditionStatus,
    this.contaminationLevel,
    this.notes,
    this.actionTaken,
    this.recommendation,
    this.nextInspectionAt,
    this.photo,
    this.inspectionDurationMinutes,
  });

  Map<String, dynamic> toJson() => {
    'asset_id': assetId,
    'inspected_by': inspectedBy,
    'inspection_type': inspectionType,
    'inspection_result': inspectionResult,
    'condition_status': conditionStatus,
    'contamination_level': contaminationLevel,
    'notes': notes,
    'action_taken': actionTaken,
    'recommendation': recommendation,
    'next_inspection_at': nextInspectionAt?.toIso8601String(),
    'inspection_duration_minutes': inspectionDurationMinutes,
  };
}