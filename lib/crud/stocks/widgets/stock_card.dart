// ============================================================
// WIDGET: Stock Card
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan ringkasan informasi stok dalam bentuk card
// 2. Mendukung aksi: tap (detail), edit, delete
// 3. Menampilkan status stok (Habis, Stok Rendah, Stok Aman) dengan warna berbeda
// 4. Menampilkan foto stok jika ada (avatar style)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stock_model.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StockCard({
    super.key,
    required this.stock,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  /// Mendapatkan status stok (Habis, Stok Rendah, Stok Aman)
  StockStatus _getStockStatus() {
    return StockStatus.fromStock(stock);
  }

  /// Mendapatkan label kondisi stok (GOOD/LOW)
  String _getConditionLabel(String condition) {
    switch (condition.toUpperCase()) {
      case 'GOOD':
        return 'Baik';
      case 'LOW':
        return 'Stok Rendah';
      default:
        return condition;
    }
  }

  /// Mendapatkan warna untuk kondisi stok
  Color _getConditionColor(String condition) {
    switch (condition.toUpperCase()) {
      case 'GOOD':
        return Colors.green;
      case 'LOW':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockStatus = _getStockStatus();
    final conditionColor = _getConditionColor(stock.stockCondition);
    final conditionLabel = _getConditionLabel(stock.stockCondition);

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
              // LEFT: FOTO STOK (Avatar)
              // ==================================================
              _buildPhotoAvatar(),
              
              const SizedBox(width: 12),
              
              // ==================================================
              // MIDDLE: INFORMASI STOK
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Stok
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stock.stockName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status Stok (Habis/Rendah/Aman)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: stockStatus.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            stockStatus.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: stockStatus.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Kode Stok & Satuan
                    Row(
                      children: [
                        if (stock.stockCode != null && stock.stockCode!.isNotEmpty)
                          Expanded(
                            child: Text(
                              'Kode: ${stock.stockCode}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (stock.stockCode != null && stock.stockCode!.isNotEmpty)
                          const SizedBox(width: 8),
                        Text(
                          'Satuan: ${stock.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
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
                        // Stok Saat Ini Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stok: ${stock.currentStock} ${stock.unit}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        
                        // Minimum Stok Chip
                        if (stock.minimumStock > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Min: ${stock.minimumStock} ${stock.unit}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        
                        // Kondisi Stok Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: conditionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conditionLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: conditionColor,
                            ),
                          ),
                        ),
                        
                        // Tipe Stok Chip
                        if (stock.stockTypeName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stock.stockTypeName!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.teal.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // Lokasi Chip
                        if (stock.storageLocationName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stock.storageLocationName!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.purple.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Informasi Waktu
                    Text(
                      'Dibuat: ${_formatDate(stock.createdAt)}',
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
                    tooltip: 'Edit Stok',
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
                    tooltip: 'Hapus Stok',
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

  /// Widget foto stok (avatar style - SQUARE)
  Widget _buildPhotoAvatar() {
    // Jika ada foto, tampilkan foto dengan BoxFit.cover
    if (stock.photoUrl != null && stock.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          stock.photoUrl!,
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
    // Ambil huruf pertama dari nama stok untuk ditampilkan di avatar
    final initial = stock.stockName.isNotEmpty ? stock.stockName[0].toUpperCase() : 'S';
    
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