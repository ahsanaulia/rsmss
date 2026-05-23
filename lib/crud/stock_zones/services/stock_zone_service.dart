import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StockZoneService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'stock_zones';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllZones() async {
    debugPrint('🔍 [Service] getAllZones - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            stock_warehouses:warehouse_id (
              id,
              code,
              name
            ),
            rooms:room_id (
              id,
              room_name,
              floors:floor_id (
                id,
                floor_number,
                buildings:building_id (
                  id,
                  building_name
                )
              )
            )
          ''')
          .order('name', ascending: true);

      debugPrint('✅ [Service] getAllZones - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllZones - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data zona: $e');
    }
  }

  Future<Map<String, dynamic>?> getZoneById(String id) async {
    debugPrint('🔍 [Service] getZoneById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            stock_warehouses:warehouse_id (
              id,
              code,
              name
            ),
            rooms:room_id (
              id,
              room_name,
              floors:floor_id (
                id,
                floor_number,
                buildings:building_id (
                  id,
                  building_name
                )
              )
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getZoneById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getZoneById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail zona: $e');
    }
  }

  Future<Map<String, dynamic>> insertZone(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertZone - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertZone - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertZone - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_zones_warehouse_id_code_key')) {
        throw Exception('Kode zona sudah ada di gudang ini. Gunakan kode lain.');
      }
      throw Exception('Gagal menambah zona: $e');
    }
  }

  Future<Map<String, dynamic>> updateZone(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateZone - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateZone - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateZone - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_zones_warehouse_id_code_key')) {
        throw Exception('Kode zona sudah ada di gudang ini. Gunakan kode lain.');
      }
      throw Exception('Gagal mengupdate zona: $e');
    }
  }

  Future<void> deleteZone(String id) async {
    debugPrint('🗑️ [Service] deleteZone - ID: $id');
    
    try {
      // Cek apakah zona memiliki rak
      final racks = await _supabase
          .from('stock_racks')
          .select('id')
          .eq('zone_id', id);
      
      if (racks.isNotEmpty) {
        throw Exception('Tidak dapat menghapus zona yang masih memiliki rak (${racks.length} rak). Hapus rak terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteZone - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteZone - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus zona: $e');
    }
  }

  // ==================== VALIDASI ====================

  Future<bool> isCodeExists(String code, String warehouseId, {String? excludeId}) async {
    debugPrint('🔍 [Service] isCodeExists - Code: $code, WarehouseID: $warehouseId, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('warehouse_id', warehouseId)
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

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    debugPrint('🔍 [Service] getWarehouses - Start');
    
    try {
      final response = await _supabase
          .from('stock_warehouses')
          .select('id, code, name, is_active')
          .eq('is_active', true)
          .order('name', ascending: true);

      final formatted = response.map((warehouse) {
        return {
          'id': warehouse['id'],
          'display_name': '${warehouse['code']} - ${warehouse['name']}',
          'code': warehouse['code'],
          'name': warehouse['name'],
        };
      }).toList();

      debugPrint('✅ [Service] getWarehouses - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getWarehouses - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRooms() async {
    debugPrint('🔍 [Service] getRooms - Start');
    
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            id,
            room_name,
            floors:floor_id (
              id,
              floor_number,
              buildings:building_id (
                id,
                building_name
              )
            )
          ''')
          .order('room_name', ascending: true);

      final formatted = response.map((room) {
        final floor = room['floors'] as Map<String, dynamic>?;
        final building = floor != null ? floor['buildings'] as Map<String, dynamic>? : null;
        final buildingName = building != null ? building['building_name'] as String? ?? '' : '';
        final floorNumber = floor != null ? floor['floor_number'] as int? ?? 0 : 0;
        
        String displayName = room['room_name'] as String? ?? '';
        if (buildingName.isNotEmpty) {
          displayName = '$buildingName - Lantai $floorNumber - $displayName';
        }
        
        return {
          'id': room['id'],
          'display_name': displayName,
          'room_name': room['room_name'],
          'building_name': buildingName,
          'floor_number': floorNumber,
        };
      }).toList();

      debugPrint('✅ [Service] getRooms - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getRooms - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  // Zone type options
  List<Map<String, String>> getZoneTypes() {
    return [
      {'value': 'NORMAL', 'label': 'Normal'},
      {'value': 'COLD', 'label': 'Cold Storage'},
      {'value': 'FREEZER', 'label': 'Freezer'},
      {'value': 'DANGEROUS', 'label': 'Bahan Berbahaya'},
      {'value': 'RESTRICTED', 'label': 'Restricted Area'},
      {'value': 'CLEANROOM', 'label': 'Cleanroom'},
    ];
  }
}