import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefStockSubCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_stock_sub_categories';

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
      throw Exception('Gagal mengambil data sub-kategori stok: $e');
    }
  }

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
      throw Exception('Gagal mengambil data sub-kategori stok: $e');
    }
  }

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
      throw Exception('Gagal mengambil detail sub-kategori stok: $e');
    }
  }

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
      
      if (e.toString().contains('ref_stock_sub_categories_category_id_sub_category_name_key')) {
        throw Exception('Nama sub-kategori stok sudah ada di kategori yang sama.');
      }
      throw Exception('Gagal menambah sub-kategori stok: $e');
    }
  }

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
      
      if (e.toString().contains('ref_stock_sub_categories_category_id_sub_category_name_key')) {
        throw Exception('Nama sub-kategori stok sudah ada di kategori yang sama.');
      }
      throw Exception('Gagal mengupdate sub-kategori stok: $e');
    }
  }

  Future<void> deleteSubCategory(String id) async {
    debugPrint('🗑️ [Service] deleteSubCategory - ID: $id');
    
    try {
      final types = await _supabase
          .from('ref_stock_types')
          .select('id')
          .eq('sub_category_id', id);
      
      if (types.isNotEmpty) {
        throw Exception('Tidak dapat menghapus sub-kategori yang masih memiliki tipe stok (${types.length} tipe). Hapus tipe stok terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteSubCategory - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteSubCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus sub-kategori stok: $e');
    }
  }

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