import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class StockZoneModel extends Equatable {
  final String? id;
  final String warehouseId;
  final String code;
  final String name;
  final String? zoneType;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? humidityMin;
  final double? humidityMax;
  final bool? isRestricted;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? roomId;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? warehouseName;
  final String? warehouseCode;
  final String? roomName;
  final String? floorName;
  final String? buildingName;

  const StockZoneModel({
    this.id,
    required this.warehouseId,
    required this.code,
    required this.name,
    this.zoneType,
    this.temperatureMin,
    this.temperatureMax,
    this.humidityMin,
    this.humidityMax,
    this.isRestricted,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.roomId,
    this.createdBy,
    this.warehouseName,
    this.warehouseCode,
    this.roomName,
    this.floorName,
    this.buildingName,
  });

  factory StockZoneModel.empty() {
    return const StockZoneModel(
      warehouseId: '',
      code: '',
      name: '',
    );
  }

  factory StockZoneModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockZoneModel.fromJson: $json');
    
    return StockZoneModel(
      id: json['id'] as String?,
      warehouseId: json['warehouse_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      zoneType: json['zone_type'] as String?,
      temperatureMin: json['temperature_min'] != null 
          ? (json['temperature_min'] as num).toDouble() 
          : null,
      temperatureMax: json['temperature_max'] != null 
          ? (json['temperature_max'] as num).toDouble() 
          : null,
      humidityMin: json['humidity_min'] != null 
          ? (json['humidity_min'] as num).toDouble() 
          : null,
      humidityMax: json['humidity_max'] != null 
          ? (json['humidity_max'] as num).toDouble() 
          : null,
      isRestricted: json['is_restricted'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      roomId: json['room_id'] as String?,
      createdBy: json['created_by'] as String?,
      warehouseName: json['stock_warehouses'] != null 
          ? (json['stock_warehouses'] as Map<String, dynamic>)['name'] as String?
          : null,
      warehouseCode: json['stock_warehouses'] != null 
          ? (json['stock_warehouses'] as Map<String, dynamic>)['code'] as String?
          : null,
      roomName: json['rooms'] != null 
          ? (json['rooms'] as Map<String, dynamic>)['room_name'] as String?
          : null,
      floorName: json['rooms'] != null && json['rooms']['floors'] != null
          ? (json['rooms']['floors'] as Map<String, dynamic>)['floor_number']?.toString()
          : null,
      buildingName: json['rooms'] != null && json['rooms']['floors'] != null && json['rooms']['floors']['buildings'] != null
          ? (json['rooms']['floors']['buildings'] as Map<String, dynamic>)['building_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'warehouse_id': warehouseId,
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      if (zoneType != null && zoneType!.isNotEmpty) 'zone_type': zoneType,
      if (temperatureMin != null) 'temperature_min': temperatureMin,
      if (temperatureMax != null) 'temperature_max': temperatureMax,
      if (humidityMin != null) 'humidity_min': humidityMin,
      if (humidityMax != null) 'humidity_max': humidityMax,
      'is_restricted': isRestricted ?? false,
      if (metadata != null) 'metadata': metadata,
      if (roomId != null) 'room_id': roomId,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  StockZoneModel copyWith({
    String? id,
    String? warehouseId,
    String? code,
    String? name,
    String? zoneType,
    double? temperatureMin,
    double? temperatureMax,
    double? humidityMin,
    double? humidityMax,
    bool? isRestricted,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomId,
    String? createdBy,
    String? warehouseName,
    String? warehouseCode,
    String? roomName,
    String? floorName,
    String? buildingName,
  }) {
    return StockZoneModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      code: code ?? this.code,
      name: name ?? this.name,
      zoneType: zoneType ?? this.zoneType,
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      humidityMin: humidityMin ?? this.humidityMin,
      humidityMax: humidityMax ?? this.humidityMax,
      isRestricted: isRestricted ?? this.isRestricted,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomId: roomId ?? this.roomId,
      createdBy: createdBy ?? this.createdBy,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseCode: warehouseCode ?? this.warehouseCode,
      roomName: roomName ?? this.roomName,
      floorName: floorName ?? this.floorName,
      buildingName: buildingName ?? this.buildingName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        warehouseId,
        code,
        name,
        zoneType,
        temperatureMin,
        temperatureMax,
        humidityMin,
        humidityMax,
        isRestricted,
        metadata,
        createdAt,
        updatedAt,
        roomId,
        createdBy,
        warehouseName,
        warehouseCode,
        roomName,
        floorName,
        buildingName,
      ];
}