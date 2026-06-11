class EmployeeModel {
  final String id;
  final String fullName;
  final String role;
  final String? rfidTag;
  final String? address;
  final String? gender;
  final String? phone;
  final String? positionId;
  final String? positionName;
  final String? avatarUrl;
  final String? employeeId;
  final String? employeeNik;
  final String? unitId;
  final String? unitCode;
  final String? unitName;
  final String? defaultShiftId;
  final String? defaultShiftName;
  final int maxWeeklyHours;
  final int maxDailyHours;
  final List<String> preferredShiftIds;
  final String wellbeingRiskLevel;
  final DateTime? lastWellbeingAssessment;
  final String? joinDate;
  final int? joinYear;
  final int intSequence;
  final String intLabel;
  final String currentSituation;
  final String? situationNotes;
  final DateTime? situationUpdatedAt;
  final int ratingTakeCount;
  final bool isAssetInitial;
  final bool isAssetInspection;
  final bool isStockInitial;
  final bool isStockOpname;
  final bool isFlexibleRoster;
  final bool isApproved;
  
  // ============ NEW PERMISSION FIELDS (can_) ============
  final bool canRegisterPeople;
  final bool canBedAssignment;
  final bool canBedUnassignment;
  final bool canCheckoutPeople;
  final bool canAssetInitial;
  final bool canAssetInspection;
  final bool canStockInitial;
  final bool canAssetRequest;
  final bool canReturnAsset;
  final bool canStockOpname;
  final bool canStockIn;
  final bool canStockPlacement;
  final bool canStockRequest;
  final bool canStockRequestApproval;
  final bool canStockFulfillment;
  final bool canStockWriteOff;
  final bool canStockWriteOffApproval;
  final bool canBuildingReference;
  final bool canBinsReference;

  EmployeeModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.rfidTag,
    this.address,
    this.gender,
    this.phone,
    this.positionId,
    this.positionName,
    this.avatarUrl,
    this.employeeId,
    this.employeeNik,
    this.unitId,
    this.unitCode,
    this.unitName,
    this.defaultShiftId,
    this.defaultShiftName,
    this.maxWeeklyHours = 40,
    this.maxDailyHours = 8,
    this.preferredShiftIds = const [],
    this.wellbeingRiskLevel = 'normal',
    this.lastWellbeingAssessment,
    this.joinDate,
    this.joinYear,
    this.intSequence = 1,
    this.intLabel = '1st',
    this.currentSituation = 'ACTIVE',
    this.situationNotes,
    this.situationUpdatedAt,
    this.ratingTakeCount = 1,
    this.isAssetInitial = false,
    this.isAssetInspection = false,
    this.isStockInitial = false,
    this.isStockOpname = false,
    this.isFlexibleRoster = false,
    this.isApproved = false,
    // New permission defaults
    this.canRegisterPeople = false,
    this.canBedAssignment = false,
    this.canBedUnassignment = false,
    this.canCheckoutPeople = false,
    this.canAssetInitial = false,
    this.canAssetInspection = false,
    this.canStockInitial = false,
    this.canAssetRequest = false,
    this.canReturnAsset = false,
    this.canStockOpname = false,
    this.canStockIn = false,
    this.canStockPlacement = false,
    this.canStockRequest = false,
    this.canStockRequestApproval = false,
    this.canStockFulfillment = false,
    this.canStockWriteOff = false,
    this.canStockWriteOffApproval = false,
    this.canBuildingReference = false,
    this.canBinsReference = false,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'operation',
      rfidTag: json['rfid_tag'],
      address: json['address'],
      gender: json['gender'],
      phone: json['phone'],
      positionId: json['position_id']?.toString(),
      positionName: json['ref_positions']?['position_name'],
      avatarUrl: json['avatar_url'],
      employeeId: json['employee_id'],
      employeeNik: json['employee_nik'],
      unitId: json['unit_id']?.toString(),
      unitCode: json['unit_code'],
      unitName: json['employee_units']?['unit_name'],
      defaultShiftId: json['default_shift_id']?.toString(),
      defaultShiftName: json['ref_shifts']?['shift_name'],
      maxWeeklyHours: json['max_weekly_hours'] ?? 40,
      maxDailyHours: json['max_daily_hours'] ?? 8,
      preferredShiftIds: json['preferred_shift_ids'] != null
          ? List<String>.from(json['preferred_shift_ids'])
          : [],
      wellbeingRiskLevel: json['wellbeing_risk_level'] ?? 'normal',
      lastWellbeingAssessment: json['last_wellbeing_assessment'] != null
          ? DateTime.parse(json['last_wellbeing_assessment'])
          : null,
      joinDate: json['join_date'],
      joinYear: json['join_year'],
      intSequence: json['int_sequence'] ?? 1,
      intLabel: json['int_label'] ?? '1st',
      currentSituation: json['current_situation'] ?? 'ACTIVE',
      situationNotes: json['situation_notes'],
      situationUpdatedAt: json['situation_updated_at'] != null
          ? DateTime.parse(json['situation_updated_at'])
          : null,
      ratingTakeCount: json['rating_take_count'] ?? 1,
      isAssetInitial: json['is_asset_initial'] ?? false,
      isAssetInspection: json['is_asset_inspection'] ?? false,
      isStockInitial: json['is_stock_initial'] ?? false,
      isStockOpname: json['is_stock_opname'] ?? false,
      isFlexibleRoster: json['is_flexible_roster'] ?? false,
      isApproved: json['is_approved'] ?? false,
      // New permission fields
      canRegisterPeople: json['can_register_people'] ?? false,
      canBedAssignment: json['can_bed_assignment'] ?? false,
      canBedUnassignment: json['can_bed_unassignment'] ?? false,
      canCheckoutPeople: json['can_checkout_people'] ?? false,
      canAssetInitial: json['can_asset_initial'] ?? false,
      canAssetInspection: json['can_asset_inspection'] ?? false,
      canStockInitial: json['can_stock_initial'] ?? false,
      canAssetRequest: json['can_asset_request'] ?? false,
      canReturnAsset: json['can_return_asset'] ?? false,
      canStockOpname: json['can_stock_opname'] ?? false,
      canStockIn: json['can_stock_in'] ?? false,
      canStockPlacement: json['can_stock_placement'] ?? false,
      canStockRequest: json['can_stock_request'] ?? false,
      canStockRequestApproval: json['can_stock_request_approval'] ?? false,
      canStockFulfillment: json['can_stock_fulfillment'] ?? false,
      canStockWriteOff: json['can_stock_write_off'] ?? false,
      canStockWriteOffApproval: json['can_stock_write_off_approval'] ?? false,
      canBuildingReference: json['can_building_reference'] ?? false,
      canBinsReference: json['can_bins_reference'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'rfid_tag': rfidTag,
      'address': address,
      'gender': gender,
      'phone': phone,
      'position_id': positionId,
      'avatar_url': avatarUrl,
      'employee_id': employeeId,
      'employee_nik': employeeNik,
      'unit_id': unitId,
      'unit_code': unitCode,
      'default_shift_id': defaultShiftId,
      'max_weekly_hours': maxWeeklyHours,
      'max_daily_hours': maxDailyHours,
      'preferred_shift_ids': preferredShiftIds,
      'wellbeing_risk_level': wellbeingRiskLevel,
      'last_wellbeing_assessment': lastWellbeingAssessment?.toIso8601String(),
      'join_date': joinDate,
      'join_year': joinYear,
      'int_sequence': intSequence,
      'int_label': intLabel,
      'current_situation': currentSituation,
      'situation_notes': situationNotes,
      'situation_updated_at': situationUpdatedAt?.toIso8601String(),
      'rating_take_count': ratingTakeCount,
      'is_asset_initial': isAssetInitial,
      'is_asset_inspection': isAssetInspection,
      'is_stock_initial': isStockInitial,
      'is_stock_opname': isStockOpname,
      'is_flexible_roster': isFlexibleRoster,
      'is_approved': isApproved,
      // New permission fields
      'can_register_people': canRegisterPeople,
      'can_bed_assignment': canBedAssignment,
      'can_bed_unassignment': canBedUnassignment,
      'can_checkout_people': canCheckoutPeople,
      'can_asset_initial': canAssetInitial,
      'can_asset_inspection': canAssetInspection,
      'can_stock_initial': canStockInitial,
      'can_asset_request': canAssetRequest,
      'can_return_asset': canReturnAsset,
      'can_stock_opname': canStockOpname,
      'can_stock_in': canStockIn,
      'can_stock_placement': canStockPlacement,
      'can_stock_request': canStockRequest,
      'can_stock_request_approval': canStockRequestApproval,
      'can_stock_fulfillment': canStockFulfillment,
      'can_stock_write_off': canStockWriteOff,
      'can_stock_write_off_approval': canStockWriteOffApproval,
      'can_building_reference': canBuildingReference,
      'can_bins_reference': canBinsReference,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? fullName,
    String? role,
    String? rfidTag,
    String? address,
    String? gender,
    String? phone,
    String? positionId,
    String? positionName,
    String? avatarUrl,
    String? employeeId,
    String? employeeNik,
    String? unitId,
    String? unitCode,
    String? unitName,
    String? defaultShiftId,
    String? defaultShiftName,
    int? maxWeeklyHours,
    int? maxDailyHours,
    List<String>? preferredShiftIds,
    String? wellbeingRiskLevel,
    DateTime? lastWellbeingAssessment,
    String? joinDate,
    int? joinYear,
    int? intSequence,
    String? intLabel,
    String? currentSituation,
    String? situationNotes,
    DateTime? situationUpdatedAt,
    int? ratingTakeCount,
    bool? isAssetInitial,
    bool? isAssetInspection,
    bool? isStockInitial,
    bool? isStockOpname,
    bool? isFlexibleRoster,
    bool? isApproved,
    // New permission fields
    bool? canRegisterPeople,
    bool? canBedAssignment,
    bool? canBedUnassignment,
    bool? canCheckoutPeople,
    bool? canAssetInitial,
    bool? canAssetInspection,
    bool? canStockInitial,
    bool? canAssetRequest,
    bool? canReturnAsset,
    bool? canStockOpname,
    bool? canStockIn,
    bool? canStockPlacement,
    bool? canStockRequest,
    bool? canStockRequestApproval,
    bool? canStockFulfillment,
    bool? canStockWriteOff,
    bool? canStockWriteOffApproval,
    bool? canBuildingReference,
    bool? canBinsReference,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      rfidTag: rfidTag ?? this.rfidTag,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      positionId: positionId ?? this.positionId,
      positionName: positionName ?? this.positionName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      employeeId: employeeId ?? this.employeeId,
      employeeNik: employeeNik ?? this.employeeNik,
      unitId: unitId ?? this.unitId,
      unitCode: unitCode ?? this.unitCode,
      unitName: unitName ?? this.unitName,
      defaultShiftId: defaultShiftId ?? this.defaultShiftId,
      defaultShiftName: defaultShiftName ?? this.defaultShiftName,
      maxWeeklyHours: maxWeeklyHours ?? this.maxWeeklyHours,
      maxDailyHours: maxDailyHours ?? this.maxDailyHours,
      preferredShiftIds: preferredShiftIds ?? this.preferredShiftIds,
      wellbeingRiskLevel: wellbeingRiskLevel ?? this.wellbeingRiskLevel,
      lastWellbeingAssessment: lastWellbeingAssessment ?? this.lastWellbeingAssessment,
      joinDate: joinDate ?? this.joinDate,
      joinYear: joinYear ?? this.joinYear,
      intSequence: intSequence ?? this.intSequence,
      intLabel: intLabel ?? this.intLabel,
      currentSituation: currentSituation ?? this.currentSituation,
      situationNotes: situationNotes ?? this.situationNotes,
      situationUpdatedAt: situationUpdatedAt ?? this.situationUpdatedAt,
      ratingTakeCount: ratingTakeCount ?? this.ratingTakeCount,
      isAssetInitial: isAssetInitial ?? this.isAssetInitial,
      isAssetInspection: isAssetInspection ?? this.isAssetInspection,
      isStockInitial: isStockInitial ?? this.isStockInitial,
      isStockOpname: isStockOpname ?? this.isStockOpname,
      isFlexibleRoster: isFlexibleRoster ?? this.isFlexibleRoster,
      isApproved: isApproved ?? this.isApproved,
      // New permission fields
      canRegisterPeople: canRegisterPeople ?? this.canRegisterPeople,
      canBedAssignment: canBedAssignment ?? this.canBedAssignment,
      canBedUnassignment: canBedUnassignment ?? this.canBedUnassignment,
      canCheckoutPeople: canCheckoutPeople ?? this.canCheckoutPeople,
      canAssetInitial: canAssetInitial ?? this.canAssetInitial,
      canAssetInspection: canAssetInspection ?? this.canAssetInspection,
      canStockInitial: canStockInitial ?? this.canStockInitial,
      canAssetRequest: canAssetRequest ?? this.canAssetRequest,
      canReturnAsset: canReturnAsset ?? this.canReturnAsset,
      canStockOpname: canStockOpname ?? this.canStockOpname,
      canStockIn: canStockIn ?? this.canStockIn,
      canStockPlacement: canStockPlacement ?? this.canStockPlacement,
      canStockRequest: canStockRequest ?? this.canStockRequest,
      canStockRequestApproval: canStockRequestApproval ?? this.canStockRequestApproval,
      canStockFulfillment: canStockFulfillment ?? this.canStockFulfillment,
      canStockWriteOff: canStockWriteOff ?? this.canStockWriteOff,
      canStockWriteOffApproval: canStockWriteOffApproval ?? this.canStockWriteOffApproval,
      canBuildingReference: canBuildingReference ?? this.canBuildingReference,
      canBinsReference: canBinsReference ?? this.canBinsReference,
    );
  }
}