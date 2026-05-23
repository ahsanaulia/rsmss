import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FloorService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'floors';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllFloors() async {
    debugPrint('🔍 [Service] getAllFloors - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            buildings:building_id (
              id,
              building_name
            )
          ''')
          .order('floor_number', ascending: true);

      debugPrint('✅ [Service] getAllFloors - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllFloors - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data lantai: $e');
    }
  }

  Future<Map<String, dynamic>?> getFloorById(String id) async {
    debugPrint('🔍 [Service] getFloorById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            buildings:building_id (
              id,
              building_name
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getFloorById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getFloorById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail lantai: $e');
    }
  }

  Future<Map<String, dynamic>> insertFloor(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertFloor - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertFloor - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertFloor - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menambah lantai: $e');
    }
  }

  Future<Map<String, dynamic>> updateFloor(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateFloor - ID: $id, Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');
      data.remove('created_at');
      data.remove('created_by');
      
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ [Service] updateFloor - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateFloor - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengupdate lantai: $e');
    }
  }

  Future<void> deleteFloor(String id) async {
    debugPrint('🗑️ [Service] deleteFloor - ID: $id');
    
    try {
      // Cek apakah lantai memiliki ruangan
      final rooms = await _supabase
          .from('rooms')
          .select('id')
          .eq('floor_id', id);
      
      if (rooms.isNotEmpty) {
        throw Exception('Tidak dapat menghapus lantai yang masih memiliki ruangan (${rooms.length} ruangan). Hapus ruangan terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteFloor - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteFloor - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus lantai: $e');
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getBuildings() async {
    debugPrint('🔍 [Service] getBuildings - Start');
    
    try {
      final response = await _supabase
          .from('buildings')
          .select('id, building_name')
          .order('building_name', ascending: true);

      debugPrint('✅ [Service] getBuildings - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getBuildings - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getApps() async {
    debugPrint('🔍 [Service] getApps - Start');
    
    try {
      final response = await _supabase
          .from('apps_config')
          .select('id, client_name')
          .order('client_name', ascending: true);

      debugPrint('✅ [Service] getApps - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getApps - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}