import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/stock_shelves/models/stock_shelf_model.dart';

class StockShelfState extends Equatable {
  final List<StockShelfModel> shelves;
  final bool isLoading;
  final String? errorMessage;
  final StockShelfModel? selectedShelf;
  final bool isSubmitting;

  const StockShelfState({
    this.shelves = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedShelf,
    this.isSubmitting = false,
  });

  factory StockShelfState.initial() {
    return const StockShelfState();
  }

  factory StockShelfState.loading() {
    return const StockShelfState(isLoading: true);
  }

  StockShelfState copyWith({
    List<StockShelfModel>? shelves,
    bool? isLoading,
    String? errorMessage,
    StockShelfModel? selectedShelf,
    bool? isSubmitting,
  }) {
    return StockShelfState(
      shelves: shelves ?? this.shelves,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedShelf: selectedShelf ?? this.selectedShelf,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        shelves,
        isLoading,
        errorMessage,
        selectedShelf,
        isSubmitting,
      ];
}