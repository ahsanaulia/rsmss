import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/scoring_categories/models/scoring_category_model.dart';

class ScoringCategoryState extends Equatable {
  final List<ScoringCategoryModel> items;
  final bool isLoading;
  final String? errorMessage;
  final ScoringCategoryModel? selectedItem;
  final bool isSubmitting;

  const ScoringCategoryState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory ScoringCategoryState.initial() {
    return const ScoringCategoryState();
  }

  factory ScoringCategoryState.loading() {
    return const ScoringCategoryState(isLoading: true);
  }

  ScoringCategoryState copyWith({
    List<ScoringCategoryModel>? items,
    bool? isLoading,
    String? errorMessage,
    ScoringCategoryModel? selectedItem,
    bool? isSubmitting,
  }) {
    return ScoringCategoryState(
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