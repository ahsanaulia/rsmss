// File: lib/insights/stocks/providers/stock_requests_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_requests_realtime_service.dart';
import '../models/stock_request_model.dart';
import '../models/stock_request_summary_model.dart';
import '../models/stock_requester_model.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

final stockRequestsRealtimeServiceProvider = Provider<StockRequestsRealtimeService>((ref) {
  return StockRequestsRealtimeService();
});

// ============================================================
// REALTIME STREAM PROVIDERS
// ============================================================

final realtimeRequestsSummaryProvider = StreamProvider<StockRequestSummaryModel>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchSummary();
});

final realtimeRequestsTrendProvider = StreamProvider<List<StockRequestTrendModel>>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchTrend();
});

final realtimePendingRequestsProvider = StreamProvider<List<StockRequestModel>>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchPendingRequests();
});

final realtimeRequestsPerUnitProvider = StreamProvider<List<StockRequestPerUnitModel>>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchRequestsPerUnit();
});

final realtimeRequestsPerRoomProvider = StreamProvider<List<StockRequestPerRoomModel>>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchRequestsPerRoom();
});

final realtimeTopRequestersProvider = StreamProvider<List<StockRequesterModel>>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchTopRequesters();
});

final realtimeRequestsPerPositionProvider = StreamProvider<List<StockRequestPerPositionModel>>((ref) {
  final service = ref.watch(stockRequestsRealtimeServiceProvider);
  return service.watchRequestsPerPosition();
});

// ============================================================
// COMBINED STATE - UNTUK LOADING DAN ERROR HANDLING
// ============================================================

final stockRequestsRealtimeStateProvider = Provider<StockRequestsRealtimeState>((ref) {
  final summaryAsync = ref.watch(realtimeRequestsSummaryProvider);
  final trendAsync = ref.watch(realtimeRequestsTrendProvider);
  final pendingAsync = ref.watch(realtimePendingRequestsProvider);
  final perUnitAsync = ref.watch(realtimeRequestsPerUnitProvider);
  final perRoomAsync = ref.watch(realtimeRequestsPerRoomProvider);
  final topRequestersAsync = ref.watch(realtimeTopRequestersProvider);
  final perPositionAsync = ref.watch(realtimeRequestsPerPositionProvider);

  final summary = summaryAsync.valueOrNull ?? StockRequestSummaryModel.empty();
  final trend = trendAsync.valueOrNull ?? [];
  final pendingRequests = pendingAsync.valueOrNull ?? [];
  final perUnit = perUnitAsync.valueOrNull ?? [];
  final perRoom = perRoomAsync.valueOrNull ?? [];
  final topRequesters = topRequestersAsync.valueOrNull ?? [];
  final perPosition = perPositionAsync.valueOrNull ?? [];

  final isLoading = 
      summaryAsync.isLoading ||
      trendAsync.isLoading ||
      pendingAsync.isLoading ||
      perUnitAsync.isLoading ||
      perRoomAsync.isLoading ||
      topRequestersAsync.isLoading ||
      perPositionAsync.isLoading;

  final errors = <String>[];
  if (summaryAsync.hasError) errors.add('summary');
  if (trendAsync.hasError) errors.add('trend');
  if (pendingAsync.hasError) errors.add('pending');
  if (perUnitAsync.hasError) errors.add('perUnit');
  if (perRoomAsync.hasError) errors.add('perRoom');
  if (topRequestersAsync.hasError) errors.add('topRequesters');
  if (perPositionAsync.hasError) errors.add('perPosition');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return StockRequestsRealtimeState(
    summary: summary,
    trend: trend,
    pendingRequests: pendingRequests,
    perUnit: perUnit,
    perRoom: perRoom,
    topRequesters: topRequesters,
    perPosition: perPosition,
    isLoading: isLoading && summary.totalRequests == 0,
    errorMessage: errorMessage,
  );
});

// ============================================================
// STATE MODEL
// ============================================================

class StockRequestsRealtimeState {
  final StockRequestSummaryModel summary;
  final List<StockRequestTrendModel> trend;
  final List<StockRequestModel> pendingRequests;
  final List<StockRequestPerUnitModel> perUnit;
  final List<StockRequestPerRoomModel> perRoom;
  final List<StockRequesterModel> topRequesters;
  final List<StockRequestPerPositionModel> perPosition;
  final bool isLoading;
  final String? errorMessage;

  StockRequestsRealtimeState({
    required this.summary,
    required this.trend,
    required this.pendingRequests,
    required this.perUnit,
    required this.perRoom,
    required this.topRequesters,
    required this.perPosition,
    this.isLoading = true,
    this.errorMessage,
  });
}

// ============================================================
// SELECTORS UNTUK VIEW (COMPATIBILITY DENGAN SCREEN EXISTING)
// ============================================================

final stockRequestsSummaryProvider = Provider<StockRequestSummaryModel>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).summary;
});

final stockRequestsTrendProvider = Provider<List<StockRequestTrendModel>>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).trend;
});

final pendingRequestsProvider = Provider<List<StockRequestModel>>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).pendingRequests;
});

final requestsPerUnitProvider = Provider<List<StockRequestPerUnitModel>>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).perUnit;
});

final requestsPerRoomProvider = Provider<List<StockRequestPerRoomModel>>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).perRoom;
});

final topRequestersProvider = Provider<List<StockRequesterModel>>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).topRequesters;
});

final requestsPerPositionProvider = Provider<List<StockRequestPerPositionModel>>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).perPosition;
});

final isStockRequestsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).isLoading;
});

final stockRequestsErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(stockRequestsRealtimeStateProvider).errorMessage;
});