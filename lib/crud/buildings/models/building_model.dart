import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class BuildingModel extends Equatable {
  final String? id;
  final String? appId;
  final String? hospitalId;
  final String buildingName;
  final String? functionId;
  final int? totalFloors;
  final DateTime? createdAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? hospitalName;
  final String? functionName;

  const BuildingModel({
    this.id,
    this.appId,
    this.hospitalId,
    required this.buildingName,
    this.functionId,
    this.totalFloors,
    this.createdAt,
    this.createdBy,
    this.hospitalName,
    this.functionName,
  });

  factory BuildingModel.empty() {
    return const BuildingModel(buildingName: '');
  }

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 BuildingModel.fromJson: $json');
    
    return BuildingModel(
      id: json['id'] as String?,
      appId: json['app_id'] as String?,
      hospitalId: json['hospital_id'] as String?,
      buildingName: json['building_name'] as String? ?? '',
      functionId: json['function_id'] as String?,
      totalFloors: json['total_floors'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      hospitalName: json['hospital_profile'] != null 
          ? (json['hospital_profile'] as Map<String, dynamic>)['name'] as String?
          : null,
      functionName: json['ref_building_functions'] != null 
          ? (json['ref_building_functions'] as Map<String, dynamic>)['function_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (hospitalId != null) 'hospital_id': hospitalId,
      'building_name': buildingName.trim(),
      if (functionId != null) 'function_id': functionId,
      if (totalFloors != null) 'total_floors': totalFloors,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  BuildingModel copyWith({
    String? id,
    String? appId,
    String? hospitalId,
    String? buildingName,
    String? functionId,
    int? totalFloors,
    DateTime? createdAt,
    String? createdBy,
    String? hospitalName,
    String? functionName,
  }) {
    return BuildingModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      hospitalId: hospitalId ?? this.hospitalId,
      buildingName: buildingName ?? this.buildingName,
      functionId: functionId ?? this.functionId,
      totalFloors: totalFloors ?? this.totalFloors,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      hospitalName: hospitalName ?? this.hospitalName,
      functionName: functionName ?? this.functionName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appId,
        hospitalId,
        buildingName,
        functionId,
        totalFloors,
        createdAt,
        createdBy,
        hospitalName,
        functionName,
      ];
}