// lib/features/stock_in_bins/models/stock_in_bins_model.dart
import 'package:equatable/equatable.dart';

class StockInBinsModel extends Equatable {
  final String? id;
  final String binId;
  final String stockId;
  final String batchNumber;
  final DateTime expiryDate;
  final double quantity;
  final String? stockInId;
  final String? putAwayBy;
  final DateTime? putAwayAt;
  final String? scannedBinBarcode;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Untuk tampilan (dari join)
  final String? binCode;
  final String? fullLocationCode;
  final String? fullLocationName;
  final String? stockName;
  final String? stockCode;
  final String? unit;
  final String? receiptNumber;

  const StockInBinsModel({
    this.id,
    required this.binId,
    required this.stockId,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    this.stockInId,
    this.putAwayBy,
    this.putAwayAt,
    this.scannedBinBarcode,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.binCode,
    this.fullLocationCode,
    this.fullLocationName,
    this.stockName,
    this.stockCode,
    this.unit,
    this.receiptNumber,
  });

  factory StockInBinsModel.fromJson(Map<String, dynamic> json) {
    return StockInBinsModel(
      id: json['id'] as String?,
      binId: json['bin_id'] as String? ?? '',
      stockId: json['stock_id'] as String? ?? '',
      batchNumber: json['batch_number'] as String? ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : DateTime.now(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      stockInId: json['stock_in_id'] as String?,
      putAwayBy: json['put_away_by'] as String?,
      putAwayAt: json['put_away_at'] != null
          ? DateTime.parse(json['put_away_at'] as String)
          : null,
      scannedBinBarcode: json['scanned_bin_barcode'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      // Joined fields
      binCode: json['stock_bins'] != null
          ? (json['stock_bins'] as Map)['code'] as String?
          : json['bin_code'] as String?,
      fullLocationCode: json['full_location_code'] as String?,
      fullLocationName: json['full_location_name'] as String?,
      stockName: json['stocks'] != null
          ? (json['stocks'] as Map)['stock_name'] as String?
          : json['stock_name'] as String?,
      stockCode: json['stocks'] != null
          ? (json['stocks'] as Map)['stock_code'] as String?
          : json['stock_code'] as String?,
      unit: json['stocks'] != null
          ? (json['stocks'] as Map)['unit'] as String?
          : json['unit'] as String?,
      receiptNumber: json['stock_in'] != null
          ? (json['stock_in'] as Map)['receipt_number'] as String?
          : json['receipt_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bin_id': binId,
      'stock_id': stockId,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'quantity': quantity,
      if (stockInId != null) 'stock_in_id': stockInId,
      if (putAwayBy != null) 'put_away_by': putAwayBy,
      'put_away_at': putAwayAt?.toIso8601String(),
      if (scannedBinBarcode != null) 'scanned_bin_barcode': scannedBinBarcode,
      if (notes != null) 'notes': notes,
    };
  }

  StockInBinsModel copyWith({
    String? id,
    String? binId,
    String? stockId,
    String? batchNumber,
    DateTime? expiryDate,
    double? quantity,
    String? stockInId,
    String? putAwayBy,
    DateTime? putAwayAt,
    String? scannedBinBarcode,
    String? notes,
  }) {
    return StockInBinsModel(
      id: id ?? this.id,
      binId: binId ?? this.binId,
      stockId: stockId ?? this.stockId,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      stockInId: stockInId ?? this.stockInId,
      putAwayBy: putAwayBy ?? this.putAwayBy,
      putAwayAt: putAwayAt ?? this.putAwayAt,
      scannedBinBarcode: scannedBinBarcode ?? this.scannedBinBarcode,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        binId,
        stockId,
        batchNumber,
        expiryDate,
        quantity,
        stockInId,
        putAwayBy,
        putAwayAt,
      ];
}