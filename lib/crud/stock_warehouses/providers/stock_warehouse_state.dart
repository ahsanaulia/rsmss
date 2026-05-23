import 'package:equatable/equatable.dart';
import 'package:rsmss/crud/stock_warehouses/models/stock_warehouse_model.dart';

class StockWarehouseState extends Equatable {
  final List<StockWarehouseModel> warehouses;
  final bool isLoading;
  final String? errorMessage;
  final StockWarehouseModel? selectedWarehouse;
  final bool isSubmitting;

  const StockWarehouseState({
    this.warehouses = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedWarehouse,
    this.isSubmitting = false,
  });

  factory StockWarehouseState.initial() {
    return const StockWarehouseState();
  }

  factory StockWarehouseState.loading() {
    return const StockWarehouseState(isLoading: true);
  }

  StockWarehouseState copyWith({
    List<StockWarehouseModel>? warehouses,
    bool? isLoading,
    String? errorMessage,
    StockWarehouseModel? selectedWarehouse,
    bool? isSubmitting,
  }) {
    return StockWarehouseState(
      warehouses: warehouses ?? this.warehouses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedWarehouse: selectedWarehouse ?? this.selectedWarehouse,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        warehouses,
        isLoading,
        errorMessage,
        selectedWarehouse,
        isSubmitting,
      ];
}