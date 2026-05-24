import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_reports_category/models/ref_reports_category_model.dart';

class RefReportsCategoryState extends Equatable {
  final List<RefReportsCategoryModel> items;
  final bool isLoading;
  final String? errorMessage;
  final RefReportsCategoryModel? selectedItem;
  final bool isSubmitting;

  const RefReportsCategoryState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory RefReportsCategoryState.initial() {
    return const RefReportsCategoryState();
  }

  factory RefReportsCategoryState.loading() {
    return const RefReportsCategoryState(isLoading: true);
  }

  RefReportsCategoryState copyWith({
    List<RefReportsCategoryModel>? items,
    bool? isLoading,
    String? errorMessage,
    RefReportsCategoryModel? selectedItem,
    bool? isSubmitting,
  }) {
    return RefReportsCategoryState(
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