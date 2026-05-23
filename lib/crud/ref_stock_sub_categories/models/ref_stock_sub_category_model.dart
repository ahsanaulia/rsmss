import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefStockSubCategoryModel extends Equatable {
  final String? id;
  final String categoryId;
  final String subCategoryName;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? categoryName;
  final String? categoryIconName;
  final String? categoryMarkerColor;

  const RefStockSubCategoryModel({
    this.id,
    required this.categoryId,
    required this.subCategoryName,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
    this.categoryName,
    this.categoryIconName,
    this.categoryMarkerColor,
  });

  factory RefStockSubCategoryModel.empty() {
    return const RefStockSubCategoryModel(
      categoryId: '',
      subCategoryName: '',
    );
  }

  factory RefStockSubCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefStockSubCategoryModel.fromJson: $json');
    
    return RefStockSubCategoryModel(
      id: json['id'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      subCategoryName: json['sub_category_name'] as String? ?? '',
      iconName: json['icon_name'] as String?,
      markerColor: json['marker_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      categoryName: json['categories'] != null 
          ? (json['categories'] as Map<String, dynamic>)['category_name'] as String?
          : null,
      categoryIconName: json['categories'] != null 
          ? (json['categories'] as Map<String, dynamic>)['icon_name'] as String?
          : null,
      categoryMarkerColor: json['categories'] != null 
          ? (json['categories'] as Map<String, dynamic>)['marker_color'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'sub_category_name': subCategoryName.trim(),
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
      if (markerColor != null && markerColor!.isNotEmpty) 'marker_color': markerColor,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RefStockSubCategoryModel copyWith({
    String? id,
    String? categoryId,
    String? subCategoryName,
    String? iconName,
    String? markerColor,
    DateTime? createdAt,
    String? createdBy,
    String? categoryName,
    String? categoryIconName,
    String? categoryMarkerColor,
  }) {
    return RefStockSubCategoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      iconName: iconName ?? this.iconName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      categoryName: categoryName ?? this.categoryName,
      categoryIconName: categoryIconName ?? this.categoryIconName,
      categoryMarkerColor: categoryMarkerColor ?? this.categoryMarkerColor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        subCategoryName,
        iconName,
        markerColor,
        createdAt,
        createdBy,
        categoryName,
        categoryIconName,
        categoryMarkerColor,
      ];
}