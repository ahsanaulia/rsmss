import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LeaveTypeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'leave_types';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('🔍 [Service] getAll - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('leave_name', ascending: true);

      debugPrint('✅ [Service] getAll - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAll - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data jenis cuti: $e');
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
      throw Exception('Gagal mengambil detail jenis cuti: $e');
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
      throw Exception('Gagal menambah jenis cuti: $e');
    }
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] update - ID: $id, Data: $data');

    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');
      data.remove('created_at');

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
      throw Exception('Gagal mengupdate jenis cuti: $e');
    }
  }

  Future<void> delete(String id) async {
    debugPrint('🗑️ [Service] delete - ID: $id');

    try {
      // Cek apakah jenis cuti digunakan di tabel leave_requests
      final requests = await _supabase
          .from('leave_requests')
          .select('id')
          .eq('leave_type_id', id)
          .limit(1);

      if (requests.isNotEmpty) {
        throw Exception('Tidak dapat menghapus jenis cuti yang sudah digunakan dalam pengajuan cuti');
      }

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] delete - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] delete - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus jenis cuti: $e');
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getActiveLeaveTypes() async {
    debugPrint('🔍 [Service] getActiveLeaveTypes - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select('id, leave_code, leave_name, max_days_per_year, color')
          .eq('is_active', true)
          .order('leave_name', ascending: true);

      debugPrint('✅ [Service] getActiveLeaveTypes - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getActiveLeaveTypes - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}