// SATU FILE UNTUK SEMUA HIERARKI (HOSPITAL -> BUILDING -> FLOOR -> ROOM -> DETECTOR)

class HospitalProfile {
  final String id;
  final String name;
  final String? address;
  final String? logoUrl;
  final List<Building>? buildings;

  HospitalProfile({
    required this.id,
    required this.name,
    this.address,
    this.logoUrl,
    this.buildings,
  });

  factory HospitalProfile.fromMap(Map<String, dynamic> map) {
    return HospitalProfile(
      id: map['id'],
      name: map['name'] ?? '',
      address: map['address'],
      logoUrl: map['logo_url'],
      buildings: map['buildings'] != null
          ? (map['buildings'] as List).map((x) => Building.fromMap(x)).toList()
          : null,
    );
  }
}

class Building {
  final String id;
  final String buildingName;
  final int totalFloors;
  final List<Floor>? floors;

  Building({
    required this.id, 
    required this.buildingName, 
    required this.totalFloors, 
    this.floors
  });

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      id: map['id'],
      buildingName: map['building_name'] ?? '',
      totalFloors: map['total_floors'] ?? 1,
      floors: map['floors'] != null
          ? (map['floors'] as List).map((x) => Floor.fromMap(x)).toList()
          : null,
    );
  }
}

class Floor {
  final String id;
  final String floorAlias;
  final List<Room>? rooms;
  final Building? building;

  Floor({
    required this.id, 
    required this.floorAlias, 
    this.rooms, 
    this.building
  });

  factory Floor.fromMap(Map<String, dynamic> map) {
    return Floor(
      id: map['id'],
      floorAlias: map['floor_alias'] ?? '',
      building: map['buildings'] != null ? Building.fromMap(map['buildings']) : null,
      rooms: map['rooms'] != null
          ? (map['rooms'] as List).map((x) => Room.fromMap(x)).toList()
          : null,
    );
  }
}

class Room {
  final String id;
  final String roomName;
  final double xPos;
  final double yPos;
  final bool isEntryGate;
  final Detector? detector; 
  final Floor? floor;

  Room({
    required this.id,
    required this.roomName,
    required this.xPos,
    required this.yPos,
    this.isEntryGate = false,
    this.detector,
    this.floor,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      roomName: map['room_name'] ?? '',
      xPos: (map['x_pos'] ?? 0.0).toDouble(),
      yPos: (map['y_pos'] ?? 0.0).toDouble(),
      isEntryGate: map['is_entry_gate'] ?? false,
      detector: map['detectors'] != null ? Detector.fromMap(map['detectors']) : null,
      floor: map['floors'] != null ? Floor.fromMap(map['floors']) : null,
    );
  }
}

class Detector {
  final String id;
  final String detectorCode;
  final bool isActive;
  final Room? room;

  Detector({
    required this.id,
    required this.detectorCode,
    required this.isActive,
    this.room,
  });

  factory Detector.fromMap(Map<String, dynamic> map) {
    return Detector(
      id: map['id'],
      detectorCode: map['detector_code'] ?? '',
      isActive: map['is_active'] ?? true,
      room: map['rooms'] != null ? Room.fromMap(map['rooms']) : null,
    );
  }
}