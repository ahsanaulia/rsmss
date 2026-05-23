import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/stock_racks/models/stock_rack_model.dart';

class StockRackState extends Equatable {
  final List<StockRackModel> racks;
  final bool isLoading;
  final String? errorMessage;
  final StockRackModel? selectedRack;
  final bool isSubmitting;

  const StockRackState({
    this.racks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedRack,
    this.isSubmitting = false,
  });

  factory StockRackState.initial() {
    return const StockRackState();
  }

  factory StockRackState.loading() {
    return const StockRackState(isLoading: true);
  }

  StockRackState copyWith({
    List<StockRackModel>? racks,
    bool? isLoading,
    String? errorMessage,
    StockRackModel? selectedRack,
    bool? isSubmitting,
  }) {
    return StockRackState(
      racks: racks ?? this.racks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedRack: selectedRack ?? this.selectedRack,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        racks,
        isLoading,
        errorMessage,
        selectedRack,
        isSubmitting,
      ];
}