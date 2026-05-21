// ============================================================
// MODEL: Asset Request (UNTUK PEGAWAI)
// ============================================================
// TANGGUNG JAWAB:
// 1. Hanya untuk INSERT ke tabel asset_assignments
// 2. Tidak untuk SELECT (karena SELECT pakai view)
// 3. Kolom disesuaikan dengan yang diinput pegawai
// ============================================================

/// Model untuk permintaan aset yang diajukan oleh PEGAWAI
/// Digunakan hanya untuk CREATE (INSERT ke asset_assignments)
class AssetRequest {
  final String assetId;           // ID aset yang dipilih (dari v_asset_available)
  final String profileId;         // ID pegawai yang mengajukan (dari AuthService)
  final String createdBy;         // Sama dengan profileId
  final String? notes;            // Catatan dari pegawai (opsional)
  final String? handoverLocationId; // ID lokasi serah terima (dari tabel rooms)
  final String assignmentStatus;  // default 'pending'
  final DateTime createdAt;       // waktu pengajuan
  final DateTime updatedAt;       // waktu update

  AssetRequest({
    required this.assetId,
    required this.profileId,
    required this.createdBy,
    this.notes,
    this.handoverLocationId,
    this.assignmentStatus = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Konstruktor untuk membuat request baru (tanpa id karena auto generate)
  factory AssetRequest.newRequest({
    required String assetId,
    required String profileId,
    String? notes,
    String? handoverLocationId,
  }) {
    final now = DateTime.now();
    return AssetRequest(
      assetId: assetId,
      profileId: profileId,
      createdBy: profileId, // sama dengan profileId
      notes: notes,
      handoverLocationId: handoverLocationId,
      assignmentStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// To JSON untuk INSERT ke tabel asset_assignments
  Map<String, dynamic> toJson() {
    return {
      'asset_id': assetId,
      'profile_id': profileId,
      'created_by': createdBy,
      'notes': notes,
      'handover_location_id': handoverLocationId,
      'assignment_status': assignmentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AssetRequest(assetId: $assetId, profileId: $profileId, status: $assignmentStatus)';
  }
}