// File: lib/insights/stocks/models/stock_type_model.dart

import 'package:flutter/material.dart';

class StockTypeModel {
  final String id;
  final String typeName;
  final String? description;
  final String? subCategoryId;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;

  StockTypeModel({
    required this.id,
    required this.typeName,
    this.description,
    this.subCategoryId,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
  });

  factory StockTypeModel.fromJson(Map<String, dynamic> json) {
    return StockTypeModel(
      id: json['id'].toString(),
      typeName: json['type_name'] ?? '',
      description: json['description'],
      subCategoryId: json['sub_category_id']?.toString(),
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
      'tablet': Icons.tablet_android,
      'capsule': Icons.medication_liquid,
      'syrup': Icons.opacity,
      'injection': Icons.medical_information,
      'infusion': Icons.water_drop,
      'ointment': Icons.spa,
      'cream': Icons.fluorescent_rounded,
      'powder': Icons.grass,
      'spray': Icons.water_drop_rounded,
      'drop': Icons.water_drop,
      'surgical_glove': Icons.biotech,
      'surgical_mask': Icons.face_retouching_natural,
      'surgical_gown': Icons.room_preferences,
    };
    return iconMap[iconName?.toLowerCase()] ?? Icons.category_outlined;
  }
}