import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rsmss/crud/scoring_categories/models/scoring_category_model.dart';
import 'package:rsmss/crud/scoring_categories/services/scoring_category_service.dart';
import 'scoring_category_state.dart';

final scoringCategoryServiceProvider = Provider<ScoringCategoryService>((ref) {
  return ScoringCategoryService();
});

final scoringCategoryProvider = StateNotifierProvider<ScoringCategoryNotifier, ScoringCategoryState>((ref) {
  final service = ref.watch(scoringCategoryServiceProvider);
  return ScoringCategoryNotifier(service);
});

class ScoringCategoryNotifier extends StateNotifier<ScoringCategoryState> {
  final ScoringCategoryService _service;

  ScoringCategoryNotifier(this._service) : super(ScoringCategoryState.initial());

  Future<void> loadItems() async {
    debugPrint('🔄 [Provider] loadItems - Start');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getAll();
      final items = response.map((json) => ScoringCategoryModel.fromJson(json)).toList();

      state = state.copyWith(
        items: items,
        isLoading: false,
      );
      debugPrint('✅ [Provider] loadItems - Success: ${items.length} items');
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadItems - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadById(String id) async {
    debugPrint('🔄 [Provider] loadById - ID: $id');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _service.getById(id);
      if (response != null) {
        final item = ScoringCategoryModel.fromJson(response);
        state = state.copyWith(
          selectedItem: item,
          isLoading: false,
        );
        debugPrint('✅ [Provider] loadById - Success');
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Data tidak ditemukan',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] loadById - Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> create(ScoringCategoryModel model) async {
    debugPrint('📝 [Provider] create - Code: ${model.categoryCode}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final data = model.toJson();
      await _service.insert(data);
      await loadItems();

      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] create - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] create - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> update(ScoringCategoryModel model) async {
    debugPrint('✏️ [Provider] update - ID: ${model.id}, Code: ${model.categoryCode}');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (model.id == null) {
        throw Exception('ID tidak ditemukan');
      }

      final data = model.toJson();
      await _service.update(model.id!, data);
      await loadItems();

      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] update - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] update - Error: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> delete(String id) async {
    debugPrint('🗑️ [Provider] delete - ID: $id');
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _service.delete(id);
      await loadItems();

      state = state.copyWith(isSubmitting: false);
      debugPrint('✅ [Provider] delete - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] delete - Error: $e');
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
    state = state.copyWith(selectedItem: null);
  }

  void setSelectedItem(ScoringCategoryModel? item) {
    state = state.copyWith(selectedItem: item);
  }
}