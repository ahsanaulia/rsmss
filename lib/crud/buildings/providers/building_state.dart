import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/buildings/models/building_model.dart';

class BuildingState extends Equatable {
  final List<BuildingModel> buildings;
  final bool isLoading;
  final String? errorMessage;
  final BuildingModel? selectedBuilding;
  final bool isSubmitting;

  const BuildingState({
    this.buildings = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedBuilding,
    this.isSubmitting = false,
  });

  factory BuildingState.initial() {
    return const BuildingState();
  }

  factory BuildingState.loading() {
    return const BuildingState(isLoading: true);
  }

  BuildingState copyWith({
    List<BuildingModel>? buildings,
    bool? isLoading,
    String? errorMessage,
    BuildingModel? selectedBuilding,
    bool? isSubmitting,
  }) {
    return BuildingState(
      buildings: buildings ?? this.buildings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedBuilding: selectedBuilding ?? this.selectedBuilding,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        buildings,
        isLoading,
        errorMessage,
        selectedBuilding,
        isSubmitting,
      ];
}