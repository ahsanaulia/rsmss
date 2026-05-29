// lib/insights/assets/views/asset_tree_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/asset_tree_provider.dart';
import '../models/asset_tree_model.dart';
import '../widgets/asset_tree_view.dart';
import '../widgets/asset_detail_popup.dart';

class AssetTreeScreen extends ConsumerStatefulWidget {
  const AssetTreeScreen({super.key});

  @override
  ConsumerState<AssetTreeScreen> createState() => _AssetTreeScreenState();
}

class _AssetTreeScreenState extends ConsumerState<AssetTreeScreen> {
  AssetTypeNode? _selectedType;

  void _onTypeTap(AssetTypeNode type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _showAssetDetail(String assetId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => AssetDetailPopup(assetId: assetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF052D9C),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assetTreeProvider);
        },
        child: Row(
          children: [
            // LEFT PANEL - Tree View (35% width)
            Expanded(
              flex: isMobile ? 5 : 4,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: AssetTreeView(
                  onTypeTap: _onTypeTap,
                  selectedTypeId: _selectedType?.id,
                ),
              ),
            ),
            // RIGHT PANEL - Assets List (65% width)
            Expanded(
              flex: isMobile ? 5 : 6,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: _selectedType == null
                    ? _buildEmptyState()
                    : _buildAssetsList(_selectedType!.assets),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.devices, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Pilih Tipe Aset',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Klik pada tipe aset di panel kiri',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsList(List<AssetItem> assets) {
    if (assets.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada aset',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.devices, size: 20, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 12),
                    Text(
                      'DAFTAR ASET',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${assets.length} aset',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    return _buildAssetCard(assets[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetCard(AssetItem asset) {
  final statusColor = _getStatusColor(asset.statusCondition);

  return GestureDetector(
    onTap: () => _showAssetDetail(asset.id),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          // 🔥 FOTO ASSET
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: asset.fotoUrl != null && asset.fotoUrl!.isNotEmpty
                  ? Image.network(
                      asset.fotoUrl!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.devices,
                            size: 28,
                            color: const Color(0xFF8B5CF6),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.devices,
                        size: 28,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Info Asset
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  asset.rfidTagId,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
                if (asset.lastRoomName != null)
                  Text(
                    '📍 ${asset.lastRoomName}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
              ],
            ),
          ),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              asset.statusCondition ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (asset.isDangerous)
            Icon(Icons.warning_amber, size: 16, color: const Color(0xFFEF4444)),
          const Icon(Icons.chevron_right, size: 16, color: Colors.white38),
        ],
      ),
    ),
  );
}
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'good':
        return const Color(0xFF10B981);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      case 'damaged':
        return const Color(0xFFEF4444);
      case 'critical':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }
}
