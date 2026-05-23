import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'rooms';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllRooms() async {
    debugPrint('🔍 [Service] getAllRooms - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            floors:floor_id (
              id,
              floor_number,
              buildings:building_id (
                id,
                building_name
              )
            ),
            ref_room_categories:category_id (
              id,
              category_name,
              color_code,
              icon_name
            )
          ''')
          .order('room_name', ascending: true);

      debugPrint('✅ [Service] getAllRooms - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllRooms - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data ruangan: $e');
    }
  }

  Future<Map<String, dynamic>?> getRoomById(String id) async {
    debugPrint('🔍 [Service] getRoomById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            floors:floor_id (
              id,
              floor_number,
              buildings:building_id (
                id,
                building_name
              )
            ),
            ref_room_categories:category_id (
              id,
              category_name,
              color_code,
              icon_name
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getRoomById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getRoomById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail ruangan: $e');
    }
  }

  Future<Map<String, dynamic>> insertRoom(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertRoom - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertRoom - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertRoom - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menambah ruangan: $e');
    }
  }

  Future<Map<String, dynamic>> updateRoom(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateRoom - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateRoom - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateRoom - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengupdate ruangan: $e');
    }
  }

  Future<void> deleteRoom(String id) async {
    debugPrint('🗑️ [Service] deleteRoom - ID: $id');
    
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteRoom - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteRoom - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus ruangan: $e');
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

      // Format hasil untuk ditampilkan di dropdown
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

  Future<List<Map<String, dynamic>>> getRoomCategories() async {
    debugPrint('🔍 [Service] getRoomCategories - Start');
    
    try {
      final response = await _supabase
          .from('ref_room_categories')
          .select('id, category_name, color_code, icon_name')
          .order('category_name', ascending: true);

      debugPrint('✅ [Service] getRoomCategories - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getRoomCategories - Error: $e');
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