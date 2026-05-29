// File: lib/insights/stocks/models/stock_discrepancy_model.dart

class StockDiscrepancyModel {
  final String stockId;
  final String stockName;
  final double systemStock;
  final double physicalStock;
  final double discrepancy;
  final double discrepancyPercent;
  final DateTime opnameAt;
  final String? opnameBy;

  StockDiscrepancyModel({
    required this.stockId,
    required this.stockName,
    required this.systemStock,
    required this.physicalStock,
    required this.discrepancy,
    required this.discrepancyPercent,
    required this.opnameAt,
    this.opnameBy,
  });

  String get discrepancyType {
    if (discrepancy > 0) return 'SURPLUS';
    if (discrepancy < 0) return 'SHORTAGE';
    return 'MATCH';
  }
}