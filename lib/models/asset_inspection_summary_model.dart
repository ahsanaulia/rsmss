class AssetInspectionSummaryModel {
  final int overdueInspectionAssets;
  final int inspectionDueToday;
  final int inspectionDueThisWeek;
  final int neverInspectedAssets;

  final DateTime? generatedAt;

  const AssetInspectionSummaryModel({
    required this.overdueInspectionAssets,
    required this.inspectionDueToday,
    required this.inspectionDueThisWeek,
    required this.neverInspectedAssets,
    required this.generatedAt,
  });

  factory AssetInspectionSummaryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AssetInspectionSummaryModel(
      overdueInspectionAssets:
          _toInt(map['overdue_inspection_assets']),
      inspectionDueToday:
          _toInt(map['inspection_due_today']),
      inspectionDueThisWeek:
          _toInt(map['inspection_due_this_week']),
      neverInspectedAssets:
          _toInt(map['never_inspected_assets']),
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