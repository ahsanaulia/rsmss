// lib/features/roster/domain/enums/wellbeing_risk_level.dart
import 'package:flutter/material.dart';
enum WellbeingRiskLevel {
  low('low', 'Rendah', Colors.green),
  medium('medium', 'Sedang', Colors.orange),
  high('high', 'Tinggi', Colors.red),
  critical('critical', 'Kritis', Colors.deepPurple);

  const WellbeingRiskLevel(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  static WellbeingRiskLevel fromValue(String? value) {
    if (value == null) return low;
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => low,
    );
  }
}