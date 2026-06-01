// lib/features/bed_assignments/models/bed_model.dart

class SimpleBedModel {
  final String id;
  final String bedNumber;
  final String status;
  final String? roomId;
  final String? roomName;
  final String? floorNumber;
  final String? buildingName;

  SimpleBedModel({
    required this.id,
    required this.bedNumber,
    required this.status,
    this.roomId,
    this.roomName,
    this.floorNumber,
    this.buildingName,
  });

  factory SimpleBedModel.fromJson(Map<String, dynamic> json) {
    // Ambil data dari relasi rooms
    final room = json['rooms'] as Map<String, dynamic>?;
    final floor = room?['floors'] as Map<String, dynamic>?;
    final building = floor?['buildings'] as Map<String, dynamic>?;

    return SimpleBedModel(
      id: json['id'] ?? '',
      bedNumber: json['bed_number'] ?? '-',
      status: json['status'] ?? 'EMPTY',
      roomId: room?['id'],
      roomName: room?['room_name'],
      floorNumber: floor?['floor_number']?.toString(),
      buildingName: building?['building_name'],
    );
  }

  // Cek apakah bed tersedia (status = EMPTY atau available)
  bool get isAvailable => status == 'EMPTY' || status == 'available';

  String get fullLocation {
    final parts = <String>[];
    if (buildingName != null && buildingName!.isNotEmpty) parts.add(buildingName!);
    if (floorNumber != null && floorNumber!.isNotEmpty) parts.add('Lantai $floorNumber');
    if (roomName != null && roomName!.isNotEmpty) parts.add(roomName!);
    parts.add('Bed $bedNumber');
    return parts.join(' - ');
  }
}