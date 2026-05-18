// lib/features/roster/domain/enums/attendance_status.dart
import 'package:flutter/material.dart';

enum AttendanceStatus {
  scheduled('scheduled', 'Terjadwal', Colors.grey),
  present('present', 'Hadir', Colors.green),
  absent('absent', 'Absen', Colors.red),
  late('late', 'Terlambat', Colors.orange),
  leave('leave', 'Cuti', Colors.blue),
  sick('sick', 'Sakit', Colors.purple);

  const AttendanceStatus(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  static AttendanceStatus fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => scheduled,
    );
  }
}

// lib/features/roster/domain/enums/approval_status.dart
enum ApprovalStatus {
  pending('pending', 'Menunggu', Colors.orange),
  approved('approved', 'Disetujui', Colors.green),
  rejected('rejected', 'Ditolak', Colors.red);

  const ApprovalStatus(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  static ApprovalStatus fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => pending,
    );
  }
}

// lib/features/roster/domain/enums/wellbeing_risk_level.dart
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