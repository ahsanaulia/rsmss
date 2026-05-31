// File: lib/insights/stocks/providers/storage_hierarchy_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_hierarchy_realtime_service.dart';
import '../models/storage_hierarchy_model.dart';
import '../models/bin_stock_detail_model.dart';

final storageHierarchyRealtimeServiceProvider = Provider<StorageHierarchyRealtimeService>((ref) {
  return StorageHierarchyRealtimeService();
});

final realtimeStorageHierarchyProvider = StreamProvider<List<StorageWarehouseModel>>((ref) {
  final service = ref.watch(storageHierarchyRealtimeServiceProvider);
  return service.watchStorageHierarchy();
});

final storageHierarchyStateProvider = Provider<AsyncValue<List<StorageWarehouseModel>>>((ref) {
  return ref.watch(realtimeStorageHierarchyProvider);
});

// Future provider untuk bin detail (TIDAK REALTIME)
final binStockDetailsProvider = FutureProvider.family<List<BinStockDetailModel>, String>((ref, binId) async {
  final service = ref.watch(storageHierarchyRealtimeServiceProvider);
  return await service.getStockDetailsByBinId(binId);
});