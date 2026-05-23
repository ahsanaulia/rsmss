import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/ref_asset_categories/models/ref_asset_category_model.dart';
import 'package:rsmss/crud/ref_asset_categories/services/ref_asset_category_service.dart';
import 'ref_asset_category_state.dart';

final refAssetCategoryServiceProvider = Provider<RefAssetCategoryService>((ref) {
  return RefAssetCategoryService();
});

final refAssetCategoryProvider = StateNotifierProvider<RefAssetCategoryNotifier, RefAssetCategoryState>((ref) {
  final service = ref.watch(refAssetCategoryServiceProvider);
  return RefAssetCategoryNotifier(service);
});

class RefAssetCategoryNotifier extends StateNotifier<RefAssetCategoryState> {
  final RefAssetCategoryService _service;

  RefAssetCategoryNotifier(this._service) : super(RefAssetCategoryState.initial());

  Future<void> loadCategories() async {
    debugPrint('🔄 [Provider] loadCategories - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAllCategories();
      final categories = response.map((json) => RefAssetCategoryModel.fromJson(json)).toList();
      
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadCategories - Success: ${categories.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadCategories - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadCategoryById(String id) async {
    debugPrint('🔄 [Provider] loadCategoryById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getCategoryById(id);
      if (response != null) {
        final category = RefAssetCategoryModel.fromJson(response);
        state = state.copyWith(
          selectedCategory: category,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadCategoryById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Kategori tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadCategoryById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createCategory(RefAssetCategoryModel model) async {
    debugPrint('📝 [Provider] createCategory - Name: ${model.categoryName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final exists = await _service.isCategoryNameExists(model.categoryName);
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama kategori "${model.categoryName}" sudah ada',
        );
        return false;
      }

      final data = model.toJson();
      await _service.insertCategory(data);
      await loadCategories();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] createCategory - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] createCategory - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateCategory(RefAssetCategoryModel model) async {
    debugPrint('✏️ [Provider] updateCategory - ID: ${model.id}, Name: ${model.categoryName}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID kategori tidak ditemukan');
      }

      final exists = await _service.isCategoryNameExists(
        model.categoryName,
        excludeId: model.id,
      );
      if (exists) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Nama kategori "${model.categoryName}" sudah ada',
        );
        return false;
      }

      final data = model.toJson();
      await _service.updateCategory(model.id!, data);
      await loadCategories();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] updateCategory - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] updateCategory - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    debugPrint('🗑️ [Provider] deleteCategory - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.deleteCategory(id);
      await loadCategories();
      
      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] deleteCategory - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] deleteCategory - Error: $e');
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
    state = state.copyWith(selectedCategory: null);
  }

  void setSelectedCategory(RefAssetCategoryModel? category) {
    state = state.copyWith(selectedCategory: category);
  }
}