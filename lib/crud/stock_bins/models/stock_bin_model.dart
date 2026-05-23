import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class StockBinModel extends Equatable {
  final String? id;
  final String shelfId;
  final String code;
  final String? barcode;
  final int? positionX;
  final int? positionY;
  final double? maxQuantity;
  final double? currentQuantity;
  final bool? isActive;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? qrcodeUrl;
  final String? assetId;
  
  // Untuk display (join data)
  final String? shelfCode;
  final String? shelfLevelNumber;
  final String? rackCode;
  final String? rackName;
  final String? zoneName;
  final String? warehouseName;
  final String? assetName;
  final String? assetCode;

  const StockBinModel({
    this.id,
    required this.shelfId,
    required this.code,
    this.barcode,
    this.positionX,
    this.positionY,
    this.maxQuantity,
    this.currentQuantity,
    this.isActive,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.qrcodeUrl,
    this.assetId,
    this.shelfCode,
    this.shelfLevelNumber,
    this.rackCode,
    this.rackName,
    this.zoneName,
    this.warehouseName,
    this.assetName,
    this.assetCode,
  });

  factory StockBinModel.empty() {
    return const StockBinModel(
      shelfId: '',
      code: '',
    );
  }

  factory StockBinModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockBinModel.fromJson: $json');
    
    return StockBinModel(
      id: json['id'] as String?,
      shelfId: json['shelf_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      barcode: json['barcode'] as String?,
      positionX: json['position_x'] as int?,
      positionY: json['position_y'] as int?,
      maxQuantity: json['max_quantity'] != null 
          ? (json['max_quantity'] as num).toDouble() 
          : null,
      currentQuantity: json['current_quantity'] != null 
          ? (json['current_quantity'] as num).toDouble() 
          : 0,
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      qrcodeUrl: json['qrcode_url'] as String?,
      assetId: json['asset_id'] as String?,
      shelfCode: json['stock_shelves'] != null 
          ? (json['stock_shelves'] as Map<String, dynamic>)['code'] as String?
          : null,
      shelfLevelNumber: json['stock_shelves'] != null 
          ? (json['stock_shelves'] as Map<String, dynamic>)['level_number']?.toString()
          : null,
      rackCode: json['stock_shelves'] != null && json['stock_shelves']['stock_racks'] != null
          ? (json['stock_shelves']['stock_racks'] as Map<String, dynamic>)['code'] as String?
          : null,
      rackName: json['stock_shelves'] != null && json['stock_shelves']['stock_racks'] != null
          ? (json['stock_shelves']['stock_racks'] as Map<String, dynamic>)['name'] as String?
          : null,
      zoneName: json['stock_shelves'] != null && json['stock_shelves']['stock_racks'] != null && json['stock_shelves']['stock_racks']['stock_zones'] != null
          ? (json['stock_shelves']['stock_racks']['stock_zones'] as Map<String, dynamic>)['name'] as String?
          : null,
      warehouseName: json['stock_shelves'] != null && json['stock_shelves']['stock_racks'] != null && json['stock_shelves']['stock_racks']['stock_zones'] != null && json['stock_shelves']['stock_racks']['stock_zones']['stock_warehouses'] != null
          ? (json['stock_shelves']['stock_racks']['stock_zones']['stock_warehouses'] as Map<String, dynamic>)['name'] as String?
          : null,
      // PERBAIKAN: sesuai struktur tabel assets (rfid_tag_id, asset_name)
      assetName: json['assets'] != null 
          ? (json['assets'] as Map<String, dynamic>)['asset_name'] as String?
          : null,
      assetCode: json['assets'] != null 
          ? (json['assets'] as Map<String, dynamic>)['rfid_tag_id'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'shelf_id': shelfId,
      'code': code.trim().toUpperCase(),
      if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (maxQuantity != null) 'max_quantity': maxQuantity,
      if (currentQuantity != null) 'current_quantity': currentQuantity,
      'is_active': isActive ?? true,
      if (metadata != null) 'metadata': metadata,
      if (qrcodeUrl != null && qrcodeUrl!.isNotEmpty) 'qrcode_url': qrcodeUrl,
      if (assetId != null) 'asset_id': assetId,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  StockBinModel copyWith({
    String? id,
    String? shelfId,
    String? code,
    String? barcode,
    int? positionX,
    int? positionY,
    double? maxQuantity,
    double? currentQuantity,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? qrcodeUrl,
    String? assetId,
    String? shelfCode,
    String? shelfLevelNumber,
    String? rackCode,
    String? rackName,
    String? zoneName,
    String? warehouseName,
    String? assetName,
    String? assetCode,
  }) {
    return StockBinModel(
      id: id ?? this.id,
      shelfId: shelfId ?? this.shelfId,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      qrcodeUrl: qrcodeUrl ?? this.qrcodeUrl,
      assetId: assetId ?? this.assetId,
      shelfCode: shelfCode ?? this.shelfCode,
      shelfLevelNumber: shelfLevelNumber ?? this.shelfLevelNumber,
      rackCode: rackCode ?? this.rackCode,
      rackName: rackName ?? this.rackName,
      zoneName: zoneName ?? this.zoneName,
      warehouseName: warehouseName ?? this.warehouseName,
      assetName: assetName ?? this.assetName,
      assetCode: assetCode ?? this.assetCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shelfId,
        code,
        barcode,
        positionX,
        positionY,
        maxQuantity,
        currentQuantity,
        isActive,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        qrcodeUrl,
        assetId,
        shelfCode,
        shelfLevelNumber,
        rackCode,
        rackName,
        zoneName,
        warehouseName,
        assetName,
        assetCode,
      ];
}