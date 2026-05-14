import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/stock_service.dart';
import 'stock_state.dart';
import '../models/stock_input_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final stockServiceProvider = Provider<StockService>((ref) {
  return StockService();
});

final stockInitialStateProvider =
    StateNotifierProvider<StockInitialNotifier, StockInitialState>((ref) {
  final service = ref.read(stockServiceProvider);
  final authService = getIt<AuthService>();
  return StockInitialNotifier(service, authService);
});

class StockInitialNotifier extends StateNotifier<StockInitialState> {
  final StockService _service;
  final AuthService _authService;

  StockInitialNotifier(this._service, this._authService)
      : super(StockInitialState()) {
    _loadInitialData();
    _generateStockCode();
  }

  void _generateStockCode() {
    final newCode = _service.generateStockCode();
    state = state.copyWith(stockCode: newCode);
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      final types = await _service.loadStockTypes();
      final locations = await _service.loadStorageLocations();

      state = state.copyWith(
        isLoading: false,
        stockTypes: types,
        storageLocations: locations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load data: $e',
      );
    }
  }

  void updateStockCode(String value) {
    state = state.copyWith(stockCode: value.toUpperCase());
  }

  void updateStockName(String value) {
    state = state.copyWith(stockName: value);
  }

  void updateUnit(String value) {
    state = state.copyWith(unit: value);
  }

  void updateMinimumStock(String value) {
    state = state.copyWith(minimumStock: value);
  }

  void updateCurrentStock(String value) {
    state = state.copyWith(currentStock: value);
  }

  void updateStockCondition(String value) {
    state = state.copyWith(stockCondition: value);
  }

  void updateBatchNumber(String value) {
    state = state.copyWith(batchNumber: value);
  }

  void updateExpiryDate(DateTime? date) {
    state = state.copyWith(expiryDate: date);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updatePhoto(File? photo) {
    state = state.copyWith(photo: photo);
  }

  void selectStockType(String id, String name) {
    state = state.copyWith(
      selectedTypeId: id,
      selectedTypeName: name,
    );
  }

  void selectStorageLocation(String id, String name) {
    state = state.copyWith(
      selectedLocationId: id,
      selectedLocationName: name,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetToForm() {
    state = StockInitialState();
    _loadInitialData();
    _generateStockCode();
  }

  Future<bool> saveStock() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Lengkapi semua data wajib');
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired, silakan login ulang');
      return false;
    }

    // Cek apakah stock code sudah ada
    final exists = await _service.isStockCodeExists(state.stockCode);
    if (exists) {
      state = state.copyWith(errorMessage: 'Kode stock sudah ada, gunakan kode lain');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final input = StockInputModel(
        stockCode: state.stockCode,
        stockName: state.stockName,
        stockTypeId: state.selectedTypeId,
        unit: state.unit,
        minimumStock: double.tryParse(state.minimumStock) ?? 0,
        currentStock: double.tryParse(state.currentStock) ?? 0,
        storageLocationId: state.selectedLocationId,
        stockCondition: state.stockCondition,
        batchNumber: state.batchNumber.isEmpty ? null : state.batchNumber,
        expiryDate: state.expiryDate,
        photo: state.photo,
        description: state.description.isEmpty ? null : state.description,
      );

      await _service.saveStock(input: input, createdBy: userId);

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage: 'Stock berhasil disimpan',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan stock: $e',
      );
      return false;
    }
  }
}