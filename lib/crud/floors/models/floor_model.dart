import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class FloorModel extends Equatable {
  final String? id;
  final String? appId;
  final String? buildingId;
  final int floorNumber;
  final String? floorAlias;
  final String? mapImageUrl;
  final DateTime? createdAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? buildingName;

  const FloorModel({
    this.id,
    this.appId,
    this.buildingId,
    required this.floorNumber,
    this.floorAlias,
    this.mapImageUrl,
    this.createdAt,
    this.createdBy,
    this.buildingName,
  });

  factory FloorModel.empty() {
    return const FloorModel(floorNumber: 0);
  }

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 FloorModel.fromJson: $json');
    
    return FloorModel(
      id: json['id'] as String?,
      appId: json['app_id'] as String?,
      buildingId: json['building_id'] as String?,
      floorNumber: json['floor_number'] as int? ?? 0,
      floorAlias: json['floor_alias'] as String?,
      mapImageUrl: json['map_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      buildingName: json['buildings'] != null 
          ? (json['buildings'] as Map<String, dynamic>)['building_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (buildingId != null) 'building_id': buildingId,
      'floor_number': floorNumber,
      if (floorAlias != null && floorAlias!.isNotEmpty) 'floor_alias': floorAlias,
      if (mapImageUrl != null && mapImageUrl!.isNotEmpty) 'map_image_url': mapImageUrl,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  FloorModel copyWith({
    String? id,
    String? appId,
    String? buildingId,
    int? floorNumber,
    String? floorAlias,
    String? mapImageUrl,
    DateTime? createdAt,
    String? createdBy,
    String? buildingName,
  }) {
    return FloorModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      buildingId: buildingId ?? this.buildingId,
      floorNumber: floorNumber ?? this.floorNumber,
      floorAlias: floorAlias ?? this.floorAlias,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      buildingName: buildingName ?? this.buildingName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appId,
        buildingId,
        floorNumber,
        floorAlias,
        mapImageUrl,
        createdAt,
        createdBy,
        buildingName,
      ];
}