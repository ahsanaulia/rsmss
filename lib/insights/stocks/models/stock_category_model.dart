// File: lib/insights/stocks/models/stock_category_model.dart

import 'package:flutter/material.dart';

class StockCategoryModel {
  final String id;
  final String categoryName;
  final String? iconName;
  final String? markerColor;
  final DateTime? createdAt;
  final String? createdBy;

  StockCategoryModel({
    required this.id,
    required this.categoryName,
    this.iconName,
    this.markerColor,
    this.createdAt,
    this.createdBy,
  });

  factory StockCategoryModel.fromJson(Map<String, dynamic> json) {
    return StockCategoryModel(
      id: json['id'].toString(),
      categoryName: json['category_name'] ?? '',
      iconName: json['icon_name'],
      markerColor: json['marker_color'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'icon_name': iconName,
      'marker_color': markerColor,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
    };
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
    // Tidak pakai const karena iconMap tidak constant
    final iconMap = {
      'inventory': Icons.inventory_2,
      'medication': Icons.medication,
      'vaccines': Icons.vaccines,
      'local_hospital': Icons.local_hospital,
      'science': Icons.science,
      'tablet': Icons.tablet_android,
      'capsule': Icons.medication_liquid,
      'syringe': Icons.medical_information,
      'bandage': Icons.health_and_safety, // Ganti bandage yang tidak ada
      'mask': Icons.face_retouching_natural, // Ganti mask yang tidak ada
      'glove': Icons.biotech,
      'dropper': Icons.opacity,
      'pill': Icons.circle,
      'injection': Icons.medical_information,
      'infusion': Icons.water_drop,
      'alcohol': Icons.cleaning_services,
      'cotton': Icons.cloud_queue,
      'scalpel': Icons.cut,
      'forceps': Icons.handshake,
      'stethoscope': Icons.healing,
      'thermometer': Icons.thermostat,
      'wheelchair': Icons.wheelchair_pickup,
      'bed': Icons.bed,
      'monitor': Icons.monitor_heart,
      'ventilator': Icons.air,
      'defibrillator': Icons.flash_on,
    };
    return iconMap[iconName?.toLowerCase()] ?? Icons.category;
  }
}