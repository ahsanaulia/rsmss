import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/floors/models/floor_model.dart';
import 'package:rsmss/crud/floors/services/floor_service.dart';
import 'floor_state.dart';

final floorServiceProvider = Provider<FloorService>((ref) {
  return FloorService();
});

final floorProvider = StateNotifierProvider<FloorNotifier, FloorState>((ref) {
  final service = ref.watch(floorServiceProvider);
  return FloorNotifier(service);
});

class FloorNotifier extends StateNotifier<FloorState> {
  final FloorService _service;

  FloorNotifier(this._service) : super(FloorState.initial());

  Future<void> loadFloors() async {
    debugPrint('🔄 [Provider] loadFloors - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllFloors();
      final floors = response.map((json) => FloorModel.fromJson(json)).toList();
      
      state = state.copyWith(
        floors: floors,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadFloors - Success: ${floors.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadFloors - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadFloorById(String id) async {
    debugPrint('🔄 [Provider] loadFloorById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getFloorById(id);
      if (response != null) {
        final floor = FloorModel.fromJson(response);
        state = state.copyWith(
          selectedFloor: floor,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadFloorById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Lantai tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadFloorById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createFloor(FloorModel model) async {
    debugPrint('📝 [Provider] createFloor - Number: ${model.floorNumber}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.buildingId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih gedung terlebih dahulu',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertFloor(data);
      await loadFloors();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createFloor - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createFloor - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateFloor(FloorModel model) async {
    debugPrint('✏️ [Provider] updateFloor - ID: ${model.id}, Number: ${model.floorNumber}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID lantai tidak ditemukan');
      }
      if (model.buildingId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih gedung terlebih dahulu',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateFloor(model.id!, data);
      await loadFloors();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateFloor - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateFloor - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteFloor(String id) async {
    debugPrint('🗑️ [Provider] deleteFloor - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteFloor(id);
      await loadFloors();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteFloor - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteFloor - Error: $e');
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
    state = state.copyWith(selectedFloor: null);
  }

  void setSelectedFloor(FloorModel? floor) {
    state = state.copyWith(selectedFloor: floor);
  }
}
