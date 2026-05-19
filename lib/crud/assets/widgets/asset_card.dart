// ============================================================
// WIDGET: Asset Card
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan ringkasan informasi aset dalam bentuk card
// 2. Mendukung aksi: tap (detail), edit, delete
// 3. Menampilkan status kondisi dengan warna yang sesuai
// 4. Menampilkan foto aset jika ada (avatar style)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset_model.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  /// Mendapatkan warna berdasarkan status kondisi aset
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

  /// Mendapatkan label status dalam Bahasa Indonesia
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

  /// Mendapatkan warna background untuk level kontaminasi
  Color _getContaminationColor(int level) {
    return ContaminationLevel.getColor(level);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(asset.statusCondition);
    final statusLabel = _getStatusLabel(asset.statusCondition);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // LEFT: FOTO ASET (Avatar)
              // ==================================================
              _buildPhotoAvatar(),
              
              const SizedBox(width: 12),
              
              // ==================================================
              // MIDDLE: INFORMASI ASET
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Aset
                    Text(
                      asset.assetName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // RFID Tag (Kode Asset - Track)
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${asset.rfidTagId}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Informasi tambahan dalam bentuk chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Status Kondisi Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Level Kontaminasi Chip
                        if (asset.levelContaminated > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getContaminationColor(asset.levelContaminated).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Kontaminasi Lv.${asset.levelContaminated}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _getContaminationColor(asset.levelContaminated),
                              ),
                            ),
                          ),
                        
                        // Tipe Aset Chip
                        if (asset.typeName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              asset.typeName!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // Ruangan Chip
                        if (asset.lastRoomName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              asset.lastRoomName!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.teal.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // Berbahaya Chip (jika is_dangerous = true)
                        if (asset.isDangerous)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 10,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Berbahaya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Informasi Waktu
                    Text(
                      'Terdaftar: ${_formatDate(asset.registeredAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // ==================================================
              // RIGHT: ACTION BUTTONS (Edit & Delete)
              // ==================================================
              Column(
                children: [
                  // Edit Button
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF01579B),
                    ),
                    tooltip: 'Edit Aset',
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  
                  // Delete Button
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    tooltip: 'Hapus Aset',
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget foto aset (avatar style)
  Widget _buildPhotoAvatar() {
    // Jika ada foto, tampilkan foto
    if (asset.fotoUrl != null && asset.fotoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          asset.fotoUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Jika tidak ada foto, tampilkan ikon default
    return _buildDefaultAvatar();
  }

  /// Avatar default (saat tidak ada foto)
  Widget _buildDefaultAvatar() {
    // Ambil huruf pertama dari nama aset untuk ditampilkan di avatar
    final initial = asset.assetName.isNotEmpty ? asset.assetName[0].toUpperCase() : 'A';
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF01579B).withValues(alpha: 0.8),
            const Color(0xFF0288D1).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Format tanggal (DD/MM/YYYY HH:MM)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}