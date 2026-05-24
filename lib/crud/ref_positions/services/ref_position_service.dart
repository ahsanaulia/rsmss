import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefPositionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_positions';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('🔍 [Service] getAll - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('position_name', ascending: true);

      debugPrint('✅ [Service] getAll - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAll - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data posisi/jabatan: $e');
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
      throw Exception('Gagal mengambil detail posisi/jabatan: $e');
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
      throw Exception('Gagal menambah posisi/jabatan: $e');
    }
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] update - ID: $id, Data: $data');

    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');

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
      throw Exception('Gagal mengupdate posisi/jabatan: $e');
    }
  }

  Future<void> delete(String id) async {
    debugPrint('🗑️ [Service] delete - ID: $id');

    try {
      // Cek apakah posisi digunakan di tabel lain (contoh: profiles)
      final profiles = await _supabase
          .from('profiles')
          .select('id')
          .eq('position_id', id)
          .limit(1);

      if (profiles.isNotEmpty) {
        throw Exception('Tidak dapat menghapus posisi yang sudah digunakan oleh pegawai');
      }

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] delete - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] delete - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus posisi/jabatan: $e');
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getAllPositions() async {
    debugPrint('🔍 [Service] getAllPositions - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select('id, position_name')
          .order('position_name', ascending: true);

      debugPrint('✅ [Service] getAllPositions - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllPositions - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}