// File: lib/insights/stocks/models/bin_stock_detail_model.dart

import 'package:flutter/material.dart';

class BinStockDetailModel {
  final String stockInBinsId;
  final String stockId;
  final String stockName;
  final String unit;
  final String batchNumber;
  final DateTime expiryDate;
  final double quantity;
  final String? putAwayBy;
  final String? putAwayByName;
  final DateTime? putAwayAt;
  final String? barcode;

  BinStockDetailModel({
    required this.stockInBinsId,
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    this.putAwayBy,
    this.putAwayByName,
    this.putAwayAt,
    this.barcode,
  });

  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  Color get statusColor {
    if (daysUntilExpiry <= 7) return const Color(0xFFEF4444);
    if (daysUntilExpiry <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get statusText {
    if (daysUntilExpiry <= 7) return 'EXPIRING SOON';
    if (daysUntilExpiry <= 30) return 'EXPIRING';
    return 'GOOD';
  }
}