// ============================================================
// MODEL: Stock
// ============================================================
// TANGGUNG JAWAB:
// 1. Mewakili data stok dari view v_crud_stocks
// 2. Menyediakan fromJson, toJson, copyWith
// 3. Menyediakan helper untuk status stok (is_empty, is_low_stock)
// ============================================================

import 'package:flutter/material.dart';

/// Model untuk Stok/Inventory Rumah Sakit
class Stock {
  // ==========================================================
  // PRIMARY & IDENTITAS
  // ==========================================================
  final String id;
  final String? stockCode;
  final String stockName;
  final String unit;
  final String? description;
  
  // ==========================================================
  // KLASIFIKASI & LOKASI
  // ==========================================================
  final String? stockTypeId;
  final String? stockTypeName;
  final String? stockTypeDescription;
  final String? storageLocationId;
  final String? storageLocationName;
  final String? storageLocationCode;
  
  // ==========================================================
  // STOK & BATCH
  // ==========================================================
  final num minimumStock;
  final num currentStock;
  final String? batchNumber;
  final DateTime? expiryDate;
  
  // ==========================================================
  // KONDISI & STATUS
  // ==========================================================
  final String stockCondition;  // GOOD, LOW
  final bool isActive;
  final String? photoUrl;
  
  // ==========================================================
  // FLAG OTOMATIS (dari view)
  // ==========================================================
  final bool isEmpty;
  final bool isLowStock;
  final bool isStockSafe;
  
  // ==========================================================
  // LAST OPNAME
  // ==========================================================
  final DateTime? lastOpnameAt;
  final String? lastOpnameBy;
  final String? lastOpnameByName;
  final String? lastOpnameByEmployeeId;
  final String? lastOpnameNote;
  final num? lastOpnameStock;
  
  // ==========================================================
  // LAST PURCHASE
  // ==========================================================
  final DateTime? lastPurchaseAt;
  final String? lastPurchaseBy;
  final String? lastPurchaseByName;
  final String? lastPurchaseByEmployeeId;
  final num? lastPurchaseQty;
  final num? lastPurchasePrice;
  
  // ==========================================================
  // LAST USAGE
  // ==========================================================
  final DateTime? lastUsageAt;
  final String? lastUsageBy;
  final String? lastUsageByName;
  final String? lastUsageByEmployeeId;
  final num? lastUsageQty;
  
  // ==========================================================
  // METADATA SISTEM
  // ==========================================================
  final String? createdBy;
  final String? createdByName;
  final String? createdByEmployeeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stock({
    required this.id,
    this.stockCode,
    required this.stockName,
    required this.unit,
    this.description,
    this.stockTypeId,
    this.stockTypeName,
    this.stockTypeDescription,
    this.storageLocationId,
    this.storageLocationName,
    this.storageLocationCode,
    this.minimumStock = 0,
    this.currentStock = 0,
    this.batchNumber,
    this.expiryDate,
    this.stockCondition = 'GOOD',
    this.isActive = true,
    this.photoUrl,
    this.isEmpty = false,
    this.isLowStock = false,
    this.isStockSafe = true,
    this.lastOpnameAt,
    this.lastOpnameBy,
    this.lastOpnameByName,
    this.lastOpnameByEmployeeId,
    this.lastOpnameNote,
    this.lastOpnameStock,
    this.lastPurchaseAt,
    this.lastPurchaseBy,
    this.lastPurchaseByName,
    this.lastPurchaseByEmployeeId,
    this.lastPurchaseQty,
    this.lastPurchasePrice,
    this.lastUsageAt,
    this.lastUsageBy,
    this.lastUsageByName,
    this.lastUsageByEmployeeId,
    this.lastUsageQty,
    this.createdBy,
    this.createdByName,
    this.createdByEmployeeId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Empty stock untuk initial form (create new stock)
  factory Stock.empty() {
    return Stock(
      id: '',
      stockName: '',
      unit: '',
      minimumStock: 0,
      currentStock: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// From JSON (dari view v_crud_stocks)
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as String,
      stockCode: json['stock_code'] as String?,
      stockName: json['stock_name'] as String,
      unit: json['unit'] as String,
      description: json['description'] as String?,
      stockTypeId: json['stock_type_id'] as String?,
      stockTypeName: json['stock_type_name'] as String?,
      stockTypeDescription: json['stock_type_description'] as String?,
      storageLocationId: json['storage_location_id'] as String?,
      storageLocationName: json['storage_location_name'] as String?,
      storageLocationCode: json['storage_location_code'] as String?,
      minimumStock: (json['minimum_stock'] as num?) ?? 0,
      currentStock: (json['current_stock'] as num?) ?? 0,
      batchNumber: json['batch_number'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'] as String)
          : null,
      stockCondition: json['stock_condition'] as String? ?? 'GOOD',
      isActive: json['is_active'] as bool? ?? true,
      photoUrl: json['photo_url'] as String?,
      isEmpty: json['is_empty'] as bool? ?? false,
      isLowStock: json['is_low_stock'] as bool? ?? false,
      isStockSafe: json['is_stock_safe'] as bool? ?? true,
      lastOpnameAt: _parseDateTime(json['last_opname_at']),
      lastOpnameBy: json['last_opname_by'] as String?,
      lastOpnameByName: json['last_opname_by_name'] as String?,
      lastOpnameByEmployeeId: json['last_opname_by_employee_id'] as String?,
      lastOpnameNote: json['last_opname_note'] as String?,
      lastOpnameStock: json['last_opname_stock'] as num?,
      lastPurchaseAt: _parseDateTime(json['last_purchase_at']),
      lastPurchaseBy: json['last_purchase_by'] as String?,
      lastPurchaseByName: json['last_purchase_by_name'] as String?,
      lastPurchaseByEmployeeId: json['last_purchase_by_employee_id'] as String?,
      lastPurchaseQty: json['last_purchase_qty'] as num?,
      lastPurchasePrice: json['last_purchase_price'] as num?,
      lastUsageAt: _parseDateTime(json['last_usage_at']),
      lastUsageBy: json['last_usage_by'] as String?,
      lastUsageByName: json['last_usage_by_name'] as String?,
      lastUsageByEmployeeId: json['last_usage_by_employee_id'] as String?,
      lastUsageQty: json['last_usage_qty'] as num?,
      createdBy: json['created_by'] as String?,
      createdByName: json['created_by_name'] as String?,
      createdByEmployeeId: json['created_by_employee_id'] as String?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// To JSON (untuk create/update ke tabel stocks)
  Map<String, dynamic> toJson() {
    return {
      if (stockCode != null && stockCode!.isNotEmpty) 'stock_code': stockCode,
      'stock_name': stockName,
      if (stockTypeId != null) 'stock_type_id': stockTypeId,
      'unit': unit,
      'minimum_stock': minimumStock,
      'current_stock': currentStock,
      'stock_condition': stockCondition,
      'is_active': isActive,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (storageLocationId != null) 'storage_location_id': storageLocationId,
      if (batchNumber != null && batchNumber!.isNotEmpty) 'batch_number': batchNumber,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (expiryDate != null) 'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  /// To JSON for CREATE (tambah created_by)
  Map<String, dynamic> toJsonForCreate(String userId) {
    return {
      ...toJson(),
      'created_by': userId,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copy with (untuk update partial)
  Stock copyWith({
    String? id,
    String? stockCode,
    String? stockName,
    String? unit,
    String? description,
    String? stockTypeId,
    String? stockTypeName,
    String? stockTypeDescription,
    String? storageLocationId,
    String? storageLocationName,
    String? storageLocationCode,
    num? minimumStock,
    num? currentStock,
    String? batchNumber,
    DateTime? expiryDate,
    String? stockCondition,
    bool? isActive,
    String? photoUrl,
    bool? isEmpty,
    bool? isLowStock,
    bool? isStockSafe,
    DateTime? lastOpnameAt,
    String? lastOpnameBy,
    String? lastOpnameByName,
    String? lastOpnameByEmployeeId,
    String? lastOpnameNote,
    num? lastOpnameStock,
    DateTime? lastPurchaseAt,
    String? lastPurchaseBy,
    String? lastPurchaseByName,
    String? lastPurchaseByEmployeeId,
    num? lastPurchaseQty,
    num? lastPurchasePrice,
    DateTime? lastUsageAt,
    String? lastUsageBy,
    String? lastUsageByName,
    String? lastUsageByEmployeeId,
    num? lastUsageQty,
    String? createdBy,
    String? createdByName,
    String? createdByEmployeeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Stock(
      id: id ?? this.id,
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      stockTypeId: stockTypeId ?? this.stockTypeId,
      stockTypeName: stockTypeName ?? this.stockTypeName,
      stockTypeDescription: stockTypeDescription ?? this.stockTypeDescription,
      storageLocationId: storageLocationId ?? this.storageLocationId,
      storageLocationName: storageLocationName ?? this.storageLocationName,
      storageLocationCode: storageLocationCode ?? this.storageLocationCode,
      minimumStock: minimumStock ?? this.minimumStock,
      currentStock: currentStock ?? this.currentStock,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      stockCondition: stockCondition ?? this.stockCondition,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmpty: isEmpty ?? this.isEmpty,
      isLowStock: isLowStock ?? this.isLowStock,
      isStockSafe: isStockSafe ?? this.isStockSafe,
      lastOpnameAt: lastOpnameAt ?? this.lastOpnameAt,
      lastOpnameBy: lastOpnameBy ?? this.lastOpnameBy,
      lastOpnameByName: lastOpnameByName ?? this.lastOpnameByName,
      lastOpnameByEmployeeId: lastOpnameByEmployeeId ?? this.lastOpnameByEmployeeId,
      lastOpnameNote: lastOpnameNote ?? this.lastOpnameNote,
      lastOpnameStock: lastOpnameStock ?? this.lastOpnameStock,
      lastPurchaseAt: lastPurchaseAt ?? this.lastPurchaseAt,
      lastPurchaseBy: lastPurchaseBy ?? this.lastPurchaseBy,
      lastPurchaseByName: lastPurchaseByName ?? this.lastPurchaseByName,
      lastPurchaseByEmployeeId: lastPurchaseByEmployeeId ?? this.lastPurchaseByEmployeeId,
      lastPurchaseQty: lastPurchaseQty ?? this.lastPurchaseQty,
      lastPurchasePrice: lastPurchasePrice ?? this.lastPurchasePrice,
      lastUsageAt: lastUsageAt ?? this.lastUsageAt,
      lastUsageBy: lastUsageBy ?? this.lastUsageBy,
      lastUsageByName: lastUsageByName ?? this.lastUsageByName,
      lastUsageByEmployeeId: lastUsageByEmployeeId ?? this.lastUsageByEmployeeId,
      lastUsageQty: lastUsageQty ?? this.lastUsageQty,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByEmployeeId: createdByEmployeeId ?? this.createdByEmployeeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Stock(id: $id, stockName: $stockName, currentStock: $currentStock, stockCondition: $stockCondition)';
  }
}

// ==========================================================
// HELPER: Status Stok
// ==========================================================

/// Status stok untuk UI
enum StockStatus {
  empty('Habis', Colors.red),
  low('Stok Rendah', Colors.orange),
  safe('Stok Aman', Colors.green);

  final String label;
  final Color color;

  const StockStatus(this.label, this.color);

  static StockStatus fromStock(Stock stock) {
    if (stock.isEmpty) return StockStatus.empty;
    if (stock.isLowStock) return StockStatus.low;
    return StockStatus.safe;
  }
}

// ==========================================================
// HELPER: Kondisi Stok
// ==========================================================

/// Enum untuk stock_condition
enum StockCondition {
  good('GOOD', 'Baik'),
  low('LOW', 'Stok Rendah');

  final String value;
  final String label;

  const StockCondition(this.value, this.label);

  static StockCondition fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => good,
    );
  }

  static List<StockCondition> get all => values;
}