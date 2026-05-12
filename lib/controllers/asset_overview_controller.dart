import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/asset_alert_summary_model.dart';
import '../models/asset_category_summary_model.dart';
import '../models/asset_health_summary_model.dart';
import '../models/asset_inspection_summary_model.dart';
import '../models/asset_overview_kpi_model.dart';
import '../services/asset_analytics_service.dart';

class AssetOverviewController
    extends ValueNotifier<AssetOverviewState> {
  AssetOverviewController({
    AssetAnalyticsService? service,
    this.autoRefreshDuration =
        const Duration(seconds: 60),
  })  : _service =
            service ?? AssetAnalyticsService(),
        super(const AssetOverviewState.initial());

  final AssetAnalyticsService _service;

  final Duration autoRefreshDuration;

  Timer? _refreshTimer;

  bool _disposed = false;

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void> initialize() async {
    await loadDashboard();

    _startAutoRefresh();
  }

  // =========================================================
  // LOAD DASHBOARD
  // =========================================================

  Future<void> loadDashboard({
    bool silentRefresh = false,
  }) async {
    if (_disposed) return;

    try {
      if (!silentRefresh) {
        value = value.copyWith(
          isLoading: true,
          hasError: false,
          errorMessage: null,
        );
      } else {
        value = value.copyWith(
          isRefreshing: true,
        );
      }

      final dashboard =
          await _service.preloadDashboard();

      if (_disposed) return;

      value = value.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasError: false,
        errorMessage: null,

        overviewKpi: dashboard.overviewKpi,
        categorySummary:
            dashboard.categorySummary,
        healthSummary:
            dashboard.healthSummary,
        inspectionSummary:
            dashboard.inspectionSummary,
        alertSummary:
            dashboard.alertSummary,

        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (_disposed) return;

      value = value.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // =========================================================
  // MANUAL REFRESH
  // =========================================================

  Future<void> refresh() async {
    await loadDashboard(
      silentRefresh: true,
    );
  }

  // =========================================================
  // AUTO REFRESH
  // =========================================================

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      autoRefreshDuration,
      (_) async {
        if (_disposed) return;

        await refresh();
      },
    );
  }

  // =========================================================
  // STOP AUTO REFRESH
  // =========================================================

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _disposed = true;

    _refreshTimer?.cancel();

    super.dispose();
  }
}

// =============================================================
// STATE
// =============================================================

class AssetOverviewState {
  final bool isLoading;

  final bool isRefreshing;

  final bool hasError;

  final String? errorMessage;

  final DateTime? lastUpdated;

  final AssetOverviewKpiModel? overviewKpi;

  final List<AssetCategorySummaryModel>
      categorySummary;

  final List<AssetHealthSummaryModel>
      healthSummary;

  final AssetInspectionSummaryModel?
      inspectionSummary;

  final AssetAlertSummaryModel? alertSummary;

  const AssetOverviewState({
    required this.isLoading,
    required this.isRefreshing,
    required this.hasError,
    required this.errorMessage,
    required this.lastUpdated,
    required this.overviewKpi,
    required this.categorySummary,
    required this.healthSummary,
    required this.inspectionSummary,
    required this.alertSummary,
  });

  const AssetOverviewState.initial()
      : isLoading = false,
        isRefreshing = false,
        hasError = false,
        errorMessage = null,
        lastUpdated = null,
        overviewKpi = null,
        categorySummary = const [],
        healthSummary = const [],
        inspectionSummary = null,
        alertSummary = null;

  AssetOverviewState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? hasError,
    String? errorMessage,
    DateTime? lastUpdated,

    AssetOverviewKpiModel? overviewKpi,

    List<AssetCategorySummaryModel>?
        categorySummary,

    List<AssetHealthSummaryModel>?
        healthSummary,

    AssetInspectionSummaryModel?
        inspectionSummary,

    AssetAlertSummaryModel?
        alertSummary,
  }) {
    return AssetOverviewState(
      isLoading:
          isLoading ?? this.isLoading,

      isRefreshing:
          isRefreshing ??
              this.isRefreshing,

      hasError:
          hasError ?? this.hasError,

      errorMessage:
          errorMessage,

      lastUpdated:
          lastUpdated ??
              this.lastUpdated,

      overviewKpi:
          overviewKpi ??
              this.overviewKpi,

      categorySummary:
          categorySummary ??
              this.categorySummary,

      healthSummary:
          healthSummary ??
              this.healthSummary,

      inspectionSummary:
          inspectionSummary ??
              this.inspectionSummary,

      alertSummary:
          alertSummary ??
              this.alertSummary,
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  bool get hasData {
    return overviewKpi != null;
  }

  bool get isEmptyDashboard {
    return categorySummary.isEmpty &&
        healthSummary.isEmpty;
  }
}