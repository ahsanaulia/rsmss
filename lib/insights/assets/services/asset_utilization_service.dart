// lib/insights/assets/services/asset_utilization_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_utilization_model.dart';

class AssetUtilizationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AssetUtilizationSummary> getAssetUtilizationSummary() async {
    // Query 1: Ambil KPI dari vw_asset_overview_kpi
    final kpiResponse = await _supabase
        .from('vw_asset_overview_kpi')
        .select()
        .limit(1);

    // Query 2: Ambil asset in use dari asset_assignments (filter released_at is null)
    final inUseResponse = await _supabase
        .from('asset_assignments')
        .select('asset_id')
        .filter('released_at', 'is', 'null')
        .eq('assignment_status', 'active');

    final assetsInUse = inUseResponse.length;

    // Query 3: Ambil total asset good
    final goodResponse = await _supabase
        .from('assets')
        .select('id')
        .eq('status_condition', 'Good')
        .eq('is_active', true);

    final goodAssets = goodResponse.length;

    // Hitung assets available (asset good yang tidak sedang diassign)
    int assetsAvailable = goodAssets - assetsInUse;
    if (assetsAvailable < 0) assetsAvailable = 0;

    // Query 4: Ambil kategori summary dari vw_asset_category_summary
    final categoriesResponse = await _supabase
        .from('vw_asset_category_summary')
        .select()
        .order('total_assets', ascending: false);

    // Query 5: Ambil top 5 tipe asset
    final typesResponse = await _supabase
        .from('v_asset_master_complete')
        .select('type_name')
        .eq('is_active', true);

    // Query 6: Ambil inspection summary dari vw_asset_inspection_summary
    final inspectionResponse = await _supabase
        .from('vw_asset_inspection_summary')
        .select()
        .limit(1);

    // Query 7: Ambil alert summary dari vw_asset_alert_summary
    final alertResponse = await _supabase
        .from('vw_asset_alert_summary')
        .select()
        .limit(1);

    // Group by type_name
    final Map<String, int> typeCount = {};
    for (final row in typesResponse) {
      final typeName = row['type_name'] as String?;
      if (typeName != null && typeName.isNotEmpty) {
        typeCount[typeName] = (typeCount[typeName] ?? 0) + 1;
      }
    }

    final topTypes = typeCount.entries
        .map((e) => AssetTypeSummary(typeName: e.key, total: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final kpiData = kpiResponse.isNotEmpty ? kpiResponse.first : {};
    
    final kpi = AssetUtilizationKpi(
      totalAssets: kpiData['total_assets'] ?? 0,
      goodAssets: goodAssets,
      maintenanceAssets: kpiData['maintenance_assets'] ?? 0,
      damagedAssets: kpiData['damaged_assets'] ?? 0,
      criticalAssets: kpiData['critical_assets'] ?? 0,
      dangerousAssets: kpiData['dangerous_assets'] ?? 0,
      highContaminationAssets: kpiData['high_contamination_assets'] ?? 0,
      assetsInUse: assetsInUse,
      assetsAvailable: assetsAvailable,
    );

    final categories = categoriesResponse
        .map((json) => AssetCategorySummary.fromJson(json))
        .toList();

    // Parse inspection summary
    final inspectionData = inspectionResponse.isNotEmpty ? inspectionResponse.first : {};
    final inspectionSummary = InspectionSummary(
      overdueInspectionAssets: inspectionData['overdue_inspection_assets'] ?? 0,
      inspectionDueToday: inspectionData['inspection_due_today'] ?? 0,
      inspectionDueThisWeek: inspectionData['inspection_due_this_week'] ?? 0,
      neverInspectedAssets: inspectionData['never_inspected_assets'] ?? 0,
    );

    // Parse alert summary
    final alertData = alertResponse.isNotEmpty ? alertResponse.first : {};
    final alertSummary = AlertSummary(
      dangerousAssets: alertData['dangerous_assets'] ?? 0,
      criticalContaminationAssets: alertData['critical_contamination_assets'] ?? 0,
      criticalConditionAssets: alertData['critical_condition_assets'] ?? 0,
      damagedAssets: alertData['damaged_assets'] ?? 0,
    );

    return AssetUtilizationSummary(
      kpi: kpi,
      categories: categories,
      topTypes: topTypes.take(5).toList(),
      inspectionSummary: inspectionSummary,
      alertSummary: alertSummary,
    );
  }
}