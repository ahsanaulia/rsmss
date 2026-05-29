// File: lib/insights/stocks/providers/stock_tree_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_tree_node_model.dart';
import '../services/stock_tree_service.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

/// Provider untuk StockTreeService (singleton)
final stockTreeServiceProvider = Provider<StockTreeService>((ref) {
  return StockTreeService();
});

// ============================================================
// STATE NOTIFIER FOR TREE DATA
// ============================================================

/// State untuk Stock Tree
class StockTreeState {
  final List<StockCategoryNode> categories;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final List<StockTreeItem> searchResults;
  final bool isSearching;

  StockTreeState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
  });

  StockTreeState copyWith({
    List<StockCategoryNode>? categories,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    List<StockTreeItem>? searchResults,
    bool? isSearching,
  }) {
    return StockTreeState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// StateNotifier untuk mengelola Stock Tree
class StockTreeNotifier extends StateNotifier<StockTreeState> {
  final StockTreeService _service;

  StockTreeNotifier(this._service) : super(StockTreeState());

  /// Load tree data
  Future<void> loadTree() async {
    // Jangan load jika sudah loading
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final categories = await _service.getStockTree();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh tree data
  Future<void> refresh() async {
    await loadTree();
  }

  /// Search stock
  Future<void> searchStock(String query) async {
    if (query.trim().isEmpty) {
      // Clear search
      state = state.copyWith(
        searchQuery: '',
        searchResults: [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      isSearching: true,
      isLoading: true,
    );

    try {
      final results = await _service.searchStock(query);
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
      isSearching: false,
    );
  }
}

/// Provider untuk StockTreeNotifier
final stockTreeProvider = StateNotifierProvider<StockTreeNotifier, StockTreeState>((ref) {
  final service = ref.watch(stockTreeServiceProvider);
  return StockTreeNotifier(service);
});

// ============================================================
// TREE SUMMARY PROVIDERS
// ============================================================

/// Provider untuk Tree Summary (FutureProvider)
final stockTreeSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(stockTreeServiceProvider);
  return await service.getTreeSummary();
});

// ============================================================
// SELECTORS (untuk performa)
// ============================================================

/// Selector: Apakah sedang loading?
final isStockTreeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(stockTreeProvider).isLoading;
});

/// Selector: Error message
final stockTreeErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(stockTreeProvider).errorMessage;
});

/// Selector: List categories
final stockTreeCategoriesProvider = Provider<List<StockCategoryNode>>((ref) {
  return ref.watch(stockTreeProvider).categories;
});

/// Selector: Search query
final stockTreeSearchQueryProvider = Provider<String>((ref) {
  return ref.watch(stockTreeProvider).searchQuery;
});

/// Selector: Search results
final stockTreeSearchResultsProvider = Provider<List<StockTreeItem>>((ref) {
  return ref.watch(stockTreeProvider).searchResults;
});

/// Selector: Apakah sedang searching?
final isStockTreeSearchingProvider = Provider<bool>((ref) {
  return ref.watch(stockTreeProvider).isSearching;
});

/// Selector: Total items di tree
final stockTreeTotalItemsProvider = Provider<int>((ref) {
  final categories = ref.watch(stockTreeCategoriesProvider);
  int total = 0;
  for (final category in categories) {
    total += category.totalItems;
  }
  return total;
});

/// Selector: Total quantity di tree
final stockTreeTotalQuantityProvider = Provider<int>((ref) {
  final categories = ref.watch(stockTreeCategoriesProvider);
  int total = 0;
  for (final category in categories) {
    total += category.totalQuantity;
  }
  return total;
});