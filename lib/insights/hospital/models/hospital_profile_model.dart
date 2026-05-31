// File: lib/insights/hospital/models/hospital_profile_model.dart

class HospitalProfileModel {
  final String id;
  final String name;
  final String? address;
  final String? logoUrl;
  final String? contactCenter;

  HospitalProfileModel({
    required this.id,
    required this.name,
    this.address,
    this.logoUrl,
    this.contactCenter,
  });

  factory HospitalProfileModel.fromJson(Map<String, dynamic> json) {
    return HospitalProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Hospital',
      address: json['address']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      contactCenter: json['contact_center']?.toString(),
    );
  }

  factory HospitalProfileModel.empty() {
    return HospitalProfileModel(
      id: '',
      name: 'Hospital',
    );
  }
}