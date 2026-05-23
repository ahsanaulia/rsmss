import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/buildings/models/building_model.dart';
import 'package:rsmss/crud/buildings/services/building_service.dart';
import 'building_state.dart';

final buildingServiceProvider = Provider<BuildingService>((ref) {
  return BuildingService();
});

final buildingProvider = StateNotifierProvider<BuildingNotifier, BuildingState>((ref) {
  final service = ref.watch(buildingServiceProvider);
  return BuildingNotifier(service);
});

class BuildingNotifier extends StateNotifier<BuildingState> {
  final BuildingService _service;

  BuildingNotifier(this._service) : super(BuildingState.initial());

  Future<void> loadBuildings() async {
    debugPrint('🔄 [Provider] loadBuildings - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllBuildings();
      final buildings = response.map((json) => BuildingModel.fromJson(json)).toList();
      
      state = state.copyWith(
        buildings: buildings,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadBuildings - Success: ${buildings.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadBuildings - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadBuildingById(String id) async {
    debugPrint('🔄 [Provider] loadBuildingById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getBuildingById(id);
      if (response != null) {
        final building = BuildingModel.fromJson(response);
        state = state.copyWith(
          selectedBuilding: building,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadBuildingById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Gedung tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadBuildingById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createBuilding(BuildingModel model) async {
    debugPrint('📝 [Provider] createBuilding - Name: ${model.buildingName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final data = model.toJson();
      await _service.insertBuilding(data);
      await loadBuildings();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createBuilding - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createBuilding - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateBuilding(BuildingModel model) async {
    debugPrint('✏️ [Provider] updateBuilding - ID: ${model.id}, Name: ${model.buildingName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID gedung tidak ditemukan');
      }

      final data = model.toJson();
      await _service.updateBuilding(model.id!, data);
      await loadBuildings();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateBuilding - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateBuilding - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteBuilding(String id) async {
    debugPrint('🗑️ [Provider] deleteBuilding - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteBuilding(id);
      await loadBuildings();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteBuilding - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteBuilding - Error: $e');
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
    state = state.copyWith(selectedBuilding: null);
  }

  void setSelectedBuilding(BuildingModel? building) {
    state = state.copyWith(selectedBuilding: building);
  }
}