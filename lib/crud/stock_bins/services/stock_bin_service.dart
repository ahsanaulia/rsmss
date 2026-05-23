import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StockBinService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'stock_bins';

  // ==================== CRUD UTAMA ====================

  Future<List<Map<String, dynamic>>> getAllBins() async {
    debugPrint('🔍 [Service] getAllBins - Start');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            stock_shelves:shelf_id (
              id,
              code,
              level_number,
              stock_racks:rack_id (
                id,
                code,
                name,
                stock_zones:zone_id (
                  id,
                  code,
                  name,
                  stock_warehouses:warehouse_id (
                    id,
                    code,
                    name
                  )
                )
              )
            ),
            assets:asset_id (
              id,
              rfid_tag_id,
              asset_name
            )
          ''')
          .order('code', ascending: true);

      debugPrint('✅ [Service] getAllBins - Success: ${response.length} records');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAllBins - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data bin: $e');
    }
  }

  Future<Map<String, dynamic>?> getBinById(String id) async {
    debugPrint('🔍 [Service] getBinById - ID: $id');
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            stock_shelves:shelf_id (
              id,
              code,
              level_number,
              stock_racks:rack_id (
                id,
                code,
                name,
                stock_zones:zone_id (
                  id,
                  code,
                  name,
                  stock_warehouses:warehouse_id (
                    id,
                    code,
                    name
                  )
                )
              )
            ),
            assets:asset_id (
              id,
              rfid_tag_id,
              asset_name
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      debugPrint('✅ [Service] getBinById - Success: ${response != null}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getBinById - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal mengambil detail bin: $e');
    }
  }

  Future<Map<String, dynamic>> insertBin(Map<String, dynamic> data) async {
    debugPrint('📝 [Service] insertBin - Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      debugPrint('✅ [Service] insertBin - Success: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] insertBin - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_bins_shelf_id_code_key')) {
        throw Exception('Kode bin sudah ada di shelf ini. Gunakan kode lain.');
      }
      if (e.toString().contains('stock_bins_barcode_key')) {
        throw Exception('Barcode sudah digunakan. Gunakan barcode lain.');
      }
      throw Exception('Gagal menambah bin: $e');
    }
  }

  Future<Map<String, dynamic>> updateBin(String id, Map<String, dynamic> data) async {
    debugPrint('✏️ [Service] updateBin - ID: $id, Data: $data');
    
    try {
      data.removeWhere((key, value) => value == null);
      data.remove('id');
      data.remove('created_at');
      data.remove('created_by');
      
      // Tambahkan updated_at
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      debugPrint('✅ [Service] updateBin - Success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateBin - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      
      if (e.toString().contains('stock_bins_shelf_id_code_key')) {
        throw Exception('Kode bin sudah ada di shelf ini. Gunakan kode lain.');
      }
      if (e.toString().contains('stock_bins_barcode_key')) {
        throw Exception('Barcode sudah digunakan. Gunakan barcode lain.');
      }
      throw Exception('Gagal mengupdate bin: $e');
    }
  }

  Future<void> deleteBin(String id) async {
    debugPrint('🗑️ [Service] deleteBin - ID: $id');
    
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      debugPrint('✅ [Service] deleteBin - Success');
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] deleteBin - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      throw Exception('Gagal menghapus bin: $e');
    }
  }

  // ==================== VALIDASI ====================

  Future<bool> isCodeExists(String code, String shelfId, {String? excludeId}) async {
    debugPrint('🔍 [Service] isCodeExists - Code: $code, ShelfID: $shelfId, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('shelf_id', shelfId)
          .eq('code', code.trim().toUpperCase());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isCodeExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isCodeExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }

  Future<bool> isBarcodeExists(String barcode, {String? excludeId}) async {
    debugPrint('🔍 [Service] isBarcodeExists - Barcode: $barcode, ExcludeID: $excludeId');
    
    try {
      var query = _supabase
          .from(_tableName)
          .select('id')
          .eq('barcode', barcode.trim());
      
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      
      final response = await query;
      
      debugPrint('✅ [Service] isBarcodeExists - Result: ${response.isNotEmpty}');
      return response.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] isBarcodeExists - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }

  // ==================== DATA UNTUK DROPDOWN ====================

  Future<List<Map<String, dynamic>>> getShelves() async {
    debugPrint('🔍 [Service] getShelves - Start');
    
    try {
      final response = await _supabase
          .from('stock_shelves')
          .select('''
            id,
            code,
            level_number,
            stock_racks:rack_id (
              id,
              code,
              name,
              stock_zones:zone_id (
                id,
                code,
                name,
                stock_warehouses:warehouse_id (
                  id,
                  code,
                  name
                )
              )
            )
          ''')
          .order('code', ascending: true);

      final formatted = response.map((shelf) {
        final rack = shelf['stock_racks'] as Map<String, dynamic>?;
        final zone = rack != null ? rack['stock_zones'] as Map<String, dynamic>? : null;
        final warehouse = zone != null ? zone['stock_warehouses'] as Map<String, dynamic>? : null;
        
        final warehouseName = warehouse != null ? warehouse['name'] as String? ?? '' : '';
        final zoneName = zone != null ? zone['name'] as String? ?? '' : '';
        final rackCode = rack != null ? rack['code'] as String? ?? '' : '';
        final shelfCode = shelf['code'] as String? ?? '';
        final levelNumber = shelf['level_number'] as int? ?? 0;
        
        String displayName = '$rackCode - Level $levelNumber - $shelfCode';
        if (warehouseName.isNotEmpty && zoneName.isNotEmpty) {
          displayName = '$warehouseName / $zoneName / $displayName';
        } else if (zoneName.isNotEmpty) {
          displayName = '$zoneName / $displayName';
        }
        
        return {
          'id': shelf['id'],
          'display_name': displayName,
          'code': shelfCode,
          'level_number': levelNumber,
          'rack_code': rackCode,
          'rack_name': rack != null ? rack['name'] : null,
          'zone_name': zoneName,
          'warehouse_name': warehouseName,
        };
      }).toList();

      debugPrint('✅ [Service] getShelves - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getShelves - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAssets() async {
    debugPrint('🔍 [Service] getAssets - Start');
    
    try {
      final response = await _supabase
          .from('assets')
          .select('id, rfid_tag_id, asset_name')
          .order('asset_name', ascending: true);

      final formatted = response.map((asset) {
        return {
          'id': asset['id'],
          'display_name': '${asset['rfid_tag_id']} - ${asset['asset_name']}',
          'asset_code': asset['rfid_tag_id'],
          'name': asset['asset_name'],
        };
      }).toList();

      debugPrint('✅ [Service] getAssets - Success: ${formatted.length} records');
      return formatted;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] getAssets - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return [];
    }
  }
}