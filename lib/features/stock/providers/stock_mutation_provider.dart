// lib/features/stock/providers/stock_mutation_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_mutation_service.dart';
import 'stock_mutation_state.dart';
import '../models/stock_mutation_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final stockMutationServiceProvider = Provider<StockMutationService>((ref) {
  return StockMutationService();
});

final stockMutationStateProvider =
    StateNotifierProvider<StockMutationNotifier, StockMutationState>((ref) {
  final service = ref.read(stockMutationServiceProvider);
  final authService = getIt<AuthService>();
  return StockMutationNotifier(service, authService);
});

final allEmployeesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(stockMutationServiceProvider);
  return await service.getAllEmployees();
});

class StockMutationNotifier extends StateNotifier<StockMutationState> {
  final StockMutationService _service;
  final AuthService _authService;

  StockMutationNotifier(this._service, this._authService)
      : super(StockMutationState()) {
    _loadBins();
  }

  void _log(String msg) {
    print('🔴 [MUTATION_NOTIFIER] $msg');
  }

  Future<void> _loadBins() async {
    try {
      final bins = await _service.loadBins();
      state = state.copyWith(bins: bins, binsTujuan: bins);
      _log('Loaded ${bins.length} bins');
    } catch (e) {
      _log('Error loading bins: $e');
    }
  }

  Future<void> loadBinAsalItems(String binId) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _service.loadBinItems(binId);
      state = state.copyWith(
        isLoading: false,
        binAsalItems: items,
        selectedBinAsalId: binId,
        selectedItem: null,
        selectedItemIndex: null,
        quantity: 0,
      );
      _log('Loaded ${items.length} items from bin asal');
    } catch (e) {
      _log('Error loading bin items: $e');
      state = state.copyWith(isLoading: false, errorMessage: 'Gagal load item: $e');
    }
  }

  Future<Map<String, dynamic>?> scanBinAsal(String barcode) async {
    try {
      final result = await _service.getBinByBarcode(barcode);
      if (result != null) {
        await loadBinAsalItems(result['bin_id'].toString());
        state = state.copyWith(selectedBinAsal: result);
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal scan bin: $e');
      return null;
    }
  }

  Future<void> selectBinAsalManual(Map<String, dynamic> bin) async {
    await loadBinAsalItems(bin['bin_id'].toString());
    state = state.copyWith(selectedBinAsal: bin);
  }

  Future<Map<String, dynamic>?> scanBinTujuan(String barcode) async {
    try {
      final result = await _service.getBinByBarcode(barcode);
      if (result != null) {
        state = state.copyWith(selectedBinTujuan: result, selectedBinTujuanId: result['bin_id'].toString());
      }
      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal scan bin tujuan: $e');
      return null;
    }
  }

  void selectBinTujuanManual(Map<String, dynamic> bin) {
    state = state.copyWith(selectedBinTujuan: bin, selectedBinTujuanId: bin['bin_id'].toString());
  }

  void selectItem(int index) {
    final item = state.binAsalItems[index];
    state = state.copyWith(
      selectedItem: item,
      selectedItemIndex: index,
      quantity: 0,
    );
    _log('Selected item: ${item.stockName}');
  }

  void updateQuantity(double value) {
    state = state.copyWith(quantity: value);
  }

  void updateReceivedBy(String userId, String userName) {
    state = state.copyWith(receivedBy: userId, receivedByName: userName);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void clearSelectedBinAsal() {
    state = state.copyWith(
      selectedBinAsal: null,
      selectedBinAsalId: null,
      binAsalItems: [],
      selectedItem: null,
      selectedItemIndex: null,
      quantity: 0,
    );
  }

  void clearSelectedBinTujuan() {
    state = state.copyWith(selectedBinTujuan: null, selectedBinTujuanId: null);
  }

  Future<bool> submitMutation() async {
    _log('submitMutation START');
    
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Lengkapi semua field');
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired');
      return false;
    }

    state = state.copyWith(isSaving: true);

    try {
      final mutationNumber = await _service.generateMutationNumber();
      
      final mutation = StockMutationModel(
        mutationNumber: mutationNumber,
        stockInBinsId: state.selectedItem!.stockInBinsId,
        binIdAsal: state.selectedBinAsalId!,
        binIdTujuan: state.selectedBinTujuanId!,
        stockId: state.selectedItem!.stockId,
        batchNumber: state.selectedItem!.batchNumber,
        expiryDate: state.selectedItem!.expiryDate,
        quantity: state.quantity,
        unit: state.selectedItem!.unit,
        movedBy: userId,
        receivedBy: state.receivedBy,
        notes: state.notes.isEmpty ? null : state.notes,
      );

      await _service.createMutation(mutation);
      
      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage: 'Mutasi stok berhasil',
      );
      _log('Submit SUCCESS');
      return true;
    } catch (e) {
      _log('Submit ERROR: $e');
      state = state.copyWith(isSaving: false, errorMessage: 'Gagal mutasi: $e');
      return false;
    }
  }

  void resetForm() {
    state = StockMutationState();
    _loadBins();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}