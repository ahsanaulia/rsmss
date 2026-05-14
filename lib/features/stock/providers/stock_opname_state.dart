class StockOpnameState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaved;

  // Data
  final List<Map<String, dynamic>> stocks;
  final String? selectedStockId;
  final Map<String, dynamic>? selectedStock;

  // Form fields
  final double physicalStock;
  final String opnameNote;
  final double stockBefore;

  StockOpnameState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isSaved = false,
    this.stocks = const [],
    this.selectedStockId,
    this.selectedStock,
    this.physicalStock = 0,
    this.opnameNote = '',
    this.stockBefore = 0,
  });

  bool get isValid {
    return selectedStockId != null &&
        selectedStockId!.isNotEmpty &&
        physicalStock >= 0;
  }

  StockOpnameState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isSaved,
    List<Map<String, dynamic>>? stocks,
    String? selectedStockId,
    Map<String, dynamic>? selectedStock,
    double? physicalStock,
    String? opnameNote,
    double? stockBefore,
  }) {
    return StockOpnameState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaved: isSaved ?? this.isSaved,
      stocks: stocks ?? this.stocks,
      selectedStockId: selectedStockId ?? this.selectedStockId,
      selectedStock: selectedStock ?? this.selectedStock,
      physicalStock: physicalStock ?? this.physicalStock,
      opnameNote: opnameNote ?? this.opnameNote,
      stockBefore: stockBefore ?? this.stockBefore,
    );
  }
}