import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefReportsCategoryModel extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final String? iconName;

  const RefReportsCategoryModel({
    this.id,
    required this.name,
    this.description,
    this.iconName,
  });

  factory RefReportsCategoryModel.empty() {
    return const RefReportsCategoryModel(
      name: '',
    );
  }

  factory RefReportsCategoryModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefReportsCategoryModel.fromJson: $json');

    return RefReportsCategoryModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name.trim(),
      if (description != null && description!.isNotEmpty) 'description': description,
      if (iconName != null && iconName!.isNotEmpty) 'icon_name': iconName,
    };
  }

  RefReportsCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
  }) {
    return RefReportsCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconName,
      ];
}