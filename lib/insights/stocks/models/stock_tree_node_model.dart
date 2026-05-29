// File: lib/insights/stocks/models/stock_tree_node_model.dart

import 'package:flutter/material.dart';
import 'stock_category_model.dart';
import 'stock_sub_category_model.dart';
import 'stock_type_model.dart';

class StockTreeItem {
  final String id;
  final String name;
  final String? unit;
  final double currentStock;
  final double minimumStock;
  final String condition;
  final String? stockTypeId;

  StockTreeItem({
    required this.id,
    required this.name,
    this.unit,
    required this.currentStock,
    required this.minimumStock,
    required this.condition,
    this.stockTypeId,
  });

  factory StockTreeItem.fromJson(Map<String, dynamic> json) {
    return StockTreeItem(
      id: json['id'].toString(),
      name: json['stock_name'] ?? '',
      unit: json['unit'],
      currentStock: (json['current_stock'] ?? 0).toDouble(),
      minimumStock: (json['minimum_stock'] ?? 0).toDouble(),
      condition: json['stock_condition'] ?? 'GOOD',
      stockTypeId: json['stock_type_id']?.toString(),
    );
  }

  bool get isLowStock => currentStock <= minimumStock && currentStock > 0;
  bool get isEmpty => currentStock <= 0;
  bool get isGood => !isLowStock && !isEmpty;

  Color get statusColor {
    if (isEmpty) return const Color(0xFFEF4444);
    if (isLowStock) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get statusText {
    if (isEmpty) return 'EMPTY';
    if (isLowStock) return 'LOW';
    return 'GOOD';
  }
}

class StockTypeNode {
  final StockTypeModel type;
  final List<StockTreeItem> items;

  StockTypeNode({
    required this.type,
    required this.items,
  });

  int get totalItems => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.currentStock.toInt());
}

class StockSubCategoryNode {
  final StockSubCategoryModel subCategory;
  final List<StockTypeNode> types;

  StockSubCategoryNode({
    required this.subCategory,
    required this.types,
  });

  int get totalItems => types.fold(0, (sum, t) => sum + t.totalItems);
  int get totalQuantity => types.fold(0, (sum, t) => sum + t.totalQuantity);
}

class StockCategoryNode {
  final StockCategoryModel category;
  final List<StockSubCategoryNode> subCategories;

  StockCategoryNode({
    required this.category,
    required this.subCategories,
  });

  int get totalItems => subCategories.fold(0, (sum, sc) => sum + sc.totalItems);
  int get totalQuantity => subCategories.fold(0, (sum, sc) => sum + sc.totalQuantity);
}