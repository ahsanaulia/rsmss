import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/stock_input_model.dart';

class StockService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Generate stock code otomatis
  String generateStockCode() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = const Uuid().v4().substring(0, 6).toUpperCase();
    return "STK-$dateStr-$random";
  }

  /// Load stock types dari database
  Future<List<Map<String, dynamic>>> loadStockTypes() async {
    try {
      final response = await _supabase
          .from('ref_stock_types')
          .select()
          .order('type_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Load storage locations dari database
  Future<List<Map<String, dynamic>>> loadStorageLocations() async {
    try {
      final response = await _supabase
          .from('storage_locations')
          .select()
          .eq('is_active', true)
          .order('location_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload foto stock
  Future<String?> uploadStockPhoto({
    required File image,
    required String stockId,
  }) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = "stock_${DateTime.now().millisecondsSinceEpoch}.$fileExt";
      final path = "stocks/$stockId/$fileName";

      await _supabase.storage
          .from('asset_images')
          .upload(path, image, fileOptions: const FileOptions(upsert: true));

      return _supabase.storage.from('asset_images').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }

  /// Cek apakah stock code sudah ada
  Future<bool> isStockCodeExists(String stockCode) async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('id')
          .eq('stock_code', stockCode)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Simpan stock baru
  Future<Map<String, String>> saveStock({
    required StockInputModel input,
    required String createdBy,
  }) async {
    final stockId = const Uuid().v4();

    String? photoUrl;
    if (input.photo != null) {
      photoUrl = await uploadStockPhoto(image: input.photo!, stockId: stockId);
    }

    await _supabase.from('stocks').insert({
      'id': stockId,
      'stock_code': input.stockCode,
      'stock_name': input.stockName,
      'stock_type_id': input.stockTypeId,
      'unit': input.unit,
      'minimum_stock': input.minimumStock,
      'current_stock': input.currentStock,
      'storage_location_id': input.storageLocationId,
      'stock_condition': input.stockCondition,
      'batch_number': input.batchNumber,
      'expiry_date': input.expiryDate?.toIso8601String(),
      'photo_url': photoUrl,
      'description': input.description,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': true,
    });

    return {'stockId': stockId, 'stockCode': input.stockCode};
  }
}