// File: lib/insights/stocks/models/stock_category_value_model.dart
import 'dart:ui';
class StockCategoryValueModel {
  final String categoryName;
  final double totalValue;
  final Color? color;

  StockCategoryValueModel({
    required this.categoryName,
    required this.totalValue,
    this.color,
  });
}