class StockOpnameInputModel {
  final String stockId;
  final double stockBefore;
  final double physicalStock;
  final String? opnameNote;
  final String? opnameBy;

  StockOpnameInputModel({
    required this.stockId,
    required this.stockBefore,
    required this.physicalStock,
    this.opnameNote,
    this.opnameBy,
  });

  double get adjustmentStock => physicalStock - stockBefore;

  Map<String, dynamic> toJson() => {
    'stock_id': stockId,
    'stock_before': stockBefore,
    'physical_stock': physicalStock,
    'adjustment_stock': adjustmentStock,
    'opname_note': opnameNote,
    'opname_by': opnameBy,
    'opname_at': DateTime.now().toIso8601String(),
  };
}