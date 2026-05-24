import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_people_categories/models/ref_people_category_model.dart';

class RefPeopleCategoryState extends Equatable {
  final List<RefPeopleCategoryModel> items;
  final bool isLoading;
  final String? errorMessage;
  final RefPeopleCategoryModel? selectedItem;
  final bool isSubmitting;

  const RefPeopleCategoryState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory RefPeopleCategoryState.initial() {
    return const RefPeopleCategoryState();
  }

  factory RefPeopleCategoryState.loading() {
    return const RefPeopleCategoryState(isLoading: true);
  }

  RefPeopleCategoryState copyWith({
    List<RefPeopleCategoryModel>? items,
    bool? isLoading,
    String? errorMessage,
    RefPeopleCategoryModel? selectedItem,
    bool? isSubmitting,
  }) {
    return RefPeopleCategoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedItem: selectedItem ?? this.selectedItem,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        items,
        isLoading,
        errorMessage,
        selectedItem,
        isSubmitting,
      ];
}