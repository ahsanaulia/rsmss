import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_asset_sub_categories/models/ref_asset_sub_category_model.dart';

class RefAssetSubCategoryState extends Equatable {
  final List<RefAssetSubCategoryModel> subCategories;
  final bool isLoading;
  final String? errorMessage;
  final RefAssetSubCategoryModel? selectedSubCategory;
  final bool isSubmitting;

  const RefAssetSubCategoryState({
    this.subCategories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSubCategory,
    this.isSubmitting = false,
  });

  factory RefAssetSubCategoryState.initial() {
    return const RefAssetSubCategoryState();
  }

  factory RefAssetSubCategoryState.loading() {
    return const RefAssetSubCategoryState(isLoading: true);
  }

  RefAssetSubCategoryState copyWith({
    List<RefAssetSubCategoryModel>? subCategories,
    bool? isLoading,
    String? errorMessage,
    RefAssetSubCategoryModel? selectedSubCategory,
    bool? isSubmitting,
  }) {
    return RefAssetSubCategoryState(
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