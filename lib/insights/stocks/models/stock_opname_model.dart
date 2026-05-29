// File: lib/insights/stocks/models/stock_opname_model.dart

import 'package:flutter/material.dart';

class StockOpnameModel {
  final String id;
  final String stockId;
  final String stockName;
  final String unit;
  final double stockBefore;
  final double physicalStock;
  final double adjustmentStock;
  final double discrepancyPercent;
  final String? opnameNote;
  final DateTime opnameAt;
  final String? opnameBy;
  final String? opnameByName;
  final String? binId;
  final String? stockInBinsId;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String opnameType;

  StockOpnameModel({
    required this.id,
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.stockBefore,
    required this.physicalStock,
    required this.adjustmentStock,
    required this.discrepancyPercent,
    this.opnameNote,
    required this.opnameAt,
    this.opnameBy,
    this.opnameByName,
    this.binId,
    this.stockInBinsId,
    this.batchNumber,
    this.expiryDate,
    this.opnameType = 'PRODUCT',
  });

  String get discrepancyType {
    if (adjustmentStock == 0) return 'MATCH';
    if (adjustmentStock > 0) return 'SURPLUS';
    return 'SHORTAGE';
  }

  Color get discrepancyColor {
    if (adjustmentStock == 0) return const Color(0xFF3B82F6);
    if (adjustmentStock > 0) return const Color(0xFF10B981);
    return const Color(0xFFEF4444);
  }
}