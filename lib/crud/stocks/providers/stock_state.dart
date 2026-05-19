// ============================================================
// STOCK STATE
// ============================================================
// TANGGUNG JAWAB:
// 1. Mendefinisikan semua state class untuk Stock management
// 2. Memisahkan state dari logic (separation of concerns)
// 3. Digunakan oleh stock_providers.dart
// ============================================================

import '../models/stock_model.dart';

// ============================================================
// STATE UNTUK STOCK LIST PAGE
// ============================================================

/// State untuk halaman daftar stok
class StockListState {
  final List<Stock> stocks;
  final bool isLoading;
  final String? error;
  final String? searchKeyword;
  final String? filterCondition;  // GOOD, LOW, empty, low_stock

  const StockListState({
    this.stocks = const [],
    this.isLoading = false,
    this.error,
    this.searchKeyword,
    this.filterCondition,
  });

  StockListState copyWith({
    List<Stock>? stocks,
    bool? isLoading,
    String? error,
    String? searchKeyword,
    String? filterCondition,
  }) {
    return StockListState(
      stocks: stocks ?? this.stocks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      filterCondition: filterCondition ?? this.filterCondition,
    );
  }

  @override
  String toString() {
    return 'StockListState(stocks: ${stocks.length}, isLoading: $isLoading, error: $error)';
  }
}

// ============================================================
// STATE UNTUK STOCK DETAIL PAGE
// ============================================================

/// State untuk halaman detail stok
class StockDetailState {
  final Stock? stock;
  final bool isLoading;
  final String? error;

  const StockDetailState({
    this.stock,
    this.isLoading = false,
    this.error,
  });

  StockDetailState copyWith({
    Stock? stock,
    bool? isLoading,
    String? error,
  }) {
    return StockDetailState(
      stock: stock ?? this.stock,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'StockDetailState(stockId: ${stock?.id}, isLoading: $isLoading, error: $error)';
  }
}

// ============================================================
// STATE UNTUK STOCK FORM (CREATE/EDIT)
// ============================================================

/// Data untuk dropdown stock type
class StockTypeDropdownData {
  final String id;
  final String typeName;
  final String? description;

  const StockTypeDropdownData({
    required this.id,
    required this.typeName,
    this.description,
  });

  factory StockTypeDropdownData.fromJson(Map<String, dynamic> json) {
    return StockTypeDropdownData(
      id: json['id'] as String,
      typeName: json['type_name'] as String,
      description: json['description'] as String?,
    );
  }
}

/// Data untuk dropdown storage location
class StorageLocationDropdownData {
  final String id;
  final String locationName;
  final String? locationCode;

  const StorageLocationDropdownData({
    required this.id,
    required this.locationName,
    this.locationCode,
  });

  factory StorageLocationDropdownData.fromJson(Map<String, dynamic> json) {
    return StorageLocationDropdownData(
      id: json['id'] as String,
      locationName: json['location_name'] as String,
      locationCode: json['location_code'] as String?,
    );
  }

  String get displayName {
    if (locationCode != null && locationCode!.isNotEmpty) {
      return '$locationCode - $locationName';
    }
    return locationName;
  }
}

/// State untuk form stok (create/edit)
class StockFormState {
  final Stock stock;
  final bool isLoading;
  final String? error;
  final bool isEditing;
  
  // Data untuk dropdown
  final List<StockTypeDropdownData> stockTypes;
  final List<StorageLocationDropdownData> storageLocations;
  
  // Loading status untuk dropdown
  final bool isLoadingTypes;
  final bool isLoadingLocations;

  const StockFormState({
    required this.stock,
    this.isLoading = false,
    this.error,
    this.isEditing = false,
    this.stockTypes = const [],
    this.storageLocations = const [],
    this.isLoadingTypes = false,
    this.isLoadingLocations = false,
  });

  StockFormState copyWith({
    Stock? stock,
    bool? isLoading,
    String? error,
    bool? isEditing,
    List<StockTypeDropdownData>? stockTypes,
    List<StorageLocationDropdownData>? storageLocations,
    bool? isLoadingTypes,
    bool? isLoadingLocations,
  }) {
    return StockFormState(
      stock: stock ?? this.stock,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      stockTypes: stockTypes ?? this.stockTypes,
      storageLocations: storageLocations ?? this.storageLocations,
      isLoadingTypes: isLoadingTypes ?? this.isLoadingTypes,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
    );
  }

  @override
  String toString() {
    return 'StockFormState(stockName: ${stock.stockName}, isLoading: $isLoading, error: $error)';
  }
}