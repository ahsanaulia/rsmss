// lib/features/stock_opname/models/stock_opname_input_model.dart
class StockOpnameInputModel {
  // Untuk opname per produk (existing - untuk kompatibilitas)
  final String? stockId;
  final double? stockBefore;
  final double? physicalStock;
  final String? opnameNote;
  final String? opnameBy;
  
  // Untuk opname per BIN (baru - utama)
  final String? stockInBinsId;
  final String? binId;
  final String? batchNumber;
  final DateTime? expiryDate;
  final double? systemQuantity;
  
  // Catatan opname (bisa untuk satu item)
  final String? itemNote;

  StockOpnameInputModel({
    this.stockId,
    this.stockBefore,
    this.physicalStock,
    this.opnameNote,
    this.opnameBy,
    this.stockInBinsId,
    this.binId,
    this.batchNumber,
    this.expiryDate,
    this.systemQuantity,
    this.itemNote,
  });

  double get adjustmentStock {
    if (physicalStock == null || stockBefore == null) return 0;
    return physicalStock! - stockBefore!;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    // Field umum
    if (stockId != null) json['stock_id'] = stockId;
    if (stockBefore != null) json['stock_before'] = stockBefore;
    if (physicalStock != null) json['physical_stock'] = physicalStock;
    if (adjustmentStock != 0) json['adjustment_stock'] = adjustmentStock;
    if (opnameNote != null && opnameNote!.isNotEmpty) json['opname_note'] = opnameNote;
    if (opnameBy != null) json['opname_by'] = opnameBy;
    
    // Field untuk opname BIN (baru)
    if (stockInBinsId != null) json['stock_in_bins_id'] = stockInBinsId;
    if (binId != null) json['bin_id'] = binId;
    if (batchNumber != null && batchNumber!.isNotEmpty) json['batch_number'] = batchNumber;
    if (expiryDate != null) json['expiry_date'] = expiryDate!.toIso8601String().split('T').first;
    if (systemQuantity != null) json['system_quantity'] = systemQuantity;
    if (itemNote != null && itemNote!.isNotEmpty) json['opname_note'] = itemNote;
    
    json['opname_at'] = DateTime.now().toIso8601String();
    
    return json;
  }
}