// lib/features/stock_in/services/stock_in_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
// import '../../../core/services/auth_service.dart';
import '../models/stock_in_model.dart';

class StockInService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Ambil current user ID dari AuthService
  String? get _currentUserId => authService.currentUserId;

  // Helper untuk debug print
  void _debugPrint(String tag, dynamic data) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [STOCK_IN][$tag] $data');
  }

  void _debugError(String tag, dynamic error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [STOCK_IN][$tag] ❌ ERROR: $error');
    if (stackTrace != null) {
      print('[$timestamp] [STOCK_IN][$tag] 📚 STACKTRACE: $stackTrace');
    }
  }

  // Generate receipt number: SIN-YYYYMMDD-XXXX
  Future<String> generateReceiptNumber() async {
    try {
      _debugPrint('generateReceiptNumber', 'Memulai generate receipt number...');
      
      final today = DateTime.now();
      final datePart = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final prefix = 'SIN-$datePart';
      
      _debugPrint('generateReceiptNumber', 'Prefix: $prefix');
      
      final response = await _supabase
          .from('stock_in')
          .select('receipt_number')
          .ilike('receipt_number', '$prefix-%')
          .order('receipt_number', ascending: false)
          .limit(1);
      
      _debugPrint('generateReceiptNumber', 'Response length: ${response.length}');
      
      if (response.isEmpty) {
        final newNumber = '$prefix-0001';
        _debugPrint('generateReceiptNumber', 'No existing number, created: $newNumber');
        return newNumber;
      }
      
      final lastNumber = response[0]['receipt_number'] as String;
      final lastSeq = int.parse(lastNumber.split('-').last);
      final newSeq = (lastSeq + 1).toString().padLeft(4, '0');
      final newNumber = '$prefix-$newSeq';
      
      _debugPrint('generateReceiptNumber', 'Last: $lastNumber, New: $newNumber');
      return newNumber;
    } catch (e, stackTrace) {
      _debugError('generateReceiptNumber', e, stackTrace);
      rethrow;
    }
  }

  // Get all stock_in with stock info (join)
  Future<List<StockInModel>> getAllStockIn({String? status}) async {
    try {
      _debugPrint('getAllStockIn', 'Memulai get all stock_in, status filter: $status');
      
      final query = _supabase
          .from('stock_in')
          .select('''
            *,
            stocks!stock_in_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''');
      
      // Apply status filter if needed
      if (status != null && status.isNotEmpty && status != 'ALL') {
        query.eq('status', status);
        _debugPrint('getAllStockIn', 'Filter applied: status = $status');
      }
      
      final response = await query.order('received_at', ascending: false);
      
      _debugPrint('getAllStockIn', 'Success, total data: ${response.length}');
      
      return (response as List)
          .map((json) => StockInModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getAllStockIn', e, stackTrace);
      rethrow;
    }
  }

  // Get stock_in by ID
  Future<StockInModel?> getStockInById(String id) async {
    try {
      _debugPrint('getStockInById', 'Memulai get by ID: $id');
      
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
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        _debugPrint('getStockInById', 'Data not found for ID: $id');
        return null;
      }
      
      _debugPrint('getStockInById', 'Success found data for ID: $id');
      return StockInModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('getStockInById', e, stackTrace);
      rethrow;
    }
  }

  // Get stock_in by receipt number
  Future<StockInModel?> getStockInByReceiptNumber(String receiptNumber) async {
    try {
      _debugPrint('getStockInByReceiptNumber', 'Memulai get by receipt: $receiptNumber');
      
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
          .eq('receipt_number', receiptNumber)
          .maybeSingle();
      
      if (response == null) {
        _debugPrint('getStockInByReceiptNumber', 'Data not found for receipt: $receiptNumber');
        return null;
      }
      
      _debugPrint('getStockInByReceiptNumber', 'Success found data for receipt: $receiptNumber');
      return StockInModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('getStockInByReceiptNumber', e, stackTrace);
      rethrow;
    }
  }

  // Create new stock_in
  Future<StockInModel> createStockIn(StockInModel stockIn) async {
    try {
      _debugPrint('createStockIn', 'Memulai create stock_in');
      _debugPrint('createStockIn', 'Receipt: ${stockIn.receiptNumber}');
      _debugPrint('createStockIn', 'Stock ID: ${stockIn.stockId}');
      _debugPrint('createStockIn', 'Quantity: ${stockIn.quantity}');
      _debugPrint('createStockIn', 'Batch: ${stockIn.batchNumber}');
      _debugPrint('createStockIn', 'Expiry: ${stockIn.expiryDate}');
      
      // Auto set received_by jika tidak diisi
      final data = stockIn.toJson();
      if (_currentUserId != null && data['received_by'] == null) {
        data['received_by'] = _currentUserId;
        _debugPrint('createStockIn', 'Auto set received_by: $_currentUserId');
      }
      
      final response = await _supabase
          .from('stock_in')
          .insert(data)
          .select('''
            *,
            stocks!stock_in_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''')
          .single();
      
      _debugPrint('createStockIn', '✅ Success created stock_in with ID: ${response['id']}');
      return StockInModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('createStockIn', e, stackTrace);
      rethrow;
    }
  }

  // Update stock_in
  Future<StockInModel> updateStockIn(StockInModel stockIn) async {
    try {
      _debugPrint('updateStockIn', 'Memulai update stock_in ID: ${stockIn.id}');
      _debugPrint('updateStockIn', 'Receipt: ${stockIn.receiptNumber}');
      _debugPrint('updateStockIn', 'Quantity: ${stockIn.quantity}');
      
      final response = await _supabase
          .from('stock_in')
          .update(stockIn.toJson())
          .eq('id', stockIn.id!)
          .select('''
            *,
            stocks!stock_in_stock_id_fkey (
              stock_code,
              stock_name,
              unit
            )
          ''')
          .single();
      
      _debugPrint('updateStockIn', '✅ Success updated stock_in ID: ${stockIn.id}');
      return StockInModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('updateStockIn', e, stackTrace);
      rethrow;
    }
  }

  // Update status only
  Future<void> updateStatus(String id, String status) async {
    try {
      _debugPrint('updateStatus', 'Memulai update status for ID: $id to $status');
      
      await _supabase
          .from('stock_in')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', id);
      
      _debugPrint('updateStatus', '✅ Success updated status for ID: $id to $status');
    } catch (e, stackTrace) {
      _debugError('updateStatus', e, stackTrace);
      rethrow;
    }
  }

  // Delete stock_in
  Future<void> deleteStockIn(String id) async {
    try {
      _debugPrint('deleteStockIn', 'Memulai delete stock_in ID: $id');
      
      await _supabase.from('stock_in').delete().eq('id', id);
      
      _debugPrint('deleteStockIn', '✅ Success deleted stock_in ID: $id');
    } catch (e, stackTrace) {
      _debugError('deleteStockIn', e, stackTrace);
      rethrow;
    }
  }

  // Get stocks for dropdown (hanya yang aktif)
  Future<List<Map<String, dynamic>>> getAvailableStocks() async {
    try {
      _debugPrint('getAvailableStocks', 'Memulai get available stocks for dropdown');
      
      final response = await _supabase
          .from('stocks')
          .select('id, stock_code, stock_name, unit, current_stock')
          .eq('is_active', true)
          .order('stock_name');
      
      _debugPrint('getAvailableStocks', '✅ Success, total stocks: ${response.length}');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      _debugError('getAvailableStocks', e, stackTrace);
      rethrow;
    }
  }

  // Get pending put away (RECEIVED or PARTIALLY_PUT_AWAY)
  Future<List<StockInModel>> getPendingPutAway() async {
    try {
      _debugPrint('getPendingPutAway', 'Memulai get pending put away');
      
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
          .order('received_at', ascending: true);
      
      _debugPrint('getPendingPutAway', '✅ Success, total pending: ${response.length}');
      return (response as List)
          .map((json) => StockInModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getPendingPutAway', e, stackTrace);
      rethrow;
    }
  }

  // Get completed put away
  Future<List<StockInModel>> getCompletedPutAway({int limit = 50}) async {
    try {
      _debugPrint('getCompletedPutAway', 'Memulai get completed put away, limit: $limit');
      
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
          .eq('status', 'COMPLETED')
          .order('received_at', ascending: false)
          .limit(limit);
      
      _debugPrint('getCompletedPutAway', '✅ Success, total completed: ${response.length}');
      return (response as List)
          .map((json) => StockInModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getCompletedPutAway', e, stackTrace);
      rethrow;
    }
  }
}