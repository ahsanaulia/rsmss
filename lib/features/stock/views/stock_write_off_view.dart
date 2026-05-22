// lib/features/stock/views/stock_write_off_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_write_off_provider.dart';
import '../providers/stock_write_off_state.dart';

class StockWriteOffView extends ConsumerStatefulWidget {
  const StockWriteOffView({super.key});

  @override
  ConsumerState<StockWriteOffView> createState() => _StockWriteOffViewState();
}

class _StockWriteOffViewState extends ConsumerState<StockWriteOffView> {
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonNoteController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isScanning = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _quantityController.dispose();
    _reasonNoteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(msg, style: GoogleFonts.poppins()),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text(msg, style: GoogleFonts.poppins()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _scanBin() async {
    if (_barcodeController.text.isEmpty) {
      _showError('Masukkan barcode bin terlebih dahulu');
      return;
    }

    setState(() => _isScanning = true);

    final notifier = ref.read(stockWriteOffStateProvider.notifier);
    final result = await notifier.scanBinByBarcode(_barcodeController.text);

    setState(() => _isScanning = false);

    if (result == null) {
      _showError('Barcode tidak ditemukan!');
      return;
    }

    _barcodeController.clear();
    _showSuccess('Bin ditemukan: ${result['full_location_name']}');
  }

  Future<void> _openBinPicker() async {
    final notifier = ref.read(stockWriteOffStateProvider.notifier);
    await notifier.openBinPicker(context);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockWriteOffStateProvider);
    final notifier = ref.read(stockWriteOffStateProvider.notifier);

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(state.errorMessage!);
        notifier.clearError();
      });
    }

    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccess(state.successMessage!);
        notifier.clearSuccess();
      });
    }

    final maxQuantity = state.selectedItem?.systemQuantity ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        title: Text(
          "Penghapusan Stok",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: 18,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF01579B)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pilih Bin
                    Text(
                      "Pilih Bin",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF01579B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Scan Barcode
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeController,
                            decoration: InputDecoration(
                              hintText: 'Scan Barcode Bin',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.25),
                              prefixIcon: const Icon(Icons.qr_code_scanner),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            onSubmitted: (_) => _scanBin(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isScanning ? null : _scanBin,
                          icon: _isScanning
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.search, size: 18),
                          label: const Text('Scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01579B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _openBinPicker,
                        icon: const Icon(Icons.list, size: 18),
                        label: const Text('Atau Pilih dari Daftar Bin'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF01579B)),
                      ),
                    ),

                    // Informasi Bin Terpilih
                    if (state.selectedBin != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade300, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.selectedBin!['full_location_name'] ?? state.selectedBin!['bin_code'] ?? 'Bin Terpilih',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 16),
                              onPressed: () {
                                notifier.clearSelectedBin();
                                _quantityController.clear();
                                _reasonNoteController.clear();
                                _notesController.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Daftar Stok di Bin
                    if (state.binItems.isNotEmpty && state.selectedBin != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Daftar Stok di Bin Ini",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF01579B)),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.binItems.length,
                        itemBuilder: (context, index) {
                          final item = state.binItems[index];
                          final isSelected = state.selectedItemIndex == index;
                          final isExpired = item.isExpired;
                          
                          return GestureDetector(
                            onTap: () => notifier.selectItem(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade50.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.blue.shade400 : (isExpired ? Colors.red.shade300 : Colors.transparent),
                                  width: isSelected ? 2 : (isExpired ? 1 : 0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio(
                                    value: index,
                                    groupValue: state.selectedItemIndex,
                                    onChanged: (_) => notifier.selectItem(index),
                                    activeColor: const Color(0xFF01579B),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.stockName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            _buildChip('Batch: ${item.batchNumber}', Colors.grey),
                                            _buildChip('Exp: ${_formatDate(item.expiryDate)}', isExpired ? Colors.red : Colors.grey),
                                            _buildChip('Stok: ${item.systemQuantity.toStringAsFixed(0)} ${item.unit}', Colors.blue),
                                          ],
                                        ),
                                        if (isExpired) _buildChip('KADALUARSA', Colors.red, isBold: true),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    // Form Write-Off
                    if (state.selectedItem != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade300, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Form Penghapusan Stok",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange.shade800),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(state.selectedItem!.stockName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Batch: ${state.selectedItem!.batchNumber} | Exp: ${_formatDate(state.selectedItem!.expiryDate)}', style: GoogleFonts.poppins(fontSize: 11)),
                                  Text('Stok Tersedia: ${state.selectedItem!.systemQuantity.toStringAsFixed(0)} ${state.selectedItem!.unit}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue.shade700)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Jumlah yang Dihapus *',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                suffixText: state.selectedItem!.unit,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: (value) => notifier.updateQuantity(double.tryParse(value) ?? 0),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: state.reason,
                              decoration: InputDecoration(
                                labelText: 'Alasan Penghapusan *',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'EXPIRED', child: Text('Kadaluarsa')),
                                DropdownMenuItem(value: 'DAMAGED', child: Text('Rusak')),
                                DropdownMenuItem(value: 'CONTAMINATED', child: Text('Terkontaminasi')),
                                DropdownMenuItem(value: 'RECALL', child: Text('Recall Produk')),
                              ],
                              onChanged: (value) => notifier.updateReason(value!),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _reasonNoteController,
                              maxLines: 2,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Catatan Alasan (opsional)',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: notifier.updateReasonNote,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 2,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Catatan Umum (opsional)',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onChanged: notifier.updateNotes,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit Button
                    if (state.selectedItem != null)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: state.isSaving ? null : () async {
                            final quantityText = _quantityController.text;
                            if (quantityText.isEmpty) {
                              _showError('Jumlah harus diisi');
                              return;
                            }
                            final quantity = double.tryParse(quantityText);
                            if (quantity == null || quantity <= 0) {
                              _showError('Jumlah harus lebih dari 0');
                              return;
                            }
                            if (state.selectedItem != null && quantity > state.selectedItem!.systemQuantity) {
                              _showError('Jumlah melebihi stok tersedia');
                              return;
                            }
                            await notifier.submitWriteOff();
                            if (state.isSaved) {
                              _quantityController.clear();
                              _reasonNoteController.clear();
                              _notesController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: state.isSaving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.delete_forever, color: Colors.white),
                          label: Text(
                            state.isSaving ? "Menyimpan..." : "Ajukan Penghapusan Stok",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    
                    if (state.selectedBin != null && state.binItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text('Tidak ada stok di bin ini', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withValues(alpha: 0.25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}