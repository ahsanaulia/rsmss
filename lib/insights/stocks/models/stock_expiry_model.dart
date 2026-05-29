// File: lib/insights/stocks/models/stock_expiry_model.dart

import 'package:flutter/material.dart';

class StockExpiryModel {
  final String stockId;
  final String stockName;
  final String unit;
  final DateTime expiryDate;
  final double quantity;
  final String? batchNumber;

  StockExpiryModel({
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.expiryDate,
    required this.quantity,
    this.batchNumber,
  });

  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  bool get isExpiringSoon => daysUntilExpiry <= 30;
  bool get isExpired => daysUntilExpiry < 0;

  Color get statusColor {
    if (isExpired) return const Color(0xFFEF4444);
    if (daysUntilExpiry <= 7) return const Color(0xFFEF4444);
    if (daysUntilExpiry <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get statusText {
    if (isExpired) return 'EXPIRED';
    if (daysUntilExpiry <= 7) return 'EXPIRING SOON';
    if (daysUntilExpiry <= 30) return 'EXPIRING';
    return 'GOOD';
  }
}