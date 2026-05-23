import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/models/ref_stock_sub_category_model.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/services/ref_stock_sub_category_service.dart';
import 'ref_stock_sub_category_state.dart';

final refStockSubCategoryServiceProvider = Provider<RefStockSubCategoryService>((ref) {
  return RefStockSubCategoryService();
});

final refStockSubCategoryProvider = StateNotifierProvider<RefStockSubCategoryNotifier, RefStockSubCategoryState>((ref) {
  final service = ref.watch(refStockSubCategoryServiceProvider);
  return RefStockSubCategoryNotifier(service);
});

class RefStockSubCategoryNotifier extends StateNotifier<RefStockSubCategoryState> {
  final RefStockSubCategoryService _service;

  RefStockSubCategoryNotifier(this._service) : super(RefStockSubCategoryState.initial());

  Future<void> loadSubCategories() async {
    debugPrint('🔄 [Provider] loadSubCategories - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllSubCategories();
      final subCategories = response.map((json) => RefStockSubCategoryModel.fromJson(json)).toList();
      
      state = state.copyWith(
        subCategories: subCategories,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadSubCategories - Success: ${subCategories.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadSubCategories - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadSubCategoriesByCategoryId(String categoryId) async {
    debugPrint('🔄 [Provider] loadSubCategoriesByCategoryId - CategoryID: $categoryId');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getSubCategoriesByCategoryId(categoryId);
      final subCategories = response.map((json) => RefStockSubCategoryModel.fromJson(json)).toList();
      
      state = state.copyWith(
        subCategories: subCategories,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadSubCategoriesByCategoryId - Success: ${subCategories.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadSubCategoriesByCategoryId - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadSubCategoryById(String id) async {
    debugPrint('🔄 [Provider] loadSubCategoryById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getSubCategoryById(id);
      if (response != null) {
        final subCategory = RefStockSubCategoryModel.fromJson(response);
        state = state.copyWith(
          selectedSubCategory: subCategory,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadSubCategoryById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sub-kategori stok tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadSubCategoryById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createSubCategory(RefStockSubCategoryModel model) async {
    debugPrint('📝 [Provider] createSubCategory - Name: ${model.subCategoryName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isSubCategoryNameExists(
        model.subCategoryName,
        model.categoryId,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama sub-kategori stok "${model.subCategoryName}" sudah ada di kategori ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertSubCategory(data);
      await loadSubCategories();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createSubCategory - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createSubCategory - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateSubCategory(RefStockSubCategoryModel model) async {
    debugPrint('✏️ [Provider] updateSubCategory - ID: ${model.id}, Name: ${model.subCategoryName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID sub-kategori stok tidak ditemukan');
      }

      final exists = await _service.isSubCategoryNameExists(
        model.subCategoryName,
        model.categoryId,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama sub-kategori stok "${model.subCategoryName}" sudah ada di kategori ini',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateSubCategory(model.id!, data);
      await loadSubCategories();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateSubCategory - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateSubCategory - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteSubCategory(String id) async {
    debugPrint('🗑️ [Provider] deleteSubCategory - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteSubCategory(id);
      await loadSubCategories();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteSubCategory - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteSubCategory - Error: $e');
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
    state = state.copyWith(selectedSubCategory: null);
  }

  void setSelectedSubCategory(RefStockSubCategoryModel? subCategory) {
    state = state.copyWith(selectedSubCategory: subCategory);
  }
}