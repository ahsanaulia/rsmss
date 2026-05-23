// lib/features/stock/models/stock_mutation_model.dart
class StockMutationModel {
  final String? id;
  final String mutationNumber;
  final String stockInBinsId;
  final String binIdAsal;
  final String? binAsalName;
  final String binIdTujuan;
  final String? binTujuanName;
  final String stockId;
  final String? stockName;
  final String batchNumber;
  final DateTime expiryDate;
  final double quantity;
  final String unit;
  final String movedBy;
  final DateTime? movedAt;
  final String? receivedBy;
  final String? receivedByName;
  final DateTime? receivedAt;
  final String? notes;
  final DateTime? createdAt;

  StockMutationModel({
    this.id,
    required this.mutationNumber,
    required this.stockInBinsId,
    required this.binIdAsal,
    this.binAsalName,
    required this.binIdTujuan,
    this.binTujuanName,
    required this.stockId,
    this.stockName,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.unit,
    required this.movedBy,
    this.movedAt,
    this.receivedBy,
    this.receivedByName,
    this.receivedAt,
    this.notes,
    this.createdAt,
  });

  factory StockMutationModel.fromJson(Map<String, dynamic> json) {
    return StockMutationModel(
      id: json['id'] as String?,
      mutationNumber: json['mutation_number'] as String? ?? '',
      stockInBinsId: json['stock_in_bins_id'] as String? ?? '',
      binIdAsal: json['bin_id_asal'] as String? ?? '',
      binAsalName: json['bin_asal_name'] as String?,
      binIdTujuan: json['bin_id_tujuan'] as String? ?? '',
      binTujuanName: json['bin_tujuan_name'] as String?,
      stockId: json['stock_id'] as String? ?? '',
      stockName: json['stock_name'] as String?,
      batchNumber: json['batch_number'] as String? ?? '',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : DateTime.now(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      movedBy: json['moved_by'] as String? ?? '',
      movedAt: json['moved_at'] != null
          ? DateTime.parse(json['moved_at'] as String)
          : null,
      receivedBy: json['received_by'] as String?,
      receivedByName: json['received_by_name'] as String?,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mutation_number': mutationNumber,
      'stock_in_bins_id': stockInBinsId,
      'bin_id_asal': binIdAsal,
      'bin_id_tujuan': binIdTujuan,
      'stock_id': stockId,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'quantity': quantity,
      'unit': unit,
      'moved_by': movedBy,
      'moved_at': movedAt?.toIso8601String(),
      if (receivedBy != null) 'received_by': receivedBy,
      if (receivedAt != null) 'received_at': receivedAt?.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  StockMutationModel copyWith({
    String? id,
    String? mutationNumber,
    String? stockInBinsId,
    String? binIdAsal,
    String? binAsalName,
    String? binIdTujuan,
    String? binTujuanName,
    String? stockId,
    String? stockName,
    String? batchNumber,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    String? movedBy,
    DateTime? movedAt,
    String? receivedBy,
    String? receivedByName,
    DateTime? receivedAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return StockMutationModel(
      id: id ?? this.id,
      mutationNumber: mutationNumber ?? this.mutationNumber,
      stockInBinsId: stockInBinsId ?? this.stockInBinsId,
      binIdAsal: binIdAsal ?? this.binIdAsal,
      binAsalName: binAsalName ?? this.binAsalName,
      binIdTujuan: binIdTujuan ?? this.binIdTujuan,
      binTujuanName: binTujuanName ?? this.binTujuanName,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      movedBy: movedBy ?? this.movedBy,
      movedAt: movedAt ?? this.movedAt,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedByName: receivedByName ?? this.receivedByName,
      receivedAt: receivedAt ?? this.receivedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}