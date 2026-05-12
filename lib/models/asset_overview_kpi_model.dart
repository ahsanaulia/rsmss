class AssetOverviewKpiModel {
  final int totalAssets;
  final int activeAssets;
  final int inactiveAssets;

  final int goodAssets;
  final int maintenanceAssets;
  final int damagedAssets;
  final int criticalAssets;

  final int dangerousAssets;
  final int highContaminationAssets;

  final DateTime? generatedAt;

  const AssetOverviewKpiModel({
    required this.totalAssets,
    required this.activeAssets,
    required this.inactiveAssets,
    required this.goodAssets,
    required this.maintenanceAssets,
    required this.damagedAssets,
    required this.criticalAssets,
    required this.dangerousAssets,
    required this.highContaminationAssets,
    required this.generatedAt,
  });

  factory AssetOverviewKpiModel.fromMap(Map<String, dynamic> map) {
    return AssetOverviewKpiModel(
      totalAssets: _toInt(map['total_assets']),
      activeAssets: _toInt(map['active_assets']),
      inactiveAssets: _toInt(map['inactive_assets']),
      goodAssets: _toInt(map['good_assets']),
      maintenanceAssets: _toInt(map['maintenance_assets']),
      damagedAssets: _toInt(map['damaged_assets']),
      criticalAssets: _toInt(map['critical_assets']),
      dangerousAssets: _toInt(map['dangerous_assets']),
      highContaminationAssets:
          _toInt(map['high_contamination_assets']),
      generatedAt: _toDateTime(map['generated_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}