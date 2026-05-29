// File: lib/insights/stocks/models/stock_prediction_model.dart

import 'package:flutter/material.dart';

class StockPredictionModel {
  final String stockId;
  final String stockName;
  final String unit;
  final double currentStock;
  final double minimumStock;
  final double dailyUsage;
  final double daysUntilEmpty;

  StockPredictionModel({
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    required this.dailyUsage,
    required this.daysUntilEmpty,
  });

  String get priority {
    if (daysUntilEmpty <= 3) return 'URGENT';
    if (daysUntilEmpty <= 7) return 'HIGH';
    if (daysUntilEmpty <= 14) return 'NORMAL';
    return 'LOW';
  }

  Color get priorityColor {
    if (daysUntilEmpty <= 3) return const Color(0xFFEF4444);
    if (daysUntilEmpty <= 7) return const Color(0xFFF59E0B);
    if (daysUntilEmpty <= 14) return const Color(0xFFFCD34D);
    return const Color(0xFF10B981);
  }

  double get recommendedQty {
    // Rekomendasi: stok untuk 30 hari - current stock
    final needFor30Days = dailyUsage * 30;
    final recommended = needFor30Days - currentStock;
    return recommended > 0 ? recommended : 0;
  }
}