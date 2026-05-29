// File: lib/insights/stocks/providers/stock_overview_providers.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_realtime_service.dart';
import '../models/stock_summary_model.dart';
import '../models/stock_trend_model.dart';
import '../models/stock_prediction_model.dart';
import '../models/stock_velocity_model.dart';
import '../models/stock_expiry_model.dart';
import '../models/stock_slow_moving_model.dart';
import '../models/stock_category_value_model.dart';
import '../models/stock_storage_model.dart';
import '../models/stock_discrepancy_model.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

final stockRealtimeServiceProvider = Provider<StockRealtimeService>((ref) {
  return StockRealtimeService();
});

// ============================================================
// REALTIME STREAM PROVIDERS
// ============================================================

final realtimeSummaryProvider = StreamProvider<StockSummaryModel>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchSummary();
});

final realtimeCategoryDistributionProvider = StreamProvider<Map<String, int>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchCategoryDistribution();
});

final realtimeTrendProvider = StreamProvider<List<StockTrendModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchStockTrend();
});

final realtimePredictionProvider = StreamProvider<List<StockPredictionModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchStockOutPrediction();
});

final realtimeTopVelocityProvider = StreamProvider<List<StockVelocityModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchTopVelocity();
});

final realtimeExpiryProvider = StreamProvider<List<StockExpiryModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchExpiryAlert();
});

final realtimeSlowMovingProvider = StreamProvider<List<StockSlowMovingModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchSlowMovingStock();
});

final realtimeCategoryValueProvider = StreamProvider<List<StockCategoryValueModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchStockValuePerCategory();
});

final realtimeStorageDistributionProvider = StreamProvider<List<StockStorageModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchStorageDistribution();
});

final realtimeTopDiscrepancyProvider = StreamProvider<List<StockDiscrepancyModel>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchTopDiscrepancy();
});

// ============================================================
// LOW STOCK & EMPTY STOCK - REALTIME (BARU)
// ============================================================

final realtimeLowStockProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchLowStock();
});

final realtimeEmptyStockProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(stockRealtimeServiceProvider);
  return service.watchEmptyStock();
});

// ============================================================
// COMBINED STATE
// ============================================================

final stockOverviewRealtimeStateProvider = Provider<StockOverviewRealtimeState>((ref) {
  final summary = ref.watch(realtimeSummaryProvider).valueOrNull ?? StockSummaryModel.empty();
  final categoryDistribution = ref.watch(realtimeCategoryDistributionProvider).valueOrNull ?? <String, int>{};
  final trend = ref.watch(realtimeTrendProvider).valueOrNull ?? <StockTrendModel>[];
  final predictions = ref.watch(realtimePredictionProvider).valueOrNull ?? <StockPredictionModel>[];
  final topVelocity = ref.watch(realtimeTopVelocityProvider).valueOrNull ?? <StockVelocityModel>[];
  final expiryAlert = ref.watch(realtimeExpiryProvider).valueOrNull ?? <StockExpiryModel>[];
  final slowMoving = ref.watch(realtimeSlowMovingProvider).valueOrNull ?? <StockSlowMovingModel>[];
  final categoryValues = ref.watch(realtimeCategoryValueProvider).valueOrNull ?? <StockCategoryValueModel>[];
  final storageDistribution = ref.watch(realtimeStorageDistributionProvider).valueOrNull ?? <StockStorageModel>[];
  final topDiscrepancy = ref.watch(realtimeTopDiscrepancyProvider).valueOrNull ?? <StockDiscrepancyModel>[];
  final lowStock = ref.watch(realtimeLowStockProvider).valueOrNull ?? <Map<String, dynamic>>[];
  final emptyStock = ref.watch(realtimeEmptyStockProvider).valueOrNull ?? <Map<String, dynamic>>[];

  final isLoading = 
      ref.watch(realtimeSummaryProvider).isLoading &&
      ref.watch(realtimeCategoryDistributionProvider).isLoading &&
      ref.watch(realtimeTrendProvider).isLoading &&
      ref.watch(realtimePredictionProvider).isLoading &&
      ref.watch(realtimeTopVelocityProvider).isLoading &&
      ref.watch(realtimeExpiryProvider).isLoading &&
      ref.watch(realtimeSlowMovingProvider).isLoading &&
      ref.watch(realtimeCategoryValueProvider).isLoading &&
      ref.watch(realtimeStorageDistributionProvider).isLoading &&
      ref.watch(realtimeTopDiscrepancyProvider).isLoading;

  final errors = <String>[];
  if (ref.watch(realtimeSummaryProvider).hasError) errors.add('summary');
  if (ref.watch(realtimeCategoryDistributionProvider).hasError) errors.add('category');
  if (ref.watch(realtimeTrendProvider).hasError) errors.add('trend');
  if (ref.watch(realtimePredictionProvider).hasError) errors.add('prediction');
  if (ref.watch(realtimeTopVelocityProvider).hasError) errors.add('velocity');
  if (ref.watch(realtimeExpiryProvider).hasError) errors.add('expiry');
  if (ref.watch(realtimeSlowMovingProvider).hasError) errors.add('slowMoving');
  if (ref.watch(realtimeCategoryValueProvider).hasError) errors.add('categoryValue');
  if (ref.watch(realtimeStorageDistributionProvider).hasError) errors.add('storage');
  if (ref.watch(realtimeTopDiscrepancyProvider).hasError) errors.add('discrepancy');
  if (ref.watch(realtimeLowStockProvider).hasError) errors.add('lowStock');
  if (ref.watch(realtimeEmptyStockProvider).hasError) errors.add('emptyStock');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return StockOverviewRealtimeState(
    summary: summary,
    categoryDistribution: categoryDistribution,
    trend: trend,
    predictions: predictions,
    topVelocity: topVelocity,
    expiryAlert: expiryAlert,
    slowMoving: slowMoving,
    categoryValues: categoryValues,
    storageDistribution: storageDistribution,
    topDiscrepancy: topDiscrepancy,
    lowStock: lowStock,
    emptyStock: emptyStock,
    isLoading: isLoading && summary.totalItems == 0,
    errorMessage: errorMessage,
  );
});

// ============================================================
// STATE MODEL
// ============================================================

class StockOverviewRealtimeState {
  final StockSummaryModel summary;
  final Map<String, int> categoryDistribution;
  final List<StockTrendModel> trend;
  final List<StockPredictionModel> predictions;
  final List<StockVelocityModel> topVelocity;
  final List<StockExpiryModel> expiryAlert;
  final List<StockSlowMovingModel> slowMoving;
  final List<StockCategoryValueModel> categoryValues;
  final List<StockStorageModel> storageDistribution;
  final List<StockDiscrepancyModel> topDiscrepancy;
  final List<Map<String, dynamic>> lowStock;
  final List<Map<String, dynamic>> emptyStock;
  final bool isLoading;
  final String? errorMessage;

  StockOverviewRealtimeState({
    required this.summary,
    required this.categoryDistribution,
    required this.trend,
    required this.predictions,
    required this.topVelocity,
    required this.expiryAlert,
    required this.slowMoving,
    required this.categoryValues,
    required this.storageDistribution,
    required this.topDiscrepancy,
    required this.lowStock,
    required this.emptyStock,
    this.isLoading = true,
    this.errorMessage,
  });
}