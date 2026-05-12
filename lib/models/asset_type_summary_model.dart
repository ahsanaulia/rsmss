class AssetTypeSummaryModel {
  final String typeId;
  final String typeName;

  final String? iconName;
  final String? markerColor;

  final String subCategoryId;
  final String subCategoryName;

  final String categoryId;
  final String categoryName;

  final int totalAssets;
  final int activeAssets;

  final int goodAssets;
  final int maintenanceAssets;
  final int damagedAssets;
  final int criticalAssets;

  final int dangerousAssets;
  final int highContaminationAssets;

  const AssetTypeSummaryModel({
    required this.typeId,
    required this.typeName,
    required this.iconName,
    required this.markerColor,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.categoryId,
    required this.categoryName,
    required this.totalAssets,
    required this.activeAssets,
    required this.goodAssets,
    required this.maintenanceAssets,
    required this.damagedAssets,
    required this.criticalAssets,
    required this.dangerousAssets,
    required this.highContaminationAssets,
  });

  factory AssetTypeSummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AssetTypeSummaryModel(
      typeId: map['type_id'] ?? '',
      typeName: map['type_name'] ?? '',
      iconName: map['icon_name'],
      markerColor: map['marker_color'],
      subCategoryId: map['sub_category_id'] ?? '',
      subCategoryName: map['sub_category_name'] ?? '',
      categoryId: map['category_id'] ?? '',
      categoryName: map['category_name'] ?? '',
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