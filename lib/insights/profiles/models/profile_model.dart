// lib/insights/profiles/models/profile_model.dart
class ProfileModel {
  final String id;
  final String fullName;
  final String? role;
  final String? rfidTag;
  final String? address;
  final String? gender;
  final String? phone;
  final String? positionId;
  final String? avatarUrl;
  final String? employeeId;
  final bool isAssetInitial;
  final bool isAssetInspection;
  final bool isStockInitial;
  final bool isStockOpname;
  final bool isFlexibleRoster;
  final String? defaultShiftId;
  final int maxWeeklyHours;
  final int maxDailyHours;
  final List<String> preferredShiftIds;
  final String wellbeingRiskLevel;
  final DateTime? lastWellbeingAssessment;
  final String? employeeNik;
  final String? unitId;
  final String? unitCode;
  final DateTime? joinDate;
  final int? joinYear;
  final int intSequence;
  final String intLabel;
  final String currentSituation;
  final String? situationNotes;
  final DateTime? situationUpdatedAt;
  final int ratingTakeCount;
  final String? currentAssignment;
  final String? assignmentDestination;
  final DateTime? assignmentStartedAt;
  final DateTime? assignmentEta;
  final double? assignmentDestinationLat;
  final double? assignmentDestinationLong;
  final bool isStockApproval;
  final bool isApproved;
  final bool isStockAdmin;
  final bool isAssetAdmin;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.role,
    this.rfidTag,
    this.address,
    this.gender,
    this.phone,
    this.positionId,
    this.avatarUrl,
    this.employeeId,
    required this.isAssetInitial,
    required this.isAssetInspection,
    required this.isStockInitial,
    required this.isStockOpname,
    required this.isFlexibleRoster,
    this.defaultShiftId,
    required this.maxWeeklyHours,
    required this.maxDailyHours,
    required this.preferredShiftIds,
    required this.wellbeingRiskLevel,
    this.lastWellbeingAssessment,
    this.employeeNik,
    this.unitId,
    this.unitCode,
    this.joinDate,
    this.joinYear,
    required this.intSequence,
    required this.intLabel,
    required this.currentSituation,
    this.situationNotes,
    this.situationUpdatedAt,
    required this.ratingTakeCount,
    this.currentAssignment,
    this.assignmentDestination,
    this.assignmentStartedAt,
    this.assignmentEta,
    this.assignmentDestinationLat,
    this.assignmentDestinationLong,
    required this.isStockApproval,
    required this.isApproved,
    required this.isStockAdmin,
    required this.isAssetAdmin,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      role: json['role'],
      rfidTag: json['rfid_tag'],
      address: json['address'],
      gender: json['gender'],
      phone: json['phone'],
      positionId: json['position_id']?.toString(),
      avatarUrl: json['avatar_url'],
      employeeId: json['employee_id'],
      isAssetInitial: json['is_asset_initial'] ?? false,
      isAssetInspection: json['is_asset_inspection'] ?? false,
      isStockInitial: json['is_stock_initial'] ?? false,
      isStockOpname: json['is_stock_opname'] ?? false,
      isFlexibleRoster: json['is_flexible_roster'] ?? false,
      defaultShiftId: json['default_shift_id']?.toString(),
      maxWeeklyHours: json['max_weekly_hours'] ?? 40,
      maxDailyHours: json['max_daily_hours'] ?? 8,
      preferredShiftIds: json['preferred_shift_ids'] != null
          ? List<String>.from(json['preferred_shift_ids'])
          : [],
      wellbeingRiskLevel: json['wellbeing_risk_level'] ?? 'normal',
      lastWellbeingAssessment: json['last_wellbeing_assessment'] != null
          ? DateTime.parse(json['last_wellbeing_assessment'])
          : null,
      employeeNik: json['employee_nik'],
      unitId: json['unit_id']?.toString(),
      unitCode: json['unit_code'],
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : null,
      joinYear: json['join_year'],
      intSequence: json['int_sequence'] ?? 1,
      intLabel: json['int_label'] ?? '1st',
      currentSituation: json['current_situation'] ?? 'ACTIVE',
      situationNotes: json['situation_notes'],
      situationUpdatedAt: json['situation_updated_at'] != null
          ? DateTime.parse(json['situation_updated_at'])
          : null,
      ratingTakeCount: json['rating_take_count'] ?? 1,
      currentAssignment: json['current_assignment'],
      assignmentDestination: json['assignment_destination'],
      assignmentStartedAt: json['assignment_started_at'] != null
          ? DateTime.parse(json['assignment_started_at'])
          : null,
      assignmentEta: json['assignment_eta'] != null
          ? DateTime.parse(json['assignment_eta'])
          : null,
      assignmentDestinationLat: json['assignment_destination_lat']?.toDouble(),
      assignmentDestinationLong: json['assignment_destination_long']?.toDouble(),
      isStockApproval: json['is_stock_approval'] ?? false,
      isApproved: json['is_approved'] ?? false,
      isStockAdmin: json['is_stock_admin'] ?? false,
      isAssetAdmin: json['is_asset_admin'] ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  String get fullPosition => '$fullName${employeeId != null ? ' ($employeeId)' : ''}';
  bool get isActive => currentSituation == 'ACTIVE';
}