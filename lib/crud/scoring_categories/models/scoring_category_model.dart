import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class ScoringCategoryModel extends Equatable {
  final String? id;
  final String categoryCode;
  final String categoryName;
  final double? weight;
  final bool? isActive;
  final DateTime? createdAt;

  const ScoringCategoryModel({
    this.id,
    required this.categoryCode,
    required this.categoryName,
    this.weight,
    this.isActive,
    this.createdAt,
  });

  factory ScoringCategoryModel.empty() {
    return const ScoringCategoryModel(
      categoryCode: '',
      categoryName: '',
    );
  }

  factory ScoringCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 ScoringCategoryModel.fromJson: $json');

    return ScoringCategoryModel(
      id: json['id'] as String?,
      categoryCode: json['category_code'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 1.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category_code': categoryCode.trim().toUpperCase(),
      'category_name': categoryName.trim(),
      if (weight != null) 'weight': weight,
      if (isActive != null) 'is_active': isActive,
    };
  }

  ScoringCategoryModel copyWith({
    String? id,
    String? categoryCode,
    String? categoryName,
    double? weight,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ScoringCategoryModel(
      id: id ?? this.id,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryCode,
        categoryName,
        weight,
        isActive,
        createdAt,
      ];
}