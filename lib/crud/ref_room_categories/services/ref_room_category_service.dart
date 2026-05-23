import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefRoomCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_room_categories';

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    debugPrint('🔍 [Service] getAllCategories - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('category_name', ascending: true);

      debugPrint('✅ [Service] getAllCategories - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllCategories - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data kategori ruangan: $e');
    }
  }

  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    debugPrint('🔍 [Service] getCategoryById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getCategoryById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getCategoryById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail kategori ruangan: $e');
    }
  }

  Future<Map<String, dynamic>> insertCategory(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertCategory - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertCategory - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_room_categories_category_name_key')) {
        throw Exception('Nama kategori ruangan sudah ada.');
      }
      throw Exception('Gagal menambah kategori ruangan: $e');
    }
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateCategory - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateCategory - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_room_categories_category_name_key')) {
        throw Exception('Nama kategori ruangan sudah ada.');
      }
      throw Exception('Gagal mengupdate kategori ruangan: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    debugPrint('🗑️ [Service] deleteCategory - ID: $id');
    
    try {
      final rooms = await _supabase
          .from('rooms')
          .select('id')
          .eq('category_id', id);
      
      if (rooms.isNotEmpty) {
        throw Exception('Tidak dapat menghapus kategori yang masih digunakan pada ruangan (${rooms.length} ruangan).');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteCategory - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus kategori ruangan: $e');
    }
  }

  Future<bool> isCategoryNameExists(String name, {String? excludeId}) async {
    debugPrint('🔍 [Service] isCategoryNameExists - Name: $name, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .ilike('category_name', name.trim());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isCategoryNameExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isCategoryNameExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }
}