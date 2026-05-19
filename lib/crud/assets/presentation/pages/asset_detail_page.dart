// ============================================================
// PAGE: Asset Detail Page
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan detail lengkap aset
// 2. Header dengan foto aset dan informasi utama
// 3. Informasi detail dalam card-grid (2 kolom)
// 4. Aksi: Edit (buka dialog), Delete (konfirmasi), Back
// 5. Refresh data saat kembali dari edit
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/asset_providers.dart';
import '../../providers/asset_state.dart';
import '../../models/asset_model.dart';
import '../../services/asset_service.dart';
import '../dialogs/asset_form_dialog.dart';

class AssetDetailPage extends ConsumerStatefulWidget {
  final String assetId;
  final VoidCallback onAssetUpdated;

  const AssetDetailPage({
    super.key,
    required this.assetId,
    required this.onAssetUpdated,
  });

  @override
  ConsumerState<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends ConsumerState<AssetDetailPage> {
  late final AuthService _authService;
  late final AssetService _assetService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _assetService = AssetService();
  }

  String? get _currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  Future<void> _refreshDetail() async {
    final notifier = ref.read(assetDetailProvider(widget.assetId).notifier);
    await notifier.loadAsset(widget.assetId);
  }

  void _showEditDialog(Asset asset) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AssetFormDialog(
          isEditing: true,
          existingAsset: asset,
          assetService: _assetService,
          currentUserId: _currentUserId,
          onSuccess: () {
            Navigator.pop(dialogContext);
            _refreshDetail();
            widget.onAssetUpdated();
          },
        );
      },
    );
  }

  void _confirmDelete(Asset asset) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus aset "${asset.assetName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              if (_currentUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session expired, silakan login ulang'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              try {
                await _assetService.deleteAsset(asset.id, _currentUserId!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aset berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Kembali ke list page
                  widget.onAssetUpdated();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus aset: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetDetailProvider(widget.assetId));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Detail Aset'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF01579B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (state.asset != null && !state.isLoading)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(state.asset!);
                } else if (value == 'delete') {
                  _confirmDelete(state.asset!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Color(0xFF01579B)),
                      SizedBox(width: 8),
                      Text('Edit Aset'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Aset'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF01579B)),
            )
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat detail aset',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01579B),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : state.asset == null
                  ? const Center(
                      child: Text('Aset tidak ditemukan'),
                    )
                  : _buildDetailContent(state.asset!),
    );
  }

  Widget _buildDetailContent(Asset asset) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // HEADER CARD: Foto & Informasi Utama
          // ==================================================
          _buildHeaderCard(asset),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Informasi Identitas
          // ==================================================
          _buildSectionTitle('Informasi Identitas'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem('Kode Asset - Track', asset.rfidTagId, Icons.qr_code),
            InfoItem('Nama Aset', asset.assetName, Icons.inventory_2),
            InfoItem('Tipe Aset', asset.typeName ?? '-', Icons.category),
            InfoItem('Kategori', asset.categoryName ?? '-', Icons.folder),
            InfoItem('Sub Kategori', asset.subCategoryName ?? '-', Icons.subdirectory_arrow_right),
          ]),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Kondisi & Perawatan
          // ==================================================
          _buildSectionTitle('Kondisi & Perawatan'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem(
              'Status Kondisi',
              _getStatusLabel(asset.statusCondition),
              Icons.health_and_safety,
              color: _getStatusColor(asset.statusCondition),
            ),
            InfoItem(
              'Level Kontaminasi',
              '${asset.levelContaminated} - ${ContaminationLevel.getLabel(asset.levelContaminated)}',
              Icons.coronavirus_outlined,
              color: ContaminationLevel.getColor(asset.levelContaminated),
            ),
            InfoItem(
              'Berbahaya',
              asset.isDangerous ? 'Ya' : 'Tidak',
              Icons.warning,
              color: asset.isDangerous ? Colors.red : Colors.grey,
            ),
            InfoItem(
              'Pola Perawatan',
              asset.maintenancePattern ?? '-',
              Icons.build,
            ),
            InfoItem(
              'Hari Inspeksi',
              asset.inspectionDayOfMonth != null
                  ? 'Setiap tanggal ${asset.inspectionDayOfMonth}'
                  : '-',
              Icons.calendar_today,
            ),
            InfoItem(
              'Terakhir Inspeksi',
              _formatDate(asset.lastInspectionAt),
              Icons.assignment_turned_in,
            ),
            InfoItem(
              'Inspeksi Berikutnya',
              _formatDate(asset.nextInspectionAt),
              Icons.event,
            ),
          ]),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Lokasi & Assignment
          // ==================================================
          _buildSectionTitle('Lokasi & Assignment'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem('Ruangan Saat Ini', asset.lastRoomName ?? '-', Icons.location_on),
            InfoItem('Detektor Terakhir', asset.lastDetectorId ?? '-', Icons.sensors),
            InfoItem('Terakhir Terdeteksi', _formatDate(asset.lastDetectedAt), Icons.access_time),
            InfoItem('Status Pergerakan', asset.lastMovementStatus ?? '-', Icons.directions_walk),
            InfoItem('Pengguna Terakhir', asset.lastUsedByName ?? '-', Icons.person),
            InfoItem('Terakhir Assign', _formatDate(asset.lastAssignedAt), Icons.assignment_ind),
          ]),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Inspeksi Terakhir
          // ==================================================
          if (asset.lastInspectionResult != null ||
              asset.lastInspectionNotes != null ||
              asset.lastActionTaken != null ||
              asset.lastRecommendation != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Hasil Inspeksi Terakhir'),
                const SizedBox(height: 8),
                _buildInfoGrid([
                  if (asset.lastInspectionResult != null)
                    InfoItem('Hasil', asset.lastInspectionResult!, Icons.assessment),
                  if (asset.lastInspectionNotes != null)
                    InfoItem('Catatan', asset.lastInspectionNotes!, Icons.note),
                  if (asset.lastActionTaken != null)
                    InfoItem('Tindakan', asset.lastActionTaken!, Icons.handyman),
                  if (asset.lastRecommendation != null)
                    InfoItem('Rekomendasi', asset.lastRecommendation!, Icons.lightbulb),
                ]),
                const SizedBox(height: 16),
              ],
            ),

          // ==================================================
          // SECTION: Deskripsi
          // ==================================================
          if (asset.description != null && asset.description!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Deskripsi'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    asset.description!,
                    style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Metadata (dibuat, diupdate)
          // ==================================================
          _buildSectionTitle('Informasi Sistem'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem('Dibuat Oleh', asset.registeredByName ?? '-', Icons.person_add),
            InfoItem('Tanggal Dibuat', _formatDate(asset.registeredAt), Icons.create),
            InfoItem('Terakhir Update', asset.updatedByName ?? '-', Icons.person),
            InfoItem('Tanggal Update', _formatDate(asset.updatedAt), Icons.update),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF01579B),
      ),
    );
  }

  Widget _buildHeaderCard(Asset asset) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF01579B),
            const Color(0xFF0288D1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01579B).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Foto Aset
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: asset.fotoUrl != null && asset.fotoUrl!.isNotEmpty
                  ? Image.network(
                      asset.fotoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(asset.assetName);
                      },
                    )
                  : _buildDefaultAvatar(asset.assetName),
            ),
            const SizedBox(width: 16),
            // Informasi Ringkas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          asset.isActive ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          asset.isActive ? 'Aktif' : 'Tidak Aktif',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    asset.assetName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.rfidTagId,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String assetName) {
    final initial = assetName.isNotEmpty ? assetName[0].toUpperCase() : 'A';
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<InfoItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (item.color ?? const Color(0xFF01579B)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 16,
                  color: item.color ?? const Color(0xFF01579B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      item.value,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'damage':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return 'Baik';
      case 'fair':
        return 'Cukup';
      case 'damage':
        return 'Rusak';
      case 'critical':
        return 'Kritis';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  InfoItem(this.label, this.value, this.icon, {this.color});
}