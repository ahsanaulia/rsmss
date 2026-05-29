// File: lib/insights/stocks/services/stock_overview_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_summary_model.dart';
import '../models/stock_trend_model.dart';
import '../models/stock_prediction_model.dart';
import '../models/stock_velocity_model.dart';
import '../models/stock_expiry_model.dart';
import '../models/stock_slow_moving_model.dart';
import '../models/stock_category_value_model.dart';
import '../models/stock_storage_model.dart';
import '../models/stock_discrepancy_model.dart';
import 'package:intl/intl.dart';

class StockOverviewService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY (KPI CARDS)
  // ============================================================
  Future<StockSummaryModel> getSummary() async {
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
      debugPrint('Error getSummary: $e');
      return StockSummaryModel.empty();
    }
  }

  // ============================================================
  // 2. CATEGORY DISTRIBUTION (Donut Chart)
  // ============================================================
  Future<Map<String, int>> getCategoryDistribution() async {
    try {
      final response = await _supabase
          .from('v_stocks')
          .select('stock_type_name');

      final data = response as List;
      final Map<String, int> result = {};

      for (final item in data) {
        final typeName = item['stock_type_name'] ?? 'Unknown';
        result[typeName] = (result[typeName] ?? 0) + 1;
      }

      return result;
    } catch (e) {
      debugPrint('Error getCategoryDistribution: $e');
      return {};
    }
  }

  // ============================================================
  // 3. STOCK TREND (30 hari) - DENGAN FALLBACK
  // ============================================================
  Future<List<StockTrendModel>> getStockTrend() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final dateFormat = DateFormat('yyyy-MM-dd');

      // Coba ambil dari stock_transactions terlebih dahulu
      final response = await _supabase
          .from('stock_transactions')
          .select('created_at, transaction_type, qty')
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final data = response as List;
      
      // Jika stock_transactions kosong, fallback ke stock_requests
      if (data.isEmpty) {
        return await _getTrendFromRequests(thirtyDaysAgo, dateFormat);
      }
      
      final Map<String, StockTrendModel> trendMap = {};

      for (final transaction in data) {
        final date = DateTime.parse(transaction['created_at'].toString());
        final dateKey = dateFormat.format(date);
        final qty = (transaction['qty'] ?? 0).toDouble();
        final type = transaction['transaction_type'];

        if (!trendMap.containsKey(dateKey)) {
          trendMap[dateKey] = StockTrendModel(
            date: date,
            inQuantity: 0,
            outQuantity: 0,
          );
        }

        final existing = trendMap[dateKey]!;
        if (type == 'IN') {
          trendMap[dateKey] = StockTrendModel(
            date: date,
            inQuantity: existing.inQuantity + qty,
            outQuantity: existing.outQuantity,
          );
        } else if (type == 'OUT') {
          trendMap[dateKey] = StockTrendModel(
            date: date,
            inQuantity: existing.inQuantity,
            outQuantity: existing.outQuantity + qty,
          );
        }
      }

      // Urutkan berdasarkan tanggal
      var result = trendMap.values.toList();
      result.sort((a, b) => a.date.compareTo(b.date));
      return result;
    } catch (e) {
      debugPrint('Error getStockTrend: $e');
      return [];
    }
  }

  /// FALLBACK: Ambil trend dari stock_requests
  Future<List<StockTrendModel>> _getTrendFromRequests(DateTime thirtyDaysAgo, DateFormat dateFormat) async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select('created_at, requested_quantity')
          .eq('status', 'FULFILLED')
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final data = response as List;
      
      if (data.isEmpty) {
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
          outQuantity: existing.outQuantity + qty, // Request = OUT
        );
      }

      var result = trendMap.values.toList();
      result.sort((a, b) => a.date.compareTo(b.date));
      return result;
    } catch (e) {
      debugPrint('Error getTrendFromRequests: $e');
      return [];
    }
  }

  // ============================================================
  // 4. STOCK OUT PREDICTION
  // ============================================================
  Future<List<StockPredictionModel>> getStockOutPrediction() async {
    try {
      // Ambil semua stock aktif
      final stocksResponse = await _supabase
          .from('stocks')
          .select('id, stock_name, unit, current_stock, minimum_stock')
          .eq('is_active', true);

      final stocks = stocksResponse as List;
      
      // Ambil request 30 hari terakhir untuk hitung daily usage
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final requestsResponse = await _supabase
          .from('stock_requests')
          .select('requested_stock_id, requested_quantity')
          .eq('status', 'FULFILLED')
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      final requests = requestsResponse as List;
      
      // Hitung total request per stock
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
        
        if (dailyUsage <= 0) continue; // Tidak ada permintaan, skip prediksi
        
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
      
      // Urutkan berdasarkan daysUntilEmpty (paling kritis dulu)
      predictions.sort((a, b) => a.daysUntilEmpty.compareTo(b.daysUntilEmpty));
      return predictions.take(10).toList();
    } catch (e) {
      debugPrint('Error getStockOutPrediction: $e');
      return [];
    }
  }

  // ============================================================
  // 5. TOP STOCK VELOCITY (Konsumsi Tercepat)
  // ============================================================
  Future<List<StockVelocityModel>> getTopVelocity({int limit = 5}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final response = await _supabase
          .from('stock_requests')
          .select('requested_stock_id, requested_quantity, stocks!inner(stock_name, unit)')
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
      debugPrint('Error getTopVelocity: $e');
      return [];
    }
  }

  // ============================================================
  // 6. EXPIRY ALERT
  // ============================================================
  Future<List<StockExpiryModel>> getExpiryAlert() async {
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
            stocks!inner(stock_name, unit)
          ''')
          .not('expiry_date', 'is', null)
          .lte('expiry_date', dateFormat.format(thirtyDaysFromNow));

      final data = response as List;
      final List<StockExpiryModel> expiries = [];
      
      // Group by stock_id untuk menghindari duplikasi (ambil batch terdekat expired)
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
      
      expiries.addAll(latestExpiry.values);
      expiries.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
      return expiries.take(10).toList();
    } catch (e) {
      debugPrint('Error getExpiryAlert: $e');
      return [];
    }
  }

  // ============================================================
  // 7. SLOW MOVING STOCK
  // ============================================================
  Future<List<StockSlowMovingModel>> getSlowMovingStock() async {
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
          daysInactive = 999; // Tidak pernah digunakan
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
      debugPrint('Error getSlowMovingStock: $e');
      return [];
    }
  }

  // ============================================================
  // 8. STOCK VALUE PER CATEGORY
  // ============================================================
  Future<List<StockCategoryValueModel>> getStockValuePerCategory() async {
    try {
      final response = await _supabase
          .from('v_stocks')
          .select('stock_type_name, current_stock, last_purchase_price');

      final data = response as List;
      final Map<String, double> valueMap = {};

      for (final item in data) {
        final category = item['stock_type_name'] ?? 'Unknown';
        final current = (item['current_stock'] ?? 0).toDouble();
        final price = (item['last_purchase_price'] ?? 0).toDouble();
        final value = current * price;
        
        valueMap[category] = (valueMap[category] ?? 0) + value;
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
      debugPrint('Error getStockValuePerCategory: $e');
      return [];
    }
  }

  // ============================================================
  // 9. STOCK PER STORAGE LOCATION
  // ============================================================
  Future<List<StockStorageModel>> getStockPerStorage() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('storage_location_id, current_stock, storage_locations!left(name)')
          .eq('is_active', true);

      final data = response as List;
      final Map<String, double> storageMap = {};

      for (final item in data) {
        String storageName = 'Tidak Ada Lokasi';
        final storageData = item['storage_locations'];
        if (storageData != null && storageData['name'] != null) {
          storageName = storageData['name'];
        }
        final qty = (item['current_stock'] ?? 0).toDouble();
        
        storageMap[storageName] = (storageMap[storageName] ?? 0) + qty;
      }

      final List<StockStorageModel> result = [];
      for (final entry in storageMap.entries) {
        result.add(StockStorageModel(
          storageId: entry.key,
          storageName: entry.key,
          totalQuantity: entry.value,
        ));
      }
      
      result.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
      return result.take(5).toList();
    } catch (e) {
      debugPrint('Error getStockPerStorage: $e');
      return [];
    }
  }

  // ============================================================
  // 10. TOP DISCREPANCY (Selisih Opname Terbesar)
  // ============================================================
  Future<List<StockDiscrepancyModel>> getTopDiscrepancy({int limit = 5}) async {
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
            stocks!inner(stock_name)
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
        
        // Hindari duplikasi stock_id
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
      debugPrint('Error getTopDiscrepancy: $e');
      return [];
    }
  }
}