// lib/features/stock_opname/providers/stock_opname_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_opname_service.dart';
import 'stock_opname_state.dart';
import '../models/stock_opname_input_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final stockOpnameServiceProvider = Provider<StockOpnameService>((ref) {
  return StockOpnameService();
});

final stockOpnameStateProvider =
    StateNotifierProvider<StockOpnameNotifier, StockOpnameState>((ref) {
  final service = ref.read(stockOpnameServiceProvider);
  final authService = getIt<AuthService>();
  return StockOpnameNotifier(service, authService);
});

class StockOpnameNotifier extends StateNotifier<StockOpnameState> {
  final StockOpnameService _service;
  final AuthService _authService;

  StockOpnameNotifier(this._service, this._authService)
      : super(StockOpnameState()) {
    _loadStocks();
    _loadBins();
  }

  // =====================================================
  // EXISTING: Opname Produk (kompatibilitas)
  // =====================================================
  
  Future<void> _loadStocks() async {
    try {
      final stocks = await _service.loadStocksForOpname();
      state = state.copyWith(stocks: stocks);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal load stock: $e');
    }
  }

  void selectStock(String stockId) {
    final stock = state.stocks.firstWhere((s) => s['id'] == stockId);
    state = state.copyWith(
      selectedStockId: stockId,
      selectedStock: stock,
      stockBefore: (stock['current_stock'] as num?)?.toDouble() ?? 0,
      physicalStock: (stock['current_stock'] as num?)?.toDouble() ?? 0,
      opnameMode: 'PRODUCT',
    );
  }

  void updatePhysicalStock(double value) {
    state = state.copyWith(physicalStock: value);
  }

  void updateOpnameNote(String value) {
    state = state.copyWith(opnameNote: value);
  }

  void clearSelectedStock() {
    state = state.copyWith(
      selectedStockId: null,
      selectedStock: null,
      stockBefore: 0,
      physicalStock: 0,
      opnameNote: '',
    );
  }

  // =====================================================
  // BARU: Opname per BIN (UTAMA)
  // =====================================================
  
  Future<void> _loadBins() async {
    try {
      final bins = await _service.loadBinsForOpname();
      state = state.copyWith(bins: bins);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal load bins: $e');
    }
  }

  Future<void> loadBinItems(String binId) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.loadBinItems(binId);
      state = state.copyWith(
        isLoading: false,
        binItems: items,
        selectedBinId: binId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load item di bin: $e',
      );
    }
  }

  Future<Map<String, dynamic>?> scanBinByBarcode(String barcode) async {
    try {
      final result = await _service.getBinByBarcode(barcode);
      if (result != null) {
        final binId = result['bin_id'].toString();
        await loadBinItems(binId);
        state = state.copyWith(selectedBin: result);
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal scan barcode: $e');
      return null;
    }
  }

  Future<void> openBinPicker(BuildContext context) async {
    if (state.bins.isEmpty) {
      state = state.copyWith(errorMessage: 'Tidak ada bin yang tersedia');
      return;
    }
    
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bin'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: state.bins.length,
            itemBuilder: (context, index) {
              final bin = state.bins[index];
              final location = bin['full_location_name']?.toString() ?? 
                              bin['bin_code']?.toString() ?? 
                              'Bin ${index + 1}';
              return ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(
                  location,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                subtitle: Text('Kode: ${bin['bin_code'] ?? '-'}'),
                onTap: () => Navigator.pop(context, bin),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
    
    if (selected != null) {
      final binId = selected['bin_id'].toString();
      await loadBinItems(binId);
      state = state.copyWith(selectedBin: selected);
    }
  }

  void updateBinItemPhysical(int index, double value) {
    final newItems = List<BinOpnameItem>.from(state.binItems);
    newItems[index].physicalQuantity = value;
    state = state.copyWith(binItems: newItems);
  }

  void updateBinItemNote(int index, String value) {
    final newItems = List<BinOpnameItem>.from(state.binItems);
    newItems[index].note = value;
    state = state.copyWith(binItems: newItems);
  }

  void updateBinOpnameNote(String value) {
    state = state.copyWith(binOpnameNote: value);
  }

  void clearSelectedBin() {
    state = state.copyWith(
      selectedBin: null,
      selectedBinId: null,
      binItems: [],
      binOpnameNote: '',
    );
  }

  // =====================================================
  // SAVE OPNAME
  // =====================================================

  Future<bool> saveOpname() async {
    if (state.opnameMode == 'BIN') {
      return _saveBinOpname();
    } else {
      return _saveProductOpname();
    }
  }

  Future<bool> _saveProductOpname() async {
    if (!state.isValidProductOpname) {
      state = state.copyWith(errorMessage: 'Pilih stock terlebih dahulu');
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired, silakan login ulang');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final input = StockOpnameInputModel(
        stockId: state.selectedStockId!,
        stockBefore: state.stockBefore,
        physicalStock: state.physicalStock,
        opnameNote: state.opnameNote.isEmpty ? null : state.opnameNote,
        opnameBy: userId,
      );

      await _service.saveOpname(input: input);

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage: 'Stock opname berhasil disimpan',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan opname: $e',
      );
      return false;
    }
  }

  Future<bool> _saveBinOpname() async {
    if (state.binItems.isEmpty) {
      state = state.copyWith(errorMessage: 'Tidak ada item di bin yang dipilih');
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired, silakan login ulang');
      return false;
    }

    // Validasi semua item sudah diisi
    for (int i = 0; i < state.binItems.length; i++) {
      final item = state.binItems[i];
      if (item.physicalQuantity < 0) {
        state = state.copyWith(
          errorMessage: 'Stok fisik untuk ${item.stockName} tidak valid',
        );
        return false;
      }
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      // Simpan setiap item sebagai 1 row opname
      for (final item in state.binItems) {
        final input = StockOpnameInputModel(
          stockId: item.stockId,
          stockInBinsId: item.stockInBinsId,
          binId: state.selectedBinId,
          batchNumber: item.batchNumber,
          expiryDate: item.expiryDate,
          systemQuantity: item.systemQuantity,
          physicalStock: item.physicalQuantity,
          stockBefore: item.systemQuantity,
          itemNote: item.note,
          opnameBy: userId,
        );
        await _service.saveBinOpname(input: input);
      }

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage: 'Opname bin berhasil disimpan (${state.binItems.length} item)',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan opname: $e',
      );
      return false;
    }
  }

  // =====================================================
  // UMUM
  // =====================================================

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetToForm() {
    state = StockOpnameState(opnameMode: 'BIN');
    _loadBins();
  }
}