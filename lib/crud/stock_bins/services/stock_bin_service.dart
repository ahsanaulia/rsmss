import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class StockBinService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'stock_bins';
  final ScreenshotController _screenshotController = ScreenshotController();

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

  // ==================== QR CODE ====================

  Future<bool> updateQrCodeUrl(String binId, String qrUrl) async {
    debugPrint('🔍 [Service] updateQrCodeUrl - BinID: $binId, URL: $qrUrl');
    
    try {
      await _supabase
          .from(_tableName)
          .update({'qrcode_url': qrUrl, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', binId);
      
      debugPrint('✅ [Service] updateQrCodeUrl - Success');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] updateQrCodeUrl - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return false;
    }
  }

  /// Generate QR Code image, upload to Supabase Storage, and return the public URL.
  Future<String?> generateAndUploadQr({
    required String binId,
    required String binCode,
    required String shelfCode,
    required String rackCode,
    required String warehouseName,
  }) async {
    debugPrint('🔍 [Service] generateAndUploadQr - Start');
    
    try {
      // 1. Generate QR widget as image using ScreenshotController
      final imageBytes = await _screenshotController.captureFromWidget(
        Material(
          child: Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "QR CODE STORAGE BIN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF01579B)),
                ),
                const SizedBox(height: 20),
                QrImageView(data: binId, size: 200, backgroundColor: Colors.white),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Kode Bin", binCode),
                      const SizedBox(height: 6),
                      _buildInfoRow("Rak", rackCode),
                      const SizedBox(height: 6),
                      _buildInfoRow("Shelf", shelfCode),
                      const SizedBox(height: 6),
                      _buildInfoRow("Gudang", warehouseName),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "RSMSS IoT - Inventory Management System",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
      
      if (imageBytes == null) {
        debugPrint('❌ [Service] generateAndUploadQr - Failed to capture QR image');
        return null;
      }
      
      // 2. Upload to Supabase Storage (bucket: stocks_images)
      final fileName = 'qr_bin_${binId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = 'stock_bins/$fileName';
      
      await _supabase.storage.from('stocks_images').uploadBinary(
        filePath,
        imageBytes,
      );
      
      final publicUrl = _supabase.storage.from('stocks_images').getPublicUrl(filePath);
      
      debugPrint('✅ [Service] generateAndUploadQr - Success: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ [Service] generateAndUploadQr - Error: $e');
      debugPrint('📚 [Service] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Helper method to build info row in QR widget
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        const Text(":", style: TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}