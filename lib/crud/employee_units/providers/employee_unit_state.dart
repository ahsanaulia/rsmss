import 'package:equatable/equatable.dart';
import '../models/employee_unit_model.dart';

class EmployeeUnitState extends Equatable {
  final bool isLoading;
  final List<EmployeeUnitModel> items;
  final String? error;
  final bool isSubmitting;
  final EmployeeUnitModel? selectedItem;

  // Filters
  final String? filterSearch;
  final bool filterIsActive;

  EmployeeUnitState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.isSubmitting = false,
    this.selectedItem,
    this.filterSearch,
    this.filterIsActive = true,
  });

  EmployeeUnitState copyWith({
    bool? isLoading,
    List<EmployeeUnitModel>? items,
    String? error,
    bool? isSubmitting,
    EmployeeUnitModel? selectedItem,
    String? filterSearch,
    bool? filterIsActive,
  }) {
    return EmployeeUnitState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedItem: selectedItem ?? this.selectedItem,
      filterSearch: filterSearch ?? this.filterSearch,
      filterIsActive: filterIsActive ?? this.filterIsActive,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        items,
        error,
        isSubmitting,
        selectedItem,
        filterSearch,
        filterIsActive,
      ];
}