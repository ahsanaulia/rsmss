import 'dart:io';

class StockInitialState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaved;

  // Dropdown data
  final List<Map<String, dynamic>> stockTypes;
  final List<Map<String, dynamic>> storageLocations;

  // Form fields
  final String stockCode;
  final String stockName;
  final String? selectedTypeId;
  final String? selectedTypeName;
  final String unit;
  final String minimumStock;
  final String currentStock;
  final String? selectedLocationId;
  final String? selectedLocationName;
  final String stockCondition;
  final String batchNumber;
  final DateTime? expiryDate;
  final File? photo;
  final String description;

  StockInitialState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isSaved = false,
    this.stockTypes = const [],
    this.storageLocations = const [],
    this.stockCode = '',
    this.stockName = '',
    this.selectedTypeId,
    this.selectedTypeName,
    this.unit = '',
    this.minimumStock = '0',
    this.currentStock = '0',
    this.selectedLocationId,
    this.selectedLocationName,
    this.stockCondition = 'GOOD',
    this.batchNumber = '',
    this.expiryDate,
    this.photo,
    this.description = '',
  });

  bool get isValid {
    return stockCode.trim().isNotEmpty &&
        stockName.trim().isNotEmpty &&
        selectedTypeId != null &&
        unit.trim().isNotEmpty &&
        currentStock.isNotEmpty &&
        double.tryParse(currentStock) != null;
  }

  StockInitialState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isSaved,
    List<Map<String, dynamic>>? stockTypes,
    List<Map<String, dynamic>>? storageLocations,
    String? stockCode,
    String? stockName,
    String? selectedTypeId,
    String? selectedTypeName,
    String? unit,
    String? minimumStock,
    String? currentStock,
    String? selectedLocationId,
    String? selectedLocationName,
    String? stockCondition,
    String? batchNumber,
    DateTime? expiryDate,
    File? photo,
    String? description,
  }) {
    return StockInitialState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaved: isSaved ?? this.isSaved,
      stockTypes: stockTypes ?? this.stockTypes,
      storageLocations: storageLocations ?? this.storageLocations,
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      selectedTypeName: selectedTypeName ?? this.selectedTypeName,
      unit: unit ?? this.unit,
      minimumStock: minimumStock ?? this.minimumStock,
      currentStock: currentStock ?? this.currentStock,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      selectedLocationName: selectedLocationName ?? this.selectedLocationName,
      stockCondition: stockCondition ?? this.stockCondition,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      photo: photo ?? this.photo,
      description: description ?? this.description,
    );
  }
}