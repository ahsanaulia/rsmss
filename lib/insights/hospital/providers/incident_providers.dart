// File: lib/insights/hospital/providers/incident_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/incident_realtime_service.dart';
import '../models/incident_summary_model.dart';
import '../models/incident_response_model.dart';

// ============================================================
// SERVICE PROVIDER
// ============================================================

final incidentServiceProvider = Provider<IncidentRealtimeService>((ref) {
  return IncidentRealtimeService();
});

// ============================================================
// REALTIME STREAM PROVIDERS
// ============================================================

final realtimeIncidentSummaryProvider = StreamProvider<IncidentSummaryModel>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.watchSummary();
});

final realtimeCategoryDistributionProvider = StreamProvider<List<IncidentCategoryDistribution>>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.watchCategoryDistribution();
});

final realtimeSeverityDistributionProvider = StreamProvider<List<IncidentSeverityDistribution>>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.watchSeverityDistribution();
});

final realtimeResponseRateProvider = StreamProvider<IncidentResponseStats>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.watchResponseRate();
});

final realtimeTopReportersProvider = StreamProvider<List<IncidentReporterStats>>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.watchTopReporters();
});

final realtimeRecentIncidentsProvider = StreamProvider<List<IncidentRecentModel>>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.watchRecentIncidents();
});

// ============================================================
// COMBINED STATE
// ============================================================

final incidentStateProvider = Provider<IncidentState>((ref) {
  final summaryAsync = ref.watch(realtimeIncidentSummaryProvider);
  final categoryAsync = ref.watch(realtimeCategoryDistributionProvider);
  final severityAsync = ref.watch(realtimeSeverityDistributionProvider);
  final responseAsync = ref.watch(realtimeResponseRateProvider);
  final reportersAsync = ref.watch(realtimeTopReportersProvider);
  final recentAsync = ref.watch(realtimeRecentIncidentsProvider);

  debugPrint('📊 [INCIDENT] summaryAsync.hasValue: ${summaryAsync.hasValue}');
  debugPrint('📊 [INCIDENT] categoryAsync.hasValue: ${categoryAsync.hasValue}');

  final summary = summaryAsync.valueOrNull ?? IncidentSummaryModel.empty();
  final categoryDistribution = categoryAsync.valueOrNull ?? [];
  final severityDistribution = severityAsync.valueOrNull ?? [];
  final responseStats = responseAsync.valueOrNull ?? IncidentResponseStats.empty();
  final topReporters = reportersAsync.valueOrNull ?? [];
  final recentIncidents = recentAsync.valueOrNull ?? [];

  final isLoading = 
      summaryAsync.isLoading ||
      categoryAsync.isLoading ||
      severityAsync.isLoading ||
      responseAsync.isLoading ||
      reportersAsync.isLoading ||
      recentAsync.isLoading;

  final errors = <String>[];
  if (summaryAsync.hasError) errors.add('summary');
  if (categoryAsync.hasError) errors.add('category');
  if (severityAsync.hasError) errors.add('severity');
  if (responseAsync.hasError) errors.add('response');
  if (reportersAsync.hasError) errors.add('reporters');
  if (recentAsync.hasError) errors.add('recent');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return IncidentState(
    summary: summary,
    categoryDistribution: categoryDistribution,
    severityDistribution: severityDistribution,
    responseStats: responseStats,
    topReporters: topReporters,
    recentIncidents: recentIncidents,
    isLoading: isLoading && summary.totalIncidents == 0,
    errorMessage: errorMessage,
  );
});

// ============================================================
// STATE MODEL
// ============================================================

class IncidentState {
  final IncidentSummaryModel summary;
  final List<IncidentCategoryDistribution> categoryDistribution;
  final List<IncidentSeverityDistribution> severityDistribution;
  final IncidentResponseStats responseStats;
  final List<IncidentReporterStats> topReporters;
  final List<IncidentRecentModel> recentIncidents;
  final bool isLoading;
  final String? errorMessage;

  IncidentState({
    required this.summary,
    required this.categoryDistribution,
    required this.severityDistribution,
    required this.responseStats,
    required this.topReporters,
    required this.recentIncidents,
    this.isLoading = true,
    this.errorMessage,
  });
}

// ============================================================
// SELECTORS UNTUK VIEW
// ============================================================

final incidentSummaryProvider = Provider<IncidentSummaryModel>((ref) {
  return ref.watch(incidentStateProvider).summary;
});

final incidentCategoryDistributionProvider = Provider<List<IncidentCategoryDistribution>>((ref) {
  return ref.watch(incidentStateProvider).categoryDistribution;
});

final incidentSeverityDistributionProvider = Provider<List<IncidentSeverityDistribution>>((ref) {
  return ref.watch(incidentStateProvider).severityDistribution;
});

final incidentResponseStatsProvider = Provider<IncidentResponseStats>((ref) {
  return ref.watch(incidentStateProvider).responseStats;
});

final incidentTopReportersProvider = Provider<List<IncidentReporterStats>>((ref) {
  return ref.watch(incidentStateProvider).topReporters;
});

final incidentRecentIncidentsProvider = Provider<List<IncidentRecentModel>>((ref) {
  return ref.watch(incidentStateProvider).recentIncidents;
});

final isIncidentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(incidentStateProvider).isLoading;
});

final incidentErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(incidentStateProvider).errorMessage;
});