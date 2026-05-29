// File: lib/insights/stocks/models/storage_summary_model.dart

class StorageSummaryModel {
  final int totalWarehouses;
  final int totalZones;
  final int totalRacks;
  final int totalShelves;
  final int totalBins;
  final double avgUtilization;

  StorageSummaryModel({
    required this.totalWarehouses,
    required this.totalZones,
    required this.totalRacks,
    required this.totalShelves,
    required this.totalBins,
    required this.avgUtilization,
  });

  factory StorageSummaryModel.empty() {
    return StorageSummaryModel(
      totalWarehouses: 0,
      totalZones: 0,
      totalRacks: 0,
      totalShelves: 0,
      totalBins: 0,
      avgUtilization: 0.0,
    );
  }
}