import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_asset_categories/models/ref_asset_category_model.dart';

class RefAssetCategoryState extends Equatable {
  final List<RefAssetCategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;
  final RefAssetCategoryModel? selectedCategory;
  final bool isSubmitting;

  const RefAssetCategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
    this.isSubmitting = false,
  });

  factory RefAssetCategoryState.initial() {
    return const RefAssetCategoryState();
  }

  factory RefAssetCategoryState.loading() {
    return const RefAssetCategoryState(isLoading: true);
  }

  RefAssetCategoryState copyWith({
    List<RefAssetCategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    RefAssetCategoryModel? selectedCategory,
    bool? isSubmitting,
  }) {
    return RefAssetCategoryState(
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