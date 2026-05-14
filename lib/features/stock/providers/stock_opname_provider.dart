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
  }

  Future<void> _loadStocks() async {
    state = state.copyWith(isLoading: true);

    try {
      final stocks = await _service.loadStocksForOpname();
      state = state.copyWith(
        isLoading: false,
        stocks: stocks,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load stock: $e',
      );
    }
  }

  void selectStock(String stockId) {
    final stock = state.stocks.firstWhere((s) => s['id'] == stockId);
    state = state.copyWith(
      selectedStockId: stockId,
      selectedStock: stock,
      stockBefore: (stock['current_stock'] as num).toDouble(),
      physicalStock: (stock['current_stock'] as num).toDouble(),
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
    _loadStocks();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetToForm() {
    state = StockOpnameState();
    _loadStocks();
  }

  Future<bool> saveOpname() async {
    if (!state.isValid) {
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
}