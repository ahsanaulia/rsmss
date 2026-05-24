import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class LeaveTypeModel extends Equatable {
  final String? id;
  final String leaveCode;
  final String leaveName;
  final int? maxDaysPerYear;
  final bool? paidLeave;
  final bool? requiresDocument;
  final bool? requiresMedicalCertificate;
  final String? color;
  final bool? isActive;
  final DateTime? createdAt;

  const LeaveTypeModel({
    this.id,
    required this.leaveCode,
    required this.leaveName,
    this.maxDaysPerYear,
    this.paidLeave,
    this.requiresDocument,
    this.requiresMedicalCertificate,
    this.color,
    this.isActive,
    this.createdAt,
  });

  factory LeaveTypeModel.empty() {
    return const LeaveTypeModel(
      leaveCode: '',
      leaveName: '',
    );
  }

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 LeaveTypeModel.fromJson: $json');

    return LeaveTypeModel(
      id: json['id'] as String?,
      leaveCode: json['leave_code'] as String? ?? '',
      leaveName: json['leave_name'] as String? ?? '',
      maxDaysPerYear: json['max_days_per_year'] as int?,
      paidLeave: json['paid_leave'] as bool? ?? true,
      requiresDocument: json['requires_document'] as bool? ?? false,
      requiresMedicalCertificate: json['requires_medical_certificate'] as bool? ?? false,
      color: json['color'] as String? ?? '#FF9800',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'leave_code': leaveCode.trim().toUpperCase(),
      'leave_name': leaveName.trim(),
      if (maxDaysPerYear != null) 'max_days_per_year': maxDaysPerYear,
      if (paidLeave != null) 'paid_leave': paidLeave,
      if (requiresDocument != null) 'requires_document': requiresDocument,
      if (requiresMedicalCertificate != null) 'requires_medical_certificate': requiresMedicalCertificate,
      if (color != null && color!.isNotEmpty) 'color': color,
      if (isActive != null) 'is_active': isActive,
    };
  }

  LeaveTypeModel copyWith({
    String? id,
    String? leaveCode,
    String? leaveName,
    int? maxDaysPerYear,
    bool? paidLeave,
    bool? requiresDocument,
    bool? requiresMedicalCertificate,
    String? color,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return LeaveTypeModel(
      id: id ?? this.id,
      leaveCode: leaveCode ?? this.leaveCode,
      leaveName: leaveName ?? this.leaveName,
      maxDaysPerYear: maxDaysPerYear ?? this.maxDaysPerYear,
      paidLeave: paidLeave ?? this.paidLeave,
      requiresDocument: requiresDocument ?? this.requiresDocument,
      requiresMedicalCertificate: requiresMedicalCertificate ?? this.requiresMedicalCertificate,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        leaveCode,
        leaveName,
        maxDaysPerYear,
        paidLeave,
        requiresDocument,
        requiresMedicalCertificate,
        color,
        isActive,
        createdAt,
      ];
}