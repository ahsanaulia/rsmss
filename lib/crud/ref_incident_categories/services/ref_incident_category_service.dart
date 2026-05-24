import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefIncidentCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_incident_categories';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('🔍 [Service] getAll - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('name', ascending: true);

      debugPrint('✅ [Service] getAll - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAll - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data kategori insiden: $e');
    }
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    debugPrint('🔍 [Service] getById - ID: $id');

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail kategori insiden: $e');
    }
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insert - Data: $data');

    try {
      data.removeWhere((key, value) => value == null);

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insert - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insert - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menambah kategori insiden: $e');
    }
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] update - ID: $id, Data: $data');

    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ [Service] update - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] update - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengupdate kategori insiden: $e');
    }
  }

  Future<void> delete(String id) async {
    debugPrint('🗑️ [Service] delete - ID: $id');

    try {
      // Cek apakah kategori insiden digunakan di tabel incidents
      final incidents = await _supabase
          .from('incidents')
          .select('id')
          .eq('category_id', id)
          .limit(1);

      if (incidents.isNotEmpty) {
        throw Exception('Tidak dapat menghapus kategori yang sudah digunakan dalam laporan insiden');
      }

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] delete - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] delete - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus kategori insiden: $e');
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getActiveCategories() async {
    debugPrint('🔍 [Service] getActiveCategories - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select('id, code, name, icon, color')
          .eq('is_active', true)
          .order('name', ascending: true);

      debugPrint('✅ [Service] getActiveCategories - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getActiveCategories - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}