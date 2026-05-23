import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class StockRackModel extends Equatable {
  final String? id;
  final String zoneId;
  final String code;
  final String? name;
  final double? capacityKg;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? zoneName;
  final String? zoneCode;
  final String? warehouseName;
  final String? warehouseCode;

  const StockRackModel({
    this.id,
    required this.zoneId,
    required this.code,
    this.name,
    this.capacityKg,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.zoneName,
    this.zoneCode,
    this.warehouseName,
    this.warehouseCode,
  });

  factory StockRackModel.empty() {
    return const StockRackModel(
      zoneId: '',
      code: '',
    );
  }

  factory StockRackModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockRackModel.fromJson: $json');
    
    return StockRackModel(
      id: json['id'] as String?,
      zoneId: json['zone_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String?,
      capacityKg: json['capacity_kg'] != null 
          ? (json['capacity_kg'] as num).toDouble() 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      zoneName: json['stock_zones'] != null 
          ? (json['stock_zones'] as Map<String, dynamic>)['name'] as String?
          : null,
      zoneCode: json['stock_zones'] != null 
          ? (json['stock_zones'] as Map<String, dynamic>)['code'] as String?
          : null,
      warehouseName: json['stock_zones'] != null && json['stock_zones']['stock_warehouses'] != null
          ? (json['stock_zones']['stock_warehouses'] as Map<String, dynamic>)['name'] as String?
          : null,
      warehouseCode: json['stock_zones'] != null && json['stock_zones']['stock_warehouses'] != null
          ? (json['stock_zones']['stock_warehouses'] as Map<String, dynamic>)['code'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'zone_id': zoneId,
      'code': code.trim().toUpperCase(),
      if (name != null && name!.isNotEmpty) 'name': name!.trim(),
      if (capacityKg != null) 'capacity_kg': capacityKg,
      if (metadata != null) 'metadata': metadata,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  StockRackModel copyWith({
    String? id,
    String? zoneId,
    String? code,
    String? name,
    double? capacityKg,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? zoneName,
    String? zoneCode,
    String? warehouseName,
    String? warehouseCode,
  }) {
    return StockRackModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      code: code ?? this.code,
      name: name ?? this.name,
      capacityKg: capacityKg ?? this.capacityKg,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      zoneName: zoneName ?? this.zoneName,
      zoneCode: zoneCode ?? this.zoneCode,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseCode: warehouseCode ?? this.warehouseCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        zoneId,
        code,
        name,
        capacityKg,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        zoneName,
        zoneCode,
        warehouseName,
        warehouseCode,
      ];
}