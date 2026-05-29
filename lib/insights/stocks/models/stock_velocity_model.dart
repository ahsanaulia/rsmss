// File: lib/insights/stocks/models/stock_velocity_model.dart

class StockVelocityModel {
  final String stockId;
  final String stockName;
  final String unit;
  final double dailyUsage;
  final double totalOut30Days;

  StockVelocityModel({
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.dailyUsage,
    required this.totalOut30Days,
  });
}