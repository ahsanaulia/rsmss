// ============================================================
// MODEL: Asset Report (UNTUK LAPORAN ADMIN)
// ============================================================
// BERDASARKAN VIEW v_asset_report
// TANGGUNG JAWAB: Representasi data untuk laporan aset
// ============================================================

class AssetReport {
  // Primary & Identitas
  final String id;
  final String rfidTagId;
  final String assetName;
  
  // Klasifikasi
  final String? typeName;
  
  // Kondisi
  final String statusCondition;
  final int levelContaminated;
  final bool isDangerous;
  
  // Lokasi
  final String? lastRoomName;
  
  // Perawatan & Status
  final String? maintenancePattern;
  final bool isActive;
  
  // Status Ketersediaan & Pemakai
  final String availabilityStatus;
  final String? currentUserName;
  final String? lastAssignmentStatus;
  
  // Registrasi
  final String? registeredByName;
  final DateTime registeredAt;
  
  // Inspeksi
  final DateTime? lastInspectionAt;
  final String? lastInspectionResult;
  final DateTime? nextInspectionAt;
  final String? lastInspectorName;
  final String inspectionStatus;

  AssetReport({
    required this.id,
    required this.rfidTagId,
    required this.assetName,
    this.typeName,
    required this.statusCondition,
    required this.levelContaminated,
    required this.isDangerous,
    this.lastRoomName,
    this.maintenancePattern,
    required this.isActive,
    required this.availabilityStatus,
    this.currentUserName,
    this.lastAssignmentStatus,
    this.registeredByName,
    required this.registeredAt,
    this.lastInspectionAt,
    this.lastInspectionResult,
    this.nextInspectionAt,
    this.lastInspectorName,
    required this.inspectionStatus,
  });

  factory AssetReport.fromJson(Map<String, dynamic> json) {
    return AssetReport(
      id: json['id'] as String,
      rfidTagId: json['rfid_tag_id'] as String,
      assetName: json['asset_name'] as String,
      typeName: json['type_name'] as String?,
      statusCondition: json['status_condition'] as String? ?? 'Good',
      levelContaminated: (json['level_contaminated'] as int?) ?? 0,
      isDangerous: (json['is_dangerous'] as bool?) ?? false,
      lastRoomName: json['last_room_name'] as String?,
      maintenancePattern: json['maintenance_pattern'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      availabilityStatus: json['availability_status'] as String? ?? 'Tersedia',
      currentUserName: json['current_user_name'] as String?,
      lastAssignmentStatus: json['last_assignment_status'] as String?,
      registeredByName: json['registered_by_name'] as String?,
      registeredAt: _parseDateTime(json['registered_at']) ?? DateTime.now(),
      lastInspectionAt: _parseDateTime(json['last_inspection_at']),
      lastInspectionResult: json['last_inspection_result'] as String?,
      nextInspectionAt: _parseDateTime(json['next_inspection_at']),
      lastInspectorName: json['last_inspector_name'] as String?,
      inspectionStatus: json['inspection_status'] as String? ?? 'Tidak Ditentukan',
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (e) {
      return null;
    }
  }

  String get statusConditionLabel {
    switch (statusCondition.toLowerCase()) {
      case 'good': return 'Baik';
      case 'fair': return 'Cukup';
      case 'damage': return 'Rusak';
      case 'critical': return 'Kritis';
      default: return statusCondition;
    }
  }

  String get isDangerousLabel => isDangerous ? 'Ya' : 'Tidak';
  
  String get isActiveLabel => isActive ? 'Aktif' : 'Tidak Aktif';

  String get formattedRegisteredAt {
    return '${registeredAt.day}/${registeredAt.month}/${registeredAt.year}';
  }

  String get formattedLastInspectionAt {
    if (lastInspectionAt == null) return '-';
    return '${lastInspectionAt!.day}/${lastInspectionAt!.month}/${lastInspectionAt!.year}';
  }

  String get formattedNextInspectionAt {
    if (nextInspectionAt == null) return '-';
    return '${nextInspectionAt!.day}/${nextInspectionAt!.month}/${nextInspectionAt!.year}';
  }
}