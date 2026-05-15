import 'package:geolocator/geolocator.dart';

class ShiftModel {
  final String id;
  final String shiftName;
  final String shiftCode;
  final String startTime;
  final String endTime;

  ShiftModel({
    required this.id,
    required this.shiftName,
    required this.shiftCode,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id']?.toString() ?? '',
      shiftName: json['shift_name'] ?? '-',
      shiftCode: json['shift_code'] ?? '-',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class ActiveAttendanceModel {
  final String id;
  final String? shiftId;
  final DateTime? checkIn;
  final String? sessionId;

  ActiveAttendanceModel({
    required this.id,
    this.shiftId,
    this.checkIn,
    this.sessionId,
  });

  factory ActiveAttendanceModel.fromJson(Map<String, dynamic> json) {
    return ActiveAttendanceModel(
      id: json['id']?.toString() ?? '',
      shiftId: json['shift_id']?.toString(),
      checkIn: json['check_in'] != null ? DateTime.parse(json['check_in']) : null,
      sessionId: json['session_id']?.toString(),
    );
  }
}

class LocationInfo {
  final Position position;
  final String address;

  LocationInfo({required this.position, required this.address});
}