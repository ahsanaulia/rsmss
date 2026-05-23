import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RefBuildingFunctionModel extends Equatable {
  final String? id;
  final String? appId;
  final String functionName;
  final String? description;
  final DateTime? createdAt;
  final String? createdBy;

  const RefBuildingFunctionModel({
    this.id,
    this.appId,
    required this.functionName,
    this.description,
    this.createdAt,
    this.createdBy,
  });

  factory RefBuildingFunctionModel.empty() {
    return const RefBuildingFunctionModel(functionName: '');
  }

  factory RefBuildingFunctionModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RefBuildingFunctionModel.fromJson: $json');
    
    return RefBuildingFunctionModel(
      id: json['id'] as String?,
      appId: json['app_id'] as String?,
      functionName: json['function_name'] as String? ?? '',
      description: json['description'] as String?,
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
      'function_name': functionName.trim(),
      if (description != null && description!.isNotEmpty) 'description': description,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RefBuildingFunctionModel copyWith({
    String? id,
    String? appId,
    String? functionName,
    String? description,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return RefBuildingFunctionModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      functionName: functionName ?? this.functionName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appId,
        functionName,
        description,
        createdAt,
        createdBy,
      ];
}