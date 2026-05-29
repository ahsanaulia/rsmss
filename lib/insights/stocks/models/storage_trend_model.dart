// File: lib/insights/stocks/models/storage_trend_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StorageTrendModel {
  final DateTime month;
  final double totalStockInQuantity;
  final int totalStockInCount;

  StorageTrendModel({
    required this.month,
    required this.totalStockInQuantity,
    required this.totalStockInCount,
  });

  String get monthName {
    return DateFormat('MMM yyyy').format(month);
  }
}

class StockExpiryModel {
  final String stockId;
  final String stockName;
  final String unit;
  final String binCode;
  final String warehouseName;
  final DateTime expiryDate;
  final double quantity;
  final String batchNumber;

  StockExpiryModel({
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.binCode,
    required this.warehouseName,
    required this.expiryDate,
    required this.quantity,
    required this.batchNumber,
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
}

class StockInSourceModel {
  final String sourceType;
  final double totalQuantity;
  final int totalCount;

  StockInSourceModel({
    required this.sourceType,
    required this.totalQuantity,
    required this.totalCount,
  });
}