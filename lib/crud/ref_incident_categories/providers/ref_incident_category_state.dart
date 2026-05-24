import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_incident_categories/models/ref_incident_category_model.dart';

class RefIncidentCategoryState extends Equatable {
  final List<RefIncidentCategoryModel> items;
  final bool isLoading;
  final String? errorMessage;
  final RefIncidentCategoryModel? selectedItem;
  final bool isSubmitting;

  const RefIncidentCategoryState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory RefIncidentCategoryState.initial() {
    return const RefIncidentCategoryState();
  }

  factory RefIncidentCategoryState.loading() {
    return const RefIncidentCategoryState(isLoading: true);
  }

  RefIncidentCategoryState copyWith({
    List<RefIncidentCategoryModel>? items,
    bool? isLoading,
    String? errorMessage,
    RefIncidentCategoryModel? selectedItem,
    bool? isSubmitting,
  }) {
    return RefIncidentCategoryState(
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