import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_positions/models/ref_position_model.dart';

class RefPositionState extends Equatable {
  final List<RefPositionModel> items;
  final bool isLoading;
  final String? errorMessage;
  final RefPositionModel? selectedItem;
  final bool isSubmitting;

  const RefPositionState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.isSubmitting = false,
  });

  factory RefPositionState.initial() {
    return const RefPositionState();
  }

  factory RefPositionState.loading() {
    return const RefPositionState(isLoading: true);
  }

  RefPositionState copyWith({
    List<RefPositionModel>? items,
    bool? isLoading,
    String? errorMessage,
    RefPositionModel? selectedItem,
    bool? isSubmitting,
  }) {
    return RefPositionState(
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