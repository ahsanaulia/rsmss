import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_building_functions/models/ref_building_function_model.dart';

class RefBuildingFunctionState extends Equatable {
  final List<RefBuildingFunctionModel> functions;
  final bool isLoading;
  final String? errorMessage;
  final RefBuildingFunctionModel? selectedFunction;
  final bool isSubmitting;

  const RefBuildingFunctionState({
    this.functions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedFunction,
    this.isSubmitting = false,
  });

  factory RefBuildingFunctionState.initial() {
    return const RefBuildingFunctionState();
  }

  factory RefBuildingFunctionState.loading() {
    return const RefBuildingFunctionState(isLoading: true);
  }

  RefBuildingFunctionState copyWith({
    List<RefBuildingFunctionModel>? functions,
    bool? isLoading,
    String? errorMessage,
    RefBuildingFunctionModel? selectedFunction,
    bool? isSubmitting,
  }) {
    return RefBuildingFunctionState(
      functions: functions ?? this.functions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedFunction: selectedFunction ?? this.selectedFunction,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        functions,
        isLoading,
        errorMessage,
        selectedFunction,
        isSubmitting,
      ];
}