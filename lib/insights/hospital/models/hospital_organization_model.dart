// File: lib/insights/hospital/models/hospital_organization_model.dart

class EmployeeUnitNode {
  final String id;
  final String unitCode;
  final String unitName;
  final String? headOfUnitName;
  final int employeeCount;
  final List<EmployeeUnitNode> children;

  EmployeeUnitNode({
    required this.id,
    required this.unitCode,
    required this.unitName,
    this.headOfUnitName,
    this.employeeCount = 0,
    this.children = const [],
  });
}

class RoomCategoryDistribution {
  final String categoryName;
  final String? colorCode;
  final int totalRooms;

  RoomCategoryDistribution({
    required this.categoryName,
    this.colorCode,
    required this.totalRooms,
  });
}

class EmployeePerUnit {
  final String unitId;
  final String unitName;
  final int employeeCount;

  EmployeePerUnit({
    required this.unitId,
    required this.unitName,
    required this.employeeCount,
  });
}

class BuildingNode {
  final String id;
  final String buildingName;
  final int totalFloors;
  final int totalRooms;
  final List<FloorNode> floors;

  BuildingNode({
    required this.id,
    required this.buildingName,
    required this.totalFloors,
    required this.totalRooms,
    required this.floors,
  });
}

class FloorNode {
  final String id;
  final int floorNumber;
  final String? floorAlias;
  final int totalRooms;
  final List<RoomNode> rooms;

  FloorNode({
    required this.id,
    required this.floorNumber,
    this.floorAlias,
    required this.totalRooms,
    required this.rooms,
  });
}

class RoomNode {
  final String id;
  final String roomName;
  final String? categoryName;
  final String? categoryColor;

  RoomNode({
    required this.id,
    required this.roomName,
    this.categoryName,
    this.categoryColor,
  });
}