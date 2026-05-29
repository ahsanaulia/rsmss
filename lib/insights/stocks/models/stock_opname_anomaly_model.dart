// File: lib/insights/stocks/models/stock_opname_anomaly_model.dart

import 'package:flutter/material.dart';

class StockOpnameAnomalyItemModel {
  final String stockId;
  final String stockName;
  final String unit;
  final double discrepancy;
  final double discrepancyPercent;
  final DateTime opnameAt;
  final double stockBefore;
  final String? binId;
  final String? binName;
  final String? opnameBy;
  final String? opnameByName;
  final int frequency;

  StockOpnameAnomalyItemModel({
    required this.stockId,
    required this.stockName,
    required this.unit,
    required this.discrepancy,
    required this.discrepancyPercent,
    required this.opnameAt,
    required this.stockBefore,
    this.binId,
    this.binName,
    this.opnameBy,
    this.opnameByName,
    this.frequency = 1,
  });

  String get discrepancyType {
    if (discrepancy == 0) return 'MATCH';
    if (discrepancy > 0) return 'SURPLUS';
    return 'SHORTAGE';
  }

  Color get priorityColor {
    if (discrepancyPercent > 50) return const Color(0xFFEF4444);
    if (discrepancyPercent > 20) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }
}

class StockOpnameAnomalyPersonModel {
  final String personId;
  final String personName;
  final String pattern;
  final double percentage;
  final int totalOpnames;

  StockOpnameAnomalyPersonModel({
    required this.personId,
    required this.personName,
    required this.pattern,
    required this.percentage,
    required this.totalOpnames,
  });

  Color get patternColor {
    if (pattern == 'SURPLUS') return const Color(0xFF10B981);
    if (pattern == 'SHORTAGE') return const Color(0xFFEF4444);
    return const Color(0xFF3B82F6);
  }
}

class StockOpnameAnomalyBinModel {
  final String binId;
  final String binName;
  final String? shelfName;
  final String? rackName;
  final String? zoneName;
  final String? warehouseName;
  double totalDiscrepancy;
  double totalPercentage;
  int count;
  double avgPercentage;
  List<StockOpnameAnomalyItemModel> topItems;

  StockOpnameAnomalyBinModel({
    required this.binId,
    required this.binName,
    this.shelfName,
    this.rackName,
    this.zoneName,
    this.warehouseName,
    this.totalDiscrepancy = 0,
    this.totalPercentage = 0,
    this.count = 0,
    this.avgPercentage = 0,
    this.topItems = const [],
  });

  String get locationHierarchy {
    final parts = <String>[];
    if (warehouseName != null) parts.add(warehouseName!);
    if (zoneName != null) parts.add(zoneName!);
    if (rackName != null) parts.add(rackName!);
    if (shelfName != null) parts.add(shelfName!);
    parts.add(binName);
    return parts.join(' → ');
  }
}