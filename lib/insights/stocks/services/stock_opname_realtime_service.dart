// File: lib/insights/stocks/services/stock_opname_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/stock_opname_model.dart';
import '../models/stock_opname_summary_model.dart';
import '../models/stock_opname_anomaly_model.dart';
import '../models/stock_opname_trend_model.dart';

class StockOpnameRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY KPI - REALTIME
  // ============================================================
  Stream<StockOpnameSummaryModel> watchSummary() {
    debugPrint('🟢 [REALTIME] watchOpnameSummary: initializing...');
    final controller = StreamController<StockOpnameSummaryModel>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchOpnameSummary: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchOpnameSummary: initial error - $e');
      if (!controller.isClosed) controller.add(StockOpnameSummaryModel.empty());
    });
    
    final channel = _supabase
        .channel('stocks_opnames_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchOpnameSummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchOpnameSummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<StockOpnameSummaryModel> _fetchSummary() async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('adjustment_stock');
      
      final data = response as List;
      
      int totalOpnames = data.length;
      double totalAdjustment = 0;
      double totalAbsAdjustment = 0;
      int problematicItems = 0;
      
      // Track per stock untuk problematic items
      final Map<String, double> stockAdjustments = {};
      
      for (final item in data) {
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        totalAdjustment += adjustment;
        totalAbsAdjustment += adjustment.abs();
      }
      
      // Ambil problematic items (adjustment >20% dari system stock)
      // Perlu query terpisah
      final stocksResponse = await _supabase
          .from('stocks_opnames')
          .select('stock_id, stock_before, adjustment_stock')
          .not('stock_before', 'is', null)
          .gt('stock_before', 0);
      
      final stocksData = stocksResponse as List;
      for (final item in stocksData) {
        final stockId = item['stock_id']?.toString();
        final stockBefore = (item['stock_before'] ?? 0).toDouble();
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        
        if (stockBefore > 0) {
          final percentage = (adjustment.abs() / stockBefore) * 100;
          if (percentage > 20 && stockId != null) {
            if (!stockAdjustments.containsKey(stockId)) {
              stockAdjustments[stockId] = 0;
            }
            stockAdjustments[stockId] = stockAdjustments[stockId]! + 1;
          }
        }
      }
      
      problematicItems = stockAdjustments.length;
      
      final avgAdjustment = totalOpnames > 0 ? (totalAdjustment / totalOpnames).toDouble() : 0.0;
      
      return StockOpnameSummaryModel(
        totalOpnames: totalOpnames,
        totalAdjustment: totalAdjustment,
        totalAbsAdjustment: totalAbsAdjustment,
        avgAdjustment: avgAdjustment,
        problematicItems: problematicItems,
      );
    } catch (e) {
      debugPrint('❌ _fetchSummary error: $e');
      return StockOpnameSummaryModel.empty();
    }
  }

  // ============================================================
  // 2. OPNAME RESULT DISTRIBUTION (MATCH/SURPLUS/SHORTAGE)
  // ============================================================
  Stream<Map<String, int>> watchOpnameDistribution() {
    debugPrint('🟢 [REALTIME] watchOpnameDistribution: initializing...');
    final controller = StreamController<Map<String, int>>.broadcast();
    
    _fetchOpnameDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchOpnameDistribution: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchOpnameDistribution: initial error - $e');
      if (!controller.isClosed) controller.add({});
    });
    
    final channel = _supabase
        .channel('stocks_opnames_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchOpnameDistribution: change detected, refetching...');
            final newData = await _fetchOpnameDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchOpnameDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<Map<String, int>> _fetchOpnameDistribution() async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('adjustment_stock');
      
      final data = response as List;
      
      int match = 0;
      int surplus = 0;
      int shortage = 0;
      
      for (final item in data) {
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        if (adjustment == 0) {
          match++;
        } else if (adjustment > 0) {
          surplus++;
        } else {
          shortage++;
        }
      }
      
      final result = <String, int>{};
      if (match > 0) result['MATCH'] = match;
      if (surplus > 0) result['SURPLUS'] = surplus;
      if (shortage > 0) result['SHORTAGE'] = shortage;
      
      return result;
    } catch (e) {
      debugPrint('❌ _fetchOpnameDistribution error: $e');
      return {};
    }
  }

  // ============================================================
  // 3. TOP ITEMS WITH LARGEST DISCREPANCY
  // ============================================================
  Stream<List<StockOpnameAnomalyItemModel>> watchTopDiscrepancyItems() {
    debugPrint('🟢 [REALTIME] watchTopDiscrepancyItems: initializing...');
    final controller = StreamController<List<StockOpnameAnomalyItemModel>>.broadcast();
    
    _fetchTopDiscrepancyItems().then((value) {
      debugPrint('✅ [REALTIME] watchTopDiscrepancyItems: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTopDiscrepancyItems: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_top_items')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTopDiscrepancyItems: change detected, refetching...');
            final newData = await _fetchTopDiscrepancyItems();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTopDiscrepancyItems: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameAnomalyItemModel>> _fetchTopDiscrepancyItems({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            stock_id,
            adjustment_stock,
            stock_before,
            opname_at,
            stocks!stocks_opnames_stock_id_fkey(stock_name, unit)
          ''')
          .not('adjustment_stock', 'is', null)
          .order('adjustment_stock', ascending: false);
      
      final data = response as List;
      final Map<String, StockOpnameAnomalyItemModel> itemMap = {};
      
      for (final item in data) {
        final stockId = item['stock_id']?.toString();
        final stockData = item['stocks'];
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        final stockBefore = (item['stock_before'] ?? 0).toDouble();
        
        if (stockId == null) continue;
        
        final percentage = stockBefore > 0 ? (adjustment.abs() / stockBefore) * 100 : 0;
        
        if (!itemMap.containsKey(stockId) || 
            adjustment.abs() > itemMap[stockId]!.discrepancy.abs()) {
          itemMap[stockId] = StockOpnameAnomalyItemModel(
            stockId: stockId,
            stockName: stockData?['stock_name'] ?? 'Unknown',
            unit: stockData?['unit'] ?? '',
            discrepancy: adjustment,
            discrepancyPercent: percentage,
            opnameAt: DateTime.tryParse(item['opname_at']?.toString() ?? '') ?? DateTime.now(),
            stockBefore: stockBefore,
          );
        }
      }
      
      var result = itemMap.values.toList();
      result.sort((a, b) => b.discrepancy.abs().compareTo(a.discrepancy.abs()));
      return result.take(limit).toList();
    } catch (e) {
      debugPrint('❌ _fetchTopDiscrepancyItems error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. TREND SELISIH PER BULAN
  // ============================================================
  Stream<List<StockOpnameTrendModel>> watchTrendPerMonth() {
    debugPrint('🟢 [REALTIME] watchTrendPerMonth: initializing...');
    final controller = StreamController<List<StockOpnameTrendModel>>.broadcast();
    
    _fetchTrendPerMonth().then((value) {
      debugPrint('✅ [REALTIME] watchTrendPerMonth: initial data loaded, months=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTrendPerMonth: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_trend')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTrendPerMonth: change detected, refetching...');
            final newData = await _fetchTrendPerMonth();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTrendPerMonth: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameTrendModel>> _fetchTrendPerMonth({int months = 12}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: months * 30));
      
      final response = await _supabase
          .from('stocks_opnames')
          .select('opname_at, adjustment_stock')
          .gte('opname_at', startDate.toIso8601String());
      
      final data = response as List;
      final Map<String, StockOpnameTrendModel> trendMap = {};
      
      for (final item in data) {
        final opnameAtStr = item['opname_at']?.toString();
        if (opnameAtStr == null) continue;
        
        final date = DateTime.parse(opnameAtStr);
        final monthKey = DateFormat('yyyy-MM').format(date);
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        
        if (!trendMap.containsKey(monthKey)) {
          trendMap[monthKey] = StockOpnameTrendModel(
            month: DateTime(date.year, date.month, 1),
            totalDiscrepancy: 0,
            totalOpnames: 0,
          );
        }
        
        final existing = trendMap[monthKey]!;
        trendMap[monthKey] = StockOpnameTrendModel(
          month: existing.month,
          totalDiscrepancy: existing.totalDiscrepancy + adjustment,
          totalOpnames: existing.totalOpnames + 1,
        );
      }
      
      var result = trendMap.values.toList();
      result.sort((a, b) => a.month.compareTo(b.month));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchTrendPerMonth error: $e');
      return [];
    }
  }

  // ============================================================
  // 5. UNUSUAL DISCREPANCY (>20%)
  // ============================================================
  Stream<List<StockOpnameAnomalyItemModel>> watchUnusualDiscrepancy() {
    debugPrint('🟢 [REALTIME] watchUnusualDiscrepancy: initializing...');
    final controller = StreamController<List<StockOpnameAnomalyItemModel>>.broadcast();
    
    _fetchUnusualDiscrepancy().then((value) {
      debugPrint('✅ [REALTIME] watchUnusualDiscrepancy: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchUnusualDiscrepancy: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_unusual')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchUnusualDiscrepancy: change detected, refetching...');
            final newData = await _fetchUnusualDiscrepancy();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchUnusualDiscrepancy: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameAnomalyItemModel>> _fetchUnusualDiscrepancy() async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            stock_id,
            bin_id,
            stock_in_bins_id,
            adjustment_stock,
            stock_before,
            opname_at,
            opname_by,
            stocks!stocks_opnames_stock_id_fkey(stock_name, unit),
            stock_bins!stocks_opnames_bin_id_fkey(bin_name, shelf_id),
            profiles!stocks_opnames_opname_by_fkey(full_name)
          ''')
          .not('stock_before', 'is', null)
          .gt('stock_before', 0);
      
      final data = response as List;
      final List<StockOpnameAnomalyItemModel> anomalies = [];
      
      for (final item in data) {
        final stockBefore = (item['stock_before'] ?? 0).toDouble();
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        
        if (stockBefore > 0) {
          final percentage = (adjustment.abs() / stockBefore) * 100;
          if (percentage > 20) {
            final stockData = item['stocks'];
            final binData = item['stock_bins'];
            final profileData = item['profiles'];
            
            anomalies.add(StockOpnameAnomalyItemModel(
              stockId: item['stock_id']?.toString() ?? '',
              stockName: stockData?['stock_name'] ?? 'Unknown',
              unit: stockData?['unit'] ?? '',
              discrepancy: adjustment,
              discrepancyPercent: percentage,
              opnameAt: DateTime.tryParse(item['opname_at']?.toString() ?? '') ?? DateTime.now(),
              stockBefore: stockBefore,
              binId: item['bin_id']?.toString(),
              binName: binData?['bin_name']?.toString(),
              opnameBy: item['opname_by']?.toString(),
              opnameByName: profileData?['full_name']?.toString(),
            ));
          }
        }
      }
      
      anomalies.sort((a, b) => b.discrepancyPercent.compareTo(a.discrepancyPercent));
      return anomalies.take(20).toList();
    } catch (e) {
      debugPrint('❌ _fetchUnusualDiscrepancy error: $e');
      return [];
    }
  }

  // ============================================================
  // 6. FREQUENT DISCREPANCY ITEMS (3+ kali dalam 3 bulan)
  // ============================================================
  Stream<List<StockOpnameAnomalyItemModel>> watchFrequentDiscrepancy() {
    debugPrint('🟢 [REALTIME] watchFrequentDiscrepancy: initializing...');
    final controller = StreamController<List<StockOpnameAnomalyItemModel>>.broadcast();
    
    _fetchFrequentDiscrepancy().then((value) {
      debugPrint('✅ [REALTIME] watchFrequentDiscrepancy: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchFrequentDiscrepancy: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_frequent')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchFrequentDiscrepancy: change detected, refetching...');
            final newData = await _fetchFrequentDiscrepancy();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchFrequentDiscrepancy: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameAnomalyItemModel>> _fetchFrequentDiscrepancy() async {
    try {
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            stock_id,
            adjustment_stock,
            stock_before,
            opname_at,
            stocks!stocks_opnames_stock_id_fkey(stock_name, unit)
          ''')
          .gte('opname_at', threeMonthsAgo.toIso8601String())
          .not('stock_before', 'is', null)
          .gt('stock_before', 0);
      
      final data = response as List;
      final Map<String, List<double>> stockDiscrepancies = {};
      
      for (final item in data) {
        final stockId = item['stock_id']?.toString();
        final stockBefore = (item['stock_before'] ?? 0).toDouble();
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        
        if (stockId != null && stockBefore > 0) {
          final percentage = (adjustment.abs() / stockBefore) * 100;
          if (!stockDiscrepancies.containsKey(stockId)) {
            stockDiscrepancies[stockId] = [];
          }
          stockDiscrepancies[stockId]!.add(percentage);
        }
      }
      
      final List<StockOpnameAnomalyItemModel> anomalies = [];
      
      for (final entry in stockDiscrepancies.entries) {
        if (entry.value.length >= 3) {
          final stockData = data.firstWhere(
            (item) => item['stock_id']?.toString() == entry.key,
            orElse: () => {},
          );
          final stockInfo = stockData['stocks'];
          
          anomalies.add(StockOpnameAnomalyItemModel(
            stockId: entry.key,
            stockName: stockInfo?['stock_name'] ?? 'Unknown',
            unit: stockInfo?['unit'] ?? '',
            discrepancy: 0,
            discrepancyPercent: entry.value.reduce((a, b) => a + b) / entry.value.length,
            opnameAt: DateTime.now(),
            stockBefore: 0,
            frequency: entry.value.length,
          ));
        }
      }
      
      anomalies.sort((a, b) => b.frequency.compareTo(a.frequency));
      return anomalies.take(10).toList();
    } catch (e) {
      debugPrint('❌ _fetchFrequentDiscrepancy error: $e');
      return [];
    }
  }

  // ============================================================
  // 7. PATTERN BY PERSON (selalu surplus/shortage)
  // ============================================================
  Stream<List<StockOpnameAnomalyPersonModel>> watchPatternByPerson() {
    debugPrint('🟢 [REALTIME] watchPatternByPerson: initializing...');
    final controller = StreamController<List<StockOpnameAnomalyPersonModel>>.broadcast();
    
    _fetchPatternByPerson().then((value) {
      debugPrint('✅ [REALTIME] watchPatternByPerson: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchPatternByPerson: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_person')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchPatternByPerson: change detected, refetching...');
            final newData = await _fetchPatternByPerson();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchPatternByPerson: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameAnomalyPersonModel>> _fetchPatternByPerson() async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            opname_by,
            adjustment_stock,
            profiles!stocks_opnames_opname_by_fkey(full_name)
          ''')
          .not('opname_by', 'is', null);
      
      final data = response as List;
      final Map<String, Map<String, dynamic>> personStats = {};
      
      for (final item in data) {
        final personId = item['opname_by']?.toString();
        final profileData = item['profiles'];
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        
        if (personId == null) continue;
        
        if (!personStats.containsKey(personId)) {
          personStats[personId] = {
            'name': profileData?['full_name'] ?? 'Unknown',
            'totalOpnames': 0,
            'surplusCount': 0,
            'shortageCount': 0,
            'matchCount': 0,
          };
        }
        
        final stats = personStats[personId]!;
        stats['totalOpnames'] = stats['totalOpnames'] + 1;
        
        if (adjustment == 0) {
          stats['matchCount'] = stats['matchCount'] + 1;
        } else if (adjustment > 0) {
          stats['surplusCount'] = stats['surplusCount'] + 1;
        } else {
          stats['shortageCount'] = stats['shortageCount'] + 1;
        }
      }
      
      final List<StockOpnameAnomalyPersonModel> anomalies = [];
      
      for (final entry in personStats.entries) {
        final stats = entry.value;
        final total = stats['totalOpnames'] as int;
        final surplusPercent = (stats['surplusCount'] as int) / total;
        final shortagePercent = (stats['shortageCount'] as int) / total;
        
        if (surplusPercent > 0.7) {
          anomalies.add(StockOpnameAnomalyPersonModel(
            personId: entry.key,
            personName: stats['name'],
            pattern: 'SURPLUS',
            percentage: surplusPercent * 100,
            totalOpnames: total,
          ));
        } else if (shortagePercent > 0.7) {
          anomalies.add(StockOpnameAnomalyPersonModel(
            personId: entry.key,
            personName: stats['name'],
            pattern: 'SHORTAGE',
            percentage: shortagePercent * 100,
            totalOpnames: total,
          ));
        }
      }
      
      anomalies.sort((a, b) => b.percentage.compareTo(a.percentage));
      return anomalies.take(10).toList();
    } catch (e) {
      debugPrint('❌ _fetchPatternByPerson error: $e');
      return [];
    }
  }

  // ============================================================
  // 8. ANOMALY PER BIN (Kebocoran di bin mana)
  // ============================================================
  Stream<List<StockOpnameAnomalyBinModel>> watchAnomalyPerBin() {
    debugPrint('🟢 [REALTIME] watchAnomalyPerBin: initializing...');
    final controller = StreamController<List<StockOpnameAnomalyBinModel>>.broadcast();
    
    _fetchAnomalyPerBin().then((value) {
      debugPrint('✅ [REALTIME] watchAnomalyPerBin: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchAnomalyPerBin: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_per_bin')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchAnomalyPerBin: change detected, refetching...');
            final newData = await _fetchAnomalyPerBin();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchAnomalyPerBin: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameAnomalyBinModel>> _fetchAnomalyPerBin() async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            bin_id,
            stock_id,
            adjustment_stock,
            stock_before,
            opname_at,
            stocks!stocks_opnames_stock_id_fkey(stock_name, unit),
            stock_bins!stocks_opnames_bin_id_fkey(
              bin_name,
              shelf_id,
              stock_shelves!stock_bins_shelf_id_fkey(
                shelf_name,
                rack_id,
                stock_racks!stock_shelves_rack_id_fkey(
                  rack_name,
                  zone_id,
                  stock_zones!stock_racks_zone_id_fkey(
                    zone_name,
                    warehouse_id,
                    stock_warehouses!stock_zones_warehouse_id_fkey(
                      warehouse_name
                    )
                  )
                )
              )
            )
          ''')
          .not('bin_id', 'is', null);
      
      final data = response as List;
      final Map<String, StockOpnameAnomalyBinModel> binMap = {};
      
      for (final item in data) {
        final binId = item['bin_id']?.toString();
        if (binId == null) continue;
        
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        final stockBefore = (item['stock_before'] ?? 0).toDouble();
        final percentage = stockBefore > 0 ? (adjustment.abs() / stockBefore) * 100 : 0;
        
        final binData = item['stock_bins'];
        final shelfData = binData?['stock_shelves'];
        final rackData = shelfData?['stock_racks'];
        final zoneData = rackData?['stock_zones'];
        final warehouseData = zoneData?['stock_warehouses'];
        final stockData = item['stocks'];
        
        if (!binMap.containsKey(binId)) {
          binMap[binId] = StockOpnameAnomalyBinModel(
            binId: binId,
            binName: binData?['bin_name']?.toString() ?? 'Unknown',
            shelfName: shelfData?['shelf_name']?.toString(),
            rackName: rackData?['rack_name']?.toString(),
            zoneName: zoneData?['zone_name']?.toString(),
            warehouseName: warehouseData?['warehouse_name']?.toString(),
            totalDiscrepancy: 0,
            totalPercentage: 0,
            count: 0,
            topItems: [],
          );
        }
        
        final bin = binMap[binId]!;
        bin.totalDiscrepancy += adjustment.abs();
        bin.totalPercentage += percentage;
        bin.count += 1;
        
        if (stockData != null) {
          bin.topItems.add(StockOpnameAnomalyItemModel(
            stockId: item['stock_id']?.toString() ?? '',
            stockName: stockData['stock_name'] ?? 'Unknown',
            unit: stockData['unit'] ?? '',
            discrepancy: adjustment,
            discrepancyPercent: percentage,
            opnameAt: DateTime.tryParse(item['opname_at']?.toString() ?? '') ?? DateTime.now(),
            stockBefore: stockBefore,
          ));
        }
      }
      
      var result = binMap.values.toList();
      for (final bin in result) {
        bin.avgPercentage = bin.count > 0 ? bin.totalPercentage / bin.count : 0;
        bin.topItems.sort((a, b) => b.discrepancyPercent.compareTo(a.discrepancyPercent));
        bin.topItems = bin.topItems.take(3).toList();
      }
      result.sort((a, b) => b.avgPercentage.compareTo(a.avgPercentage));
      return result.take(10).toList();
    } catch (e) {
      debugPrint('❌ _fetchAnomalyPerBin error: $e');
      return [];
    }
  }

  // ============================================================
  // 9. RECENT OPNAME HISTORY (Table)
  // ============================================================
  Stream<List<StockOpnameModel>> watchRecentOpnames() {
    debugPrint('🟢 [REALTIME] watchRecentOpnames: initializing...');
    final controller = StreamController<List<StockOpnameModel>>.broadcast();
    
    _fetchRecentOpnames().then((value) {
      debugPrint('✅ [REALTIME] watchRecentOpnames: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchRecentOpnames: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stocks_opnames_recent')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchRecentOpnames: change detected, refetching...');
            final newData = await _fetchRecentOpnames();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchRecentOpnames: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockOpnameModel>> _fetchRecentOpnames({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            id,
            stock_id,
            stock_before,
            physical_stock,
            adjustment_stock,
            opname_note,
            opname_at,
            opname_by,
            bin_id,
            stock_in_bins_id,
            batch_number,
            expiry_date,
            opname_type,
            stocks!stocks_opnames_stock_id_fkey(stock_name, unit),
            profiles!stocks_opnames_opname_by_fkey(full_name)
          ''')
          .order('opname_at', ascending: false)
          .limit(limit);
      
      final data = response as List;
      final List<StockOpnameModel> opnames = [];
      
      for (final item in data) {
        final stockData = item['stocks'];
        final profileData = item['profiles'];
        
        final stockBefore = (item['stock_before'] ?? 0).toDouble();
        final physicalStock = (item['physical_stock'] ?? 0).toDouble();
        final adjustment = (item['adjustment_stock'] ?? 0).toDouble();
        
        opnames.add(StockOpnameModel(
          id: item['id']?.toString() ?? '',
          stockId: item['stock_id']?.toString() ?? '',
          stockName: stockData?['stock_name'] ?? 'Unknown',
          unit: stockData?['unit'] ?? '',
          stockBefore: stockBefore,
          physicalStock: physicalStock,
          adjustmentStock: adjustment,
          discrepancyPercent: stockBefore > 0 ? (adjustment.abs() / stockBefore) * 100 : 0,
          opnameNote: item['opname_note']?.toString(),
          opnameAt: DateTime.tryParse(item['opname_at']?.toString() ?? '') ?? DateTime.now(),
          opnameBy: item['opname_by']?.toString(),
          opnameByName: profileData?['full_name']?.toString(),
          binId: item['bin_id']?.toString(),
          stockInBinsId: item['stock_in_bins_id']?.toString(),
          batchNumber: item['batch_number']?.toString(),
          expiryDate: item['expiry_date'] != null 
              ? DateTime.tryParse(item['expiry_date'].toString())
              : null,
          opnameType: item['opname_type'] ?? 'PRODUCT',
        ));
      }
      
      return opnames;
    } catch (e) {
      debugPrint('❌ _fetchRecentOpnames error: $e');
      return [];
    }
  }
}