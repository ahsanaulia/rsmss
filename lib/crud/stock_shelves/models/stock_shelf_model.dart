import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class StockShelfModel extends Equatable {
  final String? id;
  final String rackId;
  final int levelNumber;
  final String code;
  final double? maxHeightCm;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? rackCode;
  final String? rackName;
  final String? zoneName;
  final String? zoneCode;
  final String? warehouseName;
  final String? warehouseCode;

  const StockShelfModel({
    this.id,
    required this.rackId,
    required this.levelNumber,
    required this.code,
    this.maxHeightCm,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.rackCode,
    this.rackName,
    this.zoneName,
    this.zoneCode,
    this.warehouseName,
    this.warehouseCode,
  });

  factory StockShelfModel.empty() {
    return const StockShelfModel(
      rackId: '',
      levelNumber: 0,
      code: '',
    );
  }

  factory StockShelfModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockShelfModel.fromJson: $json');
    
    return StockShelfModel(
      id: json['id'] as String?,
      rackId: json['rack_id'] as String? ?? '',
      levelNumber: json['level_number'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      maxHeightCm: json['max_height_cm'] != null 
          ? (json['max_height_cm'] as num).toDouble() 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      rackCode: json['stock_racks'] != null 
          ? (json['stock_racks'] as Map<String, dynamic>)['code'] as String?
          : null,
      rackName: json['stock_racks'] != null 
          ? (json['stock_racks'] as Map<String, dynamic>)['name'] as String?
          : null,
      zoneName: json['stock_racks'] != null && json['stock_racks']['stock_zones'] != null
          ? (json['stock_racks']['stock_zones'] as Map<String, dynamic>)['name'] as String?
          : null,
      zoneCode: json['stock_racks'] != null && json['stock_racks']['stock_zones'] != null
          ? (json['stock_racks']['stock_zones'] as Map<String, dynamic>)['code'] as String?
          : null,
      warehouseName: json['stock_racks'] != null && json['stock_racks']['stock_zones'] != null && json['stock_racks']['stock_zones']['stock_warehouses'] != null
          ? (json['stock_racks']['stock_zones']['stock_warehouses'] as Map<String, dynamic>)['name'] as String?
          : null,
      warehouseCode: json['stock_racks'] != null && json['stock_racks']['stock_zones'] != null && json['stock_racks']['stock_zones']['stock_warehouses'] != null
          ? (json['stock_racks']['stock_zones']['stock_warehouses'] as Map<String, dynamic>)['code'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rack_id': rackId,
      'level_number': levelNumber,
      'code': code.trim().toUpperCase(),
      if (maxHeightCm != null) 'max_height_cm': maxHeightCm,
      if (metadata != null) 'metadata': metadata,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  StockShelfModel copyWith({
    String? id,
    String? rackId,
    int? levelNumber,
    String? code,
    double? maxHeightCm,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? rackCode,
    String? rackName,
    String? zoneName,
    String? zoneCode,
    String? warehouseName,
    String? warehouseCode,
  }) {
    return StockShelfModel(
      id: id ?? this.id,
      rackId: rackId ?? this.rackId,
      levelNumber: levelNumber ?? this.levelNumber,
      code: code ?? this.code,
      maxHeightCm: maxHeightCm ?? this.maxHeightCm,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      rackCode: rackCode ?? this.rackCode,
      rackName: rackName ?? this.rackName,
      zoneName: zoneName ?? this.zoneName,
      zoneCode: zoneCode ?? this.zoneCode,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseCode: warehouseCode ?? this.warehouseCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rackId,
        levelNumber,
        code,
        maxHeightCm,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        rackCode,
        rackName,
        zoneName,
        zoneCode,
        warehouseName,
        warehouseCode,
      ];
}