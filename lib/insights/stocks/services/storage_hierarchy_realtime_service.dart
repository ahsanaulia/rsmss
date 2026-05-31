// File: lib/insights/stocks/services/storage_hierarchy_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/storage_hierarchy_model.dart';
import '../models/bin_stock_detail_model.dart';

class StorageHierarchyRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. STORAGE HIERARCHY (REALTIME)
  // ============================================================
  Stream<List<StorageWarehouseModel>> watchStorageHierarchy() {
    debugPrint('🟢 [REALTIME] watchStorageHierarchy: initializing...');
    final controller = StreamController<List<StorageWarehouseModel>>.broadcast();
    
    _fetchStorageHierarchy().then((value) {
      debugPrint('✅ [REALTIME] watchStorageHierarchy: initial data loaded, warehouses=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStorageHierarchy: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('storage_hierarchy')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStorageHierarchy: change detected, refetching...');
            final newData = await _fetchStorageHierarchy();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStorageHierarchy: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StorageWarehouseModel>> _fetchStorageHierarchy() async {
    try {
      final response = await _supabase
          .from('stock_warehouses')
          .select('''
            id,
            name,
            stock_zones!stock_zones_warehouse_id_fkey(
              id,
              name,
              stock_racks!stock_racks_zone_id_fkey(
                id,
                name,
                stock_shelves!stock_shelves_rack_id_fkey(
                  id,
                  code,
                  stock_bins!stock_bins_shelf_id_fkey(
                    id,
                    code,
                    max_quantity
                  )
                )
              )
            )
          ''')
          .eq('is_active', true);
      
      final stockInBinsResponse = await _supabase
          .from('stock_in_bins')
          .select('bin_id, quantity')
          .gt('quantity', 0);
      
      final stockInBinsData = stockInBinsResponse as List;
      final Map<String, double> binStockMap = {};
      
      for (final item in stockInBinsData) {
        final binId = item['bin_id']?.toString();
        final qty = (item['quantity'] ?? 0).toDouble();
        if (binId != null) {
          binStockMap[binId] = (binStockMap[binId] ?? 0) + qty;
        }
      }
      
      final data = response as List;
      final List<StorageWarehouseModel> warehouses = [];
      
      for (final warehouse in data) {
        final warehouseId = warehouse['id']?.toString() ?? '';
        final warehouseName = warehouse['name'] ?? 'Unknown';
        
        final zones = <StorageZoneModel>[];
        int warehouseTotalBins = 0;
        double warehouseTotalStock = 0;
        
        final zonesData = warehouse['stock_zones'] as List?;
        if (zonesData != null) {
          for (final zone in zonesData) {
            final zoneId = zone['id']?.toString() ?? '';
            final zoneName = zone['name'] ?? 'Unknown';
            
            final racks = <StorageRackModel>[];
            int zoneTotalBins = 0;
            double zoneTotalStock = 0;
            
            final racksData = zone['stock_racks'] as List?;
            if (racksData != null) {
              for (final rack in racksData) {
                final rackId = rack['id']?.toString() ?? '';
                final rackName = rack['name'] ?? 'Unknown';
                
                final shelves = <StorageShelfModel>[];
                int rackTotalBins = 0;
                double rackTotalStock = 0;
                
                final shelvesData = rack['stock_shelves'] as List?;
                if (shelvesData != null) {
                  for (final shelf in shelvesData) {
                    final shelfId = shelf['id']?.toString() ?? '';
                    final shelfName = shelf['code'] ?? 'Unknown';
                    
                    final bins = <StorageBinNodeModel>[];
                    int shelfTotalBins = 0;
                    double shelfTotalStock = 0;
                    
                    final binsData = shelf['stock_bins'] as List?;
                    if (binsData != null) {
                      for (final bin in binsData) {
                        final binId = bin['id']?.toString() ?? '';
                        final binCode = bin['code'] ?? 'Unknown';
                        final max = bin['max_quantity'] != null 
                            ? (bin['max_quantity'] as num).toDouble() 
                            : null;
                        
                        final currentStock = binStockMap[binId] ?? 0;
                        final utilization = max != null && max > 0 
                            ? (currentStock / max) * 100 
                            : 0.0;
                        
                        bins.add(StorageBinNodeModel(
                          id: binId,
                          code: binCode,
                          currentQuantity: currentStock,
                          maxQuantity: max,
                          utilization: utilization,
                        ));
                        
                        shelfTotalBins++;
                        shelfTotalStock += currentStock;
                      }
                    }
                    
                    shelves.add(StorageShelfModel(
                      id: shelfId,
                      name: shelfName,
                      bins: bins,
                      totalBins: shelfTotalBins,
                      totalStock: shelfTotalStock,
                    ));
                    
                    rackTotalBins += shelfTotalBins;
                    rackTotalStock += shelfTotalStock;
                  }
                }
                
                racks.add(StorageRackModel(
                  id: rackId,
                  name: rackName,
                  shelves: shelves,
                  totalBins: rackTotalBins,
                  totalStock: rackTotalStock,
                ));
                
                zoneTotalBins += rackTotalBins;
                zoneTotalStock += rackTotalStock;
              }
            }
            
            zones.add(StorageZoneModel(
              id: zoneId,
              name: zoneName,
              racks: racks,
              totalBins: zoneTotalBins,
              totalStock: zoneTotalStock,
            ));
            
            warehouseTotalBins += zoneTotalBins;
            warehouseTotalStock += zoneTotalStock;
          }
        }
        
        warehouses.add(StorageWarehouseModel(
          id: warehouseId,
          name: warehouseName,
          zones: zones,
          totalBins: warehouseTotalBins,
          totalStock: warehouseTotalStock,
        ));
      }
      
      return warehouses;
    } catch (e) {
      debugPrint('❌ _fetchStorageHierarchy error: $e');
      return [];
    }
  }

  // ============================================================
  // 2. AMBIL STOCK DETAIL PER BIN (TIDAK REALTIME)
  // ============================================================
  Future<List<BinStockDetailModel>> getStockDetailsByBinId(String binId) async {
    try {
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            id,
            stock_id,
            batch_number,
            expiry_date,
            quantity,
            put_away_by,
            put_away_at,
            scanned_bin_barcode,
            stocks!stock_in_bins_stock_id_fkey(stock_name, unit),
            profiles!stock_in_bins_put_away_by_fkey(full_name)
          ''')
          .eq('bin_id', binId)
          .gt('quantity', 0);
      
      final data = response as List;
      final List<BinStockDetailModel> details = [];
      
      for (final item in data) {
        final stockData = item['stocks'];
        final profileData = item['profiles'];
        
        details.add(BinStockDetailModel(
          stockInBinsId: item['id']?.toString() ?? '',
          stockId: item['stock_id']?.toString() ?? '',
          stockName: stockData?['stock_name'] ?? 'Unknown',
          unit: stockData?['unit'] ?? '',
          batchNumber: item['batch_number'] ?? '',
          expiryDate: DateTime.tryParse(item['expiry_date'].toString()) ?? DateTime.now(),
          quantity: (item['quantity'] ?? 0).toDouble(),
          putAwayBy: item['put_away_by']?.toString(),
          putAwayByName: profileData?['full_name']?.toString(),
          putAwayAt: item['put_away_at'] != null 
              ? DateTime.tryParse(item['put_away_at'].toString())
              : null,
          barcode: item['scanned_bin_barcode']?.toString(),
        ));
      }
      
      details.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      return details;
    } catch (e) {
      debugPrint('❌ getStockDetailsByBinId error: $e');
      return [];
    }
  }
}