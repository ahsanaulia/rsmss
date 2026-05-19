// ============================================================
// PROVIDERS: Stock Providers (Riverpod)
// ============================================================
// TANGGUNG JAWAB:
// 1. State management untuk list stok
// 2. State management untuk detail stok
// 3. State management untuk form (loading, error, submit)
// 4. Mengintegrasikan StockService dengan AuthService
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';
import 'stock_state.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';

// ============================================================
// SECTION 1: SERVICE PROVIDERS
// ============================================================

/// Provider untuk StockService (singleton)
final stockServiceProvider = Provider<StockService>((ref) {
  return StockService();
});

/// Provider untuk AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return getIt<AuthService>();
});

// ============================================================
// SECTION 2: LIST STOK PROVIDER
// ============================================================

/// Notifier untuk mengelola list stok
class StockListNotifier extends StateNotifier<StockListState> {
  final Ref _ref;
  final StockService _stockService;

  StockListNotifier(this._ref, this._stockService) : super(const StockListState());

  /// Load semua stok
  Future<void> loadStocks() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stocks = await _stockService.fetchAllStocks();
      state = state.copyWith(
        stocks: stocks,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search stok berdasarkan keyword
  Future<void> searchStocks(String keyword) async {
    state = state.copyWith(isLoading: true, error: null, searchKeyword: keyword);
    
    try {
      final stocks = await _stockService.searchStocks(keyword);
      state = state.copyWith(
        stocks: stocks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filter stok berdasarkan kondisi (GOOD/LOW)
  Future<void> filterByCondition(String? condition) async {
    state = state.copyWith(isLoading: true, error: null, filterCondition: condition);
    
    try {
      List<Stock> stocks;
      if (condition == null || condition.isEmpty) {
        stocks = await _stockService.fetchAllStocks();
      } else if (condition == 'empty') {
        stocks = await _stockService.filterEmptyStocks();
      } else if (condition == 'low_stock') {
        stocks = await _stockService.filterLowStocks();
      } else {
        stocks = await _stockService.filterStocksByCondition(condition);
      }
      state = state.copyWith(
        stocks: stocks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset filter dan search
  Future<void> resetFilter() async {
    state = state.copyWith(searchKeyword: null, filterCondition: null);
    await loadStocks();
  }

  /// Hapus stok (soft delete)
  Future<bool> deleteStock(String stockId) async {
    try {
      final userId = _ref.read(authServiceProvider).currentUserId;
      if (userId == null) {
        state = state.copyWith(error: 'User tidak ditemukan');
        return false;
      }
      
      final success = await _stockService.deleteStock(stockId, userId);
      if (success) {
        await loadStocks();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider untuk list stok
final stockListProvider = StateNotifierProvider<StockListNotifier, StockListState>((ref) {
  final stockService = ref.read(stockServiceProvider);
  return StockListNotifier(ref, stockService);
});

// ============================================================
// SECTION 3: DETAIL STOK PROVIDER
// ============================================================

/// Notifier untuk mengelola detail stok
class StockDetailNotifier extends StateNotifier<StockDetailState> {
  final StockService _stockService;

  StockDetailNotifier(this._stockService) : super(const StockDetailState());

  /// Load detail stok berdasarkan ID
  Future<void> loadStock(String stockId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stock = await _stockService.fetchStockById(stockId);
      state = state.copyWith(
        stock: stock,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear state (untuk navigasi keluar)
  void clear() {
    state = const StockDetailState();
  }
}

/// Provider untuk detail stok (menerima parameter stockId)
final stockDetailProvider = StateNotifierProviderFamily<StockDetailNotifier, StockDetailState, String>((ref, stockId) {
  final stockService = ref.read(stockServiceProvider);
  final notifier = StockDetailNotifier(stockService);
  notifier.loadStock(stockId);
  return notifier;
});

// ============================================================
// SECTION 4: FORM STOK PROVIDER
// ============================================================

/// Notifier untuk mengelola form stok
class StockFormNotifier extends StateNotifier<StockFormState> {
  final Ref _ref;
  final StockService _stockService;

  StockFormNotifier(this._ref, this._stockService)
      : super(StockFormState(stock: Stock.empty())) {
    loadDropdownData();
  }

  /// Load data untuk dropdown (stock types, storage locations)
  Future<void> loadDropdownData() async {
    // Load stock types
    state = state.copyWith(isLoadingTypes: true);
    try {
      final types = await _stockService.fetchAllStockTypes();
      final stockTypes = types.map((t) => StockTypeDropdownData.fromJson(t)).toList();
      state = state.copyWith(stockTypes: stockTypes, isLoadingTypes: false);
    } catch (e) {
      state = state.copyWith(isLoadingTypes: false);
    }

    // Load storage locations
    state = state.copyWith(isLoadingLocations: true);
    try {
      final locations = await _stockService.fetchAllStorageLocations();
      final storageLocations = locations.map((l) => StorageLocationDropdownData.fromJson(l)).toList();
      state = state.copyWith(storageLocations: storageLocations, isLoadingLocations: false);
    } catch (e) {
      state = state.copyWith(isLoadingLocations: false);
    }
  }

  /// Set data untuk edit mode
  void setEditingStock(Stock stock) {
    state = state.copyWith(
      stock: stock,
      isEditing: true,
    );
  }

  /// Update field form
  void updateField({
    String? stockCode,
    String? stockName,
    String? stockTypeId,
    String? unit,
    String? description,
    String? storageLocationId,
    num? minimumStock,
    num? currentStock,
    String? batchNumber,
    DateTime? expiryDate,
    String? stockCondition,
    bool? isActive,
    String? photoUrl,
  }) {
    final updatedStock = state.stock.copyWith(
      stockCode: stockCode ?? state.stock.stockCode,
      stockName: stockName ?? state.stock.stockName,
      stockTypeId: stockTypeId ?? state.stock.stockTypeId,
      unit: unit ?? state.stock.unit,
      description: description ?? state.stock.description,
      storageLocationId: storageLocationId ?? state.stock.storageLocationId,
      minimumStock: minimumStock ?? state.stock.minimumStock,
      currentStock: currentStock ?? state.stock.currentStock,
      batchNumber: batchNumber ?? state.stock.batchNumber,
      expiryDate: expiryDate ?? state.stock.expiryDate,
      stockCondition: stockCondition ?? state.stock.stockCondition,
      isActive: isActive ?? state.stock.isActive,
      photoUrl: photoUrl ?? state.stock.photoUrl,
    );
    
    state = state.copyWith(stock: updatedStock, error: null);
  }

  /// Update foto URL setelah upload
  void updatePhotoUrl(String photoUrl) {
    final updatedStock = state.stock.copyWith(photoUrl: photoUrl);
    state = state.copyWith(stock: updatedStock);
  }

  /// Submit form (create atau update)
  Future<bool> submit() async {
    // Validasi
    if (state.stock.stockName.isEmpty) {
      state = state.copyWith(error: 'Nama stok wajib diisi');
      return false;
    }
    if (state.stock.unit.isEmpty) {
      state = state.copyWith(error: 'Satuan wajib diisi');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userId = _ref.read(authServiceProvider).currentUserId;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'User tidak ditemukan');
        return false;
      }

      if (state.isEditing) {
        await _stockService.updateStock(state.stock, userId);
      } else {
        await _stockService.createStock(state.stock, userId);
      }
      
      state = state.copyWith(isLoading: false);
      return true;
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset form ke empty state
  void resetForm() {
    state = StockFormState(stock: Stock.empty());
    loadDropdownData();
  }
}

/// Provider untuk form stok
final stockFormProvider = StateNotifierProvider<StockFormNotifier, StockFormState>((ref) {
  final stockService = ref.read(stockServiceProvider);
  return StockFormNotifier(ref, stockService);
});