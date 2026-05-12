import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/asset_alert_summary_model.dart';
import '../models/asset_category_summary_model.dart';
import '../models/asset_health_summary_model.dart';
import '../models/asset_inspection_summary_model.dart';
import '../models/asset_overview_kpi_model.dart';
import '../models/asset_subcategory_summary_model.dart';
import '../models/asset_type_summary_model.dart';

class AssetAnalyticsService {
  AssetAnalyticsService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // =========================================================
  // OVERVIEW KPI
  // =========================================================

  Future<AssetOverviewKpiModel> fetchOverviewKpi() async {
    try {
      final response = await _client
          .from('vw_asset_overview_kpi')
          .select()
          .maybeSingle();

      if (response == null) {
        return const AssetOverviewKpiModel(
          totalAssets: 0,
          activeAssets: 0,
          inactiveAssets: 0,
          goodAssets: 0,
          maintenanceAssets: 0,
          damagedAssets: 0,
          criticalAssets: 0,
          dangerousAssets: 0,
          highContaminationAssets: 0,
          generatedAt: null,
        );
      }

      return AssetOverviewKpiModel.fromMap(response);
    } catch (e, stackTrace) {
      _logError(
        'fetchOverviewKpi',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // CATEGORY SUMMARY
  // =========================================================

  Future<List<AssetCategorySummaryModel>>
      fetchCategorySummary() async {
    try {
      final response = await _client
          .from('vw_asset_category_summary')
          .select();

      return response
          .map<AssetCategorySummaryModel>(
            (item) => AssetCategorySummaryModel.fromMap(item),
          )
          .toList(growable: false);
    } catch (e, stackTrace) {
      _logError(
        'fetchCategorySummary',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // SUBCATEGORY SUMMARY
  // =========================================================

  Future<List<AssetSubcategorySummaryModel>>
      fetchSubcategorySummary({
    String? categoryId,
  }) async {
    try {
      dynamic query = _client
          .from('vw_asset_subcategory_summary')
          .select();

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query;

      return response
          .map<AssetSubcategorySummaryModel>(
            (item) =>
                AssetSubcategorySummaryModel.fromMap(item),
          )
          .toList(growable: false);
    } catch (e, stackTrace) {
      _logError(
        'fetchSubcategorySummary',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // TYPE SUMMARY
  // =========================================================

  Future<List<AssetTypeSummaryModel>>
      fetchTypeSummary({
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      dynamic query = _client
          .from('vw_asset_type_summary')
          .select();

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      if (subCategoryId != null &&
          subCategoryId.isNotEmpty) {
        query = query.eq(
          'sub_category_id',
          subCategoryId,
        );
      }

      final response = await query;

      return response
          .map<AssetTypeSummaryModel>(
            (item) => AssetTypeSummaryModel.fromMap(item),
          )
          .toList(growable: false);
    } catch (e, stackTrace) {
      _logError(
        'fetchTypeSummary',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // HEALTH SUMMARY
  // =========================================================

  Future<List<AssetHealthSummaryModel>>
      fetchHealthSummary() async {
    try {
      final response = await _client
          .from('vw_asset_health_summary')
          .select();

      return response
          .map<AssetHealthSummaryModel>(
            (item) => AssetHealthSummaryModel.fromMap(item),
          )
          .toList(growable: false);
    } catch (e, stackTrace) {
      _logError(
        'fetchHealthSummary',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // INSPECTION SUMMARY
  // =========================================================

  Future<AssetInspectionSummaryModel>
      fetchInspectionSummary() async {
    try {
      final response = await _client
          .from('vw_asset_inspection_summary')
          .select()
          .maybeSingle();

      if (response == null) {
        return const AssetInspectionSummaryModel(
          overdueInspectionAssets: 0,
          inspectionDueToday: 0,
          inspectionDueThisWeek: 0,
          neverInspectedAssets: 0,
          generatedAt: null,
        );
      }

      return AssetInspectionSummaryModel.fromMap(
        response,
      );
    } catch (e, stackTrace) {
      _logError(
        'fetchInspectionSummary',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // ALERT SUMMARY
  // =========================================================

  Future<AssetAlertSummaryModel>
      fetchAlertSummary() async {
    try {
      final response = await _client
          .from('vw_asset_alert_summary')
          .select()
          .maybeSingle();

      if (response == null) {
        return const AssetAlertSummaryModel(
          dangerousAssets: 0,
          criticalContaminationAssets: 0,
          criticalConditionAssets: 0,
          overdueInspectionAssets: 0,
          damagedAssets: 0,
          generatedAt: null,
        );
      }

      return AssetAlertSummaryModel.fromMap(response);
    } catch (e, stackTrace) {
      _logError(
        'fetchAlertSummary',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // DASHBOARD PRELOAD
  // =========================================================

  Future<AssetDashboardBundle> preloadDashboard() async {
    try {
      final results = await Future.wait([
        fetchOverviewKpi(),
        fetchCategorySummary(),
        fetchHealthSummary(),
        fetchInspectionSummary(),
        fetchAlertSummary(),
      ]);

      return AssetDashboardBundle(
        overviewKpi:
            results[0] as AssetOverviewKpiModel,
        categorySummary:
            results[1]
                as List<AssetCategorySummaryModel>,
        healthSummary:
            results[2]
                as List<AssetHealthSummaryModel>,
        inspectionSummary:
            results[3]
                as AssetInspectionSummaryModel,
        alertSummary:
            results[4] as AssetAlertSummaryModel,
      );
    } catch (e, stackTrace) {
      _logError(
        'preloadDashboard',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // INTERNAL LOGGER
  // =========================================================

  void _logError(
    String method,
    Object error,
    StackTrace stackTrace,
  ) {
    // ignore: avoid_print
    print('''
=========================================================
AssetAnalyticsService Error
Method : $method
Error  : $error

$stackTrace
=========================================================
''');
  }
}

// =========================================================
// DASHBOARD BUNDLE
// =========================================================

class AssetDashboardBundle {
  final AssetOverviewKpiModel overviewKpi;

  final List<AssetCategorySummaryModel>
      categorySummary;

  final List<AssetHealthSummaryModel>
      healthSummary;

  final AssetInspectionSummaryModel
      inspectionSummary;

  final AssetAlertSummaryModel alertSummary;

  const AssetDashboardBundle({
    required this.overviewKpi,
    required this.categorySummary,
    required this.healthSummary,
    required this.inspectionSummary,
    required this.alertSummary,
  });
}