// lib/insights/profiles/models/shift_model.dart

class ShiftModel {
  final String id;
  final String shiftName;
  final String shiftCode;
  final String startTime;
  final String endTime;
  final bool isCrossDay;
  final int toleranceLateMinutes;
  final bool isActive;
  final String? colorHex;
  final String? iconName;

  ShiftModel({
    required this.id,
    required this.shiftName,
    required this.shiftCode,
    required this.startTime,
    required this.endTime,
    required this.isCrossDay,
    required this.toleranceLateMinutes,
    required this.isActive,
    this.colorHex,
    this.iconName,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'].toString(),
      shiftName: json['shift_name'] ?? '',
      shiftCode: json['shift_code'] ?? '',
      startTime: json['start_time'] ?? '00:00:00',
      endTime: json['end_time'] ?? '00:00:00',
      isCrossDay: json['is_cross_day'] ?? false,
      toleranceLateMinutes: json['tolerance_late_minutes'] ?? 15,
      isActive: json['is_active'] ?? true,
      colorHex: json['color_hex'],
      iconName: json['icon_name'],
    );
  }

  String get shiftPeriod => '$startTime - $endTime';
}