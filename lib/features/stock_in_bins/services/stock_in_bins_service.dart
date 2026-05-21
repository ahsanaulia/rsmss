// lib/features/stock_in_bins/services/stock_in_bins_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';
import '../models/stock_in_bins_model.dart';
import '../../stock_in/models/stock_in_model.dart';
import '../../stock_in/services/stock_in_service.dart';

class StockInBinsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String? get _currentUserId => authService.currentUserId;

  void _debugPrint(String tag, dynamic data) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [STOCK_IN_BINS][$tag] $data');
  }

  void _debugError(String tag, dynamic error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [STOCK_IN_BINS][$tag] ❌ ERROR: $error');
    if (stackTrace != null) {
      print('[$timestamp] [STOCK_IN_BINS][$tag] 📚 STACKTRACE: $stackTrace');
    }
  }

  // Get all stock_in_bins
  Future<List<StockInBinsModel>> getAllStockInBins() async {
    try {
      _debugPrint('getAllStockInBins', 'Memulai get all stock_in_bins');
      
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            *,
            stock_bins!stock_in_bins_bin_id_fkey (
              code
            ),
            stocks!stock_in_bins_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            ),
            stock_in!stock_in_bins_stock_in_id_fkey (
              receipt_number
            )
          ''')
          .order('put_away_at', ascending: false);
      
      _debugPrint('getAllStockInBins', '✅ Success, total data: ${response.length}');
      
      return (response as List)
          .map((json) => StockInBinsModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getAllStockInBins', e, stackTrace);
      rethrow;
    }
  }

  // Get stock_in_bins by stock_in_id
  Future<List<StockInBinsModel>> getByStockInId(String stockInId) async {
    try {
      _debugPrint('getByStockInId', 'Mencari untuk stock_in_id: $stockInId');
      
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            *,
            stock_bins!stock_in_bins_bin_id_fkey (
              code
            ),
            stocks!stock_in_bins_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''')
          .eq('stock_in_id', stockInId);
      
      _debugPrint('getByStockInId', '✅ Found ${response.length} items');
      
      return (response as List)
          .map((json) => StockInBinsModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getByStockInId', e, stackTrace);
      rethrow;
    }
  }

  // Get all bins for dropdown (dari view stock_bins_full)
  Future<List<Map<String, dynamic>>> getAllBins() async {
    try {
      _debugPrint('getAllBins', 'Mengambil data bin dari stock_bins_full');
      
      final response = await _supabase
          .from('stock_bins_full')
          .select('bin_id, bin_code, full_location_code, full_location_name, current_quantity, max_quantity')
          .eq('bin_is_active', true)
          .order('full_location_code');
      
      _debugPrint('getAllBins', '✅ Success, total bins: ${response.length}');
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      _debugError('getAllBins', e, stackTrace);
      rethrow;
    }
  }

  // Get available bins untuk stock tertentu (bisa ditambah)
  Future<List<Map<String, dynamic>>> getAvailableBinsForStock(String stockId) async {
    try {
      _debugPrint('getAvailableBinsForStock', 'Mencari bin untuk stock_id: $stockId');
      
      // Ambil bin yang kosong atau sudah berisi stock yang sama
      final response = await _supabase
          .from('stock_bins_full')
          .select('bin_id, bin_code, full_location_code, full_location_name, current_quantity, current_product_id')
          .eq('bin_is_active', true)
          .or('current_product_id.is.null,current_product_id.eq.$stockId')
          .order('full_location_code');
      
      _debugPrint('getAvailableBinsForStock', '✅ Found ${response.length} available bins');
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      _debugError('getAvailableBinsForStock', e, stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // PERBAIKAN: getPendingStockIn dengan perhitungan sisa stok
  // =====================================================
  Future<List<StockInModel>> getPendingStockIn() async {
    try {
      _debugPrint('getPendingStockIn', '🚀 Memulai mengambil pending stock_in dengan perhitungan sisa...');
      
      // 1. Ambil semua stock_in dengan status RECEIVED atau PARTIALLY_PUT_AWAY
      final response = await _supabase
          .from('stock_in')
          .select('''
            *,
            stocks!stock_in_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''')
          .inFilter('status', ['RECEIVED', 'PARTIALLY_PUT_AWAY'])
          .order('created_at', ascending: true);
      
      _debugPrint('getPendingStockIn', '📊 Total stock_in dengan status RECEIVED/PARTIALLY: ${response.length}');
      
      final List<StockInModel> result = [];
      
      // 2. Untuk setiap stock_in, hitung sisa stok
      for (var item in response as List) {
        final stockInId = item['id'];
        final totalQuantity = (item['quantity'] as num).toDouble();
        
        _debugPrint('getPendingStockIn', '🔍 Memproses ID: $stockInId, Total: $totalQuantity');
        
        // Hitung total yang sudah di-put-away
        final putAwayResponse = await _supabase
            .from('stock_in_bins')
            .select('quantity')
            .eq('stock_in_id', stockInId);
        
        double totalPutAway = 0;
        for (var pa in putAwayResponse) {
          totalPutAway += (pa['quantity'] as num).toDouble();
        }
        
        final remaining = totalQuantity - totalPutAway;
        
        _debugPrint('getPendingStockIn', '   📦 Total Put Away: $totalPutAway, Sisa: $remaining');
        
        // 3. Hanya masukkan jika masih ada sisa (remaining > 0)
        if (remaining > 0) {
          _debugPrint('getPendingStockIn', '   ✅ Ditambahkan ke hasil (sisa: $remaining)');
          
          // Buat copy item dengan quantity = remaining (sisa)
          final modifiedItem = Map<String, dynamic>.from(item);
          modifiedItem['quantity'] = remaining;  // ← OVERRIDE quantity dengan sisa
          
          // Tambahkan juga info total_put_away (opsional, untuk debugging)
          modifiedItem['total_put_away'] = totalPutAway;
          
          result.add(StockInModel.fromJson(modifiedItem));
        } else {
          _debugPrint('getPendingStockIn', '   ⏭️ Dilewati (sisa: $remaining, sudah habis)');
        }
      }
      
      _debugPrint('getPendingStockIn', '✅ FINAL: Found ${result.length} pending items (dengan sisa > 0)');
      return result;
    } catch (e, stackTrace) {
      _debugError('getPendingStockIn', e, stackTrace);
      rethrow;
    }
  }

  // Get detail pending stock_in with remaining quantity
  Future<Map<String, dynamic>> getPendingStockInDetail(String stockInId) async {
    try {
      _debugPrint('getPendingStockInDetail', '📋 Detail untuk ID: $stockInId');
      
      // Ambil data stock_in
      final stockInService = StockInService();
      final stockIn = await stockInService.getStockInById(stockInId);
      
      if (stockIn == null) {
        throw Exception('Stock In tidak ditemukan');
      }
      
      // Ambil total yang sudah di-put-away
      final putAwayItems = await getByStockInId(stockInId);
      final totalPutAway = putAwayItems.fold(0.0, (sum, item) => sum + item.quantity);
      final remaining = stockIn.quantity - totalPutAway;
      
      _debugPrint('getPendingStockInDetail', '   Total: ${stockIn.quantity}, Put Away: $totalPutAway, Remaining: $remaining');
      
      return {
        'stockIn': stockIn,
        'totalPutAway': totalPutAway,
        'remaining': remaining,
        'putAwayItems': putAwayItems,
      };
    } catch (e, stackTrace) {
      _debugError('getPendingStockInDetail', e, stackTrace);
      rethrow;
    }
  }

  // Create put away (INSERT ke stock_in_bins)
  Future<StockInBinsModel> createPutAway(StockInBinsModel putAway) async {
    try {
      _debugPrint('createPutAway', '🚀 Memulai put away');
      _debugPrint('createPutAway', '   Stock In ID: ${putAway.stockInId}');
      _debugPrint('createPutAway', '   Bin ID: ${putAway.binId}');
      _debugPrint('createPutAway', '   Quantity: ${putAway.quantity}');
      _debugPrint('createPutAway', '   Batch: ${putAway.batchNumber}');
      
      final data = putAway.toJson();
      if (_currentUserId != null && data['put_away_by'] == null) {
        data['put_away_by'] = _currentUserId;
        _debugPrint('createPutAway', '   Auto set put_away_by: $_currentUserId');
      }
      
      final response = await _supabase
          .from('stock_in_bins')
          .insert(data)
          .select('''
            *,
            stock_bins!stock_in_bins_bin_id_fkey (
              code
            ),
            stocks!stock_in_bins_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''')
          .single();
      
      _debugPrint('createPutAway', '✅ SUCCESS! Put away created with ID: ${response['id']}');
      return StockInBinsModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('createPutAway', e, stackTrace);
      rethrow;
    }
  }

  // Update put away
  Future<StockInBinsModel> updatePutAway(StockInBinsModel putAway) async {
    try {
      _debugPrint('updatePutAway', '🔄 Updating put away ID: ${putAway.id}');
      
      final response = await _supabase
          .from('stock_in_bins')
          .update(putAway.toJson())
          .eq('id', putAway.id!)
          .select('''
            *,
            stock_bins!stock_in_bins_bin_id_fkey (
              code
            ),
            stocks!stock_in_bins_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''')
          .single();
      
      _debugPrint('updatePutAway', '✅ SUCCESS! Put away updated');
      return StockInBinsModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('updatePutAway', e, stackTrace);
      rethrow;
    }
  }

  // Delete put away
  Future<void> deletePutAway(String id) async {
    try {
      _debugPrint('deletePutAway', '🗑️ Deleting put away ID: $id');
      
      await _supabase.from('stock_in_bins').delete().eq('id', id);
      
      _debugPrint('deletePutAway', '✅ SUCCESS! Put away deleted');
    } catch (e, stackTrace) {
      _debugError('deletePutAway', e, stackTrace);
      rethrow;
    }
  }

  // Scan bin by barcode
  Future<Map<String, dynamic>?> scanBinByBarcode(String barcode) async {
    try {
      _debugPrint('scanBinByBarcode', '📷 Scanning barcode: $barcode');
      
      final response = await _supabase
          .from('stock_bins_full')
          .select('bin_id, bin_code, full_location_code, full_location_name, current_quantity, current_product_id')
          .eq('barcode', barcode)
          .eq('bin_is_active', true)
          .maybeSingle();
      
      if (response == null) {
        _debugPrint('scanBinByBarcode', '❌ Barcode tidak ditemukan!');
        return null;
      }
      
      _debugPrint('scanBinByBarcode', '✅ Bin ditemukan: ${response['bin_code']} - ${response['full_location_name']}');
      return response;
    } catch (e, stackTrace) {
      _debugError('scanBinByBarcode', e, stackTrace);
      return null;
    }
  }
}