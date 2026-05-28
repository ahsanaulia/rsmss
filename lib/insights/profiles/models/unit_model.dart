// lib/insights/profiles/models/unit_model.dart
class UnitModel {
  final String id;
  final String unitCode;
  final String unitName;
  final String? parentUnitId;
  final int unitLevel;
  final String? headOfUnitId;
  final bool shiftRequired;
  final String? description;
  final bool isActive;

  UnitModel({
    required this.id,
    required this.unitCode,
    required this.unitName,
    this.parentUnitId,
    required this.unitLevel,
    this.headOfUnitId,
    required this.shiftRequired,
    this.description,
    required this.isActive,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'].toString(),
      unitCode: json['unit_code'] ?? '',
      unitName: json['unit_name'] ?? '',
      parentUnitId: json['parent_unit_id']?.toString(),
      unitLevel: json['unit_level'] ?? 1,
      headOfUnitId: json['head_of_unit_id']?.toString(),
      shiftRequired: json['shift_required'] ?? true,
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }
}