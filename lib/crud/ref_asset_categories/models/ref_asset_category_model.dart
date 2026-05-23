import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefAssetCategoryModel extends Equatable {
  final String? id;
  final String categoryName;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;

  const RefAssetCategoryModel({
    this.id,
    required this.categoryName,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
  });

  factory RefAssetCategoryModel.empty() {
    return const RefAssetCategoryModel(categoryName: '');
  }

  factory RefAssetCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefAssetCategoryModel.fromJson: $json');
    
    return RefAssetCategoryModel(
      id: json['id'] as String?,
      categoryName: json['category_name'] as String? ?? '',
      iconName: json['icon_name'] as String?,
      markerColor: json['marker_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category_name': categoryName.trim(),
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
      if (markerColor != null && markerColor!.isNotEmpty) 'marker_color': markerColor,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RefAssetCategoryModel copyWith({
    String? id,
    String? categoryName,
    String? iconName,
    String? markerColor,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return RefAssetCategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      iconName: iconName ?? this.iconName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [id, categoryName, iconName, markerColor, createdAt, createdBy];
}