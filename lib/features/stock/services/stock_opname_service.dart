import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/stock_opname_input_model.dart';

class StockOpnameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Load semua stock aktif untuk opname
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
            stock_condition,
            storage_location_id,
            storage_locations(location_name)
          ''')
          .eq('is_active', true)
          .order('stock_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Simpan hasil opname (trigger akan update current_stock otomatis)
  Future<Map<String, String>> saveOpname({
    required StockOpnameInputModel input,
  }) async {
    final opnameId = const Uuid().v4();

    await _supabase.from('stocks_opnames').insert({
      'id': opnameId,
      'stock_id': input.stockId,
      'stock_before': input.stockBefore,
      'physical_stock': input.physicalStock,
      'adjustment_stock': input.adjustmentStock,
      'opname_note': input.opnameNote,
      'opname_by': input.opnameBy,
      'opname_at': DateTime.now().toIso8601String(),
    });

    return {'opnameId': opnameId, 'stockId': input.stockId};
  }
}