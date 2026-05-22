// lib/features/stock/services/stock_write_off_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/stock_write_off_model.dart';
import '../providers/stock_write_off_state.dart';

class StockWriteOffService {
  final SupabaseClient _supabase = Supabase.instance.client;

  void _log(String tag, dynamic data) {
    print('🔴 [STOCK_WRITE_OFF_SERVICE][$tag] $data');
  }

  Future<List<Map<String, dynamic>>> loadBinsForWriteOff() async {
    try {
      _log('loadBinsForWriteOff', 'Memulai load bins...');
      final response = await _supabase
          .from('stock_bins_full')
          .select('bin_id, bin_code, full_location_code, full_location_name')
          .eq('bin_is_active', true)
          .order('full_location_code');
      _log('loadBinsForWriteOff', '✅ Loaded ${response.length} bins');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('loadBinsForWriteOff', '❌ ERROR: $e');
      rethrow;
    }
  }

  Future<List<WriteOffBinItem>> loadBinItems(String binId) async {
    try {
      _log('loadBinItems', 'Memuat item untuk bin: $binId');
      final response = await _supabase
          .from('stock_in_bins')
          .select('''
            id, stock_id, quantity, batch_number, expiry_date,
            stocks!inner (stock_name, unit)
          ''')
          .eq('bin_id', binId)
          .gt('quantity', 0);
      
      final items = <WriteOffBinItem>[];
      for (var item in response) {
        final stocks = item['stocks'] as Map?;
        items.add(WriteOffBinItem(
          stockInBinsId: item['id'].toString(),
          stockId: item['stock_id'].toString(),
          stockName: stocks?['stock_name']?.toString() ?? 'Unknown',
          batchNumber: item['batch_number']?.toString() ?? '',
          expiryDate: DateTime.tryParse(item['expiry_date'].toString()) ?? DateTime.now(),
          systemQuantity: (item['quantity'] as num?)?.toDouble() ?? 0,
          unit: stocks?['unit']?.toString() ?? '',
        ));
      }
      _log('loadBinItems', '✅ Loaded ${items.length} items');
      return items;
    } catch (e) {
      _log('loadBinItems', '❌ ERROR: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getBinByBarcode(String barcode) async {
    try {
      _log('getBinByBarcode', 'Mencari barcode: $barcode');
      final response = await _supabase
          .from('stock_bins_full')
          .select('bin_id, bin_code, full_location_code, full_location_name')
          .eq('barcode', barcode)
          .eq('bin_is_active', true)
          .maybeSingle();
      _log('getBinByBarcode', response == null ? '❌ Tidak ditemukan' : '✅ Ditemukan');
      return response;
    } catch (e) {
      _log('getBinByBarcode', '❌ ERROR: $e');
      return null;
    }
  }

  Future<String> generateWriteOffNumber() async {
    try {
      final today = DateTime.now();
      final datePart = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final prefix = 'WO-$datePart';
      
      final response = await _supabase
          .from('stock_write_offs')
          .select('write_off_number')
          .ilike('write_off_number', '$prefix-%')
          .order('write_off_number', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        _log('generateWriteOffNumber', 'Generated: $prefix-0001');
        return '$prefix-0001';
      }
      
      final lastNumber = response[0]['write_off_number'] as String;
      final lastSeq = int.parse(lastNumber.split('-').last);
      final newSeq = (lastSeq + 1).toString().padLeft(4, '0');
      _log('generateWriteOffNumber', 'Generated: $prefix-$newSeq');
      return '$prefix-$newSeq';
    } catch (e) {
      _log('generateWriteOffNumber', '❌ ERROR: $e');
      final today = DateTime.now();
      final datePart = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      return 'WO-$datePart-0001';
    }
  }

  Future<StockWriteOffModel> createWriteOff(StockWriteOffModel writeOff) async {
    try {
      _log('createWriteOff', 'Membuat write-off: ${writeOff.writeOffNumber}');
      final id = const Uuid().v4();
      final data = writeOff.toJson();
      data['id'] = id;
      data['requested_at'] = DateTime.now().toIso8601String();
      
      await _supabase.from('stock_write_offs').insert(data);
      _log('createWriteOff', '✅ Created with ID: $id');
      return writeOff.copyWith(id: id);
    } catch (e) {
      _log('createWriteOff', '❌ ERROR: $e');
      rethrow;
    }
  }

  Future<List<StockWriteOffModel>> getMyWriteOffs(String userId) async {
    try {
      _log('getMyWriteOffs', 'Mengambil write-off untuk user: $userId');
      final response = await _supabase
          .from('stock_write_offs')
          .select('*, stocks!stock_write_offs_stock_id_fkey (stock_name)')
          .eq('requested_by', userId)
          .order('created_at', ascending: false);
      
      final result = <StockWriteOffModel>[];
      for (var item in response as List) {
        final stocks = item['stocks'] as Map?;
        result.add(StockWriteOffModel.fromJson({
          ...item,
          'stock_name': stocks?['stock_name'],
        }));
      }
      _log('getMyWriteOffs', '✅ Found ${result.length} items');
      return result;
    } catch (e) {
      _log('getMyWriteOffs', '❌ ERROR: $e');
      return [];
    }
  }

  Future<List<StockWriteOffModel>> getAllWriteOffs() async {
    try {
      _log('getAllWriteOffs', 'Mengambil semua write-off');
      final response = await _supabase
          .from('stock_write_offs')
          .select('*, stocks!stock_write_offs_stock_id_fkey (stock_name)')
          .order('created_at', ascending: false);
      
      final result = <StockWriteOffModel>[];
      for (var item in response as List) {
        final stocks = item['stocks'] as Map?;
        result.add(StockWriteOffModel.fromJson({
          ...item,
          'stock_name': stocks?['stock_name'],
        }));
      }
      _log('getAllWriteOffs', '✅ Found ${result.length} items');
      return result;
    } catch (e) {
      _log('getAllWriteOffs', '❌ ERROR: $e');
      return [];
    }
  }

  Future<void> approveWriteOff(String writeOffId, String approvedBy) async {
    try {
      _log('approveWriteOff', '🔴🔴🔴 MEMULAI APPROVE WRITE-OFF 🔴🔴🔴');
      _log('approveWriteOff', 'writeOffId: $writeOffId');
      _log('approveWriteOff', 'approvedBy: $approvedBy');
      
      // 1. Ambil data write-off
      _log('approveWriteOff', 'Mengambil data write-off...');
      final writeOff = await _supabase
          .from('stock_write_offs')
          .select('stock_in_bins_id, quantity')
          .eq('id', writeOffId)
          .single();
      _log('approveWriteOff', 'Data write-off: $writeOff');
      
      // 2. Kurangi stok
      _log('approveWriteOff', 'Memanggil RPC reduce_stock_in_bins_quantity...');
      await _supabase.rpc('reduce_stock_in_bins_quantity', params: {
        'p_stock_in_bins_id': writeOff['stock_in_bins_id'],
        'p_quantity': writeOff['quantity'],
      });
      _log('approveWriteOff', 'RPC reduce_stock_in_bins_quantity BERHASIL');
      
      // 3. Update status
      _log('approveWriteOff', 'Update status menjadi APPROVED...');
      await _supabase
          .from('stock_write_offs')
          .update({
            'status': 'APPROVED',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', writeOffId);
      _log('approveWriteOff', '✅✅✅ APPROVE WRITE-OFF BERHASIL ✅✅✅');
    } catch (e) {
      _log('approveWriteOff', '❌❌❌ ERROR: $e ❌❌❌');
      rethrow;
    }
  }
}