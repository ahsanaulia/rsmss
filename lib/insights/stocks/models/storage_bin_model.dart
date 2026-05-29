// File: lib/insights/stocks/models/storage_bin_model.dart

import 'package:flutter/material.dart';

class StorageBinModel {
  final String binId;
  final String binCode;
  final String? binName;
  final String shelfName;
  final String rackName;
  final String zoneName;
  final String warehouseName;
  final double currentQuantity;
  final double? maxQuantity;
  final double utilization;
  final int stockCount;
  final int fulfillmentCount;

  StorageBinModel({
    required this.binId,
    required this.binCode,
    this.binName,
    required this.shelfName,
    required this.rackName,
    required this.zoneName,
    required this.warehouseName,
    required this.currentQuantity,
    this.maxQuantity,
    required this.utilization,
    required this.stockCount,
    required this.fulfillmentCount,
  });

  String get locationHierarchy {
    return '$warehouseName → $zoneName → $rackName → $shelfName → ${binCode}';
  }

  Color get utilizationColor {
    if (utilization >= 80) return const Color(0xFFEF4444);
    if (utilization >= 60) return const Color(0xFFF59E0B);
    if (utilization >= 30) return const Color(0xFF10B981);
    return const Color(0xFF3B82F6);
  }

  String get utilizationStatus {
    if (utilization >= 80) return 'KRITIS - Penuh';
    if (utilization >= 60) return 'PADAT';
    if (utilization >= 30) return 'NORMAL';
    return 'LOW - Jarang dipakai';
  }
}

class StorageTopBinModel {
  final StorageBinModel bin;
  final double value;

  StorageTopBinModel({
    required this.bin,
    required this.value,
  });
}