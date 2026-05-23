import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/stock_bins/models/stock_bin_model.dart';

class StockBinState extends Equatable {
  final List<StockBinModel> bins;
  final bool isLoading;
  final String? errorMessage;
  final StockBinModel? selectedBin;
  final bool isSubmitting;

  const StockBinState({
    this.bins = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedBin,
    this.isSubmitting = false,
  });

  factory StockBinState.initial() {
    return const StockBinState();
  }

  factory StockBinState.loading() {
    return const StockBinState(isLoading: true);
  }

  StockBinState copyWith({
    List<StockBinModel>? bins,
    bool? isLoading,
    String? errorMessage,
    StockBinModel? selectedBin,
    bool? isSubmitting,
  }) {
    return StockBinState(
      bins: bins ?? this.bins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedBin: selectedBin ?? this.selectedBin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        bins,
        isLoading,
        errorMessage,
        selectedBin,
        isSubmitting,
      ];
}