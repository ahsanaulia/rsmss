import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefStockCategoryModel extends Equatable {
  final String? id;
  final String categoryName;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;

  const RefStockCategoryModel({
    this.id,
    required this.categoryName,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
  });

  factory RefStockCategoryModel.empty() {
    return const RefStockCategoryModel(categoryName: '');
  }

  factory RefStockCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefStockCategoryModel.fromJson: $json');
    
    return RefStockCategoryModel(
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

  RefStockCategoryModel copyWith({
    String? id,
    String? categoryName,
    String? iconName,
    String? markerColor,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return RefStockCategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      iconName: iconName ?? this.iconName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryName,
        iconName,
        markerColor,
        createdAt,
        createdBy,
      ];
}