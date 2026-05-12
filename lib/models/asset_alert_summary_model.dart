class AssetAlertSummaryModel {
  final int dangerousAssets;
  final int criticalContaminationAssets;
  final int criticalConditionAssets;
  final int overdueInspectionAssets;
  final int damagedAssets;

  final DateTime? generatedAt;

  const AssetAlertSummaryModel({
    required this.dangerousAssets,
    required this.criticalContaminationAssets,
    required this.criticalConditionAssets,
    required this.overdueInspectionAssets,
    required this.damagedAssets,
    required this.generatedAt,
  });

  factory AssetAlertSummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AssetAlertSummaryModel(
      dangerousAssets:
          _toInt(map['dangerous_assets']),
      criticalContaminationAssets:
          _toInt(map['critical_contamination_assets']),
      criticalConditionAssets:
          _toInt(map['critical_condition_assets']),
      overdueInspectionAssets:
          _toInt(map['overdue_inspection_assets']),
      damagedAssets:
          _toInt(map['damaged_assets']),
      generatedAt:
          _toDateTime(map['generated_at']),
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