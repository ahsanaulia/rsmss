import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefShiftService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_shifts';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('🔍 [Service] getAll - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('shift_name', ascending: true);

      debugPrint('✅ [Service] getAll - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAll - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data shift: $e');
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
      throw Exception('Gagal mengambil detail shift: $e');
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
      throw Exception('Gagal menambah shift: $e');
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
      throw Exception('Gagal mengupdate shift: $e');
    }
  }

  Future<void> delete(String id) async {
  debugPrint('🗑️ [Service] delete - ID: $id');

  try {
    // Cek apakah shift digunakan di tabel employee_shift_rosters
    final rosters = await _supabase
        .from('employee_shift_rosters')  // ← Perbaiki nama tabel
        .select('id')
        .eq('shift_id', id)
        .limit(1);

    if (rosters.isNotEmpty) {
      throw Exception('Tidak dapat menghapus shift yang sudah digunakan dalam penjadwalan karyawan');
    }

    await _supabase
        .from(_tableName)
        .delete()
        .eq('id', id);

    debugPrint('✅ [Service] delete - Success');
  } catch (e, stackTrace) {
    debugPrint('❌ [Service] delete - Error: $e');
    debugPrint('📚 [Service] StackTrace: $stackTrace');
    throw Exception('Gagal menghapus shift: $e');
  }
}

  // ==================== DATA UNTUK DROPDOWN ====================

  // HAPUS method getApps() karena sudah tidak diperlukan

  Future<List<Map<String, dynamic>>> getActiveShifts() async {
    debugPrint('🔍 [Service] getActiveShifts - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select('id, shift_name, shift_code, start_time, end_time, color_hex')
          .eq('is_active', true)
          .order('shift_name', ascending: true);

      debugPrint('✅ [Service] getActiveShifts - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getActiveShifts - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}