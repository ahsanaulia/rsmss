import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/ref_building_functions/models/ref_building_function_model.dart';
import 'package:rsmss/crud/ref_building_functions/services/ref_building_function_service.dart';
import 'ref_building_function_state.dart';

final refBuildingFunctionServiceProvider = Provider<RefBuildingFunctionService>((ref) {
  return RefBuildingFunctionService();
});

final refBuildingFunctionProvider = StateNotifierProvider<RefBuildingFunctionNotifier, RefBuildingFunctionState>((ref) {
  final service = ref.watch(refBuildingFunctionServiceProvider);
  return RefBuildingFunctionNotifier(service);
});

class RefBuildingFunctionNotifier extends StateNotifier<RefBuildingFunctionState> {
  final RefBuildingFunctionService _service;

  RefBuildingFunctionNotifier(this._service) : super(RefBuildingFunctionState.initial());

  Future<void> loadFunctions() async {
    debugPrint('🔄 [Provider] loadFunctions - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllFunctions();
      final functions = response.map((json) => RefBuildingFunctionModel.fromJson(json)).toList();
      
      state = state.copyWith(
        functions: functions,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadFunctions - Success: ${functions.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadFunctions - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadFunctionById(String id) async {
    debugPrint('🔄 [Provider] loadFunctionById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getFunctionById(id);
      if (response != null) {
        final function = RefBuildingFunctionModel.fromJson(response);
        state = state.copyWith(
          selectedFunction: function,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadFunctionById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Fungsi gedung tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadFunctionById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createFunction(RefBuildingFunctionModel model) async {
    debugPrint('📝 [Provider] createFunction - Name: ${model.functionName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isFunctionNameExists(model.functionName);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama fungsi gedung "${model.functionName}" sudah ada',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertFunction(data);
      await loadFunctions();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createFunction - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createFunction - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateFunction(RefBuildingFunctionModel model) async {
    debugPrint('✏️ [Provider] updateFunction - ID: ${model.id}, Name: ${model.functionName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID fungsi gedung tidak ditemukan');
      }

      final exists = await _service.isFunctionNameExists(
        model.functionName,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama fungsi gedung "${model.functionName}" sudah ada',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateFunction(model.id!, data);
      await loadFunctions();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateFunction - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateFunction - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteFunction(String id) async {
    debugPrint('🗑️ [Provider] deleteFunction - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteFunction(id);
      await loadFunctions();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteFunction - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteFunction - Error: $e');
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
    state = state.copyWith(selectedFunction: null);
  }

  void setSelectedFunction(RefBuildingFunctionModel? function) {
    state = state.copyWith(selectedFunction: function);
  }
}