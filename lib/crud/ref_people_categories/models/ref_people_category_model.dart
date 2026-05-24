import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefPeopleCategoryModel extends Equatable {
  final String? id;
  final String categoryName;
  final String? markerColor;
  final DateTime? createdAt;
  final bool? isInsider;

  const RefPeopleCategoryModel({
    this.id,
    required this.categoryName,
    this.markerColor,
    this.createdAt,
    this.isInsider,
  });

  factory RefPeopleCategoryModel.empty() {
    return const RefPeopleCategoryModel(
      categoryName: '',
    );
  }

  factory RefPeopleCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefPeopleCategoryModel.fromJson: $json');

    return RefPeopleCategoryModel(
      id: json['id'] as String?,
      categoryName: json['category_name'] as String? ?? '',
      markerColor: json['marker_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      isInsider: json['is_insider'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category_name': categoryName.trim(),
      if (markerColor != null && markerColor!.isNotEmpty) 'marker_color': markerColor,
      if (isInsider != null) 'is_insider': isInsider,
    };
  }

  RefPeopleCategoryModel copyWith({
    String? id,
    String? categoryName,
    String? markerColor,
    DateTime? createdAt,
    bool? isInsider,
  }) {
    return RefPeopleCategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      markerColor: markerColor ?? this.markerColor,
      createdAt: createdAt ?? this.createdAt,
      isInsider: isInsider ?? this.isInsider,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryName,
        markerColor,
        createdAt,
        isInsider,
      ];
}