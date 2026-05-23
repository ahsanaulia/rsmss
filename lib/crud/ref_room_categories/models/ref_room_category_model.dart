import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefRoomCategoryModel extends Equatable {
  final String? id;
  final String? appId;
  final String categoryName;
  final String? colorCode;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;

  const RefRoomCategoryModel({
    this.id,
    this.appId,
    required this.categoryName,
    this.colorCode,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
  });

  factory RefRoomCategoryModel.empty() {
    return const RefRoomCategoryModel(categoryName: '');
  }

  factory RefRoomCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefRoomCategoryModel.fromJson: $json');
    
    return RefRoomCategoryModel(
      id: json['id'] as String?,
      appId: json['app_id'] as String?,
      categoryName: json['category_name'] as String? ?? '',
      colorCode: json['color_code'] as String?,
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
      if (appId != null) 'app_id': appId,
      'category_name': categoryName.trim(),
      if (colorCode != null && colorCode!.isNotEmpty) 'color_code': colorCode,
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
      if (markerColor != null && markerColor!.isNotEmpty) 'marker_color': markerColor,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RefRoomCategoryModel copyWith({
    String? id,
    String? appId,
    String? categoryName,
    String? colorCode,
    String? iconName,
    String? markerColor,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return RefRoomCategoryModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      categoryName: categoryName ?? this.categoryName,
      colorCode: colorCode ?? this.colorCode,
      iconName: iconName ?? this.iconName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appId,
        categoryName,
        colorCode,
        iconName,
        markerColor,
        createdAt,
        createdBy,
      ];
}