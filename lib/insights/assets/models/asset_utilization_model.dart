// lib/insights/assets/models/asset_utilization_model.dart

class AssetUtilizationKpi {
  final int totalAssets;
  final int goodAssets;
  final int maintenanceAssets;
  final int damagedAssets;
  final int criticalAssets;
  final int dangerousAssets;
  final int highContaminationAssets;
  final int assetsInUse;
  final int assetsAvailable;

  AssetUtilizationKpi({
    required this.totalAssets,
    required this.goodAssets,
    required this.maintenanceAssets,
    required this.damagedAssets,
    required this.criticalAssets,
    required this.dangerousAssets,
    required this.highContaminationAssets,
    required this.assetsInUse,
    required this.assetsAvailable,
  });

  factory AssetUtilizationKpi.fromJson(Map<String, dynamic> json) {
    return AssetUtilizationKpi(
      totalAssets: json['total_assets'] ?? 0,
      goodAssets: json['good_assets'] ?? 0,
      maintenanceAssets: json['maintenance_assets'] ?? 0,
      damagedAssets: json['damaged_assets'] ?? 0,
      criticalAssets: json['critical_assets'] ?? 0,
      dangerousAssets: json['dangerous_assets'] ?? 0,
      highContaminationAssets: json['high_contamination_assets'] ?? 0,
      assetsInUse: json['assets_in_use'] ?? 0,
      assetsAvailable: json['assets_available'] ?? 0,
    );
  }

  int get utilizationRate {
    if (totalAssets == 0) return 0;
    return ((assetsInUse / totalAssets) * 100).round();
  }

  int get readyRate {
    if (totalAssets == 0) return 0;
    return ((assetsAvailable / totalAssets) * 100).round();
  }
}

class AssetCategorySummary {
  final String categoryName;
  final int totalAssets;
  final int goodAssets;
  final int maintenanceAssets;
  final int damagedAssets;
  final int criticalAssets;

  AssetCategorySummary({
    required this.categoryName,
    required this.totalAssets,
    required this.goodAssets,
    required this.maintenanceAssets,
    required this.damagedAssets,
    required this.criticalAssets,
  });

  factory AssetCategorySummary.fromJson(Map<String, dynamic> json) {
    return AssetCategorySummary(
      categoryName: json['category_name'] ?? 'Unknown',
      totalAssets: json['total_assets'] ?? 0,
      goodAssets: json['good_assets'] ?? 0,
      maintenanceAssets: json['maintenance_assets'] ?? 0,
      damagedAssets: json['damaged_assets'] ?? 0,
      criticalAssets: json['critical_assets'] ?? 0,
    );
  }
}

class AssetTypeSummary {
  final String typeName;
  final int total;

  AssetTypeSummary({
    required this.typeName,
    required this.total,
  });

  factory AssetTypeSummary.fromMap(Map<String, dynamic> map) {
    return AssetTypeSummary(
      typeName: map['type_name'] ?? 'Unknown',
      total: map['total'] ?? 0,
    );
  }
}

class InspectionSummary {
  final int overdueInspectionAssets;
  final int inspectionDueToday;
  final int inspectionDueThisWeek;
  final int neverInspectedAssets;

  InspectionSummary({
    required this.overdueInspectionAssets,
    required this.inspectionDueToday,
    required this.inspectionDueThisWeek,
    required this.neverInspectedAssets,
  });
}

class AlertSummary {
  final int dangerousAssets;
  final int criticalContaminationAssets;
  final int criticalConditionAssets;
  final int damagedAssets;

  AlertSummary({
    required this.dangerousAssets,
    required this.criticalContaminationAssets,
    required this.criticalConditionAssets,
    required this.damagedAssets,
  });
}

class AssetUtilizationSummary {
  final AssetUtilizationKpi kpi;
  final List<AssetCategorySummary> categories;
  final List<AssetTypeSummary> topTypes;
  final InspectionSummary? inspectionSummary;
  final AlertSummary? alertSummary;

  AssetUtilizationSummary({
    required this.kpi,
    required this.categories,
    required this.topTypes,
    this.inspectionSummary,
    this.alertSummary,
  });
}