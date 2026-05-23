import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefAssetSubCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_asset_sub_categories';

  /// Get all sub-categories with category info (joined)
  Future<List<Map<String, dynamic>>> getAllSubCategories() async {
    debugPrint('🔍 [Service] getAllSubCategories - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            categories:category_id (
              id,
              category_name,
              icon_name,
              marker_color
            )
          ''')
          .order('sub_category_name', ascending: true);

      debugPrint('✅ [Service] getAllSubCategories - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllSubCategories - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data sub-kategori: $e');
    }
  }

  /// Get sub-categories by category ID
  Future<List<Map<String, dynamic>>> getSubCategoriesByCategoryId(String categoryId) async {
    debugPrint('🔍 [Service] getSubCategoriesByCategoryId - CategoryID: $categoryId');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            categories:category_id (
              id,
              category_name,
              icon_name,
              marker_color
            )
          ''')
          .eq('category_id', categoryId)
          .order('sub_category_name', ascending: true);

      debugPrint('✅ [Service] getSubCategoriesByCategoryId - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getSubCategoriesByCategoryId - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data sub-kategori: $e');
    }
  }

  /// Get single sub-category by ID
  Future<Map<String, dynamic>?> getSubCategoryById(String id) async {
    debugPrint('🔍 [Service] getSubCategoryById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            categories:category_id (
              id,
              category_name,
              icon_name,
              marker_color
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getSubCategoryById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getSubCategoryById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail sub-kategori: $e');
    }
  }

  /// Insert new sub-category
  Future<Map<String, dynamic>> insertSubCategory(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertSubCategory - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertSubCategory - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertSubCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_asset_sub_categories_category_id_sub_category_name_key')) {
        throw Exception('Nama sub-kategori sudah ada di kategori yang sama.');
      }
      throw Exception('Gagal menambah sub-kategori: $e');
    }
  }

  /// Update existing sub-category
  Future<Map<String, dynamic>> updateSubCategory(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateSubCategory - ID: $id, Data: $data');
    
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

      debugPrint('✅ [Service] updateSubCategory - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateSubCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('ref_asset_sub_categories_category_id_sub_category_name_key')) {
        throw Exception('Nama sub-kategori sudah ada di kategori yang sama.');
      }
      throw Exception('Gagal mengupdate sub-kategori: $e');
    }
  }

  /// Delete sub-category (hard delete)
  Future<void> deleteSubCategory(String id) async {
    debugPrint('🗑️ [Service] deleteSubCategory - ID: $id');
    
    try {
      // Check if sub-category is used in any asset (if assets table exists)
      // This is optional - uncomment if assets table exists
      /*
      final assetsCount = await _supabase
          .from('assets')
          .select('id')
          .eq('sub_category_id', id);
      
      if (assetsCount.isNotEmpty) {
        throw Exception('Tidak dapat menghapus sub-kategori yang masih digunakan pada aset.');
      }
      */
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteSubCategory - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteSubCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus sub-kategori: $e');
    }
  }

  /// Check if sub-category name exists in same category (case-insensitive)
  Future<bool> isSubCategoryNameExists(String name, String categoryId, {String? excludeId}) async {
    debugPrint('🔍 [Service] isSubCategoryNameExists - Name: $name, CategoryID: $categoryId, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('category_id', categoryId)
          .ilike('sub_category_name', name.trim());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isSubCategoryNameExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isSubCategoryNameExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }
}