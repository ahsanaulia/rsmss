import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StockRackService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'stock_racks';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllRacks() async {
    debugPrint('🔍 [Service] getAllRacks - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
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

      debugPrint('✅ [Service] getAllRacks - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllRacks - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data rak: $e');
    }
  }

  Future<Map<String, dynamic>?> getRackById(String id) async {
    debugPrint('🔍 [Service] getRackById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
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
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getRackById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getRackById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail rak: $e');
    }
  }

  Future<Map<String, dynamic>> insertRack(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertRack - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertRack - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertRack - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_racks_zone_id_code_key')) {
        throw Exception('Kode rak sudah ada di zona ini. Gunakan kode lain.');
      }
      throw Exception('Gagal menambah rak: $e');
    }
  }

  Future<Map<String, dynamic>> updateRack(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateRack - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateRack - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateRack - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_racks_zone_id_code_key')) {
        throw Exception('Kode rak sudah ada di zona ini. Gunakan kode lain.');
      }
      throw Exception('Gagal mengupdate rak: $e');
    }
  }

  Future<void> deleteRack(String id) async {
    debugPrint('🗑️ [Service] deleteRack - ID: $id');
    
    try {
      // Cek apakah rak memiliki shelf
      final shelves = await _supabase
          .from('stock_shelves')
          .select('id')
          .eq('rack_id', id);
      
      if (shelves.isNotEmpty) {
        throw Exception('Tidak dapat menghapus rak yang masih memiliki shelf (${shelves.length} shelf). Hapus shelf terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteRack - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteRack - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus rak: $e');
    }
  }

  // ==================== VALIDASI ====================

  Future<bool> isCodeExists(String code, String zoneId, {String? excludeId}) async {
    debugPrint('🔍 [Service] isCodeExists - Code: $code, ZoneID: $zoneId, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('zone_id', zoneId)
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

  Future<List<Map<String, dynamic>>> getZones() async {
    debugPrint('🔍 [Service] getZones - Start');
    
    try {
      final response = await _supabase
          .from('stock_zones')
          .select('''
            id,
            code,
            name,
            stock_warehouses:warehouse_id (
              id,
              code,
              name
            )
          ''')
          .order('name', ascending: true);

      final formatted = response.map((zone) {
        final warehouse = zone['stock_warehouses'] as Map<String, dynamic>?;
        final warehouseName = warehouse != null ? warehouse['name'] as String? ?? '' : '';
        final warehouseCode = warehouse != null ? warehouse['code'] as String? ?? '' : '';
        final zoneName = zone['name'] as String? ?? '';
        final zoneCode = zone['code'] as String? ?? '';
        
        String displayName = zoneName;
        if (warehouseName.isNotEmpty) {
          displayName = '$warehouseName - $zoneName ($zoneCode)';
        }
        
        return {
          'id': zone['id'],
          'display_name': displayName,
          'code': zoneCode,
          'name': zoneName,
          'warehouse_name': warehouseName,
          'warehouse_code': warehouseCode,
        };
      }).toList();

      debugPrint('✅ [Service] getZones - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getZones - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}