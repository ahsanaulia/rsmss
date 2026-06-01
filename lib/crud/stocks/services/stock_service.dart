// ============================================================
// SERVICE: Stock Service
// ============================================================

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/stock_model.dart';

final _supabase = Supabase.instance.client;
const String _stockImageBucket = 'asset_images';

class StockService {
  
  // ==========================================================
  // READ DATA
  // ==========================================================

  Future<List<Stock>> fetchAllStocks() async {
    try {
      // print('📦 FETCHING ALL STOCKS...');
      final response = await _supabase
          .from('v_crud_stocks')
          .select('*')
          .order('stock_name', ascending: true);

      // print('📦 RESPONSE COUNT: ${response.length}');
      if (response.isEmpty) return [];
      return response.map((item) => Stock.fromJson(item)).toList();
    } catch (e) {
      // print('❌ FETCH ERROR: $e');
      throw Exception('Gagal memuat data stok: $e');
    }
  }

  Future<Stock?> fetchStockById(String stockId) async {
    try {
      final response = await _supabase
          .from('v_crud_stocks')
          .select('*')
          .eq('id', stockId)
          .maybeSingle();
      if (response == null) return null;
      return Stock.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memuat detail stok: $e');
    }
  }

  // ==========================================================
  // DROPDOWN DATA
  // ==========================================================

  Future<List<Map<String, dynamic>>> fetchAllStockTypes() async {
    try {
      return await _supabase
          .from('ref_stock_types')
          .select('id, type_name, description')
          .order('type_name', ascending: true);
    } catch (e) {
      throw Exception('Gagal memuat tipe stok: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllStorageLocations() async {
    try {
      return await _supabase
          .from('storage_locations')
          .select('id, location_name, location_code')
          .eq('is_active', true)
          .order('location_name', ascending: true);
    } catch (e) {
      throw Exception('Gagal memuat lokasi penyimpanan: $e');
    }
  }

  // ==========================================================
  // CREATE / UPDATE / DELETE
  // ==========================================================

  Future<Stock> createStock(Stock stock, String userId) async {
    try {
     
      
      if (stock.stockName.isEmpty) throw Exception('Nama stok wajib diisi');
      if (stock.unit.isEmpty) throw Exception('Satuan wajib diisi');
      
      final jsonData = stock.toJsonForCreate(userId);
      
      final response = await _supabase
          .from('stocks')
          .insert(jsonData)
          .select()
          .single();
      
      
      final createdStock = await fetchStockById(response['id'] as String);
      if (createdStock == null) throw Exception('Gagal mengambil data stok baru');
      
      return createdStock;
    } catch (e) {
      throw Exception('Gagal menambah stok: $e');
    }
  }

  Future<Stock> updateStock(Stock stock, String userId) async {
    try {
      if (stock.id.isEmpty) throw Exception('ID stok tidak ditemukan');
      if (stock.stockName.isEmpty) throw Exception('Nama stok wajib diisi');
      if (stock.unit.isEmpty) throw Exception('Satuan wajib diisi');
      
      final jsonData = stock.toJson();
      // jsonData['updated_by'] = userId;
      jsonData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('stocks')
          .update(jsonData)
          .eq('id', stock.id)
          .select()
          .single();
      
      final updatedStock = await fetchStockById(response['id'] as String);
      if (updatedStock == null) throw Exception('Gagal mengambil data stok yang diperbarui');
      return updatedStock;
    } catch (e) {
      throw Exception('Gagal memperbarui stok: $e');
    }
  }

  Future<bool> deleteStock(String stockId, String userId) async {
    try {
      await _supabase
          .from('stocks')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', stockId);
      return true;
    } catch (e) {
      throw Exception('Gagal menghapus stok: $e');
    }
  }

  // ==========================================================
  // UPLOAD FOTO
  // ==========================================================

  Future<String> uploadStockPhoto(XFile xFile, String stockId) async {
    try {

      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${stockId}_$timestamp.jpg';

      
      final bytes = await xFile.readAsBytes();

      
      await _supabase.storage
          .from(_stockImageBucket)
          .uploadBinary(fileName, bytes);
      
      final publicUrl = _supabase.storage
          .from(_stockImageBucket)
          .getPublicUrl(fileName);
      

      return publicUrl;
    } catch (e) {

      throw Exception('Gagal upload foto: ${e.toString()}');
    }
  }

  Future<void> deleteStockPhoto(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexWhere((s) => s == _stockImageBucket);
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from(_stockImageBucket).remove([filePath]);
      }
    } catch (e) {
      // pri?nt('Gagal menghapus foto stok: $e');
    }
  }

  // ==========================================================
  // SEARCH & FILTER
  // ==========================================================

  Future<List<Stock>> searchStocks(String keyword) async {
    if (keyword.isEmpty) return fetchAllStocks();
    try {
      final response = await _supabase
          .from('v_crud_stocks')
          .select('*')
          .or('stock_name.ilike.%$keyword%, stock_code.ilike.%$keyword%, stock_type_name.ilike.%$keyword%')
          .order('stock_name', ascending: true);
      if (response.isEmpty) return [];
      return response.map((item) => Stock.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mencari stok: $e');
    }
  }

  Future<List<Stock>> filterStocksByCondition(String condition) async {
    try {
      final response = await _supabase
          .from('v_crud_stocks')
          .select('*')
          .eq('stock_condition', condition)
          .order('stock_name', ascending: true);
      if (response.isEmpty) return [];
      return response.map((item) => Stock.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal memfilter stok: $e');
    }
  }

  Future<List<Stock>> filterEmptyStocks() async {
    try {
      final response = await _supabase
          .from('v_crud_stocks')
          .select('*')
          .eq('is_empty', true)
          .order('stock_name', ascending: true);
      if (response.isEmpty) return [];
      return response.map((item) => Stock.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal memfilter stok habis: $e');
    }
  }

  Future<List<Stock>> filterLowStocks() async {
    try {
      final response = await _supabase
          .from('v_crud_stocks')
          .select('*')
          .eq('is_low_stock', true)
          .order('stock_name', ascending: true);
      if (response.isEmpty) return [];
      return response.map((item) => Stock.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal memfilter stok rendah: $e');
    }
  }
}

final stockService = StockService();