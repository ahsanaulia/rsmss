import 'package:equatable/equatable.dart';

class EmployeeUnitModel extends Equatable {
  final String id;
  final String unitCode;
  final String unitName;
  final String? parentUnitId;
  final int? unitLevel;
  final String? headOfUnitId;
  final bool? shiftRequired;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? parentUnitName;
  final String? headOfUnitName;

  const EmployeeUnitModel({
    required this.id,
    required this.unitCode,
    required this.unitName,
    this.parentUnitId,
    this.unitLevel,
    this.headOfUnitId,
    this.shiftRequired,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.parentUnitName,
    this.headOfUnitName,
  });

  factory EmployeeUnitModel.fromJson(Map<String, dynamic> json) {
    return EmployeeUnitModel(
      id: json['id'] as String,
      unitCode: json['unit_code'] as String,
      unitName: json['unit_name'] as String,
      parentUnitId: json['parent_unit_id'] as String?,
      unitLevel: json['unit_level'] as int?,
      headOfUnitId: json['head_of_unit_id'] as String?,
      shiftRequired: json['shift_required'] as bool?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentUnitName: json['parent_unit_name'] as String?,
      headOfUnitName: json['head_of_unit_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_code': unitCode,
      'unit_name': unitName,
      'parent_unit_id': parentUnitId,
      'unit_level': unitLevel,
      'head_of_unit_id': headOfUnitId,
      'shift_required': shiftRequired,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EmployeeUnitModel copyWith({
    String? id,
    String? unitCode,
    String? unitName,
    String? parentUnitId,
    int? unitLevel,
    String? headOfUnitId,
    bool? shiftRequired,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentUnitName,
    String? headOfUnitName,
  }) {
    return EmployeeUnitModel(
      id: id ?? this.id,
      unitCode: unitCode ?? this.unitCode,
      unitName: unitName ?? this.unitName,
      parentUnitId: parentUnitId ?? this.parentUnitId,
      unitLevel: unitLevel ?? this.unitLevel,
      headOfUnitId: headOfUnitId ?? this.headOfUnitId,
      shiftRequired: shiftRequired ?? this.shiftRequired,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentUnitName: parentUnitName ?? this.parentUnitName,
      headOfUnitName: headOfUnitName ?? this.headOfUnitName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        unitCode,
        unitName,
        parentUnitId,
        unitLevel,
        headOfUnitId,
        shiftRequired,
        description,
        isActive,
        createdAt,
        updatedAt,
        parentUnitName,
        headOfUnitName,
      ];
}