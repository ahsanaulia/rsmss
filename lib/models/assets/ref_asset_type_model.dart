// File: lib/models/assets/ref_asset_type_model.dart

class RefAssetTypeModel {
  final String id;
  final String typeName;
  final String? iconName;
  final DateTime? createdAt;
  final String? markerColor;
  final String? subCategoryId;

  const RefAssetTypeModel({
    required this.id,
    required this.typeName,
    this.iconName,
    this.createdAt,
    this.markerColor,
    this.subCategoryId,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory RefAssetTypeModel.fromJson(Map<String, dynamic> json) {
    return RefAssetTypeModel(
      id: json['id']?.toString() ?? '',

      typeName: json['type_name']?.toString() ?? '',

      iconName: json['icon_name']?.toString(),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,

      markerColor: json['marker_color']?.toString(),

      subCategoryId: json['sub_category_id']?.toString(),
    );
  }

  // =====================================================
  // TO JSON
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_name': typeName,
      'icon_name': iconName,
      'created_at': createdAt?.toIso8601String(),
      'marker_color': markerColor,
      'sub_category_id': subCategoryId,
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  RefAssetTypeModel copyWith({
    String? id,
    String? typeName,
    String? iconName,
    DateTime? createdAt,
    String? markerColor,
    String? subCategoryId,
  }) {
    return RefAssetTypeModel(
      id: id ?? this.id,
      typeName: typeName ?? this.typeName,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      markerColor: markerColor ?? this.markerColor,
      subCategoryId: subCategoryId ?? this.subCategoryId,
    );
  }

  // =====================================================
  // UI HELPERS
  // =====================================================

  bool get hasIcon =>
      iconName != null && iconName!.trim().isNotEmpty;

  bool get hasMarkerColor =>
      markerColor != null && markerColor!.trim().isNotEmpty;

  bool get hasSubCategory =>
      subCategoryId != null &&
      subCategoryId!.trim().isNotEmpty;

  // =====================================================
  // EMPTY
  // =====================================================

  factory RefAssetTypeModel.empty() {
    return const RefAssetTypeModel(
      id: '',
      typeName: '',
      iconName: null,
      createdAt: null,
      markerColor: null,
      subCategoryId: null,
    );
  }

  // =====================================================
  // EQUALITY
  // =====================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RefAssetTypeModel &&
        other.id == id &&
        other.typeName == typeName &&
        other.iconName == iconName &&
        other.createdAt == createdAt &&
        other.markerColor == markerColor &&
        other.subCategoryId == subCategoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        typeName.hashCode ^
        iconName.hashCode ^
        createdAt.hashCode ^
        markerColor.hashCode ^
        subCategoryId.hashCode;
  }

  @override
  String toString() {
    return '''
RefAssetTypeModel(
  id: $id,
  typeName: $typeName,
  iconName: $iconName,
  createdAt: $createdAt,
  markerColor: $markerColor,
  subCategoryId: $subCategoryId,
)
''';
  }
}