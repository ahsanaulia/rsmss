// lib/insights/assets/models/asset_detail_model.dart

class AssetDetail {
  final String id;
  final String assetName;
  final String rfidTagId;
  final String? categoryName;
  final String? subCategoryName;
  final String? typeName;
  final String? statusCondition;
  final int? levelContaminated;
  final bool isDangerous;
  final String? roomName;
  final String? detectorCode;
  final String? lastMovementStatus;
  final DateTime? lastDetectedAt;
  final String? handlingInstruction;
  final String? description;
  final String? fotoUrl;
  
  // 🔥 Dari ref_asset_danger_levels
  final String? dangerLevelId;
  final String? dangerLevelCode;
  final String? dangerLevelName;
  final String? dangerRisk;
  final String? dangerProtection;
  final String? dangerInstruction;
  final String? dangerColor;

  AssetDetail({
    required this.id,
    required this.assetName,
    required this.rfidTagId,
    this.categoryName,
    this.subCategoryName,
    this.typeName,
    this.statusCondition,
    this.levelContaminated,
    this.isDangerous = false,
    this.roomName,
    this.detectorCode,
    this.lastMovementStatus,
    this.lastDetectedAt,
    this.handlingInstruction,
    this.description,
    this.fotoUrl,
    this.dangerLevelId,
    this.dangerLevelCode,
    this.dangerLevelName,
    this.dangerRisk,
    this.dangerProtection,
    this.dangerInstruction,
    this.dangerColor,
  });
  
  bool get hasDangerInfo => dangerLevelId != null && dangerLevelId!.isNotEmpty;
}