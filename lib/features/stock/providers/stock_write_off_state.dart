// lib/features/stock/providers/stock_write_off_state.dart
class StockWriteOffState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaved;

  final List<Map<String, dynamic>> bins;
  final Map<String, dynamic>? selectedBin;
  final String? selectedBinId;
  final List<WriteOffBinItem> binItems;
  final WriteOffBinItem? selectedItem;
  final int? selectedItemIndex;
  final double quantity;
  final String reason;
  final String reasonNote;
  final String notes;
  final String? photoUrl;

  StockWriteOffState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isSaved = false,
    this.bins = const [],
    this.selectedBin,
    this.selectedBinId,
    this.binItems = const [],
    this.selectedItem,
    this.selectedItemIndex,
    this.quantity = 0,
    this.reason = 'EXPIRED',
    this.reasonNote = '',
    this.notes = '',
    this.photoUrl,
  });

  bool get isValid {
    return selectedBinId != null &&
        selectedBinId!.isNotEmpty &&
        selectedItem != null &&
        quantity > 0 &&
        quantity <= (selectedItem?.systemQuantity ?? 0);
  }

  StockWriteOffState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isSaved,
    List<Map<String, dynamic>>? bins,
    Map<String, dynamic>? selectedBin,
    String? selectedBinId,
    List<WriteOffBinItem>? binItems,
    WriteOffBinItem? selectedItem,
    int? selectedItemIndex,
    double? quantity,
    String? reason,
    String? reasonNote,
    String? notes,
    String? photoUrl,
  }) {
    return StockWriteOffState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaved: isSaved ?? this.isSaved,
      bins: bins ?? this.bins,
      selectedBin: selectedBin ?? this.selectedBin,
      selectedBinId: selectedBinId ?? this.selectedBinId,
      binItems: binItems ?? this.binItems,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedItemIndex: selectedItemIndex ?? this.selectedItemIndex,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      reasonNote: reasonNote ?? this.reasonNote,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class WriteOffBinItem {
  final String stockInBinsId;
  final String stockId;
  final String stockName;
  final String batchNumber;
  final DateTime expiryDate;
  final double systemQuantity;
  final String unit;

  WriteOffBinItem({
    required this.stockInBinsId,
    required this.stockId,
    required this.stockName,
    required this.batchNumber,
    required this.expiryDate,
    required this.systemQuantity,
    required this.unit,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
}