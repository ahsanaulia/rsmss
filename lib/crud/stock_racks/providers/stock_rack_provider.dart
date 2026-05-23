 import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/stock_racks/models/stock_rack_model.dart';
import 'package:rsmss/crud/stock_racks/services/stock_rack_service.dart';
import 'stock_rack_state.dart';

final stockRackServiceProvider = Provider<StockRackService>((ref) {
  return StockRackService();
});

final stockRackProvider = StateNotifierProvider<StockRackNotifier, StockRackState>((ref) {
  final service = ref.watch(stockRackServiceProvider);
  return StockRackNotifier(service);
});

class StockRackNotifier extends StateNotifier<StockRackState> {
  final StockRackService _service;

  StockRackNotifier(this._service) : super(StockRackState.initial());

  Future<void> loadRacks() async {
    debugPrint('🔄 [Provider] loadRacks - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllRacks();
      final racks = response.map((json) => StockRackModel.fromJson(json)).toList();
      
      state = state.copyWith(
        racks: racks,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadRacks - Success: ${racks.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadRacks - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadRackById(String id) async {
    debugPrint('🔄 [Provider] loadRackById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getRackById(id);
      if (response != null) {
        final rack = StockRackModel.fromJson(response);
        state = state.copyWith(
          selectedRack: rack,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadRackById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Rak tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadRackById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createRack(StockRackModel model) async {
    debugPrint('📝 [Provider] createRack - Code: ${model.code}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isCodeExists(model.code, model.zoneId);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode rak "${model.code}" sudah ada di zona ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertRack(data);
      await loadRacks();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createRack - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createRack - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateRack(StockRackModel model) async {
    debugPrint('✏️ [Provider] updateRack - ID: ${model.id}, Code: ${model.code}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID rak tidak ditemukan');
      }

      final exists = await _service.isCodeExists(
        model.code, 
        model.zoneId,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode rak "${model.code}" sudah ada di zona ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateRack(model.id!, data);
      await loadRacks();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateRack - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateRack - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteRack(String id) async {
    debugPrint('🗑️ [Provider] deleteRack - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteRack(id);
      await loadRacks();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteRack - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteRack - Error: $e');
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
    state = state.copyWith(selectedRack: null);
  }

  void setSelectedRack(StockRackModel? rack) {
    state = state.copyWith(selectedRack: rack);
  }
}