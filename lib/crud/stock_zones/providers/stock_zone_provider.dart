import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/stock_zones/models/stock_zone_model.dart';
import 'package:rsmss/crud/stock_zones/services/stock_zone_service.dart';
import 'stock_zone_state.dart';

final stockZoneServiceProvider = Provider<StockZoneService>((ref) {
  return StockZoneService();
});

final stockZoneProvider = StateNotifierProvider<StockZoneNotifier, StockZoneState>((ref) {
  final service = ref.watch(stockZoneServiceProvider);
  return StockZoneNotifier(service);
});

class StockZoneNotifier extends StateNotifier<StockZoneState> {
  final StockZoneService _service;

  StockZoneNotifier(this._service) : super(StockZoneState.initial());

  Future<void> loadZones() async {
    debugPrint('🔄 [Provider] loadZones - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllZones();
      final zones = response.map((json) => StockZoneModel.fromJson(json)).toList();
      
      state = state.copyWith(
        zones: zones,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadZones - Success: ${zones.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadZones - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadZoneById(String id) async {
    debugPrint('🔄 [Provider] loadZoneById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getZoneById(id);
      if (response != null) {
        final zone = StockZoneModel.fromJson(response);
        state = state.copyWith(
          selectedZone: zone,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadZoneById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Zona tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadZoneById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createZone(StockZoneModel model) async {
    debugPrint('📝 [Provider] createZone - Name: ${model.name}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isCodeExists(model.code, model.warehouseId);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode zona "${model.code}" sudah ada di gudang ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertZone(data);
      await loadZones();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createZone - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createZone - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateZone(StockZoneModel model) async {
    debugPrint('✏️ [Provider] updateZone - ID: ${model.id}, Name: ${model.name}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID zona tidak ditemukan');
      }

      final exists = await _service.isCodeExists(
        model.code, 
        model.warehouseId,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Kode zona "${model.code}" sudah ada di gudang ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateZone(model.id!, data);
      await loadZones();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateZone - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateZone - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteZone(String id) async {
    debugPrint('🗑️ [Provider] deleteZone - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteZone(id);
      await loadZones();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteZone - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteZone - Error: $e');
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
    state = state.copyWith(selectedZone: null);
  }

  void setSelectedZone(StockZoneModel? zone) {
    state = state.copyWith(selectedZone: zone);
  }
}