// File: lib/insights/stocks/providers/storage_distribution_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_distribution_realtime_service.dart';
import '../models/storage_summary_model.dart';
import '../models/storage_bin_model.dart';
import '../models/storage_hierarchy_model.dart';
import '../models/storage_trend_model.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

final storageDistributionRealtimeServiceProvider = Provider<StorageDistributionRealtimeService>((ref) {
  return StorageDistributionRealtimeService();
});

// ============================================================
// REALTIME STREAM PROVIDERS
// ============================================================

final realtimeStorageSummaryProvider = StreamProvider<StorageSummaryModel>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchSummary();
});

final realtimeDistributionPerWarehouseProvider = StreamProvider<Map<String, int>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchDistributionPerWarehouse();
});

final realtimeTopBinsByStockQtyProvider = StreamProvider<List<StorageTopBinModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchTopBinsByStockQty();
});

final realtimeTopUtilizedBinsProvider = StreamProvider<List<StorageTopBinModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchTopUtilizedBins();
});

final realtimeMostFulfilledBinsProvider = StreamProvider<List<StorageTopBinModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchMostFulfilledBins();
});

final realtimeExpiringStockProvider = StreamProvider<List<StockExpiryModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchExpiringStock();
});

final realtimeStockInSourceProvider = StreamProvider<List<StockInSourceModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchStockInSourceDistribution();
});

final realtimeStockInTrendProvider = StreamProvider<List<StorageTrendModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchStockInTrend();
});

final realtimeStorageHierarchyProvider = StreamProvider<List<StorageWarehouseModel>>((ref) {
  final service = ref.watch(storageDistributionRealtimeServiceProvider);
  return service.watchStorageHierarchy();
});

// ============================================================
// COMBINED STATE
// ============================================================

final storageDistributionRealtimeStateProvider = Provider<StorageDistributionRealtimeState>((ref) {
  final summaryAsync = ref.watch(realtimeStorageSummaryProvider);
  final distributionAsync = ref.watch(realtimeDistributionPerWarehouseProvider);
  final topBinsQtyAsync = ref.watch(realtimeTopBinsByStockQtyProvider);
  final topUtilizedAsync = ref.watch(realtimeTopUtilizedBinsProvider);
  final mostFulfilledAsync = ref.watch(realtimeMostFulfilledBinsProvider);
  final expiringAsync = ref.watch(realtimeExpiringStockProvider);
  final sourceAsync = ref.watch(realtimeStockInSourceProvider);
  final trendAsync = ref.watch(realtimeStockInTrendProvider);
  final hierarchyAsync = ref.watch(realtimeStorageHierarchyProvider);

  final summary = summaryAsync.valueOrNull ?? StorageSummaryModel.empty();
  final distribution = distributionAsync.valueOrNull ?? {};
  final topBinsByQty = topBinsQtyAsync.valueOrNull ?? [];
  final topUtilizedBins = topUtilizedAsync.valueOrNull ?? [];
  final mostFulfilledBins = mostFulfilledAsync.valueOrNull ?? [];
  final expiringStock = expiringAsync.valueOrNull ?? [];
  final stockInSource = sourceAsync.valueOrNull ?? [];
  final stockInTrend = trendAsync.valueOrNull ?? [];
  final storageHierarchy = hierarchyAsync.valueOrNull ?? [];

  final isLoading = 
      summaryAsync.isLoading ||
      distributionAsync.isLoading ||
      topBinsQtyAsync.isLoading ||
      topUtilizedAsync.isLoading ||
      mostFulfilledAsync.isLoading ||
      expiringAsync.isLoading ||
      sourceAsync.isLoading ||
      trendAsync.isLoading ||
      hierarchyAsync.isLoading;

  final errors = <String>[];
  if (summaryAsync.hasError) errors.add('summary');
  if (distributionAsync.hasError) errors.add('distribution');
  if (topBinsQtyAsync.hasError) errors.add('topBinsQty');
  if (topUtilizedAsync.hasError) errors.add('topUtilized');
  if (mostFulfilledAsync.hasError) errors.add('mostFulfilled');
  if (expiringAsync.hasError) errors.add('expiring');
  if (sourceAsync.hasError) errors.add('source');
  if (trendAsync.hasError) errors.add('trend');
  if (hierarchyAsync.hasError) errors.add('hierarchy');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return StorageDistributionRealtimeState(
    summary: summary,
    distribution: distribution,
    topBinsByQty: topBinsByQty,
    topUtilizedBins: topUtilizedBins,
    mostFulfilledBins: mostFulfilledBins,
    expiringStock: expiringStock,
    stockInSource: stockInSource,
    stockInTrend: stockInTrend,
    storageHierarchy: storageHierarchy,
    isLoading: isLoading && summary.totalBins == 0,
    errorMessage: errorMessage,
  );
});

// ============================================================
// STATE MODEL
// ============================================================

class StorageDistributionRealtimeState {
  final StorageSummaryModel summary;
  final Map<String, int> distribution;
  final List<StorageTopBinModel> topBinsByQty;
  final List<StorageTopBinModel> topUtilizedBins;
  final List<StorageTopBinModel> mostFulfilledBins;
  final List<StockExpiryModel> expiringStock;
  final List<StockInSourceModel> stockInSource;
  final List<StorageTrendModel> stockInTrend;
  final List<StorageWarehouseModel> storageHierarchy;
  final bool isLoading;
  final String? errorMessage;

  StorageDistributionRealtimeState({
    required this.summary,
    required this.distribution,
    required this.topBinsByQty,
    required this.topUtilizedBins,
    required this.mostFulfilledBins,
    required this.expiringStock,
    required this.stockInSource,
    required this.stockInTrend,
    required this.storageHierarchy,
    this.isLoading = true,
    this.errorMessage,
  });
}

// ============================================================
// SELECTORS UNTUK VIEW
// ============================================================

final storageDistributionSummaryProvider = Provider<StorageSummaryModel>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).summary;
});

final storageDistributionPerWarehouseProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).distribution;
});

final storageTopBinsByQtyProvider = Provider<List<StorageTopBinModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).topBinsByQty;
});

final storageTopUtilizedBinsProvider = Provider<List<StorageTopBinModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).topUtilizedBins;
});

final storageMostFulfilledBinsProvider = Provider<List<StorageTopBinModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).mostFulfilledBins;
});

final storageExpiringStockProvider = Provider<List<StockExpiryModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).expiringStock;
});

final storageStockInSourceProvider = Provider<List<StockInSourceModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).stockInSource;
});

final storageStockInTrendProvider = Provider<List<StorageTrendModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).stockInTrend;
});

final storageHierarchyProvider = Provider<List<StorageWarehouseModel>>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).storageHierarchy;
});

final isStorageDistributionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).isLoading;
});

final storageDistributionErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(storageDistributionRealtimeStateProvider).errorMessage;
});