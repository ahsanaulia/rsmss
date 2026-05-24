import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefIncidentCategoryModel extends Equatable {
  final String? id;
  final String code;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RefIncidentCategoryModel({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory RefIncidentCategoryModel.empty() {
    return const RefIncidentCategoryModel(
      code: '',
      name: '',
    );
  }

  factory RefIncidentCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefIncidentCategoryModel.fromJson: $json');

    return RefIncidentCategoryModel(
      id: json['id'] as String?,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      if (description != null && description!.isNotEmpty) 'description': description,
      if (icon != null && icon!.isNotEmpty) 'icon': icon,
      if (color != null && color!.isNotEmpty) 'color': color,
      if (isActive != null) 'is_active': isActive,
    };
  }

  RefIncidentCategoryModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RefIncidentCategoryModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        icon,
        color,
        isActive,
        createdAt,
        updatedAt,
      ];
}