// File: lib/insights/stocks/models/storage_hierarchy_model.dart

class StorageWarehouseModel {
  final String id;
  final String name;
  final List<StorageZoneModel> zones;
  final int totalBins;
  final double totalStock;

  StorageWarehouseModel({
    required this.id,
    required this.name,
    required this.zones,
    required this.totalBins,
    required this.totalStock,
  });
}

class StorageZoneModel {
  final String id;
  final String name;
  final List<StorageRackModel> racks;
  final int totalBins;
  final double totalStock;

  StorageZoneModel({
    required this.id,
    required this.name,
    required this.racks,
    required this.totalBins,
    required this.totalStock,
  });
}

class StorageRackModel {
  final String id;
  final String name;
  final List<StorageShelfModel> shelves;
  final int totalBins;
  final double totalStock;

  StorageRackModel({
    required this.id,
    required this.name,
    required this.shelves,
    required this.totalBins,
    required this.totalStock,
  });
}

class StorageShelfModel {
  final String id;
  final String name;
  final List<StorageBinNodeModel> bins;
  final int totalBins;
  final double totalStock;

  StorageShelfModel({
    required this.id,
    required this.name,
    required this.bins,
    required this.totalBins,
    required this.totalStock,
  });
}

class StorageBinNodeModel {
  final String id;
  final String code;
  final double currentQuantity;
  final double? maxQuantity;
  final double utilization;

  StorageBinNodeModel({
    required this.id,
    required this.code,
    required this.currentQuantity,
    this.maxQuantity,
    required this.utilization,
  });
}