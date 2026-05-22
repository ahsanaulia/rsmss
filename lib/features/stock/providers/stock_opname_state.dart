// lib/features/stock_opname/providers/stock_opname_state.dart
class StockOpnameState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaved;

  // Data untuk opname produk (existing - untuk kompatibilitas)
  final List<Map<String, dynamic>> stocks;
  final String? selectedStockId;
  final Map<String, dynamic>? selectedStock;
  final double physicalStock;
  final String opnameNote;
  final double stockBefore;

  // =====================================================
  // DATA UNTUK OPNAME PER BIN (BARU - UTAMA)
  // =====================================================
  
  // List semua bin yang tersedia (untuk dropdown)
  final List<Map<String, dynamic>> bins;
  
  // Bin yang dipilih
  final Map<String, dynamic>? selectedBin;
  final String? selectedBinId;
  
  // Items dalam bin yang dipilih (dari stock_in_bins)
  final List<BinOpnameItem> binItems;
  final String binOpnameNote; // Catatan umum untuk seluruh sesi opname bin ini
  
  // Status
  final String opnameMode; // 'PRODUCT' or 'BIN'

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
    this.bins = const [],
    this.selectedBin,
    this.selectedBinId,
    this.binItems = const [],
    this.binOpnameNote = '',
    this.opnameMode = 'BIN', // Default ke BIN
  });

  bool get isValidProductOpname {
    return selectedStockId != null &&
        selectedStockId!.isNotEmpty &&
        physicalStock >= 0;
  }

  bool get isValidBinOpname {
    return selectedBinId != null &&
        selectedBinId!.isNotEmpty &&
        binItems.isNotEmpty &&
        binItems.every((item) => item.physicalQuantity >= 0);
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
    List<Map<String, dynamic>>? bins,
    Map<String, dynamic>? selectedBin,
    String? selectedBinId,
    List<BinOpnameItem>? binItems,
    String? binOpnameNote,
    String? opnameMode,
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
      bins: bins ?? this.bins,
      selectedBin: selectedBin ?? this.selectedBin,
      selectedBinId: selectedBinId ?? this.selectedBinId,
      binItems: binItems ?? this.binItems,
      binOpnameNote: binOpnameNote ?? this.binOpnameNote,
      opnameMode: opnameMode ?? this.opnameMode,
    );
  }
}

// Model untuk item dalam bin
class BinOpnameItem {
  final String stockInBinsId;
  final String stockId;
  final String stockName;
  final String batchNumber;
  final DateTime expiryDate;
  final double systemQuantity;
  final String unit;
  double physicalQuantity;
  String? note;

  BinOpnameItem({
    required this.stockInBinsId,
    required this.stockId,
    required this.stockName,
    required this.batchNumber,
    required this.expiryDate,
    required this.systemQuantity,
    required this.unit,
    this.physicalQuantity = 0,
    this.note,
  });

  double get adjustment => physicalQuantity - systemQuantity;

  Map<String, dynamic> toMap() {
    return {
      'stock_in_bins_id': stockInBinsId,
      'stock_id': stockId,
      'stock_name': stockName,
      'batch_number': batchNumber,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'system_quantity': systemQuantity,
      'physical_quantity': physicalQuantity,
      'adjustment': adjustment,
      'unit': unit,
      'note': note,
    };
  }
}