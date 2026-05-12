import 'package:flutter/foundation.dart';

@immutable
class HospitalProfileModel {
  final String id;

  final String? appId;

  final String name;

  final String? address;

  final String? logoUrl;

  final String? contactCenter;

  final int totalBuildings;

  final DateTime? createdAt;

  const HospitalProfileModel({
    required this.id,
    required this.name,
    required this.totalBuildings,
    this.appId,
    this.address,
    this.logoUrl,
    this.contactCenter,
    this.createdAt,
  });

  factory HospitalProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HospitalProfileModel(
      id: json['id'] ?? '',

      appId: json['app_id'],

      name: json['name'] ?? 'Unknown Hospital',

      address: json['address'],

      logoUrl: json['logo_url'],

      contactCenter: json['contact_center'],

      totalBuildings:
          json['total_buildings'] ?? 0,

      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(
                json['created_at'],
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'name': name,
      'address': address,
      'logo_url': logoUrl,
      'contact_center': contactCenter,
      'total_buildings':
          totalBuildings,
      'created_at':
          createdAt?.toIso8601String(),
    };
  }

  HospitalProfileModel copyWith({
    String? id,
    String? appId,
    String? name,
    String? address,
    String? logoUrl,
    String? contactCenter,
    int? totalBuildings,
    DateTime? createdAt,
  }) {
    return HospitalProfileModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      name: name ?? this.name,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      contactCenter:
          contactCenter ??
          this.contactCenter,
      totalBuildings:
          totalBuildings ??
          this.totalBuildings,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return '''
HospitalProfileModel(
  id: $id,
  name: $name,
  address: $address,
  logoUrl: $logoUrl,
  totalBuildings: $totalBuildings
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HospitalProfileModel &&
            runtimeType ==
                other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}