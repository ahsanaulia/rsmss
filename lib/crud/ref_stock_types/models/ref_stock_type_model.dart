import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefStockTypeModel extends Equatable {
  final String? id;
  final String subCategoryId;
  final String typeName;
  final String? description;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? subCategoryName;
  final String? categoryName;
  final String? categoryId;

  const RefStockTypeModel({
    this.id,
    required this.subCategoryId,
    required this.typeName,
    this.description,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
    this.subCategoryName,
    this.categoryName,
    this.categoryId,
  });

  factory RefStockTypeModel.empty() {
    return const RefStockTypeModel(
      subCategoryId: '',
      typeName: '',
    );
  }

  factory RefStockTypeModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefStockTypeModel.fromJson: $json');
    
    return RefStockTypeModel(
      id: json['id'] as String?,
      subCategoryId: json['sub_category_id'] as String? ?? '',
      typeName: json['type_name'] as String? ?? '',
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      markerColor: json['marker_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      subCategoryName: json['sub_categories'] != null 
          ? (json['sub_categories'] as Map<String, dynamic>)['sub_category_name'] as String?
          : null,
      categoryName: json['sub_categories'] != null && json['sub_categories']['categories'] != null
          ? (json['sub_categories']['categories'] as Map<String, dynamic>)['category_name'] as String?
          : null,
      categoryId: json['sub_categories'] != null 
          ? (json['sub_categories'] as Map<String, dynamic>)['category_id'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sub_category_id': subCategoryId,
      'type_name': typeName.trim(),
      if (description != null && description!.isNotEmpty) 'description': description,
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
      if (markerColor != null && markerColor!.isNotEmpty) 'marker_color': markerColor,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RefStockTypeModel copyWith({
    String? id,
    String? subCategoryId,
    String? typeName,
    String? description,
    String? iconName,
    String? markerColor,
    DateTime? createdAt,
    String? createdBy,
    String? subCategoryName,
    String? categoryName,
    String? categoryId,
  }) {
    return RefStockTypeModel(
      id: id ?? this.id,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      typeName: typeName ?? this.typeName,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subCategoryId,
        typeName,
        description,
        iconName,
        markerColor,
        createdAt,
        createdBy,
        subCategoryName,
        categoryName,
        categoryId,
      ];
}