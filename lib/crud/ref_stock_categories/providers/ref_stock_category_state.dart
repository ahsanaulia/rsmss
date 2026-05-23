import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_stock_categories/models/ref_stock_category_model.dart';

class RefStockCategoryState extends Equatable {
  final List<RefStockCategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;
  final RefStockCategoryModel? selectedCategory;
  final bool isSubmitting;

  const RefStockCategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
    this.isSubmitting = false,
  });

  factory RefStockCategoryState.initial() {
    return const RefStockCategoryState();
  }

  factory RefStockCategoryState.loading() {
    return const RefStockCategoryState(isLoading: true);
  }

  RefStockCategoryState copyWith({
    List<RefStockCategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    RefStockCategoryModel? selectedCategory,
    bool? isSubmitting,
  }) {
    return RefStockCategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        isLoading,
        errorMessage,
        selectedCategory,
        isSubmitting,
      ];
}