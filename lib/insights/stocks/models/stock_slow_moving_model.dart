// File: lib/insights/stocks/models/stock_slow_moving_model.dart

class StockSlowMovingModel {
  final String stockId;
  final String stockName;
  final String unit;
  final double currentStock;
  final DateTime? lastUsageAt;
  final int daysInactive;

  StockSlowMovingModel({
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.currentStock,
    this.lastUsageAt,
    required this.daysInactive,
  });
}