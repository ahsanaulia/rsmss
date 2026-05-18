import 'package:flutter/material.dart';
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

