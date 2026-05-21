// lib/features/stock_in_entry/providers/stock_in_entry_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_in_entry_model.dart';
import '../services/stock_in_entry_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';

// ==========================================================
// PROVIDER: Auth Service (dari service_locator)
// ==========================================================

final authServiceProvider = Provider<AuthService>((ref) {
  return getIt<AuthService>();
});

// ==========================================================
// PROVIDER: Service instance
// ==========================================================

final stockInEntryServiceProvider = Provider<StockInEntryService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return StockInEntryService(authService);
});

// ==========================================================
// PROVIDER: List semua stock in entry (dengan filter)
// ==========================================================

final stockInEntryListProvider = FutureProvider.autoDispose
    .family<List<StockInEntryWithDetail>, StockInEntryFilter>(
  (ref, filter) async {
    final service = ref.watch(stockInEntryServiceProvider);
    final result = await service.getAllWithDetail(
      sourceType: filter.sourceType,
      stockId: filter.stockId,
      searchQuery: filter.searchQuery,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );
    return result;
  },
);

// ==========================================================
// PROVIDER: Single stock in entry by ID
// ==========================================================

final stockInEntryByIdProvider = FutureProvider.autoDispose
    .family<StockInEntry?, String>((ref, id) async {
  final service = ref.watch(stockInEntryServiceProvider);
  return await service.getById(id);
});

// ==========================================================
// PROVIDER: Search stock in entry
// ==========================================================

final stockInEntrySearchProvider = FutureProvider.autoDispose
    .family<List<StockInEntryWithDetail>, String>((ref, keyword) async {
  final service = ref.watch(stockInEntryServiceProvider);
  return await service.search(keyword);
});

// ==========================================================
// PROVIDER: Stock list untuk dropdown
// ==========================================================

final stockDropdownProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('stocks')
      .select('id, stock_code, stock_name, unit')
      .eq('is_active', true)
      .order('stock_code');

  return response.map((json) => {
    'id': json['id'],
    'stock_code': json['stock_code'],
    'stock_name': json['stock_name'],
    'unit': json['unit'],
    'display': '${json['stock_code']} - ${json['stock_name']} (${json['unit']})',
  }).toList();
});

// ==========================================================
// PROVIDER: Form state (untuk input)
// ==========================================================

class StockInEntryFormState {
  final StockInEntry? entry;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? selectedStockId;
  final String? selectedStockName;
  final String? selectedStockCode;

  const StockInEntryFormState({
    this.entry,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.selectedStockId,
    this.selectedStockName,
    this.selectedStockCode,
  });

  StockInEntryFormState copyWith({
    StockInEntry? entry,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? selectedStockId,
    String? selectedStockName,
    String? selectedStockCode,
  }) {
    return StockInEntryFormState(
      entry: entry ?? this.entry,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      selectedStockId: selectedStockId ?? this.selectedStockId,
      selectedStockName: selectedStockName ?? this.selectedStockName,
      selectedStockCode: selectedStockCode ?? this.selectedStockCode,
    );
  }
}

class StockInEntryFormNotifier extends StateNotifier<StockInEntryFormState> {
  final Ref _ref;

  StockInEntryFormNotifier(this._ref) : super(const StockInEntryFormState());

  StockInEntryService get _service => _ref.read(stockInEntryServiceProvider);

  void setField(String field, dynamic value) {
    final currentEntry = state.entry ?? StockInEntry.empty();
    StockInEntry newEntry;

    switch (field) {
      case 'stockId':
        newEntry = currentEntry.copyWith(stockId: value as String);
        state = state.copyWith(
          entry: newEntry,
          selectedStockId: value,
        );
        break;
      case 'stockName':
        state = state.copyWith(selectedStockName: value as String);
        break;
      case 'stockCode':
        state = state.copyWith(selectedStockCode: value as String);
        break;
      case 'quantity':
        newEntry = currentEntry.copyWith(quantity: (value as num).toDouble());
        state = state.copyWith(entry: newEntry);
        break;
      case 'batchNumber':
        newEntry = currentEntry.copyWith(batchNumber: value as String);
        state = state.copyWith(entry: newEntry);
        break;
      case 'expiryDate':
        newEntry = currentEntry.copyWith(expiryDate: value as DateTime);
        state = state.copyWith(entry: newEntry);
        break;
      case 'sourceType':
        newEntry = currentEntry.copyWith(sourceType: value as String);
        state = state.copyWith(entry: newEntry);
        break;
      case 'sourceId':
        newEntry = currentEntry.copyWith(sourceId: value as String?);
        state = state.copyWith(entry: newEntry);
        break;
      case 'receivedBinId':
        newEntry = currentEntry.copyWith(receivedBinId: value as String?);
        state = state.copyWith(entry: newEntry);
        break;
      case 'returnedBy':
        newEntry = currentEntry.copyWith(returnedBy: value as String?);
        state = state.copyWith(entry: newEntry);
        break;
      case 'returnedFromUnit':
        newEntry = currentEntry.copyWith(returnedFromUnit: value as String?);
        state = state.copyWith(entry: newEntry);
        break;
      case 'returnReason':
        newEntry = currentEntry.copyWith(returnReason: value as String?);
        state = state.copyWith(entry: newEntry);
        break;
      default:
        break;
    }
  }

  void setSelectedStock(String stockId, String stockName, String stockCode) {
    setField('stockId', stockId);
    setField('stockName', stockName);
    setField('stockCode', stockCode);
  }

  Future<bool> submit() async {
    final entry = state.entry;
    if (entry == null) {
      state = state.copyWith(error: 'Data tidak lengkap');
      return false;
    }

    if (entry.stockId.isEmpty) {
      state = state.copyWith(error: 'Pilih produk terlebih dahulu');
      return false;
    }
    if (entry.quantity <= 0) {
      state = state.copyWith(error: 'Jumlah harus lebih dari 0');
      return false;
    }
    if (entry.batchNumber.isEmpty) {
      state = state.copyWith(error: 'Batch number wajib diisi');
      return false;
    }
    if (!StockInEntryService.isExpiryValid(entry.expiryDate)) {
      state = state.copyWith(error: 'Expiry date minimal 90 hari dari sekarang');
      return false;
    }

    if (entry.sourceType == 'PURCHASE') {
      final exists = await _service.isBatchNumberExists(
        entry.stockId,
        entry.batchNumber,
      );
      if (exists) {
        state = state.copyWith(
          error: 'Batch number sudah pernah digunakan untuk produk ini',
        );
        return false;
      }
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final entryNumber = await _service.generateEntryNumber();
      final finalEntry = entry.copyWith(entryNumber: entryNumber);
      await _service.insert(finalEntry);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Gagal menyimpan: $e');
      return false;
    }
  }

  void reset() {
    state = const StockInEntryFormState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final stockInEntryFormProvider = StateNotifierProvider<StockInEntryFormNotifier, StockInEntryFormState>(
  (ref) => StockInEntryFormNotifier(ref),
);

// ==========================================================
// PROVIDER: Summary / Dashboard
// ==========================================================

// final stockInEntrySummaryProvider = FutureProvider.autoDispose((ref) async {
//   final service = ref.watch(stockInEntryServiceProvider);
//   final allData = await service.getAllWithDetail();

//   final totalPurchase = allData
//       .where((item) => item.entry.sourceType == 'PURCHASE')
//       .fold<double>(0, (sum, item) => sum + item.entry.quantity);

//   final totalReturn = allData
//       .where((item) => item.entry.sourceType == 'RETURN')
//       .fold<double>(0, (sum, item) => sum + item.entry.quantity);

//   final totalDonation = allData
//       .where((item) => item.entry.sourceType == 'DONATION')
//       .fold<double>(0, (sum, item) => sum + item.entry.quantity);

//   return {
//     'totalEntries': allData.length,
//     'totalPurchase': totalPurchase,
//     'totalReturn': totalReturn,
//     'totalDonation': totalDonation,
//     'todayEntries': allData.where((item) {
//       final today = DateTime.now();
//       return item.entry.entryDate.year == today.year &&
//           item.entry.entryDate.month == today.month &&
//           item.entry.entryDate.day == today.day;
//     }).length,
//   };
// });

// ==========================================================
// FILTER MODEL
// ==========================================================

class StockInEntryFilter {
  final String? sourceType;
  final String? stockId;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const StockInEntryFilter({
    this.sourceType,
    this.stockId,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  StockInEntryFilter copyWith({
    String? sourceType,
    String? stockId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StockInEntryFilter(
      sourceType: sourceType ?? this.sourceType,
      stockId: stockId ?? this.stockId,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get isEmpty => sourceType == null &&
      stockId == null &&
      searchQuery == null &&
      startDate == null &&
      endDate == null;

  Map<String, dynamic> toJson() {
    return {
      if (sourceType != null) 'sourceType': sourceType,
      if (stockId != null) 'stockId': stockId,
      if (searchQuery != null) 'searchQuery': searchQuery,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
    };
  }
}