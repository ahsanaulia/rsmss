// lib/features/stock_in/models/stock_in_model.dart
import 'package:equatable/equatable.dart';

class StockInModel extends Equatable {
  final String? id;
  final String receiptNumber;
  final String stockId;
  final String stockName; // Untuk tampilan (dari join)
  final String stockCode; // Untuk tampilan
  final String unit; // Untuk tampilan
  final double quantity;
  final String batchNumber;
  final DateTime expiryDate;
  final String sourceType;
  final String? sourceReference;
  final String? returnedFromUnit;
  final String? returnReason;
  final String? receivedBy;
  final DateTime? receivedAt;
  final String status;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String riskLevel;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StockInModel({
    this.id,
    required this.receiptNumber,
    required this.stockId,
    this.stockName = '',
    this.stockCode = '',
    this.unit = '',
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    this.sourceType = 'PURCHASE',
    this.sourceReference,
    this.returnedFromUnit,
    this.returnReason,
    this.receivedBy,
    this.receivedAt,
    this.status = 'RECEIVED',
    this.verifiedBy,
    this.verifiedAt,
    this.riskLevel = 'NORMAL',
    this.notes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory StockInModel.fromJson(Map<String, dynamic> json) {
    return StockInModel(
      id: json['id'] as String?,
      receiptNumber: json['receipt_number'] as String? ?? '',
      stockId: json['stock_id'] as String? ?? '',
      stockName: json['stocks'] != null 
          ? (json['stocks'] as Map)['stock_name'] as String? ?? ''
          : '',
      stockCode: json['stocks'] != null
          ? (json['stocks'] as Map)['stock_code'] as String? ?? ''
          : '',
      unit: json['stocks'] != null
          ? (json['stocks'] as Map)['unit'] as String? ?? ''
          : '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      batchNumber: json['batch_number'] as String? ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : DateTime.now(),
      sourceType: json['source_type'] as String? ?? 'PURCHASE',
      sourceReference: json['source_reference'] as String?,
      returnedFromUnit: json['returned_from_unit'] as String?,
      returnReason: json['return_reason'] as String?,
      receivedBy: json['received_by'] as String?,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'] as String)
          : null,
      status: json['status'] as String? ?? 'RECEIVED',
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      riskLevel: json['risk_level'] as String? ?? 'NORMAL',
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'receipt_number': receiptNumber,
      'stock_id': stockId,
      'quantity': quantity,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'source_type': sourceType,
      if (sourceReference != null) 'source_reference': sourceReference,
      if (returnedFromUnit != null) 'returned_from_unit': returnedFromUnit,
      if (returnReason != null) 'return_reason': returnReason,
      if (receivedBy != null) 'received_by': receivedBy,
      'received_at': receivedAt?.toIso8601String(),
      'status': status,
      if (verifiedBy != null) 'verified_by': verifiedBy,
      if (verifiedAt != null) 'verified_at': verifiedAt?.toIso8601String(),
      'risk_level': riskLevel,
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
    };
  }

  StockInModel copyWith({
    String? id,
    String? receiptNumber,
    String? stockId,
    String? stockName,
    String? stockCode,
    String? unit,
    double? quantity,
    String? batchNumber,
    DateTime? expiryDate,
    String? sourceType,
    String? sourceReference,
    String? returnedFromUnit,
    String? returnReason,
    String? receivedBy,
    DateTime? receivedAt,
    String? status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? riskLevel,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockInModel(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      stockCode: stockCode ?? this.stockCode,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      sourceType: sourceType ?? this.sourceType,
      sourceReference: sourceReference ?? this.sourceReference,
      returnedFromUnit: returnedFromUnit ?? this.returnedFromUnit,
      returnReason: returnReason ?? this.returnReason,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedAt: receivedAt ?? this.receivedAt,
      status: status ?? this.status,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      riskLevel: riskLevel ?? this.riskLevel,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        receiptNumber,
        stockId,
        stockName,
        quantity,
        batchNumber,
        expiryDate,
        sourceType,
        status,
      ];
}