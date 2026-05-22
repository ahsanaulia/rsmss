// lib/features/stock/models/stock_write_off_model.dart
class StockWriteOffModel {
  final String? id;
  final String writeOffNumber;
  final String stockInBinsId;
  final String binId;
  final String stockId;
  final String? stockName;
  final String batchNumber;
  final DateTime expiryDate;
  final double quantity;
  final String unit;
  final String reason;
  final String? reasonNote;
  final String? requestedBy;
  final DateTime? requestedAt;
  final String status;
  final String? photoUrl;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StockWriteOffModel({
    this.id,
    required this.writeOffNumber,
    required this.stockInBinsId,
    required this.binId,
    required this.stockId,
    this.stockName,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.unit,
    required this.reason,
    this.reasonNote,
    this.requestedBy,
    this.requestedAt,
    this.status = 'DRAFT',
    this.photoUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory StockWriteOffModel.fromJson(Map<String, dynamic> json) {
    return StockWriteOffModel(
      id: json['id'] as String?,
      writeOffNumber: json['write_off_number'] as String? ?? '',
      stockInBinsId: json['stock_in_bins_id'] as String? ?? '',
      binId: json['bin_id'] as String? ?? '',
      stockId: json['stock_id'] as String? ?? '',
      stockName: json['stock_name'] as String?,
      batchNumber: json['batch_number'] as String? ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : DateTime.now(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      reasonNote: json['reason_note'] as String?,
      requestedBy: json['requested_by'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      status: json['status'] as String? ?? 'DRAFT',
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
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
      'write_off_number': writeOffNumber,
      'stock_in_bins_id': stockInBinsId,
      'bin_id': binId,
      'stock_id': stockId,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      if (reasonNote != null && reasonNote!.isNotEmpty) 'reason_note': reasonNote,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (requestedAt != null) 'requested_at': requestedAt?.toIso8601String(),
      'status': status,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photo_url': photoUrl,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  StockWriteOffModel copyWith({
    String? id,
    String? writeOffNumber,
    String? stockInBinsId,
    String? binId,
    String? stockId,
    String? stockName,
    String? batchNumber,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    String? reason,
    String? reasonNote,
    String? requestedBy,
    DateTime? requestedAt,
    String? status,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockWriteOffModel(
      id: id ?? this.id,
      writeOffNumber: writeOffNumber ?? this.writeOffNumber,
      stockInBinsId: stockInBinsId ?? this.stockInBinsId,
      binId: binId ?? this.binId,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      reason: reason ?? this.reason,
      reasonNote: reasonNote ?? this.reasonNote,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}