// lib/features/stock_in_entry/models/stock_in_entry_model.dart

import 'package:flutter/material.dart';

/// Model untuk mencatat stok masuk ke sistem
class StockInEntry {
  final String? id;
  final String entryNumber;
  final String stockId;
  final double quantity;
  final String batchNumber;
  final DateTime expiryDate;
  final String sourceType;
  final String? sourceId;
  final DateTime entryDate;
  final String? receivedBinId;
  final String? currentBinId;
  final String? receivedBy;
  final String? returnedBy;
  final String? returnedFromUnit;
  final String? returnReason;
  final String? putAwayBy;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String riskLevel;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockInEntry({
    this.id,
    required this.entryNumber,
    required this.stockId,
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    required this.sourceType,
    this.sourceId,
    DateTime? entryDate,
    this.receivedBinId,
    this.currentBinId,
    this.receivedBy,
    this.returnedBy,
    this.returnedFromUnit,
    this.returnReason,
    this.putAwayBy,
    this.verifiedBy,
    this.verifiedAt,
    this.riskLevel = 'NORMAL',
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : entryDate = entryDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory StockInEntry.empty() {
    return StockInEntry(
      entryNumber: '',
      stockId: '',
      quantity: 0,
      batchNumber: '',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      sourceType: 'PURCHASE',
    );
  }

  factory StockInEntry.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockInEntry.fromJson: ${json['id']}');
    return StockInEntry(
      id: json['id'] as String?,
      entryNumber: json['entry_number'] as String? ?? '',
      stockId: json['stock_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      batchNumber: json['batch_number'] as String? ?? '',
      expiryDate: _parseDateTime(json['expiry_date']) ?? DateTime.now(),
      sourceType: json['source_type'] as String? ?? 'PURCHASE',
      sourceId: json['source_id'] as String?,
      entryDate: _parseDateTime(json['entry_date']) ?? DateTime.now(),
      receivedBinId: json['received_bin_id'] as String?,
      currentBinId: json['current_bin_id'] as String?,
      receivedBy: json['received_by'] as String?,
      returnedBy: json['returned_by'] as String?,
      returnedFromUnit: json['returned_from_unit'] as String?,
      returnReason: json['return_reason'] as String?,
      putAwayBy: json['put_away_by'] as String?,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: _parseDateTime(json['verified_at']),
      riskLevel: json['risk_level'] as String? ?? 'NORMAL',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJsonForInsert(String userId) {
    return {
      'entry_number': entryNumber,
      'stock_id': stockId,
      'quantity': quantity,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String(),
      'source_type': sourceType,
      'source_id': sourceId,
      'entry_date': entryDate.toIso8601String(),
      'received_bin_id': receivedBinId,
      'current_bin_id': currentBinId,
      'received_by': receivedBy ?? userId,
      'returned_by': returnedBy,
      'returned_from_unit': returnedFromUnit,
      'return_reason': returnReason,
      'put_away_by': putAwayBy,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'risk_level': riskLevel,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      if (currentBinId != null) 'current_bin_id': currentBinId,
      if (putAwayBy != null) 'put_away_by': putAwayBy,
      if (verifiedBy != null) 'verified_by': verifiedBy,
      if (verifiedAt != null) 'verified_at': verifiedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  StockInEntry copyWith({
    String? id,
    String? entryNumber,
    String? stockId,
    double? quantity,
    String? batchNumber,
    DateTime? expiryDate,
    String? sourceType,
    String? sourceId,
    DateTime? entryDate,
    String? receivedBinId,
    String? currentBinId,
    String? receivedBy,
    String? returnedBy,
    String? returnedFromUnit,
    String? returnReason,
    String? putAwayBy,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? riskLevel,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockInEntry(
      id: id ?? this.id,
      entryNumber: entryNumber ?? this.entryNumber,
      stockId: stockId ?? this.stockId,
      quantity: quantity ?? this.quantity,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      entryDate: entryDate ?? this.entryDate,
      receivedBinId: receivedBinId ?? this.receivedBinId,
      currentBinId: currentBinId ?? this.currentBinId,
      receivedBy: receivedBy ?? this.receivedBy,
      returnedBy: returnedBy ?? this.returnedBy,
      returnedFromUnit: returnedFromUnit ?? this.returnedFromUnit,
      returnReason: returnReason ?? this.returnReason,
      putAwayBy: putAwayBy ?? this.putAwayBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      riskLevel: riskLevel ?? this.riskLevel,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (e) {
      debugPrint('⚠️ Error parsing DateTime: $value');
      return null;
    }
  }

  @override
  String toString() {
    return 'StockInEntry(id: $id, entryNumber: $entryNumber, stockId: $stockId, quantity: $quantity, batchNumber: $batchNumber)';
  }
}

// ==========================================================
// DTO: Stock In Entry With Detail
// ==========================================================

class StockInEntryWithDetail {
  final StockInEntry entry;
  final String stockName;
  final String stockCode;
  final String unit;
  final String? binCode;
  final String? fullLocationCode;
  final String? receivedByName;
  final String? returnedByName;

  const StockInEntryWithDetail({
    required this.entry,
    required this.stockName,
    required this.stockCode,
    required this.unit,
    this.binCode,
    this.fullLocationCode,
    this.receivedByName,
    this.returnedByName,
  });

  factory StockInEntryWithDetail.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 StockInEntryWithDetail.fromJson: ${json['id']}');
    final entry = StockInEntry.fromJson(json);
    
    final stockData = json['stocks'] as Map<String, dynamic>?;
    final stockName = stockData?['stock_name'] as String? ?? 'Unknown';
    final stockCode = stockData?['stock_code'] as String? ?? '';
    final unit = stockData?['unit'] as String? ?? 'pcs';
    
    final binData = json['current_bin'] as Map<String, dynamic>?;
    final binCode = binData?['code'] as String?;
    
    final receivedProfile = json['received_profile'] as Map<String, dynamic>?;
    final receivedByName = receivedProfile?['full_name'] as String?;
    
    final returnedProfile = json['returned_profile'] as Map<String, dynamic>?;
    final returnedByName = returnedProfile?['full_name'] as String?;
    
    return StockInEntryWithDetail(
      entry: entry,
      stockName: stockName,
      stockCode: stockCode,
      unit: unit,
      binCode: binCode,
      fullLocationCode: null,
      receivedByName: receivedByName,
      returnedByName: returnedByName,
    );
  }
}