// File: lib/insights/hospital/providers/human_ratio_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/human_ratio_realtime_service.dart';
import '../models/human_ratio_summary.dart';
import '../models/human_ratio_distribution.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

final humanRatioServiceProvider = Provider<HumanRatioRealtimeService>((ref) {
  return HumanRatioRealtimeService();
});

// ============================================================
// REALTIME STREAM PROVIDERS
// ============================================================

final realtimeHumanRatioSummaryProvider = StreamProvider<HumanRatioSummary>((ref) {
  final service = ref.watch(humanRatioServiceProvider);
  return service.watchSummary();
});

final realtimePeopleCategoryDistributionProvider = StreamProvider<List<PeopleCategoryDistribution>>((ref) {
  final service = ref.watch(humanRatioServiceProvider);
  return service.watchPeopleCategoryDistribution();
});

final realtimePositionDistributionProvider = StreamProvider<List<PositionDistribution>>((ref) {
  final service = ref.watch(humanRatioServiceProvider);
  return service.watchPositionDistribution();
});

final realtimeEmployeePerUnitProvider = StreamProvider<List<EmployeePerUnit>>((ref) {
  final service = ref.watch(humanRatioServiceProvider);
  return service.watchEmployeePerUnit();
});

final realtimeTechInsightProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(humanRatioServiceProvider);
  return service.watchTechInsight();
});

// ============================================================
// COMBINED STATE
// ============================================================

final humanRatioStateProvider = Provider<HumanRatioState>((ref) {
  // WATCH SEMUA STREAM
  final summaryAsync = ref.watch(realtimeHumanRatioSummaryProvider);
  final peopleCategoryAsync = ref.watch(realtimePeopleCategoryDistributionProvider);
  final positionAsync = ref.watch(realtimePositionDistributionProvider);
  final employeeUnitAsync = ref.watch(realtimeEmployeePerUnitProvider);
  final techInsightAsync = ref.watch(realtimeTechInsightProvider);

  // DEBUG PRINT
  debugPrint('📊 [PROVIDER] summaryAsync.hasValue: ${summaryAsync.hasValue}');
  debugPrint('📊 [PROVIDER] summaryAsync.isLoading: ${summaryAsync.isLoading}');
  debugPrint('📊 [PROVIDER] summaryAsync.hasError: ${summaryAsync.hasError}');
  debugPrint('📊 [PROVIDER] peopleCategoryAsync.hasValue: ${peopleCategoryAsync.hasValue}');
  debugPrint('📊 [PROVIDER] positionAsync.hasValue: ${positionAsync.hasValue}');
  debugPrint('📊 [PROVIDER] employeeUnitAsync.hasValue: ${employeeUnitAsync.hasValue}');
  debugPrint('📊 [PROVIDER] techInsightAsync.hasValue: ${techInsightAsync.hasValue}');

  // AMBIL VALUE ATAU DEFAULT
  final summary = summaryAsync.valueOrNull ?? HumanRatioSummary.empty();
  final peopleCategories = peopleCategoryAsync.valueOrNull ?? [];
  final positions = positionAsync.valueOrNull ?? [];
  final employeePerUnit = employeeUnitAsync.valueOrNull ?? [];
  final techInsight = techInsightAsync.valueOrNull ?? {};

  // DEBUG PRINT NILAI
  debugPrint('📊 [PROVIDER] summary.totalEmployees: ${summary.totalEmployees}');
  debugPrint('📊 [PROVIDER] summary.totalPeople: ${summary.totalPeople}');
  debugPrint('📊 [PROVIDER] peopleCategories.length: ${peopleCategories.length}');
  debugPrint('📊 [PROVIDER] positions.length: ${positions.length}');
  debugPrint('📊 [PROVIDER] employeePerUnit.length: ${employeePerUnit.length}');

  // CEK LOADING
  final isLoading = 
      summaryAsync.isLoading ||
      peopleCategoryAsync.isLoading ||
      positionAsync.isLoading ||
      employeeUnitAsync.isLoading ||
      techInsightAsync.isLoading;

  debugPrint('📊 [PROVIDER] isLoading: $isLoading');

  // KUMPULKAN ERROR
  final errors = <String>[];
  if (summaryAsync.hasError) errors.add('summary');
  if (peopleCategoryAsync.hasError) errors.add('peopleCategory');
  if (positionAsync.hasError) errors.add('position');
  if (employeeUnitAsync.hasError) errors.add('employeeUnit');
  if (techInsightAsync.hasError) errors.add('techInsight');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;
  
  if (errorMessage != null) {
    debugPrint('📊 [PROVIDER] errorMessage: $errorMessage');
  }

  return HumanRatioState(
    summary: summary,
    peopleCategories: peopleCategories,
    positions: positions,
    employeePerUnit: employeePerUnit,
    techInsight: techInsight,
    isLoading: isLoading && summary.totalPeople == 0,
    errorMessage: errorMessage,
  );
});

// ============================================================
// STATE MODEL
// ============================================================

class HumanRatioState {
  final HumanRatioSummary summary;
  final List<PeopleCategoryDistribution> peopleCategories;
  final List<PositionDistribution> positions;
  final List<EmployeePerUnit> employeePerUnit;
  final Map<String, dynamic> techInsight;
  final bool isLoading;
  final String? errorMessage;

  HumanRatioState({
    required this.summary,
    required this.peopleCategories,
    required this.positions,
    required this.employeePerUnit,
    required this.techInsight,
    this.isLoading = true,
    this.errorMessage,
  });
}

// ============================================================
// SELECTORS UNTUK VIEW
// ============================================================

final humanRatioSummaryProvider = Provider<HumanRatioSummary>((ref) {
  return ref.watch(humanRatioStateProvider).summary;
});

final humanRatioPeopleCategoriesProvider = Provider<List<PeopleCategoryDistribution>>((ref) {
  return ref.watch(humanRatioStateProvider).peopleCategories;
});

final humanRatioPositionsProvider = Provider<List<PositionDistribution>>((ref) {
  return ref.watch(humanRatioStateProvider).positions;
});

final humanRatioEmployeePerUnitProvider = Provider<List<EmployeePerUnit>>((ref) {
  return ref.watch(humanRatioStateProvider).employeePerUnit;
});

final humanRatioTechInsightProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(humanRatioStateProvider).techInsight;
});

final isHumanRatioLoadingProvider = Provider<bool>((ref) {
  return ref.watch(humanRatioStateProvider).isLoading;
});

final humanRatioErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(humanRatioStateProvider).errorMessage;
});