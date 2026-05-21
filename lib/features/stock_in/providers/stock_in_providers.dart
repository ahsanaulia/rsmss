// lib/features/stock_in/providers/stock_in_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_in_model.dart';
import '../services/stock_in_service.dart';

// Debug helper
void _debugProvider(String tag, dynamic data) {
  final timestamp = DateTime.now().toIso8601String();
  print('[$timestamp] [STOCK_IN_PROVIDER][$tag] $data');
}

// Service provider (singleton)
final stockInServiceProvider = Provider<StockInService>((ref) {
  _debugProvider('stockInServiceProvider', 'Initializing StockInService');
  return StockInService();
});

// State untuk form (data sementara sebelum submit)
final stockInFormProvider = StateProvider<StockInModel?>((ref) {
  _debugProvider('stockInFormProvider', 'Initialized');
  return null;
});

// State untuk list semua stock_in
final stockInListProvider = FutureProvider<List<StockInModel>>((ref) async {
  _debugProvider('stockInListProvider', 'Fetching all stock_in...');
  final service = ref.read(stockInServiceProvider);
  final result = await service.getAllStockIn();
  _debugProvider('stockInListProvider', 'Fetched ${result.length} items');
  return result;
});

// State untuk list stock_in berdasarkan status
final stockInByStatusProvider = FutureProvider.family<List<StockInModel>, String>((ref, status) async {
  _debugProvider('stockInByStatusProvider', 'Fetching stock_in with status: $status');
  final service = ref.read(stockInServiceProvider);
  final result = await service.getAllStockIn(status: status);
  _debugProvider('stockInByStatusProvider', 'Fetched ${result.length} items for status: $status');
  return result;
});

// State untuk list pending put away
final pendingPutAwayProvider = FutureProvider<List<StockInModel>>((ref) async {
  _debugProvider('pendingPutAwayProvider', 'Fetching pending put away...');
  final service = ref.read(stockInServiceProvider);
  final result = await service.getPendingPutAway();
  _debugProvider('pendingPutAwayProvider', 'Fetched ${result.length} pending items');
  return result;
});

// State untuk list completed put away
final completedPutAwayProvider = FutureProvider<List<StockInModel>>((ref) async {
  _debugProvider('completedPutAwayProvider', 'Fetching completed put away...');
  final service = ref.read(stockInServiceProvider);
  final result = await service.getCompletedPutAway();
  _debugProvider('completedPutAwayProvider', 'Fetched ${result.length} completed items');
  return result;
});

// State untuk detail stock_in by id
final stockInDetailProvider = FutureProvider.family<StockInModel?, String>((ref, id) async {
  _debugProvider('stockInDetailProvider', 'Fetching detail for ID: $id');
  final service = ref.read(stockInServiceProvider);
  final result = await service.getStockInById(id);
  _debugProvider('stockInDetailProvider', 'Detail fetched for ID: $id, found: ${result != null}');
  return result;
});

// State untuk dropdown stocks
final availableStocksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _debugProvider('availableStocksProvider', 'Fetching available stocks...');
  final service = ref.read(stockInServiceProvider);
  final result = await service.getAvailableStocks();
  _debugProvider('availableStocksProvider', 'Fetched ${result.length} stocks');
  return result;
});

// Controller untuk create/update/delete
class StockInController {
  final Ref ref;
  
  StockInController(this.ref);
  
  Future<StockInModel> createStockIn(StockInModel stockIn) async {
    _debugProvider('createStockIn', 'Creating new stock_in...');
    final service = ref.read(stockInServiceProvider);
    final result = await service.createStockIn(stockIn);
    _debugProvider('createStockIn', '✅ Created with ID: ${result.id}');
    
    // Refresh list setelah create
    ref.invalidate(stockInListProvider);
    ref.invalidate(pendingPutAwayProvider);
    ref.invalidate(completedPutAwayProvider);
    ref.invalidate(stockInByStatusProvider);
    _debugProvider('createStockIn', 'Providers invalidated');
    
    return result;
  }
  
  Future<StockInModel> updateStockIn(StockInModel stockIn) async {
    _debugProvider('updateStockIn', 'Updating stock_in ID: ${stockIn.id}');
    final service = ref.read(stockInServiceProvider);
    final result = await service.updateStockIn(stockIn);
    _debugProvider('updateStockIn', '✅ Updated stock_in ID: ${result.id}');
    
    // Refresh list dan detail
    ref.invalidate(stockInListProvider);
    ref.invalidate(pendingPutAwayProvider);
    ref.invalidate(completedPutAwayProvider);
    ref.invalidate(stockInByStatusProvider);
    if (stockIn.id != null) {
      ref.invalidate(stockInDetailProvider(stockIn.id!));
    }
    _debugProvider('updateStockIn', 'Providers invalidated');
    
    return result;
  }
  
  Future<void> deleteStockIn(String id) async {
    _debugProvider('deleteStockIn', 'Deleting stock_in ID: $id');
    final service = ref.read(stockInServiceProvider);
    await service.deleteStockIn(id);
    _debugProvider('deleteStockIn', '✅ Deleted stock_in ID: $id');
    
    // Refresh list
    ref.invalidate(stockInListProvider);
    ref.invalidate(pendingPutAwayProvider);
    ref.invalidate(completedPutAwayProvider);
    ref.invalidate(stockInByStatusProvider);
    _debugProvider('deleteStockIn', 'Providers invalidated');
  }
  
  Future<void> updateStatus(String id, String status) async {
    _debugProvider('updateStatus', 'Updating status for ID: $id to $status');
    final service = ref.read(stockInServiceProvider);
    await service.updateStatus(id, status);
    _debugProvider('updateStatus', '✅ Status updated for ID: $id');
    
    // Refresh list dan detail
    ref.invalidate(stockInListProvider);
    ref.invalidate(pendingPutAwayProvider);
    ref.invalidate(completedPutAwayProvider);
    ref.invalidate(stockInByStatusProvider);
    ref.invalidate(stockInDetailProvider(id));
    _debugProvider('updateStatus', 'Providers invalidated');
  }
  
  Future<String> generateReceiptNumber() async {
    _debugProvider('generateReceiptNumber', 'Generating receipt number...');
    final service = ref.read(stockInServiceProvider);
    final result = await service.generateReceiptNumber();
    _debugProvider('generateReceiptNumber', 'Generated: $result');
    return result;
  }
}

final stockInControllerProvider = Provider<StockInController>((ref) {
  _debugProvider('stockInControllerProvider', 'Initializing StockInController');
  return StockInController(ref);
});