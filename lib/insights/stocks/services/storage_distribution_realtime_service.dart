// File: lib/insights/stocks/services/storage_distribution_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/storage_summary_model.dart';
import '../models/storage_bin_model.dart';
import '../models/storage_hierarchy_model.dart';
import '../models/storage_trend_model.dart';

class StorageDistributionRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY (KPI CARDS) - REALTIME
  // ============================================================
  Stream<StorageSummaryModel> watchSummary() {
    debugPrint('🟢 [REALTIME] watchStorageSummary: initializing...');
    final controller = StreamController<StorageSummaryModel>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchStorageSummary: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStorageSummary: initial error - $e');
      if (!controller.isClosed) controller.add(StorageSummaryModel.empty());
    });
    
    final channel = _supabase
        .channel('storage_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStorageSummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStorageSummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<StorageSummaryModel> _fetchSummary() async {
    try {
      final warehouses = await _supabase.from('stock_warehouses').select('id');
      final zones = await _supabase.from('stock_zones').select('id');
      final racks = await _supabase.from('stock_racks').select('id');
      final shelves = await _supabase.from('stock_shelves').select('id');
      final bins = await _supabase
          .from('stock_bins')
          .select('current_quantity, max_quantity')
          .eq('is_active', true);
      
      final binsData = bins as List;
      double totalUtilization = 0;
      int binsWithMax = 0;
      
      for (final bin in binsData) {
        final current = (bin['current_quantity'] ?? 0).toDouble();
        final max = (bin['max_quantity'] ?? 0).toDouble();
        if (max > 0) {
          totalUtilization += (current / max) * 100;
          binsWithMax++;
        }
      }
      
      final avgUtilization = binsWithMax > 0 ? (totalUtilization / binsWithMax).toDouble() : 0.0;
      
      return StorageSummaryModel(
        totalWarehouses: (warehouses as List).length,
        totalZones: (zones as List).length,
        totalRacks: (racks as List).length,
        totalShelves: (shelves as List).length,
        totalBins: (bins as List).length,
        avgUtilization: avgUtilization,
      );
    } catch (e) {
      debugPrint('❌ _fetchSummary error: $e');
      return StorageSummaryModel.empty();
    }
  }

  // ============================================================
  // 2. DISTRIBUSI PER WAREHOUSE (Donut Chart)
  // ============================================================
  Stream<Map<String, int>> watchDistributionPerWarehouse() {
    debugPrint('🟢 [REALTIME] watchDistributionPerWarehouse: initializing...');
    final controller = StreamController<Map<String, int>>.broadcast();
    
    _fetchDistributionPerWarehouse().then((value) {
      debugPrint('✅ [REALTIME] watchDistributionPerWarehouse: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchDistributionPerWarehouse: initial error - $e');
      if (!controller.isClosed) controller.add({});
    });
    
    final channel = _supabase
        .channel('storage_warehouse_dist')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchDistributionPerWarehouse: change detected, refetching...');
            final newData = await _fetchDistributionPerWarehouse();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchDistributionPerWarehouse: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<Map<String, int>> _fetchDistributionPerWarehouse() async {
    try {
      final response = await _supabase
          .from('stock_warehouses')
          .select('''
            id,
            name,
            stock_zones!stock_zones_warehouse_id_fkey(
              stock_racks!stock_racks_zone_id_fkey(
                stock_shelves!stock_shelves_rack_id_fkey(
                  stock_bins!stock_bins_shelf_id_fkey(
                    id
                  )
                )
              )
            )
          ''');
      
      final data = response as List;
      final Map<String, int> distribution = {};
      
      for (final warehouse in data) {
        final name = warehouse['name'] ?? 'Unknown';
        int binCount = 0;
        
        final zones = warehouse['stock_zones'] as List?;
        if (zones != null) {
          for (final zone in zones) {
            final racks = zone['stock_racks'] as List?;
            if (racks != null) {
              for (final rack in racks) {
                final shelves = rack['stock_shelves'] as List?;
                if (shelves != null) {
                  for (final shelf in shelves) {
                    final bins = shelf['stock_bins'] as List?;
                    if (bins != null) {
                      binCount += bins.length;
                    }
                  }
                }
              }
            }
          }
        }
        
        if (binCount > 0) {
          distribution[name] = binCount;
        }
      }
      
      return distribution;
    } catch (e) {
      debugPrint('❌ _fetchDistributionPerWarehouse error: $e');
      return {};
    }
  }

  // ============================================================
  // 3. TOP 10 BIN BY STOCK QTY
  // ============================================================
  Stream<List<StorageTopBinModel>> watchTopBinsByStockQty() {
    debugPrint('🟢 [REALTIME] watchTopBinsByStockQty: initializing...');
    final controller = StreamController<List<StorageTopBinModel>>.broadcast();
    
    _fetchTopBinsByStockQty().then((value) {
      debugPrint('✅ [REALTIME] watchTopBinsByStockQty: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTopBinsByStockQty: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('storage_top_bins_qty')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_in_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTopBinsByStockQty: change detected, refetching...');
            final newData = await _fetchTopBinsByStockQty();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTopBinsByStockQty: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StorageTopBinModel>> _fetchTopBinsByStockQty({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            bin_id,
            quantity,
            stock_bins!stock_in_bins_bin_id_fkey(
              id,
              code,
              current_quantity,
              max_quantity,
              stock_shelves!stock_bins_shelf_id_fkey(
                code,
                stock_racks!stock_shelves_rack_id_fkey(
                  name,
                  stock_zones!stock_racks_zone_id_fkey(
                    name,
                    stock_warehouses!stock_zones_warehouse_id_fkey(
                      name
                    )
                  )
                )
              )
            )
          ''')
          .gt('quantity', 0);
      
      final data = response as List;
      final Map<String, double> binQuantities = {};
      final Map<String, Map<String, dynamic>> binDetails = {};
      
      for (final item in data) {
        final binId = item['bin_id']?.toString();
        final qty = (item['quantity'] ?? 0).toDouble();
        final binData = item['stock_bins'];
        
        if (binId == null) continue;
        
        binQuantities[binId] = (binQuantities[binId] ?? 0) + qty;
        
        if (!binDetails.containsKey(binId) && binData != null) {
          final shelfData = binData['stock_shelves'];
          final rackData = shelfData?['stock_racks'];
          final zoneData = rackData?['stock_zones'];
          final warehouseData = zoneData?['stock_warehouses'];
          
          binDetails[binId] = {
            'binCode': binData['code'] ?? 'Unknown',
            'shelfName': shelfData?['code'] ?? 'Unknown',
            'rackName': rackData?['name'] ?? 'Unknown',
            'zoneName': zoneData?['name'] ?? 'Unknown',
            'warehouseName': warehouseData?['name'] ?? 'Unknown',
            'currentQuantity': (binData['current_quantity'] ?? 0).toDouble(),
            'maxQuantity': binData['max_quantity'] != null 
                ? (binData['max_quantity'] as num).toDouble() 
                : null,
          };
        }
      }
      
      final List<MapEntry<String, double>> sortedEntries = binQuantities.entries.toList();
      sortedEntries.sort((a, b) => b.value.compareTo(a.value));
      
      final List<StorageTopBinModel> topBins = [];
      
      for (int i = 0; i < sortedEntries.length && i < limit; i++) {
        final entry = sortedEntries[i];
        final details = binDetails[entry.key];
        
        if (details != null) {
          final maxQty = details['maxQuantity'] as double?;
          final utilization = maxQty != null && maxQty > 0 
              ? ((details['currentQuantity'] as double) / maxQty) * 100 
              : 0.0;
          
          final bin = StorageBinModel(
            binId: entry.key,
            binCode: details['binCode'],
            shelfName: details['shelfName'],
            rackName: details['rackName'],
            zoneName: details['zoneName'],
            warehouseName: details['warehouseName'],
            currentQuantity: details['currentQuantity'],
            maxQuantity: maxQty,
            utilization: utilization,
            stockCount: 0,
            fulfillmentCount: 0,
          );
          
          topBins.add(StorageTopBinModel(bin: bin, value: entry.value));
        }
      }
      
      return topBins;
    } catch (e) {
      debugPrint('❌ _fetchTopBinsByStockQty error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. BIN UTILIZATION (PALING PENUH)
  // ============================================================
  Stream<List<StorageTopBinModel>> watchTopUtilizedBins() {
    debugPrint('🟢 [REALTIME] watchTopUtilizedBins: initializing...');
    final controller = StreamController<List<StorageTopBinModel>>.broadcast();
    
    _fetchTopUtilizedBins().then((value) {
      debugPrint('✅ [REALTIME] watchTopUtilizedBins: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTopUtilizedBins: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('storage_utilized_bins')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'stock_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTopUtilizedBins: change detected, refetching...');
            final newData = await _fetchTopUtilizedBins();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTopUtilizedBins: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StorageTopBinModel>> _fetchTopUtilizedBins({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('stock_bins')
          .select('''
            id,
            code,
            current_quantity,
            max_quantity,
            stock_shelves!stock_bins_shelf_id_fkey(
              code,
              stock_racks!stock_shelves_rack_id_fkey(
                name,
                stock_zones!stock_racks_zone_id_fkey(
                  name,
                  stock_warehouses!stock_zones_warehouse_id_fkey(
                    name
                  )
                )
              )
            )
          ''')
          .eq('is_active', true)
          .not('max_quantity', 'is', null)
          .gt('max_quantity', 0);
      
      final data = response as List;
      final List<StorageTopBinModel> bins = [];
      
      for (final item in data) {
        final current = (item['current_quantity'] ?? 0).toDouble();
        final max = (item['max_quantity'] as num).toDouble();
        final utilization = (current / max) * 100;
        
        final shelfData = item['stock_shelves'];
        final rackData = shelfData?['stock_racks'];
        final zoneData = rackData?['stock_zones'];
        final warehouseData = zoneData?['stock_warehouses'];
        
        final bin = StorageBinModel(
          binId: item['id']?.toString() ?? '',
          binCode: item['code'] ?? 'Unknown',
          shelfName: shelfData?['code'] ?? 'Unknown',
          rackName: rackData?['name'] ?? 'Unknown',
          zoneName: zoneData?['name'] ?? 'Unknown',
          warehouseName: warehouseData?['name'] ?? 'Unknown',
          currentQuantity: current,
          maxQuantity: max,
          utilization: utilization,
          stockCount: 0,
          fulfillmentCount: 0,
        );
        
        bins.add(StorageTopBinModel(bin: bin, value: utilization));
      }
      
      bins.sort((a, b) => b.value.compareTo(a.value));
      return bins.take(limit).toList();
    } catch (e) {
      debugPrint('❌ _fetchTopUtilizedBins error: $e');
      return [];
    }
  }

  // ============================================================
  // 5. BIN PALING SERING DIAMBIL
  // ============================================================
  Stream<List<StorageTopBinModel>> watchMostFulfilledBins() {
    debugPrint('🟢 [REALTIME] watchMostFulfilledBins: initializing...');
    final controller = StreamController<List<StorageTopBinModel>>.broadcast();
    
    _fetchMostFulfilledBins().then((value) {
      debugPrint('✅ [REALTIME] watchMostFulfilledBins: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchMostFulfilledBins: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('storage_fulfilled_bins')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stock_request_fulfillments',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchMostFulfilledBins: change detected, refetching...');
            final newData = await _fetchMostFulfilledBins();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchMostFulfilledBins: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StorageTopBinModel>> _fetchMostFulfilledBins({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('stock_request_fulfillments')
          .select('''
            bin_id,
            stock_bins!stock_request_fulfillments_bin_id_fkey(
              id,
              code,
              current_quantity,
              max_quantity,
              stock_shelves!stock_bins_shelf_id_fkey(
                code,
                stock_racks!stock_shelves_rack_id_fkey(
                  name,
                  stock_zones!stock_racks_zone_id_fkey(
                    name,
                    stock_warehouses!stock_zones_warehouse_id_fkey(
                      name
                    )
                  )
                )
              )
            )
          ''');
      
      final data = response as List;
      final Map<String, int> binCounts = {};
      final Map<String, Map<String, dynamic>> binDetails = {};
      
      for (final item in data) {
        final binId = item['bin_id']?.toString();
        final binData = item['stock_bins'];
        
        if (binId == null) continue;
        
        binCounts[binId] = (binCounts[binId] ?? 0) + 1;
        
        if (!binDetails.containsKey(binId) && binData != null) {
          final shelfData = binData['stock_shelves'];
          final rackData = shelfData?['stock_racks'];
          final zoneData = rackData?['stock_zones'];
          final warehouseData = zoneData?['stock_warehouses'];
          
          binDetails[binId] = {
            'binCode': binData['code'] ?? 'Unknown',
            'shelfName': shelfData?['code'] ?? 'Unknown',
            'rackName': rackData?['name'] ?? 'Unknown',
            'zoneName': zoneData?['name'] ?? 'Unknown',
            'warehouseName': warehouseData?['name'] ?? 'Unknown',
            'currentQuantity': (binData['current_quantity'] ?? 0).toDouble(),
            'maxQuantity': binData['max_quantity'] != null 
                ? (binData['max_quantity'] as num).toDouble() 
                : null,
          };
        }
      }
      
      final List<MapEntry<String, int>> sortedEntries = binCounts.entries.toList();
      sortedEntries.sort((a, b) => b.value.compareTo(a.value));
      
      final List<StorageTopBinModel> topBins = [];
      
      for (int i = 0; i < sortedEntries.length && i < limit; i++) {
        final entry = sortedEntries[i];
        final details = binDetails[entry.key];
        
        if (details != null) {
          final maxQty = details['maxQuantity'] as double?;
          final utilization = maxQty != null && maxQty > 0 
              ? ((details['currentQuantity'] as double) / maxQty) * 100 
              : 0.0;
          
          final bin = StorageBinModel(
            binId: entry.key,
            binCode: details['binCode'],
            shelfName: details['shelfName'],
            rackName: details['rackName'],
            zoneName: details['zoneName'],
            warehouseName: details['warehouseName'],
            currentQuantity: details['currentQuantity'],
            maxQuantity: maxQty,
            utilization: utilization,
            stockCount: 0,
            fulfillmentCount: entry.value,
          );
          
          topBins.add(StorageTopBinModel(bin: bin, value: entry.value.toDouble()));
        }
      }
      
      return topBins;
    } catch (e) {
      debugPrint('❌ _fetchMostFulfilledBins error: $e');
      return [];
    }
  }

  // ============================================================
  // 6. STOCK MENDEKATI EXPIRED (<=30 hari)
  // ============================================================
  Stream<List<StockExpiryModel>> watchExpiringStock() {
    debugPrint('🟢 [REALTIME] watchExpiringStock: initializing...');
    final controller = StreamController<List<StockExpiryModel>>.broadcast();
    
    _fetchExpiringStock().then((value) {
      debugPrint('✅ [REALTIME] watchExpiringStock: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchExpiringStock: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('storage_expiring_stock')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_in_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchExpiringStock: change detected, refetching...');
            final newData = await _fetchExpiringStock();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchExpiringStock: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockExpiryModel>> _fetchExpiringStock() async {
    try {
      final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            stock_id,
            batch_number,
            expiry_date,
            quantity,
            bin_id,
            stocks!stock_in_bins_stock_id_fkey(stock_name, unit),
            stock_bins!stock_in_bins_bin_id_fkey(
              code,
              stock_shelves!stock_bins_shelf_id_fkey(
                code,
                stock_racks!stock_shelves_rack_id_fkey(
                  name,
                  stock_zones!stock_racks_zone_id_fkey(
                    name,
                    stock_warehouses!stock_zones_warehouse_id_fkey(
                      name
                    )
                  )
                )
              )
            )
          ''')
          .not('expiry_date', 'is', null)
          .lte('expiry_date', dateFormat.format(thirtyDaysFromNow))
          .gt('quantity', 0);
      
      final data = response as List;
      final List<StockExpiryModel> expiries = [];
      
      for (final item in data) {
        final stockData = item['stocks'];
        final binData = item['stock_bins'];
        
        String warehouseName = 'Unknown';
        if (binData != null) {
          final shelfData = binData['stock_shelves'];
          final rackData = shelfData?['stock_racks'];
          final zoneData = rackData?['stock_zones'];
          final warehouseData = zoneData?['stock_warehouses'];
          warehouseName = warehouseData?['name'] ?? 'Unknown';
        }
        
        final expiryDate = DateTime.tryParse(item['expiry_date'].toString());
        if (expiryDate != null) {
          expiries.add(StockExpiryModel(
            stockId: item['stock_id']?.toString() ?? '',
            stockName: stockData?['stock_name'] ?? 'Unknown',
            unit: stockData?['unit'] ?? '',
            binCode: binData?['code'] ?? 'Unknown',
            warehouseName: warehouseName,
            expiryDate: expiryDate,
            quantity: (item['quantity'] ?? 0).toDouble(),
            batchNumber: item['batch_number'] ?? '',
          ));
        }
      }
      
      expiries.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
      return expiries;
    } catch (e) {
      debugPrint('❌ _fetchExpiringStock error: $e');
      return [];
    }
  }

  // ============================================================
  // 7. STOCK IN SOURCE DISTRIBUTION
  // ============================================================
  Stream<List<StockInSourceModel>> watchStockInSourceDistribution() {
    debugPrint('🟢 [REALTIME] watchStockInSourceDistribution: initializing...');
    final controller = StreamController<List<StockInSourceModel>>.broadcast();
    
    _fetchStockInSourceDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchStockInSourceDistribution: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStockInSourceDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stock_in_source')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stock_in',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStockInSourceDistribution: change detected, refetching...');
            final newData = await _fetchStockInSourceDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStockInSourceDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockInSourceModel>> _fetchStockInSourceDistribution() async {
    try {
      final response = await _supabase
          .from('stock_in')
          .select('source_type, quantity')
          .eq('status', 'COMPLETED');
      
      final data = response as List;
      final Map<String, StockInSourceModel> sourceMap = {};
      
      for (final item in data) {
        final sourceType = item['source_type'] ?? 'UNKNOWN';
        final qty = (item['quantity'] ?? 0).toDouble();
        
        if (!sourceMap.containsKey(sourceType)) {
          sourceMap[sourceType] = StockInSourceModel(
            sourceType: sourceType,
            totalQuantity: 0,
            totalCount: 0,
          );
        }
        
        final existing = sourceMap[sourceType]!;
        sourceMap[sourceType] = StockInSourceModel(
          sourceType: sourceType,
          totalQuantity: existing.totalQuantity + qty,
          totalCount: existing.totalCount + 1,
        );
      }
      
      var result = sourceMap.values.toList();
      result.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchStockInSourceDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 8. TREND STOCK IN PER BULAN
  // ============================================================
  Stream<List<StorageTrendModel>> watchStockInTrend() {
    debugPrint('🟢 [REALTIME] watchStockInTrend: initializing...');
    final controller = StreamController<List<StorageTrendModel>>.broadcast();
    
    _fetchStockInTrend().then((value) {
      debugPrint('✅ [REALTIME] watchStockInTrend: initial data loaded, months=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStockInTrend: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stock_in_trend')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stock_in',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStockInTrend: change detected, refetching...');
            final newData = await _fetchStockInTrend();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStockInTrend: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StorageTrendModel>> _fetchStockInTrend({int months = 12}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: months * 30));
      
      final response = await _supabase
          .from('stock_in')
          .select('received_at, quantity')
          .eq('status', 'COMPLETED')
          .gte('received_at', startDate.toIso8601String());
      
      final data = response as List;
      final Map<String, StorageTrendModel> trendMap = {};
      
      for (final item in data) {
        final receivedAtStr = item['received_at']?.toString();
        if (receivedAtStr == null) continue;
        
        final date = DateTime.parse(receivedAtStr);
        final monthKey = DateFormat('yyyy-MM').format(date);
        final qty = (item['quantity'] ?? 0).toDouble();
        
        if (!trendMap.containsKey(monthKey)) {
          trendMap[monthKey] = StorageTrendModel(
            month: DateTime(date.year, date.month, 1),
            totalStockInQuantity: 0,
            totalStockInCount: 0,
          );
        }
        
        final existing = trendMap[monthKey]!;
        trendMap[monthKey] = StorageTrendModel(
          month: existing.month,
          totalStockInQuantity: existing.totalStockInQuantity + qty,
          totalStockInCount: existing.totalStockInCount + 1,
        );
      }
      
      var result = trendMap.values.toList();
      result.sort((a, b) => a.month.compareTo(b.month));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchStockInTrend error: $e');
      return [];
    }
  }

  // ============================================================
  // 9. STORAGE HIERARCHY VIEWER (Tree)
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
    // Ambil semua warehouse, zone, rack, shelf, bin (struktur fisik)
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
                  current_quantity,
                  max_quantity
                )
              )
            )
          )
        ''')
        .eq('is_active', true);
    
    // Ambil quantity aktual dari stock_in_bins (stok yang sebenarnya)
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
                      
                      // 🔥 AMBIL STOCK DARI stock_in_bins, BUKAN current_quantity
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
}