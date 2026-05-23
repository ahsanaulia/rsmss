import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StockShelfService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'stock_shelves';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllShelves() async {
    debugPrint('🔍 [Service] getAllShelves - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            stock_racks:rack_id (
              id,
              code,
              name,
              stock_zones:zone_id (
                id,
                code,
                name,
                stock_warehouses:warehouse_id (
                  id,
                  code,
                  name
                )
              )
            )
          ''')
          .order('code', ascending: true);

      debugPrint('✅ [Service] getAllShelves - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllShelves - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data shelf: $e');
    }
  }

  Future<Map<String, dynamic>?> getShelfById(String id) async {
    debugPrint('🔍 [Service] getShelfById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            stock_racks:rack_id (
              id,
              code,
              name,
              stock_zones:zone_id (
                id,
                code,
                name,
                stock_warehouses:warehouse_id (
                  id,
                  code,
                  name
                )
              )
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getShelfById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getShelfById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail shelf: $e');
    }
  }

  Future<Map<String, dynamic>> insertShelf(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertShelf - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertShelf - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertShelf - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_shelves_rack_id_code_key')) {
        throw Exception('Kode shelf sudah ada di rak ini. Gunakan kode lain.');
      }
      throw Exception('Gagal menambah shelf: $e');
    }
  }

  Future<Map<String, dynamic>> updateShelf(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateShelf - ID: $id, Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');
      data.remove('created_at');
      data.remove('created_by');
      
      // Tambahkan updated_at
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ [Service] updateShelf - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateShelf - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_shelves_rack_id_code_key')) {
        throw Exception('Kode shelf sudah ada di rak ini. Gunakan kode lain.');
      }
      throw Exception('Gagal mengupdate shelf: $e');
    }
  }

  Future<void> deleteShelf(String id) async {
    debugPrint('🗑️ [Service] deleteShelf - ID: $id');
    
    try {
      // Cek apakah shelf memiliki bin
      final bins = await _supabase
          .from('stock_bins')
          .select('id')
          .eq('shelf_id', id);
      
      if (bins.isNotEmpty) {
        throw Exception('Tidak dapat menghapus shelf yang masih memiliki bin (${bins.length} bin). Hapus bin terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteShelf - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteShelf - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus shelf: $e');
    }
  }

  // ==================== VALIDASI ====================

  Future<bool> isCodeExists(String code, String rackId, {String? excludeId}) async {
    debugPrint('🔍 [Service] isCodeExists - Code: $code, RackID: $rackId, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('rack_id', rackId)
          .eq('code', code.trim().toUpperCase());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isCodeExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isCodeExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getRacks() async {
    debugPrint('🔍 [Service] getRacks - Start');
    
    try {
      final response = await _supabase
          .from('stock_racks')
          .select('''
            id,
            code,
            name,
            stock_zones:zone_id (
              id,
              code,
              name,
              stock_warehouses:warehouse_id (
                id,
                code,
                name
              )
            )
          ''')
          .order('code', ascending: true);

      final formatted = response.map((rack) {
        final zone = rack['stock_zones'] as Map<String, dynamic>?;
        final warehouse = zone != null ? zone['stock_warehouses'] as Map<String, dynamic>? : null;
        final warehouseName = warehouse != null ? warehouse['name'] as String? ?? '' : '';
        final zoneName = zone != null ? zone['name'] as String? ?? '' : '';
        final rackCode = rack['code'] as String? ?? '';
        final rackName = rack['name'] as String?;
        
        String displayName = rackCode;
        if (rackName != null && rackName.isNotEmpty) {
          displayName = '$rackCode - $rackName';
        }
        if (warehouseName.isNotEmpty && zoneName.isNotEmpty) {
          displayName = '$warehouseName / $zoneName / $displayName';
        } else if (zoneName.isNotEmpty) {
          displayName = '$zoneName / $displayName';
        }
        
        return {
          'id': rack['id'],
          'display_name': displayName,
          'code': rackCode,
          'name': rackName,
          'zone_name': zoneName,
          'zone_code': zone != null ? zone['code'] : null,
          'warehouse_name': warehouseName,
          'warehouse_code': warehouse != null ? warehouse['code'] : null,
        };
      }).toList();

      debugPrint('✅ [Service] getRacks - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getRacks - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}