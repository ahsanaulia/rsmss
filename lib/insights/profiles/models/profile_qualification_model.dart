// lib/insights/profiles/models/profile_qualification_model.dart

class QualificationModel {
  final String id;
  final String qualificationCode;
  final String qualificationName;
  final String? category;
  final int? validityPeriodMonths;
  final bool requiresRenewal;
  final String? description;
  final bool isActive;

  QualificationModel({
    required this.id,
    required this.qualificationCode,
    required this.qualificationName,
    this.category,
    this.validityPeriodMonths,
    required this.requiresRenewal,
    this.description,
    required this.isActive,
  });

  factory QualificationModel.fromJson(Map<String, dynamic> json) {
    return QualificationModel(
      id: json['id'].toString(),
      qualificationCode: json['qualification_code'] ?? '',
      qualificationName: json['qualification_name'] ?? '',
      category: json['category'],
      validityPeriodMonths: json['validity_period_months'],
      requiresRenewal: json['requires_renewal'] ?? true,
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class QualificationAssignmentModel {
  final String id;
  final String profileId;
  final String qualificationId;
  final DateTime acquiredDate;
  final DateTime? expiryDate;
  final String? certificateNumber;
  final double? score;
  final bool isActive;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? notes;

  QualificationAssignmentModel({
    required this.id,
    required this.profileId,
    required this.qualificationId,
    required this.acquiredDate,
    this.expiryDate,
    this.certificateNumber,
    this.score,
    required this.isActive,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft <= 30 && daysLeft > 0;
  }

  String get expiryStatus {
    if (expiryDate == null) return 'no_expiry';
    if (isExpired) return 'expired';
    if (isExpiringSoon) return 'expiring_soon';
    return 'active';
  }

  factory QualificationAssignmentModel.fromJson(Map<String, dynamic> json) {
    return QualificationAssignmentModel(
      id: json['id'].toString(),
      profileId: json['profile_id'].toString(),
      qualificationId: json['qualification_id'].toString(),
      acquiredDate: json['acquired_date'] != null
          ? DateTime.parse(json['acquired_date'])
          : DateTime.now(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      certificateNumber: json['certificate_number'],
      score: json['score']?.toDouble(),
      isActive: json['is_active'] ?? true,
      verifiedBy: json['verified_by']?.toString(),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      notes: json['notes'],
    );
  }
}

// 🔥 DIPERBAIKI: Menambahkan field profileName, profileId, unitCode
class QualificationWithAssignment {
  final QualificationModel qualification;
  final QualificationAssignmentModel? assignment;
  final String? profileName;    // 🔥 Nama pegawai pemilik sertifikasi
  final String? profileId;      // 🔥 ID pegawai pemilik sertifikasi
  final String? unitCode;       // 🔥 Unit pegawai pemilik sertifikasi
  final String? avatarUrl;      // 🔥 Avatar pegawai (opsional)

  QualificationWithAssignment({
    required this.qualification,
    this.assignment,
    this.profileName,
    this.profileId,
    this.unitCode,
    this.avatarUrl,
  });

  bool get isOwned => assignment != null && assignment!.isActive;
  bool get isExpired => assignment != null && assignment!.isExpired;
  bool get isExpiringSoon => assignment != null && assignment!.isExpiringSoon;
  DateTime? get expiryDate => assignment?.expiryDate;
  
  String get displayName {
    if (profileName != null && profileName!.isNotEmpty) {
      return profileName!;
    }
    return 'Pegawai';
  }
  
  String get displayUnit {
    if (unitCode != null && unitCode!.isNotEmpty) {
      return unitCode!;
    }
    return '';
  }
}