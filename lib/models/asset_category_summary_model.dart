class AssetCategorySummaryModel {
  final String categoryId;
  final String categoryName;

  final String? iconName;
  final String? markerColor;

  final int totalAssets;
  final int activeAssets;

  final int goodAssets;
  final int maintenanceAssets;
  final int damagedAssets;
  final int criticalAssets;

  final int dangerousAssets;
  final int highContaminationAssets;

  const AssetCategorySummaryModel({
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.markerColor,
    required this.totalAssets,
    required this.activeAssets,
    required this.goodAssets,
    required this.maintenanceAssets,
    required this.damagedAssets,
    required this.criticalAssets,
    required this.dangerousAssets,
    required this.highContaminationAssets,
  });

  factory AssetCategorySummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AssetCategorySummaryModel(
      categoryId: map['category_id'] ?? '',
      categoryName: map['category_name'] ?? '',
      iconName: map['icon_name'],
      markerColor: map['marker_color'],
      totalAssets: _toInt(map['total_assets']),
      activeAssets: _toInt(map['active_assets']),
      goodAssets: _toInt(map['good_assets']),
      maintenanceAssets: _toInt(map['maintenance_assets']),
      damagedAssets: _toInt(map['damaged_assets']),
      criticalAssets: _toInt(map['critical_assets']),
      dangerousAssets: _toInt(map['dangerous_assets']),
      highContaminationAssets:
          _toInt(map['high_contamination_assets']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
}