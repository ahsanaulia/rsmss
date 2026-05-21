// lib/features/stock_in_bins/providers/stock_in_bins_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_in_bins_model.dart';
import '../services/stock_in_bins_service.dart';
import '../../stock_in/models/stock_in_model.dart';

void _debugProvider(String tag, dynamic data) {
  final timestamp = DateTime.now().toIso8601String();
  print('[$timestamp] [STOCK_IN_BINS_PROVIDER][$tag] $data');
}

final stockInBinsServiceProvider = Provider<StockInBinsService>((ref) {
  _debugProvider('stockInBinsServiceProvider', 'Initializing');
  return StockInBinsService();
});

// List semua put away
final stockInBinsListProvider = FutureProvider<List<StockInBinsModel>>((ref) async {
  _debugProvider('stockInBinsListProvider', 'Fetching all...');
  final service = ref.read(stockInBinsServiceProvider);
  final result = await service.getAllStockInBins();
  _debugProvider('stockInBinsListProvider', 'Fetched ${result.length} items');
  return result;
});

// List bins untuk dropdown
final allBinsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _debugProvider('allBinsProvider', 'Fetching bins...');
  final service = ref.read(stockInBinsServiceProvider);
  final result = await service.getAllBins();
  _debugProvider('allBinsProvider', 'Fetched ${result.length} bins');
  return result;
});

// List pending stock_in (RECEIVED atau PARTIALLY_PUT_AWAY)
final pendingStockInProvider = FutureProvider<List<StockInModel>>((ref) async {
  _debugProvider('pendingStockInProvider', 'Fetching pending...');
  final service = ref.read(stockInBinsServiceProvider);
  final result = await service.getPendingStockIn();
  _debugProvider('pendingStockInProvider', 'Fetched ${result.length} pending');
  return result;
});

// Detail pending stock_in (dengan remaining quantity) - di-cache agar tidak terus2an fetch
final pendingStockInDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, stockInId) async {
  _debugProvider('pendingStockInDetailProvider', 'Fetching detail for: $stockInId');
  final service = ref.read(stockInBinsServiceProvider);
  final result = await service.getPendingStockInDetail(stockInId);
  _debugProvider('pendingStockInDetailProvider', 'Remaining: ${result['remaining']}');
  return result;
});

// =====================================================
// NOTIFIER PROVIDER untuk state management yang lebih baik
// =====================================================
class PendingStockInNotifier extends StateNotifier<AsyncValue<List<StockInModel>>> {
  final Ref _ref;
  
  PendingStockInNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadPending();
  }
  
  Future<void> _loadPending() async {
    try {
      state = const AsyncValue.loading();
      final service = _ref.read(stockInBinsServiceProvider);
      final result = await service.getPendingStockIn();
      state = AsyncValue.data(result);
      _debugProvider('Notifier', 'Loaded ${result.length} items');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      _debugProvider('Notifier', 'Error: $e');
    }
  }
  
  Future<void> refresh() async {
    _debugProvider('Notifier', 'Refreshing...');
    await _loadPending();
  }
  
  Future<void> createPutAway(StockInBinsModel putAway) async {
    try {
      final service = _ref.read(stockInBinsServiceProvider);
      await service.createPutAway(putAway);
      
      // Refresh semua terkait
      _ref.invalidate(stockInBinsListProvider);
      _ref.invalidate(pendingStockInProvider);
      if (putAway.stockInId != null) {
        _ref.invalidate(pendingStockInDetailProvider(putAway.stockInId!));
      }
      
      // Reload pending list
      await _loadPending();
      
      _debugProvider('Notifier', 'Put away created, refreshed');
    } catch (e) {
      _debugProvider('Notifier', 'Error creating put away: $e');
      rethrow;
    }
  }
}

final pendingStockInNotifierProvider = StateNotifierProvider<PendingStockInNotifier, AsyncValue<List<StockInModel>>>((ref) {
  return PendingStockInNotifier(ref);
});

// Controller untuk operasi CRUD
class StockInBinsController {
  final Ref ref;
  
  StockInBinsController(this.ref);
  
  Future<StockInBinsModel> createPutAway(StockInBinsModel putAway) async {
    _debugProvider('createPutAway', 'Creating...');
    final service = ref.read(stockInBinsServiceProvider);
    final result = await service.createPutAway(putAway);
    _debugProvider('createPutAway', '✅ Created with ID: ${result.id}');
    
    // Refresh semua provider
    ref.invalidate(stockInBinsListProvider);
    ref.invalidate(pendingStockInProvider);
    // Refresh notifier juga
    final notifier = ref.read(pendingStockInNotifierProvider.notifier);
    await notifier.refresh();
    
    if (putAway.stockInId != null) {
      ref.invalidate(pendingStockInDetailProvider(putAway.stockInId!));
    }
    
    return result;
  }
  
  Future<void> deletePutAway(String id, String? stockInId) async {
    _debugProvider('deletePutAway', 'Deleting ID: $id');
    final service = ref.read(stockInBinsServiceProvider);
    await service.deletePutAway(id);
    _debugProvider('deletePutAway', '✅ Deleted');
    
    ref.invalidate(stockInBinsListProvider);
    ref.invalidate(pendingStockInProvider);
    final notifier = ref.read(pendingStockInNotifierProvider.notifier);
    await notifier.refresh();
    
    if (stockInId != null) {
      ref.invalidate(pendingStockInDetailProvider(stockInId));
    }
  }
  
  Future<Map<String, dynamic>?> scanBin(String barcode) async {
    _debugProvider('scanBin', 'Scanning: $barcode');
    final service = ref.read(stockInBinsServiceProvider);
    return await service.scanBinByBarcode(barcode);
  }
}

final stockInBinsControllerProvider = Provider<StockInBinsController>((ref) {
  return StockInBinsController(ref);
});