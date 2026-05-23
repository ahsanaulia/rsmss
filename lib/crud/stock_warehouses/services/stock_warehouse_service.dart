import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StockWarehouseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'stock_warehouses';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    debugPrint('🔍 [Service] getAllWarehouses - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            floors:floor_id (
              id,
              floor_number,
              floor_alias,
              buildings:building_id (
                id,
                building_name
              )
            ),
            profiles:manager_id (
              id,
              full_name
            )
          ''')
          .order('name', ascending: true);

      debugPrint('✅ [Service] getAllWarehouses - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllWarehouses - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data gudang: $e');
    }
  }

  Future<Map<String, dynamic>?> getWarehouseById(String id) async {
    debugPrint('🔍 [Service] getWarehouseById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            floors:floor_id (
              id,
              floor_number,
              floor_alias,
              buildings:building_id (
                id,
                building_name
              )
            ),
            profiles:manager_id (
              id,
              full_name
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getWarehouseById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getWarehouseById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail gudang: $e');
    }
  }

  Future<Map<String, dynamic>> insertWarehouse(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertWarehouse - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertWarehouse - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertWarehouse - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_warehouses_code_key')) {
        throw Exception('Kode gudang sudah ada. Gunakan kode lain.');
      }
      throw Exception('Gagal menambah gudang: $e');
    }
  }

  Future<Map<String, dynamic>> updateWarehouse(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateWarehouse - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateWarehouse - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateWarehouse - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_warehouses_code_key')) {
        throw Exception('Kode gudang sudah ada. Gunakan kode lain.');
      }
      throw Exception('Gagal mengupdate gudang: $e');
    }
  }

  Future<void> deleteWarehouse(String id) async {
    debugPrint('🗑️ [Service] deleteWarehouse - ID: $id');
    
    try {
      // Cek apakah gudang memiliki zona
      final zones = await _supabase
          .from('stock_zones')
          .select('id')
          .eq('warehouse_id', id);
      
      if (zones.isNotEmpty) {
        throw Exception('Tidak dapat menghapus gudang yang masih memiliki zona (${zones.length} zona). Hapus zona terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteWarehouse - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteWarehouse - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus gudang: $e');
    }
  }

  // ==================== VALIDASI ====================

  Future<bool> isCodeExists(String code, {String? excludeId}) async {
    debugPrint('🔍 [Service] isCodeExists - Code: $code, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
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

  Future<List<Map<String, dynamic>>> getFloors() async {
    debugPrint('🔍 [Service] getFloors - Start');
    
    try {
      final response = await _supabase
          .from('floors')
          .select('''
            id,
            floor_number,
            floor_alias,
            buildings:building_id (
              id,
              building_name
            )
          ''')
          .order('floor_number', ascending: true);

      final formatted = response.map((floor) {
        final buildingName = floor['buildings'] != null 
            ? (floor['buildings'] as Map<String, dynamic>)['building_name'] as String? ?? ''
            : '';
        final floorNumber = floor['floor_number'] as int? ?? 0;
        final floorAlias = floor['floor_alias'] as String?;
        
        String displayName = 'Gedung $buildingName - Lantai $floorNumber';
        if (floorAlias != null && floorAlias.isNotEmpty) {
          displayName += ' ($floorAlias)';
        }
        
        return {
          'id': floor['id'],
          'display_name': displayName,
          'floor_number': floorNumber,
          'building_name': buildingName,
        };
      }).toList();

      debugPrint('✅ [Service] getFloors - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getFloors - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getManagers() async {
    debugPrint('🔍 [Service] getManagers - Start');
    
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, role')
          .order('full_name', ascending: true);

      debugPrint('✅ [Service] getManagers - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getManagers - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}