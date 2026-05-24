import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class EmployeeQualificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'employee_qualifications';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAll() async {
    debugPrint('🔍 [Service] getAll - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('qualification_name', ascending: true);

      debugPrint('✅ [Service] getAll - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAll - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data kualifikasi: $e');
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
      throw Exception('Gagal mengambil detail kualifikasi: $e');
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
      throw Exception('Gagal menambah kualifikasi: $e');
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
      throw Exception('Gagal mengupdate kualifikasi: $e');
    }
  }

  Future<void> delete(String id) async {
    debugPrint('🗑️ [Service] delete - ID: $id');

    try {
      // Cek apakah kualifikasi digunakan di tabel employee_qualifications (relasi)
      // Jika ada tabel yang mereferensi, tambahkan pengecekan di sini

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] delete - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] delete - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus kualifikasi: $e');
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================
  // (Opsional, jika diperlukan untuk referensi ke modul lain)

  Future<List<Map<String, dynamic>>> getActiveQualifications() async {
    debugPrint('🔍 [Service] getActiveQualifications - Start');

    try {
      final response = await _supabase
          .from(_tableName)
          .select('id, qualification_code, qualification_name')
          .eq('is_active', true)
          .order('qualification_name', ascending: true);

      debugPrint('✅ [Service] getActiveQualifications - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getActiveQualifications - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}