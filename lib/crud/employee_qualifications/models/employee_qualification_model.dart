import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class EmployeeQualificationModel extends Equatable {
  final String? id;
  final String qualificationCode;
  final String qualificationName;
  final String? category;
  final int? validityPeriodMonths;
  final bool? requiresRenewal;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;

  const EmployeeQualificationModel({
    this.id,
    required this.qualificationCode,
    required this.qualificationName,
    this.category,
    this.validityPeriodMonths,
    this.requiresRenewal,
    this.description,
    this.isActive,
    this.createdAt,
  });

  factory EmployeeQualificationModel.empty() {
    return const EmployeeQualificationModel(
      qualificationCode: '',
      qualificationName: '',
    );
  }

  factory EmployeeQualificationModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📦 EmployeeQualificationModel.fromJson: $json');

    return EmployeeQualificationModel(
      id: json['id'] as String?,
      qualificationCode: json['qualification_code'] as String? ?? '',
      qualificationName: json['qualification_name'] as String? ?? '',
      category: json['category'] as String?,
      validityPeriodMonths: json['validity_period_months'] as int?,
      requiresRenewal: json['requires_renewal'] as bool? ?? true,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'qualification_code': qualificationCode.trim().toUpperCase(),
      'qualification_name': qualificationName.trim(),
      if (category != null && category!.isNotEmpty) 'category': category,
      if (validityPeriodMonths != null) 'validity_period_months': validityPeriodMonths,
      if (requiresRenewal != null) 'requires_renewal': requiresRenewal,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (isActive != null) 'is_active': isActive,
    };
  }

  EmployeeQualificationModel copyWith({
    String? id,
    String? qualificationCode,
    String? qualificationName,
    String? category,
    int? validityPeriodMonths,
    bool? requiresRenewal,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return EmployeeQualificationModel(
      id: id ?? this.id,
      qualificationCode: qualificationCode ?? this.qualificationCode,
      qualificationName: qualificationName ?? this.qualificationName,
      category: category ?? this.category,
      validityPeriodMonths: validityPeriodMonths ?? this.validityPeriodMonths,
      requiresRenewal: requiresRenewal ?? this.requiresRenewal,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        qualificationCode,
        qualificationName,
        category,
        validityPeriodMonths,
        requiresRenewal,
        description,
        isActive,
        createdAt,
      ];
}