// File: lib/insights/hospital/models/occupancy_summary.dart

class OccupancySummary {
  final int totalBeds;
  final int occupiedBeds;
  final int emptyBeds;
  final int maintenanceBeds;
  final double occupancyRate;

  OccupancySummary({
    required this.totalBeds,
    required this.occupiedBeds,
    required this.emptyBeds,
    required this.maintenanceBeds,
    required this.occupancyRate,
  });

  factory OccupancySummary.empty() {
    return OccupancySummary(
      totalBeds: 0,
      occupiedBeds: 0,
      emptyBeds: 0,
      maintenanceBeds: 0,
      occupancyRate: 0.0,
    );
  }
}

class OccupancyPerRoom {
  final String roomId;
  final String roomName;
  final int totalBeds;
  final int occupiedBeds;
  final double occupancyRate;

  OccupancyPerRoom({
    required this.roomId,
    required this.roomName,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.occupancyRate,
  });
}

class BedCategoryDistribution {
  final String categoryName;
  final String? colorCode;
  final int totalBeds;
  final int occupiedBeds;
  final double occupancyRate;

  BedCategoryDistribution({
    required this.categoryName,
    this.colorCode,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.occupancyRate,
  });
}

class ActivePatient {
  final String assignmentId;
  final String bedId;
  final String bedNumber;
  final String roomName;
  final String patientId;
  final String patientName;
  final DateTime assignedAt;
  final DateTime? predictedUntil;
  final String? notes;

  ActivePatient({
    required this.assignmentId,
    required this.bedId,
    required this.bedNumber,
    required this.roomName,
    required this.patientId,
    required this.patientName,
    required this.assignedAt,
    this.predictedUntil,
    this.notes,
  });

  int get daysSinceAdmission {
    return DateTime.now().difference(assignedAt).inDays;
  }

  int get daysUntilPredicted {
    if (predictedUntil == null) return 0;
    return predictedUntil!.difference(DateTime.now()).inDays;
  }
}