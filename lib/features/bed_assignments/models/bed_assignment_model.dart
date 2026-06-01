// lib/features/bed_assignments/models/bed_assignment_model.dart

class BedAssignmentModel {
  final String id;
  final String peopleId;
  final String peopleName;
  final String bedId;
  final String bedNumber;
  final String bedLocation;
  final DateTime assignedAt;
  final DateTime? predictedUntil;
  final DateTime? dischargedAt;
  final String? notes;

  BedAssignmentModel({
    required this.id,
    required this.peopleId,
    required this.peopleName,
    required this.bedId,
    required this.bedNumber,
    required this.bedLocation,
    required this.assignedAt,
    this.predictedUntil,
    this.dischargedAt,
    this.notes,
  });

  factory BedAssignmentModel.fromJson(Map<String, dynamic> json) {
    final people = json['people'] as Map<String, dynamic>?;
    final bed = json['bed'] as Map<String, dynamic>?;
    final room = bed?['rooms'] as Map<String, dynamic>?;
    final floor = room?['floors'] as Map<String, dynamic>?;
    final building = floor?['buildings'] as Map<String, dynamic>?;

    final locationParts = <String>[];
    if (building?['building_name'] != null) locationParts.add(building!['building_name']);
    if (floor?['floor_number'] != null) locationParts.add('Lantai ${floor!['floor_number']}');
    if (room?['room_name'] != null) locationParts.add(room!['room_name']);
    locationParts.add('Bed ${bed?['bed_number'] ?? '-'}');

    return BedAssignmentModel(
      id: json['id'] ?? '',
      peopleId: people?['id'] ?? '',
      peopleName: people?['full_name'] ?? '-',
      bedId: bed?['id'] ?? '',
      bedNumber: bed?['bed_number'] ?? '-',
      bedLocation: locationParts.join(' - '),
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : DateTime.now(),
      predictedUntil: json['predicted_until'] != null
          ? DateTime.parse(json['predicted_until'])
          : null,
      dischargedAt: json['discharged_at'] != null
          ? DateTime.parse(json['discharged_at'])
          : null,
      notes: json['notes'],
    );
  }

  bool get isActive => dischargedAt == null;
}