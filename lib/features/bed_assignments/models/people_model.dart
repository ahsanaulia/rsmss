// lib/features/bed_assignments/models/people_model.dart
// (copy dari model people yang sudah ada, atau buat simple version dulu)

class SimplePeopleModel {
  final String id;
  final String rfidTagId;
  final String fullName;
  final String? categoryName;
  final bool isActive;

  SimplePeopleModel({
    required this.id,
    required this.rfidTagId,
    required this.fullName,
    this.categoryName,
    required this.isActive,
  });

  factory SimplePeopleModel.fromJson(Map<String, dynamic> json) {
    return SimplePeopleModel(
      id: json['id'] ?? '',
      rfidTagId: json['rfid_tag_id'] ?? '',
      fullName: json['full_name'] ?? '',
      categoryName: json['ref_people_categories']?['category_name'],
      isActive: json['is_active'] ?? true,
    );
  }
}