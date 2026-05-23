import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/ref_stock_types/models/ref_stock_type_model.dart';
import 'package:rsmss/crud/ref_stock_types/services/ref_stock_type_service.dart';
import 'ref_stock_type_state.dart';

final refStockTypeServiceProvider = Provider<RefStockTypeService>((ref) {
  return RefStockTypeService();
});

final refStockTypeProvider = StateNotifierProvider<RefStockTypeNotifier, RefStockTypeState>((ref) {
  final service = ref.watch(refStockTypeServiceProvider);
  return RefStockTypeNotifier(service);
});

class RefStockTypeNotifier extends StateNotifier<RefStockTypeState> {
  final RefStockTypeService _service;

  RefStockTypeNotifier(this._service) : super(RefStockTypeState.initial());

  Future<void> loadTypes() async {
    debugPrint('🔄 [Provider] loadTypes - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllTypes();
      final types = response.map((json) => RefStockTypeModel.fromJson(json)).toList();
      
      state = state.copyWith(
        types: types,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadTypes - Success: ${types.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadTypes - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadTypesBySubCategoryId(String subCategoryId) async {
    debugPrint('🔄 [Provider] loadTypesBySubCategoryId - SubCategoryID: $subCategoryId');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getTypesBySubCategoryId(subCategoryId);
      final types = response.map((json) => RefStockTypeModel.fromJson(json)).toList();
      
      state = state.copyWith(
        types: types,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadTypesBySubCategoryId - Success: ${types.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadTypesBySubCategoryId - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadTypeById(String id) async {
    debugPrint('🔄 [Provider] loadTypeById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getTypeById(id);
      if (response != null) {
        final type = RefStockTypeModel.fromJson(response);
        state = state.copyWith(
          selectedType: type,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadTypeById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Tipe stok tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadTypeById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createType(RefStockTypeModel model) async {
    debugPrint('📝 [Provider] createType - Name: ${model.typeName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.subCategoryId.isEmpty) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih sub-kategori stok terlebih dahulu',
        );
        return false;
      }

      final exists = await _service.isTypeNameExists(
        model.typeName,
        model.subCategoryId,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama tipe stok "${model.typeName}" sudah ada di sub-kategori ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertType(data);
      await loadTypes();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createType - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createType - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateType(RefStockTypeModel model) async {
    debugPrint('✏️ [Provider] updateType - ID: ${model.id}, Name: ${model.typeName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID tipe stok tidak ditemukan');
      }
      if (model.subCategoryId.isEmpty) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih sub-kategori stok terlebih dahulu',
        );
        return false;
      }

      final exists = await _service.isTypeNameExists(
        model.typeName,
        model.subCategoryId,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama tipe stok "${model.typeName}" sudah ada di sub-kategori ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateType(model.id!, data);
      await loadTypes();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateType - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateType - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteType(String id) async {
    debugPrint('🗑️ [Provider] deleteType - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteType(id);
      await loadTypes();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteType - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteType - Error: $e');
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
    state = state.copyWith(selectedType: null);
  }

  void setSelectedType(RefStockTypeModel? type) {
    state = state.copyWith(selectedType: type);
  }
}