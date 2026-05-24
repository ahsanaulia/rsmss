import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/leave_types/models/leave_type_model.dart';

class LeaveTypeState extends Equatable {
  final List<LeaveTypeModel> items;
  final bool isLoading;
  final String? errorMessage;
  final LeaveTypeModel? selectedItem;
  final bool isSubmitting;

  const LeaveTypeState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory LeaveTypeState.initial() {
    return const LeaveTypeState();
  }

  factory LeaveTypeState.loading() {
    return const LeaveTypeState(isLoading: true);
  }

  LeaveTypeState copyWith({
    List<LeaveTypeModel>? items,
    bool? isLoading,
    String? errorMessage,
    LeaveTypeModel? selectedItem,
    bool? isSubmitting,
  }) {
    return LeaveTypeState(
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