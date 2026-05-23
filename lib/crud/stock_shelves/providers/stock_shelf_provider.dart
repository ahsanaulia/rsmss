import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/stock_shelves/models/stock_shelf_model.dart';
import 'package:rsmss/crud/stock_shelves/services/stock_shelf_service.dart';
import 'stock_shelf_state.dart';

final stockShelfServiceProvider = Provider<StockShelfService>((ref) {
  return StockShelfService();
});

final stockShelfProvider = StateNotifierProvider<StockShelfNotifier, StockShelfState>((ref) {
  final service = ref.watch(stockShelfServiceProvider);
  return StockShelfNotifier(service);
});

class StockShelfNotifier extends StateNotifier<StockShelfState> {
  final StockShelfService _service;

  StockShelfNotifier(this._service) : super(StockShelfState.initial());

  Future<void> loadShelves() async {
    debugPrint('🔄 [Provider] loadShelves - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllShelves();
      final shelves = response.map((json) => StockShelfModel.fromJson(json)).toList();
      
      state = state.copyWith(
        shelves: shelves,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadShelves - Success: ${shelves.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadShelves - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadShelfById(String id) async {
    debugPrint('🔄 [Provider] loadShelfById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getShelfById(id);
      if (response != null) {
        final shelf = StockShelfModel.fromJson(response);
        state = state.copyWith(
          selectedShelf: shelf,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadShelfById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Shelf tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadShelfById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createShelf(StockShelfModel model) async {
    debugPrint('📝 [Provider] createShelf - Code: ${model.code}, Level: ${model.levelNumber}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isCodeExists(model.code, model.rackId);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode shelf "${model.code}" sudah ada di rak ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertShelf(data);
      await loadShelves();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createShelf - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createShelf - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateShelf(StockShelfModel model) async {
    debugPrint('✏️ [Provider] updateShelf - ID: ${model.id}, Code: ${model.code}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID shelf tidak ditemukan');
      }

      final exists = await _service.isCodeExists(
        model.code, 
        model.rackId,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode shelf "${model.code}" sudah ada di rak ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateShelf(model.id!, data);
      await loadShelves();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateShelf - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateShelf - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteShelf(String id) async {
    debugPrint('🗑️ [Provider] deleteShelf - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteShelf(id);
      await loadShelves();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteShelf - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteShelf - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSelected() {
    state = state.copyWith(selectedShelf: null);
  }

  void setSelectedShelf(StockShelfModel? shelf) {
    state = state.copyWith(selectedShelf: shelf);
  }
}