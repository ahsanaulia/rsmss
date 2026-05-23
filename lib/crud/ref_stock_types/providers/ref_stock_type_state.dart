import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/ref_stock_types/models/ref_stock_type_model.dart';

class RefStockTypeState extends Equatable {
  final List<RefStockTypeModel> types;
  final bool isLoading;
  final String? errorMessage;
  final RefStockTypeModel? selectedType;
  final bool isSubmitting;

  const RefStockTypeState({
    this.types = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType,
    this.isSubmitting = false,
  });

  factory RefStockTypeState.initial() {
    return const RefStockTypeState();
  }

  factory RefStockTypeState.loading() {
    return const RefStockTypeState(isLoading: true);
  }

  RefStockTypeState copyWith({
    List<RefStockTypeModel>? types,
    bool? isLoading,
    String? errorMessage,
    RefStockTypeModel? selectedType,
    bool? isSubmitting,
  }) {
    return RefStockTypeState(
      types: types ?? this.types,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedType: selectedType ?? this.selectedType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        types,
        isLoading,
        errorMessage,
        selectedType,
        isSubmitting,
      ];
}