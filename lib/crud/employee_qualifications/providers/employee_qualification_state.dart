import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/employee_qualifications/models/employee_qualification_model.dart';

class EmployeeQualificationState extends Equatable {
  final List<EmployeeQualificationModel> items;
  final bool isLoading;
  final String? errorMessage;
  final EmployeeQualificationModel? selectedItem;
  final bool isSubmitting;

  const EmployeeQualificationState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory EmployeeQualificationState.initial() {
    return const EmployeeQualificationState();
  }

  factory EmployeeQualificationState.loading() {
    return const EmployeeQualificationState(isLoading: true);
  }

  EmployeeQualificationState copyWith({
    List<EmployeeQualificationModel>? items,
    bool? isLoading,
    String? errorMessage,
    EmployeeQualificationModel? selectedItem,
    bool? isSubmitting,
  }) {
    return EmployeeQualificationState(
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