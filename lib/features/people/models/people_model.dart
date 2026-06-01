// lib/features/people/models/people_model.dart

class PeopleModel {
  final String? id;
  final String? appId;
  final String rfidTagId;
  final String fullName;
  final String? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String? fotoUrl;
  final bool isMale;
  final bool isChild;
  final DateTime createdAt;
  final bool isActive;
  final String? lastDetectorId;
  final String? lastRoomId;
  final DateTime? lastDetectedAt;
  final String? lastMovementStatus;
  final DateTime? updatedAt;
  final String? levelContaminated;

  PeopleModel({
    this.id,
    this.appId,
    required this.rfidTagId,
    required this.fullName,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.fotoUrl,
    required this.isMale,
    required this.isChild,
    required this.createdAt,
    required this.isActive,
    this.lastDetectorId,
    this.lastRoomId,
    this.lastDetectedAt,
    this.lastMovementStatus,
    this.updatedAt,
    this.levelContaminated,
  });

  factory PeopleModel.fromJson(Map<String, dynamic> json) {
    return PeopleModel(
      id: json['id'],
      appId: json['app_id'],
      rfidTagId: json['rfid_tag_id'] ?? '',
      fullName: json['full_name'] ?? '',
      categoryId: json['category_id'],
      categoryName: json['ref_people_categories'] != null
          ? json['ref_people_categories']['category_name']
          : null,
      categoryColor: json['ref_people_categories'] != null
          ? json['ref_people_categories']['marker_color']
          : null,
      fotoUrl: json['foto_url'],
      isMale: json['is_male'] ?? true,
      isChild: json['is_child'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
      lastDetectorId: json['last_detector_id'],
      lastRoomId: json['last_room_id'],
      lastDetectedAt: json['last_detected_at'] != null
          ? DateTime.parse(json['last_detected_at'])
          : null,
      lastMovementStatus: json['last_movement_status'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      levelContaminated: json['level_contaminated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rfid_tag_id': rfidTagId,
      'full_name': fullName,
      'category_id': categoryId,
      'foto_url': fotoUrl,
      'is_male': isMale,
      'is_child': isChild,
      'is_active': isActive,
      'level_contaminated': levelContaminated,
    };
  }

  PeopleModel copyWith({
    String? id,
    String? appId,
    String? rfidTagId,
    String? fullName,
    String? categoryId,
    String? categoryName,
    String? categoryColor,
    String? fotoUrl,
    bool? isMale,
    bool? isChild,
    DateTime? createdAt,
    bool? isActive,
    String? lastDetectorId,
    String? lastRoomId,
    DateTime? lastDetectedAt,
    String? lastMovementStatus,
    DateTime? updatedAt,
    String? levelContaminated,
  }) {
    return PeopleModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      rfidTagId: rfidTagId ?? this.rfidTagId,
      fullName: fullName ?? this.fullName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      isMale: isMale ?? this.isMale,
      isChild: isChild ?? this.isChild,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      lastDetectorId: lastDetectorId ?? this.lastDetectorId,
      lastRoomId: lastRoomId ?? this.lastRoomId,
      lastDetectedAt: lastDetectedAt ?? this.lastDetectedAt,
      lastMovementStatus: lastMovementStatus ?? this.lastMovementStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      levelContaminated: levelContaminated ?? this.levelContaminated,
    );
  }
}

// Model untuk kategori people
class PeopleCategory {
  final String id;
  final String categoryName;
  final String? markerColor;
  final bool? isInsider;

  PeopleCategory({
    required this.id,
    required this.categoryName,
    this.markerColor,
    this.isInsider,
  });

  factory PeopleCategory.fromJson(Map<String, dynamic> json) {
    return PeopleCategory(
      id: json['id'],
      categoryName: json['category_name'] ?? '',
      markerColor: json['marker_color'],
      isInsider: json['is_insider'],
    );
  }
}