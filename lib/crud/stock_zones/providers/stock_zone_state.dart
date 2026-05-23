import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/stock_zones/models/stock_zone_model.dart';

class StockZoneState extends Equatable {
  final List<StockZoneModel> zones;
  final bool isLoading;
  final String? errorMessage;
  final StockZoneModel? selectedZone;
  final bool isSubmitting;

  const StockZoneState({
    this.zones = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedZone,
    this.isSubmitting = false,
  });

  factory StockZoneState.initial() {
    return const StockZoneState();
  }

  factory StockZoneState.loading() {
    return const StockZoneState(isLoading: true);
  }

  StockZoneState copyWith({
    List<StockZoneModel>? zones,
    bool? isLoading,
    String? errorMessage,
    StockZoneModel? selectedZone,
    bool? isSubmitting,
  }) {
    return StockZoneState(
      zones: zones ?? this.zones,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedZone: selectedZone ?? this.selectedZone,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        zones,
        isLoading,
        errorMessage,
        selectedZone,
        isSubmitting,
      ];
}