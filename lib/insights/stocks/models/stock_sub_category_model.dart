// File: lib/insights/stocks/models/stock_sub_category_model.dart

import 'package:flutter/material.dart';

class StockSubCategoryModel {
  final String id;
  final String categoryId;
  final String subCategoryName;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;

  StockSubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.subCategoryName,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
  });

  factory StockSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return StockSubCategoryModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      subCategoryName: json['sub_category_name'] ?? '',
      iconName: json['icon_name'],
      markerColor: json['marker_color'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      createdBy: json['created_by']?.toString(),
    );
  }

  Color get markerColorValue {
    if (markerColor == null || markerColor!.isEmpty) return Colors.white70;
    try {
      final hex = markerColor!.replaceAll('#', '');
      return Color(int.parse('0xFF$hex'));
    } catch (e) {
      return Colors.white70;
    }
  }

  IconData get icon {
    final iconMap = {
      'antibiotic': Icons.medical_services,
      'analgesic': Icons.medication,
      'antiviral': Icons.coronavirus,
      'antifungal': Icons.bug_report,
      'antihistamine': Icons.medication,
      'bandage': Icons.health_and_safety,
      'syringe': Icons.medical_information,
      'infusion': Icons.water_drop,
      'surgical': Icons.cut,
      'diagnostic': Icons.science,
    };
    return iconMap[iconName?.toLowerCase()] ?? Icons.subdirectory_arrow_right;
  }
}