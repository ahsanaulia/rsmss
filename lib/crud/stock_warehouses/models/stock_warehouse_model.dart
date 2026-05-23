import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class StockWarehouseModel extends Equatable {
  final String? id;
  final String code;
  final String name;
  final String? address;
  final String? managerId;
  final bool? isActive;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? floorId;
  final String? createdBy;
  
  // Untuk display (join data)
  final String? floorName;
  final String? buildingName;
  final String? managerName;

  const StockWarehouseModel({
    this.id,
    required this.code,
    required this.name,
    this.address,
    this.managerId,
    this.isActive,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.floorId,
    this.createdBy,
    this.floorName,
    this.buildingName,
    this.managerName,
  });

  factory StockWarehouseModel.empty() {
    return const StockWarehouseModel(
      code: '',
      name: '',
    );
  }

  factory StockWarehouseModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockWarehouseModel.fromJson: $json');
    
    return StockWarehouseModel(
      id: json['id'] as String?,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      managerId: json['manager_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      floorId: json['floor_id'] as String?,
      createdBy: json['created_by'] as String?,
      floorName: json['floors'] != null
          ? (json['floors'] as Map<String, dynamic>)['floor_number']?.toString()
          : null,
      buildingName: json['floors'] != null && json['floors']['buildings'] != null
          ? (json['floors']['buildings'] as Map<String, dynamic>)['building_name'] as String?
          : null,
      managerName: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['full_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      if (address != null && address!.isNotEmpty) 'address': address,
      if (managerId != null) 'manager_id': managerId,
      'is_active': isActive ?? true,
      if (metadata != null) 'metadata': metadata,
      if (floorId != null) 'floor_id': floorId,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  StockWarehouseModel copyWith({
    String? id,
    String? code,
    String? name,
    String? address,
    String? managerId,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? floorId,
    String? createdBy,
    String? floorName,
    String? buildingName,
    String? managerName,
  }) {
    return StockWarehouseModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      managerId: managerId ?? this.managerId,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      floorId: floorId ?? this.floorId,
      createdBy: createdBy ?? this.createdBy,
      floorName: floorName ?? this.floorName,
      buildingName: buildingName ?? this.buildingName,
      managerName: managerName ?? this.managerName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        address,
        managerId,
        isActive,
        metadata,
        createdAt,
        updatedAt,
        floorId,
        createdBy,
        floorName,
        buildingName,
        managerName,
      ];
}