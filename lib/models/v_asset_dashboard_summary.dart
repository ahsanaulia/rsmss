class AssetDashboardSummaryModel {
  final int totalAssets;
  final int totalGood;
  final int totalMaintenance;
  final int totalCritical;
  final int totalDamaged;
  final int totalDangerous;
  final int highContamination;
  final int overdueInspection;

  AssetDashboardSummaryModel({
    required this.totalAssets,
    required this.totalGood,
    required this.totalMaintenance,
    required this.totalCritical,
    required this.totalDamaged,
    required this.totalDangerous,
    required this.highContamination,
    required this.overdueInspection,
  });

  factory AssetDashboardSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssetDashboardSummaryModel(
      totalAssets:
          json['total_assets'] ?? 0,

      totalGood:
          json['total_good'] ?? 0,

      totalMaintenance:
          json['total_maintenance'] ?? 0,

      totalCritical:
          json['total_critical'] ?? 0,

      totalDamaged:
          json['total_damaged'] ?? 0,

      totalDangerous:
          json['total_dangerous'] ?? 0,

      highContamination:
          json['high_contamination'] ?? 0,

      overdueInspection:
          json['overdue_inspection'] ?? 0,
    );
  }
}