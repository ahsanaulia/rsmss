// lib/insights/assets/widgets/asset_detail_popup.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/asset_detail_provider.dart';
import '../models/asset_detail_model.dart';

class AssetDetailPopup extends ConsumerStatefulWidget {
  final String assetId;

  const AssetDetailPopup({super.key, required this.assetId});

  @override
  ConsumerState<AssetDetailPopup> createState() => _AssetDetailPopupState();
}

class _AssetDetailPopupState extends ConsumerState<AssetDetailPopup> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(selectedAssetIdProvider.notifier).state = widget.assetId;
      }
    });
  }

  @override
  void dispose() {
    ref.read(selectedAssetIdProvider.notifier).state = null;
    super.dispose();
  }

  void _closeDialog() {
    ref.read(selectedAssetIdProvider.notifier).state = null;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(assetDetailProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: isMobile ? screenWidth * 0.95 : screenWidth * 0.7,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A2A4A).withValues(alpha: 0.95),
                const Color(0xFF0F1A2E).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: detailAsync.when(
                data: (detail) {
                  if (!mounted) return const SizedBox.shrink();
                  return _buildContent(context, detail, isMobile);
                },
                loading: () {
                  if (!mounted) return const SizedBox.shrink();
                  return _buildLoading();
                },
                error: (e, st) {
                  if (!mounted) return const SizedBox.shrink();
                  return _buildError(e.toString());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AssetDetail? detail, bool isMobile) {
    if (detail == null) {
      return _buildError('Data tidak ditemukan');
    }

    return Column(
      children: [
        _buildHeader(detail),
        Expanded(
          child: isMobile
              ? _buildMobileBody(detail)
              : _buildDesktopBody(detail),
        ),
      ],
    );
  }

  Widget _buildHeader(AssetDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.assetName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'RFID: ${detail.rfidTagId}',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _closeDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(AssetDetail detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT PANEL - PHOTO & CONDITION (40%)
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPhotoPanel(detail),
                const SizedBox(height: 16),
                _buildConditionBadge(detail),
                if (detail.isDangerous && detail.hasDangerInfo) ...[
                  const SizedBox(height: 16),
                  _buildDangerousInfoPanel(detail),
                ],
              ],
            ),
          ),
        ),
        // RIGHT PANEL - INFO (60%)
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(detail),
                const SizedBox(height: 16),
                _buildHandlingInstruction(detail.handlingInstruction),
                if (detail.description != null && detail.description!.isNotEmpty)
                  _buildDescription(detail.description!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody(AssetDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPhotoPanel(detail),
          const SizedBox(height: 16),
          _buildConditionBadge(detail),
          if (detail.isDangerous && detail.hasDangerInfo) ...[
            const SizedBox(height: 16),
            _buildDangerousInfoPanel(detail),
          ],
          const SizedBox(height: 20),
          _buildInfoSection(detail),
          const SizedBox(height: 16),
          _buildHandlingInstruction(detail.handlingInstruction),
          if (detail.description != null && detail.description!.isNotEmpty)
            _buildDescription(detail.description!),
        ],
      ),
    );
  }

  Widget _buildPhotoPanel(AssetDetail detail) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: detail.fotoUrl != null && detail.fotoUrl!.isNotEmpty
            ? Image.network(
                detail.fotoUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.white54),
                          const SizedBox(height: 8),
                          Text('Gambar tidak tersedia', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                          const SizedBox(height: 8),
                          Text('Memuat gambar...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container(
                height: 250,
                color: Colors.white.withValues(alpha: 0.05),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices, size: 64, color: Colors.white54),
                      const SizedBox(height: 8),
                      Text('Tidak ada gambar', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildConditionBadge(AssetDetail detail) {
    Color color;
    String label = detail.statusCondition ?? 'Unknown';
    
    switch (label.toLowerCase()) {
      case 'good':
        color = const Color(0xFF10B981);
        break;
      case 'maintenance':
        color = const Color(0xFFF59E0B);
        break;
      case 'damaged':
        color = const Color(0xFFEF4444);
        break;
      case 'critical':
        color = const Color(0xFFDC2626);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text('Kondisi: $label', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          if (detail.levelContaminated != null && detail.levelContaminated! > 0)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('⚠️ Lv.${detail.levelContaminated}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDangerousInfoPanel(AssetDetail detail) {
    final dangerLevel = detail.dangerLevelName ?? 'SEDANG';
    final dangerRisk = detail.dangerRisk ?? 'Perlu penanganan khusus sesuai prosedur rumah sakit';
    final dangerProtection = detail.dangerProtection ?? 'Gunakan APD sesuai standar rumah sakit';
    final dangerInstruction = detail.dangerInstruction ?? 'Ikuti prosedur penanganan aset berbahaya';
    
    Color dangerColor;
    if (detail.dangerColor != null) {
      try {
        dangerColor = Color(int.parse('0xFF${detail.dangerColor!.replaceAll('#', '')}'));
      } catch (e) {
        dangerColor = const Color(0xFFF59E0B);
      }
    } else {
      dangerColor = const Color(0xFFF59E0B);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7F1D1D).withValues(alpha: 0.2),
            const Color(0xFF991B1B).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 24, color: Color(0xFFEF4444)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ASET BERBAHAYA', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
                    Text('Perlu penanganan khusus', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dangerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dangerColor.withValues(alpha: 0.5), width: 1),
                ),
                child: Text(dangerLevel, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: dangerColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 12),
          _buildDangerInfoRow('⚠️ Resiko', dangerRisk),
          const SizedBox(height: 8),
          _buildDangerInfoRow('🧪 Kontaminasi', 
            detail.levelContaminated != null
                ? 'Level ${detail.levelContaminated} - ${_getContaminationDescription(detail.levelContaminated!)}'
                : 'Tidak terdeteksi kontaminasi'
          ),
          const SizedBox(height: 8),
          _buildDangerInfoRow('🛡️ Proteksi', dangerProtection),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFFFCA5A5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(dangerInstruction, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFFCA5A5))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70))),
        Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54))),
      ],
    );
  }

  String _getContaminationDescription(int level) {
    switch (level) {
      case 1: return 'Kontaminasi ringan, bersihkan dengan prosedur standar';
      case 2: return 'Kontaminasi sedang, perlu dekontaminasi khusus';
      case 3: return 'Kontaminasi tinggi, isolasi dan dekontaminasi intensif';
      case 4: return 'Kontaminasi sangat tinggi, area merah, tim khusus diperlukan';
      default: return 'Perlu penanganan khusus';
    }
  }

  Widget _buildInfoSection(AssetDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 INFORMASI ASET', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70)),
          const SizedBox(height: 16),
          _buildInfoRow('Kategori', detail.categoryName),
          _buildInfoRow('Sub Kategori', detail.subCategoryName),
          _buildInfoRow('Tipe', detail.typeName),
          const Divider(height: 20, color: Colors.white24),
          _buildInfoRow('Ruangan', detail.roomName),
          _buildInfoRow('Detektor', detail.detectorCode),
          _buildInfoRow('Status Pergerakan', detail.lastMovementStatus),
          _buildInfoRow('Terakhir Terdeteksi', _formatDateTime(detail.lastDetectedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54))),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildHandlingInstruction(String? instruction) {
    if (instruction == null || instruction.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️ PETUNJUK PENANGANAN', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFF59E0B))),
          const SizedBox(height: 8),
          Text(instruction, style: GoogleFonts.poppins(fontSize: 11, height: 1.5, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📝 DESKRIPSI', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.poppins(fontSize: 11, height: 1.5, color: Colors.white54)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return '${value.day}/${value.month}/${value.year} ${value.hour}:${value.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Memuat detail aset...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Gagal memuat data', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(message, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _closeDialog,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF052D9C)),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}