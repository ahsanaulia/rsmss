// lib/features/stock/views/stock_mutation_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_mutation_provider.dart';

class StockMutationView extends ConsumerStatefulWidget {
  const StockMutationView({super.key});

  @override
  ConsumerState<StockMutationView> createState() => _StockMutationViewState();
}

class _StockMutationViewState extends ConsumerState<StockMutationView> {
  final _barcodeControllerAsal = TextEditingController();
  final _barcodeControllerTujuan = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isScanningAsal = false;
  bool _isScanningTujuan = false;

  @override
  void dispose() {
    _barcodeControllerAsal.dispose();
    _barcodeControllerTujuan.dispose();
    _quantityController.dispose();
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

  Future<void> _scanBinAsal() async {
    if (_barcodeControllerAsal.text.isEmpty) {
      _showError('Masukkan barcode bin asal terlebih dahulu');
      return;
    }

    setState(() => _isScanningAsal = true);

    final notifier = ref.read(stockMutationStateProvider.notifier);
    final result = await notifier.scanBinAsal(_barcodeControllerAsal.text);

    setState(() => _isScanningAsal = false);

    if (result == null) {
      _showError('Barcode bin asal tidak ditemukan!');
      return;
    }

    _barcodeControllerAsal.clear();
    _showSuccess('Bin asal: ${result['full_location_name']}');
  }

  Future<void> _scanBinTujuan() async {
    if (_barcodeControllerTujuan.text.isEmpty) {
      _showError('Masukkan barcode bin tujuan terlebih dahulu');
      return;
    }

    setState(() => _isScanningTujuan = true);

    final notifier = ref.read(stockMutationStateProvider.notifier);
    final result = await notifier.scanBinTujuan(_barcodeControllerTujuan.text);

    setState(() => _isScanningTujuan = false);

    if (result == null) {
      _showError('Barcode bin tujuan tidak ditemukan!');
      return;
    }

    _barcodeControllerTujuan.clear();
    _showSuccess('Bin tujuan: ${result['full_location_name']}');
  }

  Future<void> _openBinPickerAsal() async {
    final state = ref.read(stockMutationStateProvider);
    final notifier = ref.read(stockMutationStateProvider.notifier);
    
    if (state.bins.isEmpty) {
      _showError('Tidak ada bin yang tersedia');
      return;
    }
    
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bin Asal'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: state.bins.length,
            itemBuilder: (context, index) {
              final bin = state.bins[index];
              final location = bin['full_location_name']?.toString() ?? bin['bin_code']?.toString() ?? 'Bin ${index + 1}';
              return ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(location, overflow: TextOverflow.ellipsis, maxLines: 2),
                subtitle: Text('Kode: ${bin['bin_code'] ?? '-'}'),
                onTap: () => Navigator.pop(context, bin),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
    
    if (selected != null) {
      await notifier.selectBinAsalManual(selected);
    }
  }

  Future<void> _openBinPickerTujuan() async {
    final state = ref.read(stockMutationStateProvider);
    final notifier = ref.read(stockMutationStateProvider.notifier);
    
    if (state.binsTujuan.isEmpty) {
      _showError('Tidak ada bin yang tersedia');
      return;
    }
    
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bin Tujuan'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: state.binsTujuan.length,
            itemBuilder: (context, index) {
              final bin = state.binsTujuan[index];
              final location = bin['full_location_name']?.toString() ?? bin['bin_code']?.toString() ?? 'Bin ${index + 1}';
              return ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(location, overflow: TextOverflow.ellipsis, maxLines: 2),
                subtitle: Text('Kode: ${bin['bin_code'] ?? '-'}'),
                onTap: () => Navigator.pop(context, bin),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
    
    if (selected != null) {
      notifier.selectBinTujuanManual(selected);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockMutationStateProvider);
    final notifier = ref.read(stockMutationStateProvider.notifier);
    final employeesAsync = ref.watch(allEmployeesProvider);

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
        notifier.resetForm();
        _quantityController.clear();
        _notesController.clear();
        _barcodeControllerAsal.clear();
        _barcodeControllerTujuan.clear();
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
          "Mutasi Stok",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
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
                    // =====================================================
                    // BIN ASAL
                    // =====================================================
                    Text(
                      "Bin Asal (Sumber)",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF01579B)),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeControllerAsal,
                            decoration: InputDecoration(
                              hintText: 'Scan Barcode Bin Asal',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.25),
                              prefixIcon: const Icon(Icons.qr_code_scanner),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            onSubmitted: (_) => _scanBinAsal(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isScanningAsal ? null : _scanBinAsal,
                          icon: _isScanningAsal
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.search, size: 18),
                          label: const Text('Scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01579B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _openBinPickerAsal,
                        icon: const Icon(Icons.list, size: 18),
                        label: const Text('Atau Pilih dari Daftar Bin'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF01579B)),
                      ),
                    ),

                    if (state.selectedBinAsal != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.selectedBinAsal!['full_location_name'] ?? state.selectedBinAsal!['bin_code'] ?? 'Bin Asal',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 16),
                              onPressed: () => notifier.clearSelectedBinAsal(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // =====================================================
                    // DAFTAR STOK DI BIN ASAL
                    // =====================================================
                    if (state.binAsalItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Daftar Stok di Bin Asal",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF01579B)),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.binAsalItems.length,
                        itemBuilder: (context, index) {
                          final item = state.binAsalItems[index];
                          final isSelected = state.selectedItemIndex == index;
                          return GestureDetector(
                            onTap: () => notifier.selectItem(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade50.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? Colors.blue.shade400 : Colors.transparent, width: isSelected ? 2 : 0),
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
                                            _buildChip('Exp: ${_formatDate(item.expiryDate)}', Colors.grey),
                                            _buildChip('Stok: ${item.systemQuantity.toStringAsFixed(0)} ${item.unit}', Colors.blue),
                                          ],
                                        ),
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

                    // =====================================================
                    // BIN TUJUAN
                    // =====================================================
                    if (state.selectedItem != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Bin Tujuan (Target)",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF01579B)),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _barcodeControllerTujuan,
                              decoration: InputDecoration(
                                hintText: 'Scan Barcode Bin Tujuan',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.25),
                                prefixIcon: const Icon(Icons.qr_code_scanner),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                              onSubmitted: (_) => _scanBinTujuan(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isScanningTujuan ? null : _scanBinTujuan,
                            icon: _isScanningTujuan
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.search, size: 18),
                            label: const Text('Scan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF01579B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _openBinPickerTujuan,
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text('Atau Pilih dari Daftar Bin'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF01579B)),
                        ),
                      ),

                      if (state.selectedBinTujuan != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.selectedBinTujuan!['full_location_name'] ?? state.selectedBinTujuan!['bin_code'] ?? 'Bin Tujuan',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 16),
                                onPressed: () => notifier.clearSelectedBinTujuan(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // =====================================================
                    // JUMLAH
                    // =====================================================
                    if (state.selectedItem != null && state.selectedBinTujuan != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Jumlah yang Dipindahkan",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF01579B)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Jumlah *',
                          suffixText: state.selectedItem!.unit,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        onChanged: (value) => notifier.updateQuantity(double.tryParse(value) ?? 0),
                      ),
                      if (maxQuantity > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 12),
                          child: Text(
                            'Maksimal: ${maxQuantity.toStringAsFixed(0)} ${state.selectedItem!.unit}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                    ],

                    // =====================================================
                    // PENERIMA
                    // =====================================================
                    if (state.selectedItem != null && state.selectedBinTujuan != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Penerima di Bin Tujuan",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF01579B)),
                      ),
                      const SizedBox(height: 8),
                      employeesAsync.when(
                        data: (employees) => DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Pilih Penerima *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          value: state.receivedBy,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Pilih Penerima')),
                            ...employees.map((emp) => DropdownMenuItem(
                              value: emp['id'],
                              child: Text(emp['full_name']),
                            )),
                          ],
                          onChanged: (value) {
                            final selected = employees.firstWhere((e) => e['id'] == value, orElse: () => {});
                            notifier.updateReceivedBy(value ?? '', selected['full_name'] ?? '');
                          },
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ],

                    // =====================================================
                    // CATATAN
                    // =====================================================
                    if (state.selectedItem != null && state.selectedBinTujuan != null) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Catatan (opsional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        onChanged: notifier.updateNotes,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // =====================================================
                    // SUBMIT BUTTON
                    // =====================================================
                    if (state.selectedItem != null && state.selectedBinTujuan != null)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: state.isSaving ? null : () async {
                            final quantity = double.tryParse(_quantityController.text);
                            if (quantity == null || quantity <= 0) {
                              _showError('Jumlah harus diisi dan lebih dari 0');
                              return;
                            }
                            if (quantity > maxQuantity) {
                              _showError('Jumlah melebihi stok tersedia');
                              return;
                            }
                            if (state.receivedBy == null) {
                              _showError('Pilih penerima terlebih dahulu');
                              return;
                            }
                            await notifier.submitMutation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: state.isSaving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.swap_horiz, color: Colors.white),
                          label: Text(
                            state.isSaving ? "Memproses..." : "MUTASI STOK",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
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