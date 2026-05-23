// lib/features/stock/providers/stock_mutation_state.dart
class StockMutationState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaved;

  // Pilih bin asal
  final List<Map<String, dynamic>> bins;
  final Map<String, dynamic>? selectedBinAsal;
  final String? selectedBinAsalId;
  final List<MutationBinItem> binAsalItems;
  final MutationBinItem? selectedItem;
  final int? selectedItemIndex;
  
  // Pilih bin tujuan
  final List<Map<String, dynamic>> binsTujuan;
  final Map<String, dynamic>? selectedBinTujuan;
  final String? selectedBinTujuanId;
  
  // Form
  final double quantity;
  final String? receivedBy;
  final String? receivedByName;
  final String notes;

  StockMutationState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isSaved = false,
    this.bins = const [],
    this.selectedBinAsal,
    this.selectedBinAsalId,
    this.binAsalItems = const [],
    this.selectedItem,
    this.selectedItemIndex,
    this.binsTujuan = const [],
    this.selectedBinTujuan,
    this.selectedBinTujuanId,
    this.quantity = 0,
    this.receivedBy,
    this.receivedByName,
    this.notes = '',
  });

  bool get isValid {
    return selectedBinAsalId != null &&
        selectedBinAsalId!.isNotEmpty &&
        selectedItem != null &&
        selectedBinTujuanId != null &&
        selectedBinTujuanId!.isNotEmpty &&
        quantity > 0 &&
        quantity <= (selectedItem?.systemQuantity ?? 0);
  }

  StockMutationState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isSaved,
    List<Map<String, dynamic>>? bins,
    Map<String, dynamic>? selectedBinAsal,
    String? selectedBinAsalId,
    List<MutationBinItem>? binAsalItems,
    MutationBinItem? selectedItem,
    int? selectedItemIndex,
    List<Map<String, dynamic>>? binsTujuan,
    Map<String, dynamic>? selectedBinTujuan,
    String? selectedBinTujuanId,
    double? quantity,
    String? receivedBy,
    String? receivedByName,
    String? notes,
  }) {
    return StockMutationState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSaved: isSaved ?? this.isSaved,
      bins: bins ?? this.bins,
      selectedBinAsal: selectedBinAsal ?? this.selectedBinAsal,
      selectedBinAsalId: selectedBinAsalId ?? this.selectedBinAsalId,
      binAsalItems: binAsalItems ?? this.binAsalItems,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedItemIndex: selectedItemIndex ?? this.selectedItemIndex,
      binsTujuan: binsTujuan ?? this.binsTujuan,
      selectedBinTujuan: selectedBinTujuan ?? this.selectedBinTujuan,
      selectedBinTujuanId: selectedBinTujuanId ?? this.selectedBinTujuanId,
      quantity: quantity ?? this.quantity,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedByName: receivedByName ?? this.receivedByName,
      notes: notes ?? this.notes,
    );
  }
}

class MutationBinItem {
  final String stockInBinsId;
  final String stockId;
  final String stockName;
  final String batchNumber;
  final DateTime expiryDate;
  final double systemQuantity;
  final String unit;

  MutationBinItem({
    required this.stockInBinsId,
    required this.stockId,
    required this.stockName,
    required this.batchNumber,
    required this.expiryDate,
    required this.systemQuantity,
    required this.unit,
  });
}