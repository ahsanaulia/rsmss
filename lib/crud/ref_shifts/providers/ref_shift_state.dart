import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_shifts/models/ref_shift_model.dart';

class RefShiftState extends Equatable {
  final List<RefShiftModel> items;
  final bool isLoading;
  final String? errorMessage;
  final RefShiftModel? selectedItem;
  final bool isSubmitting;

  const RefShiftState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory RefShiftState.initial() {
    return const RefShiftState();
  }

  factory RefShiftState.loading() {
    return const RefShiftState(isLoading: true);
  }

  RefShiftState copyWith({
    List<RefShiftModel>? items,
    bool? isLoading,
    String? errorMessage,
    RefShiftModel? selectedItem,
    bool? isSubmitting,
  }) {
    return RefShiftState(
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