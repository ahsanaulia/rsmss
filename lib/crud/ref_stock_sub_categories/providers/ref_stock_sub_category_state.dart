import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/models/ref_stock_sub_category_model.dart';

class RefStockSubCategoryState extends Equatable {
  final List<RefStockSubCategoryModel> subCategories;
  final bool isLoading;
  final String? errorMessage;
  final RefStockSubCategoryModel? selectedSubCategory;
  final bool isSubmitting;

  const RefStockSubCategoryState({
    this.subCategories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSubCategory,
    this.isSubmitting = false,
  });

  factory RefStockSubCategoryState.initial() {
    return const RefStockSubCategoryState();
  }

  factory RefStockSubCategoryState.loading() {
    return const RefStockSubCategoryState(isLoading: true);
  }

  RefStockSubCategoryState copyWith({
    List<RefStockSubCategoryModel>? subCategories,
    bool? isLoading,
    String? errorMessage,
    RefStockSubCategoryModel? selectedSubCategory,
    bool? isSubmitting,
  }) {
    return RefStockSubCategoryState(
      subCategories: subCategories ?? this.subCategories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        subCategories,
        isLoading,
        errorMessage,
        selectedSubCategory,
        isSubmitting,
      ];
}