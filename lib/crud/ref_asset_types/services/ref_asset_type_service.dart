import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefAssetTypeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_asset_types';

  /// Get all types with sub-category info
  Future<List<Map<String, dynamic>>> getAllTypes() async {
    debugPrint('🔍 [Service] getAllTypes - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            sub_categories:sub_category_id (
              id,
              sub_category_name,
              categories:category_id (
                id,
                category_name,
                icon_name,
                marker_color
              )
            )
          ''')
          .order('type_name', ascending: true);

      debugPrint('✅ [Service] getAllTypes - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllTypes - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data tipe aset: $e');
    }
  }

  /// Get types by sub-category ID
  Future<List<Map<String, dynamic>>> getTypesBySubCategoryId(String subCategoryId) async {
    debugPrint('🔍 [Service] getTypesBySubCategoryId - SubCategoryID: $subCategoryId');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            sub_categories:sub_category_id (
              id,
              sub_category_name,
              categories:category_id (
                id,
                category_name,
                icon_name,
                marker_color
              )
            )
          ''')
          .eq('sub_category_id', subCategoryId)
          .order('type_name', ascending: true);

      debugPrint('✅ [Service] getTypesBySubCategoryId - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getTypesBySubCategoryId - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data tipe aset: $e');
    }
  }

  /// Get single type by ID
  Future<Map<String, dynamic>?> getTypeById(String id) async {
    debugPrint('🔍 [Service] getTypeById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            sub_categories:sub_category_id (
              id,
              sub_category_name,
              categories:category_id (
                id,
                category_name,
                icon_name,
                marker_color
              )
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getTypeById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getTypeById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail tipe aset: $e');
    }
  }

  /// Insert new type
  Future<Map<String, dynamic>> insertType(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertType - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertType - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertType - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_asset_types_sub_category_id_type_name_key')) {
        throw Exception('Nama tipe aset sudah ada di sub-kategori yang sama.');
      }
      throw Exception('Gagal menambah tipe aset: $e');
    }
  }

  /// Update existing type
  Future<Map<String, dynamic>> updateType(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateType - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateType - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateType - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_asset_types_sub_category_id_type_name_key')) {
        throw Exception('Nama tipe aset sudah ada di sub-kategori yang sama.');
      }
      throw Exception('Gagal mengupdate tipe aset: $e');
    }
  }

  /// Delete type (hard delete)
  Future<void> deleteType(String id) async {
    debugPrint('🗑️ [Service] deleteType - ID: $id');
    
    try {
      // Check if type is used in any asset (if assets table exists)
      // This is optional - uncomment if assets table exists
      /*
      final assetsCount = await _supabase
          .from('assets')
          .select('id')
          .eq('type_id', id);
      
      if (assetsCount.isNotEmpty) {
        throw Exception('Tidak dapat menghapus tipe aset yang masih digunakan pada aset.');
      }
      */
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteType - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteType - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus tipe aset: $e');
    }
  }

  /// Check if type name exists in same sub-category (case-insensitive)
  Future<bool> isTypeNameExists(String name, String subCategoryId, {String? excludeId}) async {
    debugPrint('🔍 [Service] isTypeNameExists - Name: $name, SubCategoryID: $subCategoryId, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('sub_category_id', subCategoryId)
          .ilike('type_name', name.trim());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isTypeNameExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isTypeNameExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }
}