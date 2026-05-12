class AssetMasterModel {
  final String id;
  final String rfidTagId;
  final String assetName;

  final String? description;
  final String? fotoUrl;

  // CATEGORY
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  // SUB CATEGORY
  final String? subCategoryId;
  final String? subCategoryName;
  final String? subCategoryIcon;
  final String? subCategoryColor;

  // TYPE
  final String? typeId;
  final String? typeName;
  final String? typeIcon;
  final String? typeColor;

  // STATUS
  final String? statusCondition;
  final int? levelContaminated;
  final bool? isDangerous;
  final String? handlingInstruction;
  final String? maintenancePattern;
  final bool? isActive;

  // INSPECTION SUMMARY
  final int? inspectionDayOfMonth;
  final DateTime? lastInspectionAt;
  final DateTime? nextInspectionAt;

  final String? lastInspectionResult;
  final String? lastInspectionNotes;
  final String? lastActionTaken;
  final String? lastRecommendation;

  // ROOM
  final String? roomId;
  final String? roomName;

  // DETECTOR
  final String? detectorId;
  final String? detectorCode;

  // MOVEMENT
  final DateTime? lastDetectedAt;
  final String? lastMovementStatus;

  // LAST USER
  final String? lastUsedById;
  final String? lastUsedByName;
  final String? lastUsedByRole;

  // ASSIGNMENT
  final String? assignmentId;
  final String? assignmentStatus;

  // ASSIGNED PROFILE
  final String? assignedProfileId;
  final String? assignedProfileName;

  // TIMESTAMP
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssetMasterModel({
    required this.id,
    required this.rfidTagId,
    required this.assetName,

    this.description,
    this.fotoUrl,

    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,

    this.subCategoryId,
    this.subCategoryName,
    this.subCategoryIcon,
    this.subCategoryColor,

    this.typeId,
    this.typeName,
    this.typeIcon,
    this.typeColor,

    this.statusCondition,
    this.levelContaminated,
    this.isDangerous,
    this.handlingInstruction,
    this.maintenancePattern,
    this.isActive,

    this.inspectionDayOfMonth,
    this.lastInspectionAt,
    this.nextInspectionAt,

    this.lastInspectionResult,
    this.lastInspectionNotes,
    this.lastActionTaken,
    this.lastRecommendation,

    this.roomId,
    this.roomName,

    this.detectorId,
    this.detectorCode,

    this.lastDetectedAt,
    this.lastMovementStatus,

    this.lastUsedById,
    this.lastUsedByName,
    this.lastUsedByRole,

    this.assignmentId,
    this.assignmentStatus,

    this.assignedProfileId,
    this.assignedProfileName,

    this.createdAt,
    this.updatedAt,
  });

  factory AssetMasterModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssetMasterModel(
      id: json['id'],
      rfidTagId: json['rfid_tag_id'],
      assetName: json['asset_name'],

      description: json['description'],
      fotoUrl: json['foto_url'],

      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      categoryColor: json['category_color'],

      subCategoryId: json['sub_category_id'],
      subCategoryName: json['sub_category_name'],
      subCategoryIcon: json['sub_category_icon'],
      subCategoryColor: json['sub_category_color'],

      typeId: json['type_id'],
      typeName: json['type_name'],
      typeIcon: json['type_icon'],
      typeColor: json['type_color'],

      statusCondition: json['status_condition'],
      levelContaminated:
          json['level_contaminated'],
      isDangerous:
          json['is_dangerous'],

      handlingInstruction:
          json['handling_instruction'],

      maintenancePattern:
          json['maintenance_pattern'],

      isActive: json['is_active'],

      inspectionDayOfMonth:
          json['inspection_day_of_month'],

      lastInspectionAt:
          json['last_inspection_at'] != null
              ? DateTime.parse(
                  json['last_inspection_at'],
                )
              : null,

      nextInspectionAt:
          json['next_inspection_at'] != null
              ? DateTime.parse(
                  json['next_inspection_at'],
                )
              : null,

      lastInspectionResult:
          json['last_inspection_result'],

      lastInspectionNotes:
          json['last_inspection_notes'],

      lastActionTaken:
          json['last_action_taken'],

      lastRecommendation:
          json['last_recommendation'],

      roomId: json['room_id'],
      roomName: json['room_name'],

      detectorId: json['detector_id'],
      detectorCode:
          json['detector_code'],

      lastDetectedAt:
          json['last_detected_at'] != null
              ? DateTime.parse(
                  json['last_detected_at'],
                )
              : null,

      lastMovementStatus:
          json['last_movement_status'],

      lastUsedById:
          json['last_used_by_id'],

      lastUsedByName:
          json['last_used_by_name'],

      lastUsedByRole:
          json['last_used_by_role'],

      assignmentId:
          json['assignment_id'],

      assignmentStatus:
          json['assignment_status'],

      assignedProfileId:
          json['assigned_profile_id'],

      assignedProfileName:
          json['assigned_profile_name'],

      createdAt:
          json['created_at'] != null
              ? DateTime.parse(
                  json['created_at'],
                )
              : null,

      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(
                  json['updated_at'],
                )
              : null,
    );
  }
}