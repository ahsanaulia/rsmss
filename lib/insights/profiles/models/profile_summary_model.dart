// lib/insights/profiles/models/profile_summary_model.dart

// import 'profile_model.dart';

class ProfileSummaryModel {
  final int totalEmployees;
  final Map<String, int> employeesByUnit;
  final Map<String, int> employeesByPosition;
  final Map<String, int> employeesByGender;
  final Map<String, int> employeesByJoinYear;
  final Map<String, int> employeesBySituation;

  ProfileSummaryModel({
    required this.totalEmployees,
    required this.employeesByUnit,
    required this.employeesByPosition,
    required this.employeesByGender,
    required this.employeesByJoinYear,
    required this.employeesBySituation,
  });

  factory ProfileSummaryModel.empty() {
    return ProfileSummaryModel(
      totalEmployees: 0,
      employeesByUnit: {},
      employeesByPosition: {},
      employeesByGender: {},
      employeesByJoinYear: {},
      employeesBySituation: {},
    );
  }
}

// Untuk item daftar pegawai (tree view)
class ProfileListItem {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? employeeId;  // 🔥 TAMBAHKAN FIELD INI
  final String? positionName;
  final String? unitCode;
  final String? unitName;
  final String fullPosition;
  final int positionLevel;
  final String? positionColor;
  final String? positionIcon;
  final double? scorePercentage;
  final bool isActiveToday;
  final String currentSituation;

  ProfileListItem({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.employeeId,  // 🔥 TAMBAHKAN
    this.positionName,
    this.unitCode,
    this.unitName,
    required this.fullPosition,
    required this.positionLevel,
    this.positionColor,
    this.positionIcon,
    this.scorePercentage,
    required this.isActiveToday,
    required this.currentSituation,
  });

  factory ProfileListItem.fromJson(Map<String, dynamic> json) {
    return ProfileListItem(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      employeeId: json['employee_id'],  // 🔥 TAMBAHKAN
      positionName: json['position_name'],
      unitCode: json['unit_code'],
      unitName: json['unit_name'],
      fullPosition: json['full_position'] ?? json['full_name'] ?? '',
      positionLevel: json['level'] ?? 99,
      positionColor: json['color'],
      positionIcon: json['icon_name'],
      scorePercentage: json['total_percentage'] != null
          ? (json['total_percentage'] as num).toDouble()
          : null,
      isActiveToday: json['is_active_today'] ?? false,
      currentSituation: json['current_situation'] ?? 'ACTIVE',
    );
  }
}