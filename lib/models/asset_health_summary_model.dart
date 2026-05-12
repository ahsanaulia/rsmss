class AssetHealthSummaryModel {
  final String statusCondition;

  final int totalAssets;
  final int activeAssets;

  final int dangerousAssets;
  final int highContaminationAssets;

  const AssetHealthSummaryModel({
    required this.statusCondition,
    required this.totalAssets,
    required this.activeAssets,
    required this.dangerousAssets,
    required this.highContaminationAssets,
  });

  factory AssetHealthSummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AssetHealthSummaryModel(
      statusCondition: map['status_condition'] ?? '',
      totalAssets: _toInt(map['total_assets']),
      activeAssets: _toInt(map['active_assets']),
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