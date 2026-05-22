// lib/features/stock_opname/views/stock_bin_opname_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_opname_provider.dart';
import '../providers/stock_opname_state.dart';

class StockBinOpnameView extends ConsumerStatefulWidget {
  const StockBinOpnameView({super.key});

  @override
  ConsumerState<StockBinOpnameView> createState() => _StockBinOpnameViewState();
}

class _StockBinOpnameViewState extends ConsumerState<StockBinOpnameView> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _globalNotesController = TextEditingController();
  
  bool _isScanning = false;
  
  // Controllers for each item (dibuat dinamis saat load items)
  final Map<int, TextEditingController> _physicalStockControllers = {};
  final Map<int, TextEditingController> _itemNotesControllers = {};

  @override
  void dispose() {
    _barcodeController.dispose();
    _globalNotesController.dispose();
    for (var controller in _physicalStockControllers.values) {
      controller.dispose();
    }
    for (var controller in _itemNotesControllers.values) {
      controller.dispose();
    }
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

    final notifier = ref.read(stockOpnameStateProvider.notifier);
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
    final notifier = ref.read(stockOpnameStateProvider.notifier);
    await notifier.openBinPicker(context);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Initialize controllers ketika binItems berubah
  void _initializeControllers(List<BinOpnameItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (!_physicalStockControllers.containsKey(i)) {
        _physicalStockControllers[i] = TextEditingController(
          text: items[i].physicalQuantity.toStringAsFixed(0),
        );
      }
      if (!_itemNotesControllers.containsKey(i)) {
        _itemNotesControllers[i] = TextEditingController(
          text: items[i].note ?? '',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockOpnameStateProvider);
    final notifier = ref.read(stockOpnameStateProvider.notifier);

    // Handle error & success
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

    // Initialize controllers ketika ada binItems
    if (state.binItems.isNotEmpty) {
      _initializeControllers(state.binItems);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        centerTitle: true,
        title: Text(
          "Opname Per BIN",
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
                    // =====================================================
                    // STEP 1: Pilih BIN (Scan atau Pilih Manual)
                    // =====================================================
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _scanBin(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isScanning ? null : _scanBin,
                          icon: _isScanning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search, size: 18),
                          label: const Text('Scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01579B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
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
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF01579B),
                        ),
                      ),
                    ),

                    // =====================================================
                    // STEP 2: Informasi Bin Terpilih
                    // =====================================================
                    if (state.selectedBin != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.selectedBin!['full_location_name'] ??
                                        state.selectedBin!['bin_code'] ??
                                        'Bin Terpilih',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red, size: 16),
                                  onPressed: () {
                                    notifier.clearSelectedBin();
                                    _physicalStockControllers.clear();
                                    _itemNotesControllers.clear();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kode: ${state.selectedBin!['bin_code'] ?? '-'}',
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lokasi: ${state.selectedBin!['full_location_code'] ?? '-'}',
                              style: GoogleFonts.poppins(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // =====================================================
                    // STEP 3: DAFTAR STOK DI BIN (MULTIPLE ITEMS)
                    // =====================================================
                    if (state.binItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Daftar Stok di Bin Ini",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // List items
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.binItems.length,
                        itemBuilder: (context, index) {
                          final item = state.binItems[index];
                          final adjustment = item.physicalQuantity - item.systemQuantity;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: adjustment != 0 
                                    ? Colors.orange.shade300 
                                    : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header item
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: adjustment != 0 
                                            ? Colors.orange 
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.stockName,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 4,
                                            children: [
                                              _buildChip(
                                                'Batch: ${item.batchNumber}',
                                                Colors.grey,
                                              ),
                                              _buildChip(
                                                'Exp: ${_formatDate(item.expiryDate)}',
                                                item.expiryDate.isBefore(DateTime.now())
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              _buildChip(
                                                'Unit: ${item.unit}',
                                                Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Stok Sistem
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.computer, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Stok Sistem: ',
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      Text(
                                        '${item.systemQuantity.toStringAsFixed(0)} ${item.unit}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Input Stok Fisik
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _physicalStockControllers[index],
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(fontSize: 14),
                                        decoration: InputDecoration(
                                          labelText: 'Stok Fisik',
                                          labelStyle: GoogleFonts.poppins(fontSize: 12),
                                          suffixText: item.unit,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.5),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        ),
                                        onChanged: (value) {
                                          final doubleVal = double.tryParse(value) ?? 0;
                                          notifier.updateBinItemPhysical(index, doubleVal);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Adjustment
                                if (adjustment != 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: adjustment > 0
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          adjustment > 0
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          size: 16,
                                          color: adjustment > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Adjustment: ',
                                          style: GoogleFonts.poppins(fontSize: 12),
                                        ),
                                        Text(
                                          '${adjustment > 0 ? "+" : ""}${adjustment.toStringAsFixed(0)} ${item.unit}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: adjustment > 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: 8),
                                
                                // Catatan per item (opsional)
                                TextFormField(
                                  controller: _itemNotesControllers[index],
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Catatan untuk item ini (opsional)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.3),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    notifier.updateBinItemNote(index, value);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],

                    // =====================================================
                    // STEP 4: Catatan Umum & Submit
                    // =====================================================
                    if (state.binItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _globalNotesController,
                          maxLines: 2,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Catatan Umum Opname (opsional)',
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.2),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: state.isSaving
                              ? null
                              : () async {
                                  // Validasi semua input
                                  bool allValid = true;
                                  for (int i = 0; i < state.binItems.length; i++) {
                                    final item = state.binItems[i];
                                    if (item.physicalQuantity < 0) {
                                      _showError('Stok fisik untuk ${item.stockName} tidak valid');
                                      allValid = false;
                                      break;
                                    }
                                  }
                                  if (!allValid) return;
                                  
                                  // Update catatan umum (opsional)
                                  // Catatan umum bisa disimpan di session atau diabaikan
                                  
                                  await notifier.saveOpname();
                                  if (state.isSaved) {
                                    _physicalStockControllers.clear();
                                    _itemNotesControllers.clear();
                                    _globalNotesController.clear();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01579B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: state.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded,
                                  color: Colors.white),
                          label: Text(
                            state.isSaving 
                                ? "Menyimpan ${state.binItems.length} item..." 
                                : "Simpan Semua Opname (${state.binItems.length} item)",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    // Jika tidak ada item di bin
                    if (state.selectedBin != null && state.binItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada stok di bin ini',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}