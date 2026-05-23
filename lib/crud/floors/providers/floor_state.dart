import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/floors/models/floor_model.dart';

class FloorState extends Equatable {
  final List<FloorModel> floors;
  final bool isLoading;
  final String? errorMessage;
  final FloorModel? selectedFloor;
  final bool isSubmitting;

  const FloorState({
    this.floors = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedFloor,
    this.isSubmitting = false,
  });

  factory FloorState.initial() {
    return const FloorState();
  }

  factory FloorState.loading() {
    return const FloorState(isLoading: true);
  }

  FloorState copyWith({
    List<FloorModel>? floors,
    bool? isLoading,
    String? errorMessage,
    FloorModel? selectedFloor,
    bool? isSubmitting,
  }) {
    return FloorState(
      floors: floors ?? this.floors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedFloor: selectedFloor ?? this.selectedFloor,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        floors,
        isLoading,
        errorMessage,
        selectedFloor,
        isSubmitting,
      ];
}