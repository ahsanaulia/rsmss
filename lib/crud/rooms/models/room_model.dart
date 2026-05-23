import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class RoomModel extends Equatable {
  final String? id;
  final String? appId;
  final String? floorId;
  final String roomName;
  final String? categoryId;
  final bool? isEntryGate;
  final double? xPos;
  final double? yPos;
  final int? xPosMax;
  final int? yPosMax;
  final DateTime? createdAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? floorName;
  final String? buildingName;
  final String? categoryName;
  final String? categoryColorCode;
  final String? categoryIconName;

  const RoomModel({
    this.id,
    this.appId,
    this.floorId,
    required this.roomName,
    this.categoryId,
    this.isEntryGate,
    this.xPos,
    this.yPos,
    this.xPosMax,
    this.yPosMax,
    this.createdAt,
    this.createdBy,
    this.floorName,
    this.buildingName,
    this.categoryName,
    this.categoryColorCode,
    this.categoryIconName,
  });

  factory RoomModel.empty() {
    return const RoomModel(roomName: '');
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 RoomModel.fromJson: $json');
    
    return RoomModel(
      id: json['id'] as String?,
      appId: json['app_id'] as String?,
      floorId: json['floor_id'] as String?,
      roomName: json['room_name'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      isEntryGate: json['is_entry_gate'] as bool? ?? false,
      xPos: json['x_pos'] != null ? (json['x_pos'] as num).toDouble() : null,
      yPos: json['y_pos'] != null ? (json['y_pos'] as num).toDouble() : null,
      xPosMax: json['x_pos_max'] as int?,
      yPosMax: json['y_pos_max'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      floorName: json['floors'] != null 
          ? (json['floors'] as Map<String, dynamic>)['floor_number']?.toString()
          : null,
      buildingName: json['floors'] != null && json['floors']['buildings'] != null
          ? (json['floors']['buildings'] as Map<String, dynamic>)['building_name'] as String?
          : null,
      categoryName: json['ref_room_categories'] != null 
          ? (json['ref_room_categories'] as Map<String, dynamic>)['category_name'] as String?
          : null,
      categoryColorCode: json['ref_room_categories'] != null 
          ? (json['ref_room_categories'] as Map<String, dynamic>)['color_code'] as String?
          : null,
      categoryIconName: json['ref_room_categories'] != null 
          ? (json['ref_room_categories'] as Map<String, dynamic>)['icon_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (floorId != null) 'floor_id': floorId,
      'room_name': roomName.trim(),
      if (categoryId != null) 'category_id': categoryId,
      'is_entry_gate': isEntryGate ?? false,
      if (xPos != null) 'x_pos': xPos,
      if (yPos != null) 'y_pos': yPos,
      if (xPosMax != null) 'x_pos_max': xPosMax,
      if (yPosMax != null) 'y_pos_max': yPosMax,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  RoomModel copyWith({
    String? id,
    String? appId,
    String? floorId,
    String? roomName,
    String? categoryId,
    bool? isEntryGate,
    double? xPos,
    double? yPos,
    int? xPosMax,
    int? yPosMax,
    DateTime? createdAt,
    String? createdBy,
    String? floorName,
    String? buildingName,
    String? categoryName,
    String? categoryColorCode,
    String? categoryIconName,
  }) {
    return RoomModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      floorId: floorId ?? this.floorId,
      roomName: roomName ?? this.roomName,
      categoryId: categoryId ?? this.categoryId,
      isEntryGate: isEntryGate ?? this.isEntryGate,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      xPosMax: xPosMax ?? this.xPosMax,
      yPosMax: yPosMax ?? this.yPosMax,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      floorName: floorName ?? this.floorName,
      buildingName: buildingName ?? this.buildingName,
      categoryName: categoryName ?? this.categoryName,
      categoryColorCode: categoryColorCode ?? this.categoryColorCode,
      categoryIconName: categoryIconName ?? this.categoryIconName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appId,
        floorId,
        roomName,
        categoryId,
        isEntryGate,
        xPos,
        yPos,
        xPosMax,
        yPosMax,
        createdAt,
        createdBy,
        floorName,
        buildingName,
        categoryName,
        categoryColorCode,
        categoryIconName,
      ];
}