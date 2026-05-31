// File: lib/insights/hospital/models/hospital_overview_summary.dart

class HospitalOverviewSummary {
  final int totalBuildings;
  final int totalFloors;
  final int totalRooms;
  final int totalEmployees;
  final int totalUnits;
  final int presentToday;
  final double occupancyRate;

  HospitalOverviewSummary({
    required this.totalBuildings,
    required this.totalFloors,
    required this.totalRooms,
    required this.totalEmployees,
    required this.totalUnits,
    required this.presentToday,
    required this.occupancyRate,
  });

  factory HospitalOverviewSummary.empty() {
    return HospitalOverviewSummary(
      totalBuildings: 0,
      totalFloors: 0,
      totalRooms: 0,
      totalEmployees: 0,
      totalUnits: 0,
      presentToday: 0,
      occupancyRate: 0.0,
    );
  }
}