// File: lib/insights/stocks/providers/stock_opname_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_opname_realtime_service.dart';
import '../models/stock_opname_model.dart';
import '../models/stock_opname_summary_model.dart';
import '../models/stock_opname_anomaly_model.dart';
import '../models/stock_opname_trend_model.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

final stockOpnameRealtimeServiceProvider = Provider<StockOpnameRealtimeService>((ref) {
  return StockOpnameRealtimeService();
});

// ============================================================
// REALTIME STREAM PROVIDERS
// ============================================================

final realtimeOpnameSummaryProvider = StreamProvider<StockOpnameSummaryModel>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchSummary();
});

final realtimeOpnameDistributionProvider = StreamProvider<Map<String, int>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchOpnameDistribution();
});

final realtimeTopDiscrepancyItemsProvider = StreamProvider<List<StockOpnameAnomalyItemModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchTopDiscrepancyItems();
});

final realtimeTrendPerMonthProvider = StreamProvider<List<StockOpnameTrendModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchTrendPerMonth();
});

final realtimeUnusualDiscrepancyProvider = StreamProvider<List<StockOpnameAnomalyItemModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchUnusualDiscrepancy();
});

final realtimeFrequentDiscrepancyProvider = StreamProvider<List<StockOpnameAnomalyItemModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchFrequentDiscrepancy();
});

final realtimePatternByPersonProvider = StreamProvider<List<StockOpnameAnomalyPersonModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchPatternByPerson();
});

final realtimeAnomalyPerBinProvider = StreamProvider<List<StockOpnameAnomalyBinModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchAnomalyPerBin();
});

final realtimeRecentOpnamesProvider = StreamProvider<List<StockOpnameModel>>((ref) {
  final service = ref.watch(stockOpnameRealtimeServiceProvider);
  return service.watchRecentOpnames();
});

// ============================================================
// COMBINED STATE
// ============================================================

final stockOpnameRealtimeStateProvider = Provider<StockOpnameRealtimeState>((ref) {
  final summaryAsync = ref.watch(realtimeOpnameSummaryProvider);
  final distributionAsync = ref.watch(realtimeOpnameDistributionProvider);
  final topItemsAsync = ref.watch(realtimeTopDiscrepancyItemsProvider);
  final trendAsync = ref.watch(realtimeTrendPerMonthProvider);
  final unusualAsync = ref.watch(realtimeUnusualDiscrepancyProvider);
  final frequentAsync = ref.watch(realtimeFrequentDiscrepancyProvider);
  final personAsync = ref.watch(realtimePatternByPersonProvider);
  final binAsync = ref.watch(realtimeAnomalyPerBinProvider);
  final recentAsync = ref.watch(realtimeRecentOpnamesProvider);

  final summary = summaryAsync.valueOrNull ?? StockOpnameSummaryModel.empty();
  final distribution = distributionAsync.valueOrNull ?? {};
  final topItems = topItemsAsync.valueOrNull ?? [];
  final trend = trendAsync.valueOrNull ?? [];
  final unusualDiscrepancy = unusualAsync.valueOrNull ?? [];
  final frequentDiscrepancy = frequentAsync.valueOrNull ?? [];
  final patternByPerson = personAsync.valueOrNull ?? [];
  final anomalyPerBin = binAsync.valueOrNull ?? [];
  final recentOpnames = recentAsync.valueOrNull ?? [];

  final isLoading = 
      summaryAsync.isLoading ||
      distributionAsync.isLoading ||
      topItemsAsync.isLoading ||
      trendAsync.isLoading ||
      unusualAsync.isLoading ||
      frequentAsync.isLoading ||
      personAsync.isLoading ||
      binAsync.isLoading ||
      recentAsync.isLoading;

  final errors = <String>[];
  if (summaryAsync.hasError) errors.add('summary');
  if (distributionAsync.hasError) errors.add('distribution');
  if (topItemsAsync.hasError) errors.add('topItems');
  if (trendAsync.hasError) errors.add('trend');
  if (unusualAsync.hasError) errors.add('unusual');
  if (frequentAsync.hasError) errors.add('frequent');
  if (personAsync.hasError) errors.add('person');
  if (binAsync.hasError) errors.add('bin');
  if (recentAsync.hasError) errors.add('recent');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return StockOpnameRealtimeState(
    summary: summary,
    distribution: distribution,
    topItems: topItems,
    trend: trend,
    unusualDiscrepancy: unusualDiscrepancy,
    frequentDiscrepancy: frequentDiscrepancy,
    patternByPerson: patternByPerson,
    anomalyPerBin: anomalyPerBin,
    recentOpnames: recentOpnames,
    isLoading: isLoading && summary.totalOpnames == 0,
    errorMessage: errorMessage,
  );
});

// ============================================================
// STATE MODEL
// ============================================================

class StockOpnameRealtimeState {
  final StockOpnameSummaryModel summary;
  final Map<String, int> distribution;
  final List<StockOpnameAnomalyItemModel> topItems;
  final List<StockOpnameTrendModel> trend;
  final List<StockOpnameAnomalyItemModel> unusualDiscrepancy;
  final List<StockOpnameAnomalyItemModel> frequentDiscrepancy;
  final List<StockOpnameAnomalyPersonModel> patternByPerson;
  final List<StockOpnameAnomalyBinModel> anomalyPerBin;
  final List<StockOpnameModel> recentOpnames;
  final bool isLoading;
  final String? errorMessage;

  StockOpnameRealtimeState({
    required this.summary,
    required this.distribution,
    required this.topItems,
    required this.trend,
    required this.unusualDiscrepancy,
    required this.frequentDiscrepancy,
    required this.patternByPerson,
    required this.anomalyPerBin,
    required this.recentOpnames,
    this.isLoading = true,
    this.errorMessage,
  });
}

// ============================================================
// SELECTORS UNTUK VIEW
// ============================================================

final stockOpnameSummaryProvider = Provider<StockOpnameSummaryModel>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).summary;
});

final stockOpnameDistributionProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).distribution;
});

final stockOpnameTopItemsProvider = Provider<List<StockOpnameAnomalyItemModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).topItems;
});

final stockOpnameTrendProvider = Provider<List<StockOpnameTrendModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).trend;
});

final stockOpnameUnusualDiscrepancyProvider = Provider<List<StockOpnameAnomalyItemModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).unusualDiscrepancy;
});

final stockOpnameFrequentDiscrepancyProvider = Provider<List<StockOpnameAnomalyItemModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).frequentDiscrepancy;
});

final stockOpnamePatternByPersonProvider = Provider<List<StockOpnameAnomalyPersonModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).patternByPerson;
});

final stockOpnameAnomalyPerBinProvider = Provider<List<StockOpnameAnomalyBinModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).anomalyPerBin;
});

final stockOpnameRecentProvider = Provider<List<StockOpnameModel>>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).recentOpnames;
});

final isStockOpnameLoadingProvider = Provider<bool>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).isLoading;
});

final stockOpnameErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(stockOpnameRealtimeStateProvider).errorMessage;
});