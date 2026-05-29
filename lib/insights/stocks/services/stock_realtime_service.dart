// File: lib/insights/stocks/services/stock_realtime_service.dart

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/stock_summary_model.dart';
import '../models/stock_trend_model.dart';
import '../models/stock_prediction_model.dart';
import '../models/stock_velocity_model.dart';
import '../models/stock_expiry_model.dart';
import '../models/stock_slow_moving_model.dart';
import '../models/stock_category_value_model.dart';
import '../models/stock_discrepancy_model.dart';
import '../models/stock_storage_model.dart';

class StockRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY (KPI CARDS)
  // ============================================================
  Stream<StockSummaryModel> watchSummary() {
    debugPrint('🟢 [REALTIME] watchSummary: initializing...');
    final controller = StreamController<StockSummaryModel>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchSummary: initial data loaded, totalItems=${value.totalItems}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchSummary: initial error - $e');
      if (!controller.isClosed) controller.add(StockSummaryModel.empty());
    });
    
    final channel = _supabase
        .channel('stocks_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchSummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
            debugPrint('✅ [REALTIME] watchSummary: updated, totalItems=${newData.totalItems}');
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchSummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<StockSummaryModel> _fetchSummary() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('id, current_stock, minimum_stock, last_purchase_price')
          .eq('is_active', true);

      final data = response as List;

      int totalItems = data.length;
      double totalQuantity = 0;
      int lowStock = 0;
      int emptyStock = 0;
      double stockValue = 0;

      for (final item in data) {
        final current = (item['current_stock'] ?? 0).toDouble();
        final min = (item['minimum_stock'] ?? 0).toDouble();
        final price = (item['last_purchase_price'] ?? 0).toDouble();

        totalQuantity += current;
        if (current <= min && current > 0) lowStock++;
        if (current <= 0) emptyStock++;
        stockValue += current * price;
      }

      return StockSummaryModel(
        totalItems: totalItems,
        totalQuantity: totalQuantity,
        lowStock: lowStock,
        emptyStock: emptyStock,
        stockValue: stockValue,
      );
    } catch (e) {
      debugPrint('❌ _fetchSummary error: $e');
      return StockSummaryModel.empty();
    }
  }

  // ============================================================
  // 2. CATEGORY DISTRIBUTION
  // ============================================================
  Stream<Map<String, int>> watchCategoryDistribution() {
    debugPrint('🟢 [REALTIME] watchCategoryDistribution: initializing...');
    final controller = StreamController<Map<String, int>>.broadcast();
    
    _fetchCategoryDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchCategoryDistribution: initial data loaded, entries=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchCategoryDistribution: initial error - $e');
      if (!controller.isClosed) controller.add({});
    });
    
    final channel = _supabase
        .channel('category_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchCategoryDistribution: change detected, refetching...');
            final newData = await _fetchCategoryDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchCategoryDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<Map<String, int>> _fetchCategoryDistribution() async {
  try {
    final response = await _supabase
        .from('ref_stock_types')
        .select('''
          type_name,
          stocks!stocks_stock_type_id_fkey(id)
        ''');

    final data = response as List;
    final Map<String, int> result = {};

    for (final item in data) {
      final typeName = item['type_name'] ?? 'Unknown';
      final stocks = item['stocks'] as List?;
      final count = stocks?.length ?? 0;
      if (count > 0) {
        result[typeName] = count;
      }
    }

    if (result.isEmpty) {
      debugPrint('⚠️ _fetchCategoryDistribution: no data found');
      return {'Belum Ada Kategori': 1};
    }

    return result;
  } catch (e) {
    debugPrint('❌ _fetchCategoryDistribution error: $e');
    return {'Error Load Data': 1};
  }
}

  // ============================================================
  // 3. STOCK TREND (30 hari)
  // ============================================================
  Stream<List<StockTrendModel>> watchStockTrend() {
    debugPrint('🟢 [REALTIME] watchStockTrend: initializing...');
    final controller = StreamController<List<StockTrendModel>>.broadcast();
    
    _fetchStockTrend().then((value) {
      debugPrint('✅ [REALTIME] watchStockTrend: initial data loaded, entries=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStockTrend: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stock_trend')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stock_requests',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStockTrend: change detected, refetching...');
            final newData = await _fetchStockTrend();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStockTrend: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockTrendModel>> _fetchStockTrend() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final dateFormat = DateFormat('yyyy-MM-dd');

      final response = await _supabase
          .from('stock_requests')
          .select('created_at, requested_quantity')
          .eq('status', 'FULFILLED')
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final data = response as List;

      if (data.isEmpty) {
        debugPrint('⚠️ _fetchStockTrend: no data found');
        return [];
      }

      final Map<String, StockTrendModel> trendMap = {};

      for (final req in data) {
        final date = DateTime.parse(req['created_at'].toString());
        final dateKey = dateFormat.format(date);
        final qty = (req['requested_quantity'] ?? 0).toDouble();

        if (!trendMap.containsKey(dateKey)) {
          trendMap[dateKey] = StockTrendModel(
            date: date,
            inQuantity: 0,
            outQuantity: 0,
          );
        }

        final existing = trendMap[dateKey]!;
        trendMap[dateKey] = StockTrendModel(
          date: date,
          inQuantity: existing.inQuantity,
          outQuantity: existing.outQuantity + qty,
        );
      }

      var result = trendMap.values.toList();
      result.sort((a, b) => a.date.compareTo(b.date));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchStockTrend error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. STOCK OUT PREDICTION
  // ============================================================
  Stream<List<StockPredictionModel>> watchStockOutPrediction() {
    debugPrint('🟢 [REALTIME] watchStockOutPrediction: initializing...');
    final controller = StreamController<List<StockPredictionModel>>.broadcast();
    
    _fetchStockOutPrediction().then((value) {
      debugPrint('✅ [REALTIME] watchStockOutPrediction: initial data loaded, predictions=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStockOutPrediction: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('stock_prediction')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStockOutPrediction: change detected, refetching...');
            final newData = await _fetchStockOutPrediction();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStockOutPrediction: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockPredictionModel>> _fetchStockOutPrediction() async {
    try {
      final stocksResponse = await _supabase
          .from('stocks')
          .select('id, stock_name, unit, current_stock, minimum_stock')
          .eq('is_active', true);

      final stocks = stocksResponse as List;

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final requestsResponse = await _supabase
          .from('stock_requests')
          .select('requested_stock_id, requested_quantity')
          .eq('status', 'FULFILLED')
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final requests = requestsResponse as List;

      final Map<String, double> requestMap = {};
      for (final req in requests) {
        final stockId = req['requested_stock_id']?.toString();
        final qty = (req['requested_quantity'] ?? 0).toDouble();
        if (stockId != null) {
          requestMap[stockId] = (requestMap[stockId] ?? 0) + qty;
        }
      }

      final List<StockPredictionModel> predictions = [];

      for (final stock in stocks) {
        final stockId = stock['id'].toString();
        final stockName = stock['stock_name'] ?? '';
        final unit = stock['unit'] ?? '';
        final currentStock = (stock['current_stock'] ?? 0).toDouble();
        final minimumStock = (stock['minimum_stock'] ?? 0).toDouble();

        final totalRequest = requestMap[stockId] ?? 0;
        final dailyUsage = totalRequest / 30;

        if (dailyUsage <= 0) continue;

        final daysUntilEmpty = currentStock / dailyUsage;

        if (daysUntilEmpty <= 30) {
          predictions.add(StockPredictionModel(
            stockId: stockId,
            stockName: stockName,
            unit: unit,
            currentStock: currentStock,
            minimumStock: minimumStock,
            dailyUsage: dailyUsage,
            daysUntilEmpty: daysUntilEmpty,
          ));
        }
      }

      predictions.sort((a, b) => a.daysUntilEmpty.compareTo(b.daysUntilEmpty));
      return predictions.take(10).toList();
    } catch (e) {
      debugPrint('❌ _fetchStockOutPrediction error: $e');
      return [];
    }
  }

  // ============================================================
  // 5. TOP STOCK VELOCITY
  // ============================================================
  Stream<List<StockVelocityModel>> watchTopVelocity() {
    debugPrint('🟢 [REALTIME] watchTopVelocity: initializing...');
    final controller = StreamController<List<StockVelocityModel>>.broadcast();
    
    _fetchTopVelocity().then((value) {
      debugPrint('✅ [REALTIME] watchTopVelocity: initial data loaded, velocities=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTopVelocity: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('top_velocity')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stock_requests',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTopVelocity: change detected, refetching...');
            final newData = await _fetchTopVelocity();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTopVelocity: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockVelocityModel>> _fetchTopVelocity({int limit = 5}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final response = await _supabase
          .from('stock_requests')
          .select('''
            requested_stock_id,
            requested_quantity,
            stocks!stock_requests_requested_stock_id_fkey(stock_name, unit)
          ''')
          .eq('status', 'FULFILLED')
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final data = response as List;
      final Map<String, double> usageMap = {};
      final Map<String, Map<String, dynamic>> stockInfo = {};

      for (final req in data) {
        final stockId = req['requested_stock_id']?.toString();
        final qty = (req['requested_quantity'] ?? 0).toDouble();
        final stockData = req['stocks'];

        if (stockId != null && stockData != null) {
          usageMap[stockId] = (usageMap[stockId] ?? 0) + qty;
          if (!stockInfo.containsKey(stockId)) {
            stockInfo[stockId] = {
              'name': stockData['stock_name'] ?? 'Unknown',
              'unit': stockData['unit'] ?? '',
            };
          }
        }
      }

      final List<StockVelocityModel> velocities = [];
      for (final entry in usageMap.entries) {
        final info = stockInfo[entry.key];
        if (info != null) {
          velocities.add(StockVelocityModel(
            stockId: entry.key,
            stockName: info['name'],
            unit: info['unit'],
            totalOut30Days: entry.value,
            dailyUsage: entry.value / 30,
          ));
        }
      }

      velocities.sort((a, b) => b.totalOut30Days.compareTo(a.totalOut30Days));
      return velocities.take(limit).toList();
    } catch (e) {
      debugPrint('❌ _fetchTopVelocity error: $e');
      return [];
    }
  }

  // ============================================================
  // 6. EXPIRY ALERT
  // ============================================================
  Stream<List<StockExpiryModel>> watchExpiryAlert() {
    debugPrint('🟢 [REALTIME] watchExpiryAlert: initializing...');
    final controller = StreamController<List<StockExpiryModel>>.broadcast();
    
    _fetchExpiryAlert().then((value) {
      debugPrint('✅ [REALTIME] watchExpiryAlert: initial data loaded, expiries=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchExpiryAlert: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('expiry_alert')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_in_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchExpiryAlert: change detected, refetching...');
            final newData = await _fetchExpiryAlert();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchExpiryAlert: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockExpiryModel>> _fetchExpiryAlert() async {
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
            stocks!stock_in_bins_stock_id_fkey(stock_name, unit)
          ''')
          .not('expiry_date', 'is', null)
          .lte('expiry_date', dateFormat.format(thirtyDaysFromNow));

      final data = response as List;
      final Map<String, StockExpiryModel> latestExpiry = {};

      for (final item in data) {
        final stockId = item['stock_id']?.toString();
        final stockData = item['stocks'];
        final expiryDate = DateTime.tryParse(item['expiry_date'].toString());

        if (stockId != null && stockData != null && expiryDate != null) {
          final expiry = StockExpiryModel(
            stockId: stockId,
            stockName: stockData['stock_name'] ?? 'Unknown',
            unit: stockData['unit'] ?? '',
            expiryDate: expiryDate,
            quantity: (item['quantity'] ?? 0).toDouble(),
            batchNumber: item['batch_number']?.toString(),
          );

          if (!latestExpiry.containsKey(stockId)) {
            latestExpiry[stockId] = expiry;
          } else {
            final existing = latestExpiry[stockId]!;
            if (expiry.daysUntilExpiry < existing.daysUntilExpiry) {
              latestExpiry[stockId] = expiry;
            }
          }
        }
      }

      final expiries = latestExpiry.values.toList();
      expiries.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
      return expiries.take(10).toList();
    } catch (e) {
      debugPrint('❌ _fetchExpiryAlert error: $e');
      return [];
    }
  }

  // ============================================================
  // 7. SLOW MOVING STOCK
  // ============================================================
  Stream<List<StockSlowMovingModel>> watchSlowMovingStock() {
    debugPrint('🟢 [REALTIME] watchSlowMovingStock: initializing...');
    final controller = StreamController<List<StockSlowMovingModel>>.broadcast();
    
    _fetchSlowMovingStock().then((value) {
      debugPrint('✅ [REALTIME] watchSlowMovingStock: initial data loaded, slowMoving=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchSlowMovingStock: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('slow_moving')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchSlowMovingStock: change detected, refetching...');
            final newData = await _fetchSlowMovingStock();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchSlowMovingStock: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockSlowMovingModel>> _fetchSlowMovingStock() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('id, stock_name, unit, current_stock, last_usage_at')
          .eq('is_active', true);

      final data = response as List;
      final List<StockSlowMovingModel> slowMoving = [];

      for (final item in data) {
        final lastUsageAt = item['last_usage_at'] != null
            ? DateTime.tryParse(item['last_usage_at'].toString())
            : null;

        int daysInactive = 999;
        if (lastUsageAt != null) {
          daysInactive = DateTime.now().difference(lastUsageAt).inDays;
        } else {
          daysInactive = 999;
        }

        if (daysInactive > 30) {
          slowMoving.add(StockSlowMovingModel(
            stockId: item['id'].toString(),
            stockName: item['stock_name'] ?? 'Unknown',
            unit: item['unit'] ?? '',
            currentStock: (item['current_stock'] ?? 0).toDouble(),
            lastUsageAt: lastUsageAt,
            daysInactive: daysInactive,
          ));
        }
      }

      slowMoving.sort((a, b) => b.daysInactive.compareTo(a.daysInactive));
      return slowMoving.take(10).toList();
    } catch (e) {
      debugPrint('❌ _fetchSlowMovingStock error: $e');
      return [];
    }
  }

  // ============================================================
  // 8. STOCK VALUE PER CATEGORY
  // ============================================================
  Stream<List<StockCategoryValueModel>> watchStockValuePerCategory() {
    debugPrint('🟢 [REALTIME] watchStockValuePerCategory: initializing...');
    final controller = StreamController<List<StockCategoryValueModel>>.broadcast();
    
    _fetchStockValuePerCategory().then((value) {
      debugPrint('✅ [REALTIME] watchStockValuePerCategory: initial data loaded, categories=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStockValuePerCategory: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('category_value')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStockValuePerCategory: change detected, refetching...');
            final newData = await _fetchStockValuePerCategory();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStockValuePerCategory: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockCategoryValueModel>> _fetchStockValuePerCategory() async {
  try {
    final response = await _supabase
        .from('ref_stock_categories')
        .select('''
          category_name,
          ref_stock_sub_categories!ref_stock_sub_categories_category_id_fkey(
            ref_stock_types!ref_stock_types_sub_category_id_fkey(
              stocks!stocks_stock_type_id_fkey(
                current_stock,
                last_purchase_price
              )
            )
          )
        ''');

    final data = response as List;
    final Map<String, double> valueMap = {};

    for (final category in data) {
      final categoryName = category['category_name'] ?? 'Unknown';
      double totalValue = 0;

      final subCategories = category['ref_stock_sub_categories'] as List?;
      if (subCategories != null) {
        for (final subCat in subCategories) {
          final types = subCat['ref_stock_types'] as List?;
          if (types != null) {
            for (final type in types) {
              final stocks = type['stocks'] as List?;
              if (stocks != null) {
                for (final stock in stocks) {
                  final current = (stock['current_stock'] ?? 0).toDouble();
                  final price = (stock['last_purchase_price'] ?? 0).toDouble();
                  totalValue += current * price;
                }
              }
            }
          }
        }
      }

      if (totalValue > 0) {
        valueMap[categoryName] = totalValue;
      }
    }

    final List<StockCategoryValueModel> result = [];
    for (final entry in valueMap.entries) {
      result.add(StockCategoryValueModel(
        categoryName: entry.key,
        totalValue: entry.value,
      ));
    }

    result.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    return result.take(5).toList();
  } catch (e) {
    debugPrint('❌ _fetchStockValuePerCategory error: $e');
    return [];
  }
}

  // ============================================================
  // 9. STORAGE DISTRIBUTION (per WAREHOUSE)
  // ============================================================
  Stream<List<StockStorageModel>> watchStorageDistribution() {
    debugPrint('🟢 [REALTIME] watchStorageDistribution: initializing...');
    final controller = StreamController<List<StockStorageModel>>.broadcast();
    
    _fetchStorageDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchStorageDistribution: initial data loaded, warehouses=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchStorageDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('storage_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stock_in_bins',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchStorageDistribution: change detected, refetching...');
            final newData = await _fetchStorageDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchStorageDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  // ============================================================
  // GET ALL STOCKS FOR LOW/EMPTY ALERT
  // ============================================================
  Future<List<Map<String, dynamic>>> getAllStocksForAlert() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('''
            id,
            stock_name,
            current_stock,
            minimum_stock,
            unit,
            stock_type_id,
            ref_stock_types!stocks_stock_type_id_fkey(type_name)
          ''')
          .eq('is_active', true);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('❌ getAllStocksForAlert error: $e');
      return [];
    }
  }

    // ============================================================
  // LOW STOCK - REALTIME
  // ============================================================
  Stream<List<Map<String, dynamic>>> watchLowStock() {
    debugPrint('🟢 [REALTIME] watchLowStock: initializing...');
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    
    _fetchLowStock().then((value) {
      debugPrint('✅ [REALTIME] watchLowStock: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchLowStock: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('low_stock')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchLowStock: change detected, refetching...');
            final newData = await _fetchLowStock();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchLowStock: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchLowStock() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('''
            id,
            stock_name,
            current_stock,
            minimum_stock,
            unit,
            ref_stock_types!stocks_stock_type_id_fkey(type_name)
          ''')
          .eq('is_active', true);
      
      final stocks = response as List<Map<String, dynamic>>;
      
      final result = stocks.where((s) {
        final current = (s['current_stock'] as num?)?.toDouble() ?? 0;
        final minimum = (s['minimum_stock'] as num?)?.toDouble() ?? 0;
        return current <= minimum && current > 0;
      }).toList();
      
      result.sort((a, b) {
        final aCurrent = (a['current_stock'] as num?)?.toDouble() ?? 0;
        final aMinimum = (a['minimum_stock'] as num?)?.toDouble() ?? 0;
        final bCurrent = (b['current_stock'] as num?)?.toDouble() ?? 0;
        final bMinimum = (b['minimum_stock'] as num?)?.toDouble() ?? 0;
        final aRatio = aCurrent / aMinimum;
        final bRatio = bCurrent / bMinimum;
        return aRatio.compareTo(bRatio);
      });
      
      return result;
    } catch (e) {
      debugPrint('❌ _fetchLowStock error: $e');
      return [];
    }
  }

  // ============================================================
  // EMPTY STOCK - REALTIME
  // ============================================================
  Stream<List<Map<String, dynamic>>> watchEmptyStock() {
    debugPrint('🟢 [REALTIME] watchEmptyStock: initializing...');
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    
    _fetchEmptyStock().then((value) {
      debugPrint('✅ [REALTIME] watchEmptyStock: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchEmptyStock: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('empty_stock')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchEmptyStock: change detected, refetching...');
            final newData = await _fetchEmptyStock();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchEmptyStock: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchEmptyStock() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('''
            id,
            stock_name,
            current_stock,
            minimum_stock,
            unit,
            ref_stock_types!stocks_stock_type_id_fkey(type_name)
          ''')
          .eq('is_active', true);
      
      final stocks = response as List<Map<String, dynamic>>;
      
      return stocks.where((s) {
        final current = (s['current_stock'] as num?)?.toDouble() ?? 0;
        return current <= 0;
      }).toList();
    } catch (e) {
      debugPrint('❌ _fetchEmptyStock error: $e');
      return [];
    }
  }

  Future<List<StockStorageModel>> _fetchStorageDistribution() async {
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
                  stock_in_bins!stock_in_bins_bin_id_fkey(
                    quantity
                  )
                )
              )
            )
          )
        ''');

    final data = response as List;
    final Map<String, double> warehouseMap = {};

    for (final warehouse in data) {
      final warehouseName = warehouse['name'] ?? 'Unknown';
      double totalQuantity = 0;

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
                    for (final bin in bins) {
                      final stockInBins = bin['stock_in_bins'] as List?;
                      if (stockInBins != null) {
                        for (final sib in stockInBins) {
                          final qty = (sib['quantity'] ?? 0).toDouble();
                          totalQuantity += qty;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (totalQuantity > 0) {
        warehouseMap[warehouseName] = totalQuantity;
      }
    }

    // Hitung stok yang tidak terhubung ke warehouse
    try {
      final allStocksResponse = await _supabase
          .from('stock_in_bins')
          .select('quantity');

      final allStocks = allStocksResponse as List;
      double allTotal = 0;
      for (final item in allStocks) {
        allTotal += (item['quantity'] ?? 0).toDouble();
      }

      final connectedTotal = warehouseMap.values.fold(0.0, (sum, val) => sum + val);
      final unlocatedTotal = allTotal - connectedTotal;

      if (unlocatedTotal > 0) {
        warehouseMap['Tidak Terlokasi'] = unlocatedTotal;
      }
    } catch (e) {
      debugPrint('⚠️ Error calculating unlocated stock: $e');
    }

    final List<StockStorageModel> result = [];
    for (final entry in warehouseMap.entries) {
      result.add(StockStorageModel(
        storageId: entry.key,
        storageName: entry.key,
        totalQuantity: entry.value,
      ));
    }

    result.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return result.take(5).toList();
  } catch (e) {
    debugPrint('❌ _fetchStorageDistribution error: $e');
    return [];
  }
}

  // ============================================================
  // 10. TOP DISCREPANCY
  // ============================================================
  Stream<List<StockDiscrepancyModel>> watchTopDiscrepancy() {
    debugPrint('🟢 [REALTIME] watchTopDiscrepancy: initializing...');
    final controller = StreamController<List<StockDiscrepancyModel>>.broadcast();
    
    _fetchTopDiscrepancy().then((value) {
      debugPrint('✅ [REALTIME] watchTopDiscrepancy: initial data loaded, discrepancies=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTopDiscrepancy: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('top_discrepancy')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stocks_opnames',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTopDiscrepancy: change detected, refetching...');
            final newData = await _fetchTopDiscrepancy();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTopDiscrepancy: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<StockDiscrepancyModel>> _fetchTopDiscrepancy({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('stocks_opnames')
          .select('''
            stock_id,
            stock_before,
            physical_stock,
            adjustment_stock,
            opname_at,
            opname_by,
            stocks!stocks_opnames_stock_id_fkey(stock_name)
          ''')
          .order('adjustment_stock', ascending: false);

      final data = response as List;
      final List<StockDiscrepancyModel> discrepancies = [];
      final Set<String> addedStocks = {};

      for (final item in data) {
        final stockId = item['stock_id']?.toString();
        final stockData = item['stocks'];
        final stockName = stockData?['stock_name'] ?? 'Unknown';
        final systemStock = (item['stock_before'] ?? 0).toDouble();
        final physicalStock = (item['physical_stock'] ?? 0).toDouble();
        final discrepancy = (item['adjustment_stock'] ?? 0).toDouble();

        if (stockId == null) continue;
        if (addedStocks.contains(stockId)) continue;
        addedStocks.add(stockId);

        double discrepancyPercent = 0;
        if (systemStock > 0) {
          discrepancyPercent = (discrepancy.abs() / systemStock) * 100;
        }

        if (discrepancyPercent > 5) {
          discrepancies.add(StockDiscrepancyModel(
            stockId: stockId,
            stockName: stockName,
            systemStock: systemStock,
            physicalStock: physicalStock,
            discrepancy: discrepancy,
            discrepancyPercent: discrepancyPercent,
            opnameAt: DateTime.tryParse(item['opname_at'].toString()) ?? DateTime.now(),
            opnameBy: item['opname_by']?.toString(),
          ));
        }

        if (discrepancies.length >= limit) break;
      }

      return discrepancies;
    } catch (e) {
      debugPrint('❌ _fetchTopDiscrepancy error: $e');
      return [];
    }
  }
}