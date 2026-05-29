// File: lib/insights/stocks/models/stock_trend_model.dart

class StockTrendModel {
  final DateTime date;
  final double inQuantity;
  final double outQuantity;

  StockTrendModel({
    required this.date,
    required this.inQuantity,
    required this.outQuantity,
  });

  double get netChange => inQuantity - outQuantity;
}