// lib/features/stock/services/stock_mutation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/stock_mutation_model.dart';
import '../providers/stock_mutation_state.dart';

class StockMutationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  void _log(String tag, dynamic data) {
    print('🔴 [STOCK_MUTATION_SERVICE][$tag] $data');
  }

  Future<List<Map<String, dynamic>>> loadBins() async {
    try {
      _log('loadBins', 'Memuat bins...');
      final response = await _supabase
          .from('stock_bins_full')
          .select('bin_id, bin_code, full_location_code, full_location_name')
          .eq('bin_is_active', true)
          .order('full_location_code');
      _log('loadBins', '✅ Loaded ${response.length} bins');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('loadBins', '❌ ERROR: $e');
      rethrow;
    }
  }

  Future<List<MutationBinItem>> loadBinItems(String binId) async {
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
      
      final items = <MutationBinItem>[];
      for (var item in response) {
        final stocks = item['stocks'] as Map?;
        items.add(MutationBinItem(
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

  Future<String> generateMutationNumber() async {
    final today = DateTime.now();
    final datePart = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    final prefix = 'MU-$datePart';
    
    final response = await _supabase
        .from('stock_mutations')
        .select('mutation_number')
        .ilike('mutation_number', '$prefix-%')
        .order('mutation_number', ascending: false)
        .limit(1);
    
    if (response.isEmpty) return '$prefix-0001';
    
    final lastNumber = response[0]['mutation_number'] as String;
    final lastSeq = int.parse(lastNumber.split('-').last);
    final newSeq = (lastSeq + 1).toString().padLeft(4, '0');
    return '$prefix-$newSeq';
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name')
          .order('full_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> createMutation(StockMutationModel mutation) async {
    try {
      _log('createMutation', 'Membuat mutasi: ${mutation.mutationNumber}');
      
      final id = const Uuid().v4();
      final data = mutation.toJson();
      data['id'] = id;
      data['moved_at'] = DateTime.now().toIso8601String();
      if (data['received_at'] == null && data['received_by'] != null) {
        data['received_at'] = DateTime.now().toIso8601String();
      }

      // 1. Kurangi stok di bin asal
      await _supabase.rpc('reduce_stock_in_bins_quantity', params: {
        'p_stock_in_bins_id': mutation.stockInBinsId,
        'p_quantity': mutation.quantity,
      });

      // 2. Tambah stok di bin tujuan
      await _addStockToBin(
        binId: mutation.binIdTujuan,
        stockId: mutation.stockId,
        batchNumber: mutation.batchNumber,
        expiryDate: mutation.expiryDate,
        quantity: mutation.quantity,
        unit: mutation.unit,
        stockInId: null,
        notes: 'Mutasi dari bin ${mutation.binIdAsal}',
      );

      // 3. Catat mutasi
      await _supabase.from('stock_mutations').insert(data);
      
      _log('createMutation', '✅ Mutasi berhasil');
    } catch (e) {
      _log('createMutation', '❌ ERROR: $e');
      rethrow;
    }
  }

  Future<void> _addStockToBin({
    required String binId,
    required String stockId,
    required String batchNumber,
    required DateTime expiryDate,
    required double quantity,
    required String unit,
    String? stockInId,
    String? notes,
  }) async {
    // Cek apakah sudah ada kombinasi yang sama di bin tujuan
    final existing = await _supabase
        .from('stock_in_bins')
        .select('id, quantity')
        .eq('bin_id', binId)
        .eq('stock_id', stockId)
        .eq('batch_number', batchNumber)
        .maybeSingle();

    if (existing != null) {
      // UPDATE quantity (tambah stok ke bin yang sama)
      final newQuantity = (existing['quantity'] as num).toDouble() + quantity;
      await _supabase
          .from('stock_in_bins')
          .update({'quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', existing['id']);
    } else {
      // INSERT baru
      final newId = const Uuid().v4();
      await _supabase.from('stock_in_bins').insert({
        'id': newId,
        'bin_id': binId,
        'stock_id': stockId,
        'batch_number': batchNumber,
        'expiry_date': expiryDate.toIso8601String().split('T').first,
        'quantity': quantity,
        'stock_in_id': stockInId,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}