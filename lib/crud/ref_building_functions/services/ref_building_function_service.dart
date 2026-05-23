import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefBuildingFunctionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_building_functions';

  Future<List<Map<String, dynamic>>> getAllFunctions() async {
    debugPrint('🔍 [Service] getAllFunctions - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('function_name', ascending: true);

      debugPrint('✅ [Service] getAllFunctions - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllFunctions - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data fungsi gedung: $e');
    }
  }

  Future<Map<String, dynamic>?> getFunctionById(String id) async {
    debugPrint('🔍 [Service] getFunctionById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getFunctionById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getFunctionById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail fungsi gedung: $e');
    }
  }

  Future<Map<String, dynamic>> insertFunction(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertFunction - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertFunction - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertFunction - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_building_functions_function_name_key')) {
        throw Exception('Nama fungsi gedung sudah ada.');
      }
      throw Exception('Gagal menambah fungsi gedung: $e');
    }
  }

  Future<Map<String, dynamic>> updateFunction(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateFunction - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateFunction - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateFunction - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_building_functions_function_name_key')) {
        throw Exception('Nama fungsi gedung sudah ada.');
      }
      throw Exception('Gagal mengupdate fungsi gedung: $e');
    }
  }

  Future<void> deleteFunction(String id) async {
    debugPrint('🗑️ [Service] deleteFunction - ID: $id');
    
    try {
      final buildings = await _supabase
          .from('buildings')
          .select('id')
          .eq('function_id', id);
      
      if (buildings.isNotEmpty) {
        throw Exception('Tidak dapat menghapus fungsi yang masih digunakan pada gedung (${buildings.length} gedung).');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteFunction - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteFunction - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus fungsi gedung: $e');
    }
  }

  Future<bool> isFunctionNameExists(String name, {String? excludeId}) async {
    debugPrint('🔍 [Service] isFunctionNameExists - Name: $name, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .ilike('function_name', name.trim());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isFunctionNameExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isFunctionNameExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }
}