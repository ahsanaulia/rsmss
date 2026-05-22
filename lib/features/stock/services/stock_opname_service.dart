// lib/features/stock_opname/services/stock_opname_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/stock_opname_input_model.dart';
import '../providers/stock_opname_state.dart';

class StockOpnameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Load semua stock aktif untuk opname produk (existing)
  Future<List<Map<String, dynamic>>> loadStocksForOpname() async {
    try {
      final response = await _supabase
          .from('stocks')
          .select('''
            id,
            stock_code,
            stock_name,
            unit,
            current_stock,
            minimum_stock,
            stock_condition
          ''')
          .eq('is_active', true)
          .order('stock_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Load semua bin yang tersedia (untuk dropdown)
  Future<List<Map<String, dynamic>>> loadBinsForOpname() async {
    try {
      final response = await _supabase
          .from('stock_bins_full')
          .select('''
            bin_id,
            bin_code,
            full_location_code,
            full_location_name
          ''')
          .eq('bin_is_active', true)
          .order('full_location_code');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Load items dalam bin (dari stock_in_bins)
  Future<List<BinOpnameItem>> loadBinItems(String binId) async {
    try {
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            id,
            stock_id,
            quantity,
            batch_number,
            expiry_date,
            stocks!inner (
              stock_name,
              unit
            )
          ''')
          .eq('bin_id', binId)
          .gt('quantity', 0);
      
      final items = <BinOpnameItem>[];
      for (var item in response) {
        final stocks = item['stocks'] as Map?;
        items.add(BinOpnameItem(
          stockInBinsId: item['id'].toString(),
          stockId: item['stock_id'].toString(),
          stockName: stocks?['stock_name']?.toString() ?? 'Unknown',
          batchNumber: item['batch_number']?.toString() ?? '',
          expiryDate: DateTime.tryParse(item['expiry_date'].toString()) ?? DateTime.now(),
          systemQuantity: (item['quantity'] as num?)?.toDouble() ?? 0,
          unit: stocks?['unit']?.toString() ?? '',
          physicalQuantity: (item['quantity'] as num?)?.toDouble() ?? 0,
        ));
      }
      return items;
    } catch (e) {
      rethrow;
    }
  }

  /// Get bin by barcode (untuk scan QRCode)
  Future<Map<String, dynamic>?> getBinByBarcode(String barcode) async {
    try {
      final response = await _supabase
          .from('stock_bins_full')
          .select('''
            bin_id,
            bin_code,
            full_location_code,
            full_location_name
          ''')
          .eq('barcode', barcode)
          .eq('bin_is_active', true)
          .maybeSingle();
      
      if (response == null) return null;
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Simpan hasil opname produk (existing)
  Future<Map<String, String>> saveOpname({
    required StockOpnameInputModel input,
  }) async {
    final opnameId = const Uuid().v4();
    final data = input.toJson();
    data['id'] = opnameId;

    await _supabase.from('stocks_opnames').insert(data);

    return {'opnameId': opnameId, 'stockId': input.stockId ?? ''};
  }

  /// Simpan hasil opname BIN (baru)
  Future<Map<String, String>> saveBinOpname({
    required StockOpnameInputModel input,
  }) async {
    final opnameId = const Uuid().v4();
    final data = input.toJson();
    data['id'] = opnameId;
    
    await _supabase.from('stocks_opnames').insert(data);

    return {'opnameId': opnameId, 'stockInBinsId': input.stockInBinsId ?? ''};
  }
}