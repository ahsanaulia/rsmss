// lib/features/stock_in_entry/services/stock_in_entry_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_in_entry_model.dart';
import '../../../../core/services/auth_service.dart';

class StockInEntryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService;

  StockInEntryService(this._authService);

  Future<String> generateEntryNumber() async {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _supabase
        .from('stock_in_entries')
        .select('id')
        .gte('entry_date', startOfDay.toIso8601String())
        .lt('entry_date', endOfDay.toIso8601String());

    final sequence = response.length + 1;
    return 'SIN-$dateStr-${sequence.toString().padLeft(4, '0')}';
  }

  Future<bool> isBatchNumberExists(String stockId, String batchNumber,
      {String? excludeId}) async {
    try {
      var query = _supabase
          .from('stock_in_entries')
          .select('id')
          .eq('stock_id', stockId)
          .eq('batch_number', batchNumber)
          .eq('source_type', 'PURCHASE');

      if (excludeId != null && excludeId.isNotEmpty) {
        query = query.neq('id', excludeId);
      }

      final response = await query;
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static bool isExpiryValid(DateTime expiryDate) {
    final minExpiry = DateTime.now().add(const Duration(days: 90));
    return expiryDate.isAfter(minExpiry);
  }

  Future<StockInEntry> insert(StockInEntry entry) async {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User tidak login');
    }

    try {
      final data = entry.toJsonForInsert(userId);
      final response = await _supabase
          .from('stock_in_entries')
          .insert(data)
          .select()
          .single();

      return StockInEntry.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menyimpan stok masuk: $e');
    }
  }

  Future<void> updateBinLocation(
      String entryId, String binId, String putAwayBy) async {
    if (entryId.isEmpty || binId.isEmpty || putAwayBy.isEmpty) {
      throw Exception('Parameter tidak lengkap');
    }

    try {
      await _supabase.from('stock_in_entries').update({
        'current_bin_id': binId,
        'put_away_by': putAwayBy,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', entryId);
    } catch (e) {
      throw Exception('Gagal update lokasi bin: $e');
    }
  }

  Future<void> updateVerification(
      String entryId, String verifiedBy, bool isVerified) async {
    try {
      await _supabase.from('stock_in_entries').update({
        'verified_by': verifiedBy,
        'verified_at': isVerified ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', entryId);
    } catch (e) {
      throw Exception('Gagal update verifikasi: $e');
    }
  }

  Future<List<StockInEntryWithDetail>> getAllWithDetail({
    String? sourceType,
    String? stockId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('stock_in_entries').select('''
          *,
          stocks!stock_id (
            stock_name,
            stock_code,
            unit
          ),
          current_bin:current_bin_id (
            code
          ),
          received_profile:received_by (
            full_name
          ),
          returned_profile:returned_by (
            full_name
          )
        ''');

      if (sourceType != null && sourceType.isNotEmpty) {
        query = query.eq('source_type', sourceType);
      }
      if (stockId != null && stockId.isNotEmpty) {
        query = query.eq('stock_id', stockId);
      }
      if (startDate != null) {
        query = query.gte('entry_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        final endOfDay = endDate.add(const Duration(days: 1));
        query = query.lt('entry_date', endOfDay.toIso8601String());
      }

      final response = await query.order('entry_date', ascending: false);
      debugPrint('📊 Query response length: ${response.length}');

      final results = <StockInEntryWithDetail>[];
      
      for (var json in response) {
        try {
          final entry = StockInEntry.fromJson(json);
          final stockData = json['stocks'] as Map<String, dynamic>?;
          
          results.add(StockInEntryWithDetail(
            entry: entry,
            stockName: stockData?['stock_name'] as String? ?? 'Unknown',
            stockCode: stockData?['stock_code'] as String? ?? '',
            unit: stockData?['unit'] as String? ?? 'pcs',
            binCode: (json['current_bin'] as Map<String, dynamic>?)?['code'],
            fullLocationCode: null,
            receivedByName: (json['received_profile'] as Map<String, dynamic>?)?['full_name'],
            returnedByName: (json['returned_profile'] as Map<String, dynamic>?)?['full_name'],
          ));
        } catch (e) {
          debugPrint('❌ Error parsing row: $e');
          continue;
        }
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        return results.where((item) {
          return item.stockName.toLowerCase().contains(queryLower) ||
              item.stockCode.toLowerCase().contains(queryLower) ||
              item.entry.batchNumber.toLowerCase().contains(queryLower) ||
              item.entry.entryNumber.toLowerCase().contains(queryLower);
        }).toList();
      }

      return results;
    } catch (e) {
      debugPrint('❌ Error in getAllWithDetail: $e');
      return [];
    }
  }

  Future<List<StockInEntry>> getBySourceType(String sourceType) async {
    try {
      final response = await _supabase
          .from('stock_in_entries')
          .select()
          .eq('source_type', sourceType)
          .order('entry_date', ascending: false);

      return response.map((json) => StockInEntry.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }

  Future<StockInEntry?> getById(String id) async {
    if (id.isEmpty) return null;

    try {
      final response = await _supabase
          .from('stock_in_entries')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return StockInEntry.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    if (id.isEmpty) throw Exception('ID tidak boleh kosong');

    try {
      await _supabase
          .from('stock_in_entries')
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Gagal update data: $e');
    }
  }

  Future<void> delete(String id) async {
    if (id.isEmpty) throw Exception('ID tidak boleh kosong');

    try {
      final entry = await getById(id);
      if (entry?.currentBinId != null && entry!.currentBinId!.isNotEmpty) {
        throw Exception('Tidak bisa menghapus entry yang sudah dipindahkan ke bin storage');
      }

      await _supabase.from('stock_in_entries').delete().eq('id', id);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal menghapus data: $e');
    }
  }

  Future<double> getTotalQuantityByBatch(String stockId, String batchNumber) async {
    if (stockId.isEmpty || batchNumber.isEmpty) return 0;

    try {
      final response = await _supabase
          .from('stock_in_entries')
          .select('quantity')
          .eq('stock_id', stockId)
          .eq('batch_number', batchNumber);

      double total = 0;
      for (var item in response) {
        total += (item['quantity'] as num?)?.toDouble() ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<List<StockInEntryWithDetail>> search(String keyword) async {
    if (keyword.isEmpty) return [];

    try {
      final allData = await getAllWithDetail();
      final lowerKeyword = keyword.toLowerCase();

      return allData.where((item) {
        return item.stockName.toLowerCase().contains(lowerKeyword) ||
            item.stockCode.toLowerCase().contains(lowerKeyword) ||
            item.entry.batchNumber.toLowerCase().contains(lowerKeyword) ||
            item.entry.entryNumber.toLowerCase().contains(lowerKeyword) ||
            (item.receivedByName?.toLowerCase().contains(lowerKeyword) ?? false) ||
            (item.returnedByName?.toLowerCase().contains(lowerKeyword) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mencari data: $e');
    }
  }
}