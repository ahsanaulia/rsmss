// lib/features/stock/providers/stock_write_off_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_write_off_service.dart';
import 'stock_write_off_state.dart';
import '../models/stock_write_off_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final stockWriteOffServiceProvider = Provider<StockWriteOffService>((ref) {
  print('🔴 [PROVIDER] stockWriteOffServiceProvider initialized');
  return StockWriteOffService();
});

final stockWriteOffStateProvider =
    StateNotifierProvider<StockWriteOffNotifier, StockWriteOffState>((ref) {
  print('🔴 [PROVIDER] stockWriteOffStateProvider initialized');
  final service = ref.read(stockWriteOffServiceProvider);
  final authService = getIt<AuthService>();
  return StockWriteOffNotifier(service, authService);
});

final stockWriteOffHistoryProvider = FutureProvider<List<StockWriteOffModel>>((ref) async {
  print('🔴 [PROVIDER] stockWriteOffHistoryProvider dipanggil');
  final service = ref.read(stockWriteOffServiceProvider);
  final authService = getIt<AuthService>();
  final userId = authService.currentUserId;
  if (userId == null) {
    print('🔴 [PROVIDER] userId null, return []');
    return [];
  }
  return await service.getMyWriteOffs(userId);
});

final allWriteOffsProvider = FutureProvider<List<StockWriteOffModel>>((ref) async {
  print('🔴 [PROVIDER] allWriteOffsProvider dipanggil');
  final service = ref.read(stockWriteOffServiceProvider);
  return await service.getAllWriteOffs();
});

class StockWriteOffNotifier extends StateNotifier<StockWriteOffState> {
  final StockWriteOffService _service;
  final AuthService _authService;

  StockWriteOffNotifier(this._service, this._authService)
      : super(StockWriteOffState()) {
    print('🔴 [NOTIFIER] StockWriteOffNotifier initialized');
    _loadBins();
  }

  void _log(String msg) {
    print('🔴 [NOTIFIER] $msg');
  }

  Future<void> _loadBins() async {
    _log('_loadBins dipanggil');
    try {
      final bins = await _service.loadBinsForWriteOff();
      state = state.copyWith(bins: bins);
      _log('_loadBins success, ${bins.length} bins');
    } catch (e) {
      _log('_loadBins error: $e');
      state = state.copyWith(errorMessage: 'Gagal load bins: $e');
    }
  }

  Future<void> loadBinItems(String binId) async {
    _log('loadBinItems dipanggil untuk binId: $binId');
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.loadBinItems(binId);
      state = state.copyWith(
        isLoading: false,
        binItems: items,
        selectedBinId: binId,
        selectedItem: null,
        selectedItemIndex: null,
        quantity: 0,
      );
      _log('loadBinItems success, ${items.length} items');
    } catch (e) {
      _log('loadBinItems error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load item di bin: $e',
      );
    }
  }

  Future<Map<String, dynamic>?> scanBinByBarcode(String barcode) async {
    _log('scanBinByBarcode dipanggil: $barcode');
    try {
      final result = await _service.getBinByBarcode(barcode);
      if (result != null) {
        final binId = result['bin_id'].toString();
        await loadBinItems(binId);
        state = state.copyWith(selectedBin: result);
        _log('scanBinByBarcode success, binId: $binId');
      } else {
        _log('scanBinByBarcode result null');
      }
      return result;
    } catch (e) {
      _log('scanBinByBarcode error: $e');
      state = state.copyWith(errorMessage: 'Gagal scan barcode: $e');
      return null;
    }
  }

  Future<void> openBinPicker(BuildContext context) async {
    _log('openBinPicker dipanggil');
    if (state.bins.isEmpty) {
      _log('openBinPicker bins kosong');
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
      final binId = selected['bin_id'].toString();
      await loadBinItems(binId);
      state = state.copyWith(selectedBin: selected);
      _log('openBinPicker success, binId: $binId');
    }
  }

  void clearSelectedBin() {
    _log('clearSelectedBin dipanggil');
    state = state.copyWith(
      selectedBin: null,
      selectedBinId: null,
      binItems: [],
      selectedItem: null,
      selectedItemIndex: null,
      quantity: 0,
    );
  }

  void selectItem(int index) {
    _log('selectItem dipanggil index: $index');
    final item = state.binItems[index];
    state = state.copyWith(
      selectedItem: item,
      selectedItemIndex: index,
      quantity: 0,
      reason: item.isExpired ? 'EXPIRED' : 'DAMAGED',
    );
    _log('selectItem: ${item.stockName}');
  }

  void updateQuantity(double value) {
    state = state.copyWith(quantity: value);
  }

  void updateReason(String value) {
    state = state.copyWith(reason: value);
  }

  void updateReasonNote(String value) {
    state = state.copyWith(reasonNote: value);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  Future<bool> submitWriteOff() async {
    _log('🔴🔴🔴 submitWriteOff START 🔴🔴🔴');
    _log('isValid: ${state.isValid}');
    _log('selectedBinId: ${state.selectedBinId}');
    _log('selectedItem: ${state.selectedItem?.stockName}');
    _log('quantity: ${state.quantity}');
    
    if (!state.isValid) {
      _log('submitWriteOff NOT VALID');
      state = state.copyWith(errorMessage: 'Lengkapi semua field terlebih dahulu');
      return false;
    }

    final userId = _authService.currentUserId;
    _log('userId: $userId');
    
    if (userId == null) {
      _log('submitWriteOff userId NULL');
      state = state.copyWith(errorMessage: 'Session expired, silakan login ulang');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final writeOffNumber = await _service.generateWriteOffNumber();
      _log('writeOffNumber: $writeOffNumber');
      
      final writeOff = StockWriteOffModel(
        writeOffNumber: writeOffNumber,
        stockInBinsId: state.selectedItem!.stockInBinsId,
        binId: state.selectedBinId!,
        stockId: state.selectedItem!.stockId,
        batchNumber: state.selectedItem!.batchNumber,
        expiryDate: state.selectedItem!.expiryDate,
        quantity: state.quantity,
        unit: state.selectedItem!.unit,
        reason: state.reason,
        reasonNote: state.reasonNote.isEmpty ? null : state.reasonNote,
        requestedBy: userId,
        notes: state.notes.isEmpty ? null : state.notes,
        status: 'DRAFT',
      );

      await _service.createWriteOff(writeOff);
      _log('submitWriteOff ✅ SUCCESS');

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage: 'Write-off berhasil diajukan',
      );

      return true;
    } catch (e) {
      _log('submitWriteOff ❌ ERROR: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal mengajukan write-off: $e',
      );
      return false;
    }
  }

  Future<bool> approveWriteOff(String writeOffId) async {
    _log('🔴🔴🔴 approveWriteOff START 🔴🔴🔴');
    _log('writeOffId: $writeOffId');
    
    final userId = _authService.currentUserId;
    _log('userId: $userId');
    
    if (userId == null) {
      _log('approveWriteOff userId NULL');
      state = state.copyWith(errorMessage: 'Session expired');
      return false;
    }

    state = state.copyWith(isSaving: true);

    try {
      await _service.approveWriteOff(writeOffId, userId);
      _log('approveWriteOff ✅ SUCCESS');
      
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Write-off approved, stok berkurang',
      );
      return true;
    } catch (e) {
      _log('approveWriteOff ❌ ERROR: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal approve write-off: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetForm() {
    _log('resetForm dipanggil');
    state = StockWriteOffState();
    _loadBins();
  }
}