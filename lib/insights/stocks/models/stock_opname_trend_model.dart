// File: lib/insights/stocks/models/stock_opname_trend_model.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class StockOpnameTrendModel {
  final DateTime month;
  final double totalDiscrepancy;
  final int totalOpnames;

  StockOpnameTrendModel({
    required this.month,
    required this.totalDiscrepancy,
    required this.totalOpnames,
  });

  String get monthName {
    final formatter = DateFormat('MMM yyyy');
    return formatter.format(month);
  }

  double get avgDiscrepancyPerOpname {
    if (totalOpnames == 0) return 0;
    return totalDiscrepancy / totalOpnames;
  }

  Color get trendColor {
    if (totalDiscrepancy > 0) return const Color(0xFFEF4444);
    if (totalDiscrepancy < 0) return const Color(0xFF10B981);
    return const Color(0xFF3B82F6);
  }
}

// Required import for DateFormat
