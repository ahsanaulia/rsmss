import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/stock_warehouses/models/stock_warehouse_model.dart';
import 'package:rsmss/crud/stock_warehouses/services/stock_warehouse_service.dart';
import 'stock_warehouse_state.dart';

final stockWarehouseServiceProvider = Provider<StockWarehouseService>((ref) {
  return StockWarehouseService();
});

final stockWarehouseProvider = StateNotifierProvider<StockWarehouseNotifier, StockWarehouseState>((ref) {
  final service = ref.watch(stockWarehouseServiceProvider);
  return StockWarehouseNotifier(service);
});

class StockWarehouseNotifier extends StateNotifier<StockWarehouseState> {
  final StockWarehouseService _service;

  StockWarehouseNotifier(this._service) : super(StockWarehouseState.initial());

  Future<void> loadWarehouses() async {
    debugPrint('🔄 [Provider] loadWarehouses - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllWarehouses();
      final warehouses = response.map((json) => StockWarehouseModel.fromJson(json)).toList();
      
      state = state.copyWith(
        warehouses: warehouses,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadWarehouses - Success: ${warehouses.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadWarehouses - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadWarehouseById(String id) async {
    debugPrint('🔄 [Provider] loadWarehouseById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getWarehouseById(id);
      if (response != null) {
        final warehouse = StockWarehouseModel.fromJson(response);
        state = state.copyWith(
          selectedWarehouse: warehouse,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadWarehouseById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Gudang tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadWarehouseById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createWarehouse(StockWarehouseModel model) async {
    debugPrint('📝 [Provider] createWarehouse - Name: ${model.name}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.floorId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih lantai terlebih dahulu',
        );
        return false;
      }

      final exists = await _service.isCodeExists(model.code);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode gudang "${model.code}" sudah ada',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertWarehouse(data);
      await loadWarehouses();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createWarehouse - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createWarehouse - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateWarehouse(StockWarehouseModel model) async {
    debugPrint('✏️ [Provider] updateWarehouse - ID: ${model.id}, Name: ${model.name}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID gudang tidak ditemukan');
      }
      if (model.floorId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih lantai terlebih dahulu',
        );
        return false;
      }

      final exists = await _service.isCodeExists(model.code, excludeId: model.id);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode gudang "${model.code}" sudah ada',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateWarehouse(model.id!, data);
      await loadWarehouses();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateWarehouse - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateWarehouse - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteWarehouse(String id) async {
    debugPrint('🗑️ [Provider] deleteWarehouse - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteWarehouse(id);
      await loadWarehouses();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteWarehouse - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteWarehouse - Error: $e');
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
    state = state.copyWith(selectedWarehouse: null);
  }

  void setSelectedWarehouse(StockWarehouseModel? warehouse) {
    state = state.copyWith(selectedWarehouse: warehouse);
  }
}