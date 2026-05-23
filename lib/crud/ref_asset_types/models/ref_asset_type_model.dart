import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefAssetTypeModel extends Equatable {
  final String? id;
  final String typeName;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;
  final String? subCategoryId;
  
  // Untuk display (join data)
  final String? subCategoryName;
  final String? categoryName;

  const RefAssetTypeModel({
    this.id,
    required this.typeName,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
    this.subCategoryId,
    this.subCategoryName,
    this.categoryName,
  });

  factory RefAssetTypeModel.empty() {
    return const RefAssetTypeModel(typeName: '');
  }

  factory RefAssetTypeModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefAssetTypeModel.fromJson: $json');
    
    return RefAssetTypeModel(
      id: json['id'] as String?,
      typeName: json['type_name'] as String? ?? '',
      iconName: json['icon_name'] as String?,
      markerColor: json['marker_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      subCategoryId: json['sub_category_id'] as String?,
      subCategoryName: json['sub_categories'] != null
          ? (json['sub_categories'] as Map<String, dynamic>)['sub_category_name'] as String?
          : null,
      categoryName: json['sub_categories'] != null && json['sub_categories']['categories'] != null
          ? (json['sub_categories']['categories'] as Map<String, dynamic>)['category_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type_name': typeName.trim(),
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
      if (markerColor != null && markerColor!.isNotEmpty) 'marker_color': markerColor,
      if (subCategoryId != null) 'sub_category_id': subCategoryId,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RefAssetTypeModel copyWith({
    String? id,
    String? typeName,
    String? iconName,
    String? markerColor,
    DateTime? createdAt,
    String? createdBy,
    String? subCategoryId,
    String? subCategoryName,
    String? categoryName,
  }) {
    return RefAssetTypeModel(
      id: id ?? this.id,
      typeName: typeName ?? this.typeName,
      iconName: iconName ?? this.iconName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        typeName,
        iconName,
        markerColor,
        createdAt,
        createdBy,
        subCategoryId,
        subCategoryName,
        categoryName,
      ];
}