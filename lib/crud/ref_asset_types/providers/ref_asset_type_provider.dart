import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/ref_asset_types/models/ref_asset_type_model.dart';
import 'package:rsmss/crud/ref_asset_types/services/ref_asset_type_service.dart';
import 'ref_asset_type_state.dart';

final refAssetTypeServiceProvider = Provider<RefAssetTypeService>((ref) {
  return RefAssetTypeService();
});

final refAssetTypeProvider = StateNotifierProvider<RefAssetTypeNotifier, RefAssetTypeState>((ref) {
  final service = ref.watch(refAssetTypeServiceProvider);
  return RefAssetTypeNotifier(service);
});

class RefAssetTypeNotifier extends StateNotifier<RefAssetTypeState> {
  final RefAssetTypeService _service;

  RefAssetTypeNotifier(this._service) : super(RefAssetTypeState.initial());

  Future<void> loadTypes() async {
    debugPrint('🔄 [Provider] loadTypes - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllTypes();
      final types = response.map((json) => RefAssetTypeModel.fromJson(json)).toList();
      
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
      final types = response.map((json) => RefAssetTypeModel.fromJson(json)).toList();
      
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
        final type = RefAssetTypeModel.fromJson(response);
        state = state.copyWith(
          selectedType: type,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadTypeById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Tipe aset tidak ditemukan',
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

  Future<bool> createType(RefAssetTypeModel model) async {
    debugPrint('📝 [Provider] createType - Name: ${model.typeName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.subCategoryId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih sub-kategori terlebih dahulu',
        );
        return false;
      }

      final exists = await _service.isTypeNameExists(
        model.typeName,
        model.subCategoryId!,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama tipe aset "${model.typeName}" sudah ada di sub-kategori ini',
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

  Future<bool> updateType(RefAssetTypeModel model) async {
    debugPrint('✏️ [Provider] updateType - ID: ${model.id}, Name: ${model.typeName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID tipe aset tidak ditemukan');
      }
      if (model.subCategoryId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Pilih sub-kategori terlebih dahulu',
        );
        return false;
      }

      final exists = await _service.isTypeNameExists(
        model.typeName,
        model.subCategoryId!,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama tipe aset "${model.typeName}" sudah ada di sub-kategori ini',
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

  void setSelectedType(RefAssetTypeModel? type) {
    state = state.copyWith(selectedType: type);
  }
}