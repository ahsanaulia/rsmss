import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RefAssetCategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'ref_asset_categories';

  /// Get all categories (sorted by category_name case-insensitive)
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
      throw Exception('Gagal mengambil data kategori: $e');
    }
  }

  /// Get single category by ID
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
      throw Exception('Gagal mengambil detail kategori: $e');
    }
  }

  /// Insert new category
  Future<Map<String, dynamic>> insertCategory(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertCategory - Data: $data');
    
    try {
      // Remove null values before insert
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
      
      // Handle unique constraint violation
      if (e.toString().contains('ref_asset_categories_name_key')) {
        throw Exception('Nama kategori sudah ada. Gunakan nama lain.');
      }
      throw Exception('Gagal menambah kategori: $e');
    }
  }

  /// Update existing category
  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateCategory - ID: $id, Data: $data');
    
    try {
      // Remove null values and ID from update data
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
      
      if (e.toString().contains('ref_asset_categories_name_key')) {
        throw Exception('Nama kategori sudah ada. Gunakan nama lain.');
      }
      throw Exception('Gagal mengupdate kategori: $e');
    }
  }

  /// Delete category (hard delete)
  Future<void> deleteCategory(String id) async {
    debugPrint('🗑️ [Service] deleteCategory - ID: $id');
    
    try {
      // Check if category has sub-categories first
      final subCategories = await _supabase
          .from('ref_asset_sub_categories')
          .select('id')
          .eq('category_id', id);
      
      if (subCategories.isNotEmpty) {
        throw Exception('Tidak dapat menghapus kategori yang masih memiliki sub-kategori (${subCategories.length} sub-kategori). Hapus sub-kategori terlebih dahulu.');
      }
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteCategory - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteCategory - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus kategori: $e');
    }
  }

  /// Check if category name already exists (case-insensitive)
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