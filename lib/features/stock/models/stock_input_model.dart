import 'dart:io';

class StockInputModel {
  final String stockCode;
  final String stockName;
  final String? stockTypeId;
  final String unit;
  final double minimumStock;
  final double currentStock;
  final String? storageLocationId;
  final String stockCondition;
  final String? batchNumber;
  final DateTime? expiryDate;
  final File? photo;
  final String? description;

  StockInputModel({
    required this.stockCode,
    required this.stockName,
    this.stockTypeId,
    required this.unit,
    this.minimumStock = 0,
    required this.currentStock,
    this.storageLocationId,
    this.stockCondition = 'GOOD',
    this.batchNumber,
    this.expiryDate,
    this.photo,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'stock_code': stockCode,
    'stock_name': stockName,
    'stock_type_id': stockTypeId,
    'unit': unit,
    'minimum_stock': minimumStock,
    'current_stock': currentStock,
    'storage_location_id': storageLocationId,
    'stock_condition': stockCondition,
    'batch_number': batchNumber,
    'expiry_date': expiryDate?.toIso8601String(),
    'description': description,
  };
}