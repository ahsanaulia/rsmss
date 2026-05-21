// ============================================================
// MODEL: Asset Assignment Pending
// ============================================================

class AssetAssignmentPending {
  final String id;
  final String assetId;
  final String assetName;
  final String? fotoUrl;
  final String profileId;
  final String requesterName;      // tetap required, tapi akan diisi fallback
  final String? requesterEmployeeId;
  final String? notes;
  final String assignmentStatus;
  final DateTime requestedAt;
  final String? handoverLocationId;
  final String? handoverLocationName;
  final String? assignedByName;

  AssetAssignmentPending({
    required this.id,
    required this.assetId,
    required this.assetName,
    this.fotoUrl,
    required this.profileId,
    required this.requesterName,
    this.requesterEmployeeId,
    this.notes,
    required this.assignmentStatus,
    required this.requestedAt,
    this.handoverLocationId,
    this.handoverLocationName,
    this.assignedByName,
  });

  factory AssetAssignmentPending.fromJson(Map<String, dynamic> json) {
    // Cek apakah ada requester_name (dari v_pending_assignments)
    // Jika tidak, gunakan profile_id sebagai fallback
    final hasRequesterName = json.containsKey('requester_name');
    
    String requesterName;
    String? requesterEmployeeId;
    
    if (hasRequesterName) {
      requesterName = json['requester_name'] as String? ?? 'Unknown';
      requesterEmployeeId = json['requester_employee_id'] as String?;
    } else {
      // Untuk v_my_asset_requests, kita tidak punya nama pemohon
      // Gunakan profile_id sebagai fallback
      requesterName = json['profile_id'] as String? ?? 'Unknown';
      requesterEmployeeId = null;
    }
    
    return AssetAssignmentPending(
      id: json['id'] as String,
      assetId: json['asset_id'] as String,
      assetName: json['asset_name'] as String,
      fotoUrl: json['foto_url'] as String?,
      profileId: json['profile_id'] as String,
      requesterName: requesterName,
      requesterEmployeeId: requesterEmployeeId,
      notes: json['notes'] as String?,
      assignmentStatus: json['assignment_status'] as String? ?? 'pending',
      requestedAt: _parseDateTime(json['requested_at']) ?? DateTime.now(),
      handoverLocationId: json['handover_location_id'] as String?,
      handoverLocationName: json['handover_location_name'] as String?,
      assignedByName: json['assigned_by_name'] as String?,
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

  Map<String, dynamic> toJsonForApprove(String adminUserId) {
    return {
      'assignment_status': 'active',
      'assigned_by': adminUserId,
      'assigned_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForReject(String adminUserId) {
    return {
      'assignment_status': 'rejected',
      'assigned_by': adminUserId,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AssetAssignmentPending(id: $id, assetName: $assetName, status: $assignmentStatus)';
  }
}