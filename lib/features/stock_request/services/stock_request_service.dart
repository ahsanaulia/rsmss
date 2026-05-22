// // lib/features/stock_request/services/stock_request_service.dart
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../core/di/service_locator.dart';
// import '../../../core/services/auth_service.dart';
// import '../models/stock_request_model.dart';

// class StockRequestService {
//   final SupabaseClient _supabase = Supabase.instance.client;
  
//   String? get _currentUserId => authService.currentUserId;
//   String? get _currentUserName => authService.currentSession?.fullName;

//   void _debugPrint(String tag, dynamic data) {
//     final timestamp = DateTime.now().toIso8601String();
//     print('[$timestamp] [STOCK_REQUEST][$tag] $data');
//   }

//   void _debugError(String tag, dynamic error, StackTrace? stackTrace) {
//     final timestamp = DateTime.now().toIso8601String();
//     print('[$timestamp] [STOCK_REQUEST][$tag] ❌ ERROR: $error');
//     if (stackTrace != null) {
//       print('[$timestamp] [STOCK_REQUEST][$tag] 📚 STACKTRACE: $stackTrace');
//     }
//   }

//   // Generate request number menggunakan function SQL
//   Future<String> generateRequestNumber() async {
//     try {
//       _debugPrint('generateRequestNumber', 'Memanggil function SQL...');
      
//       final response = await _supabase.rpc('generate_request_number');
      
//       _debugPrint('generateRequestNumber', '✅ Generated: $response');
//       return response as String;
//     } catch (e, stackTrace) {
//       _debugError('generateRequestNumber', e, stackTrace);
//       // Fallback manual jika function error
//       final today = DateTime.now();
//       final datePart = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
//       return 'SR-$datePart-0001';
//     }
//   }

//   // Get all rooms untuk dropdown
//   Future<List<Map<String, dynamic>>> getAllRooms() async {
//     try {
//       _debugPrint('getAllRooms', 'Mengambil data rooms...');
      
//       final response = await _supabase
//           .from('rooms')
//           .select('id, room_name')
//           .order('room_name');
      
//       _debugPrint('getAllRooms', '✅ Success, total rooms: ${response.length}');
//       return List<Map<String, dynamic>>.from(response as List);
//     } catch (e, stackTrace) {
//       _debugError('getAllRooms', e, stackTrace);
//       return [];
//     }
//   }

//   // Get stocks untuk dropdown
//   Future<List<Map<String, dynamic>>> getAvailableStocks() async {
//     try {
//       _debugPrint('getAvailableStocks', 'Mengambil data stocks...');
      
//       final response = await _supabase
//           .from('stocks')
//           .select('id, stock_code, stock_name, unit, current_stock')
//           .eq('is_active', true)
//           .order('stock_name');
      
//       _debugPrint('getAvailableStocks', '✅ Success, total stocks: ${response.length}');
//       return List<Map<String, dynamic>>.from(response as List);
//     } catch (e, stackTrace) {
//       _debugError('getAvailableStocks', e, stackTrace);
//       return [];
//     }
//   }

//   // Create new request
//   Future<StockRequestModel> createRequest(StockRequestModel request) async {
//     try {
//       _debugPrint('createRequest', 'Membuat request baru...');
//       _debugPrint('createRequest', 'Product: ${request.requestedStockName}');
//       _debugPrint('createRequest', 'Quantity: ${request.requestedQuantity} ${request.requestedUnit}');
//       _debugPrint('createRequest', 'Room: ${request.roomId}');
//       _debugPrint('createRequest', 'Purpose: ${request.purpose}');
      
//       final Map<String, dynamic> data = {};
      
//       // Hanya tambahkan field yang memiliki nilai (tidak null)
//       data['request_number'] = request.requestNumber;
//       data['requester_id'] = _currentUserId;  // ← String, bukan String?
//       data['requester_name'] = _currentUserName;
//       data['room_id'] = request.roomId;
//       data['purpose'] = request.purpose;
//       data['request_date'] = request.requestDate.toIso8601String();
//       data['notes'] = request.notes;
//       data['requested_stock_id'] = request.requestedStockId;
//       data['requested_stock_name'] = request.requestedStockName;
//       data['requested_quantity'] = request.requestedQuantity;
//       data['requested_unit'] = request.requestedUnit;
//       data['requested_batch'] = request.requestedBatch;
//       data['status'] = 'PENDING';
//       data['fulfilled_quantity'] = 0;
      
//       // Hapus field yang null (jika ada)
//       data.removeWhere((key, value) => value == null);
      
//       _debugPrint('createRequest', 'Data to insert: $data');
      
//       final response = await _supabase
//           .from('stock_requests')
//           .insert(data)
//           .select('''
//             *,
//             rooms!stock_requests_room_id_fkey (
//               room_name
//             )
//           ''')
//           .single();
      
//       _debugPrint('createRequest', '✅ Success! Request ID: ${response['id']}');
//       return StockRequestModel.fromJson(response);
//     } catch (e, stackTrace) {
//       _debugError('createRequest', e, stackTrace);
//       rethrow;
//     }
//   }

//   // Get my requests (untuk riwayat pegawai)
//   Future<List<StockRequestModel>> getMyRequests() async {
//     try {
//       _debugPrint('getMyRequests', 'Mengambil request milik saya...');
      
//       final response = await _supabase
//           .from('stock_requests')
//           .select('''
//             *,
//             rooms!stock_requests_room_id_fkey (
//               room_name
//             )
//           ''')
//           .eq('requester_id', _currentUserId ?? '')
//           .order('created_at', ascending: false);
      
//       _debugPrint('getMyRequests', '✅ Found ${response.length} requests');
//       return (response as List)
//           .map((json) => StockRequestModel.fromJson(json))
//           .toList();
//     } catch (e, stackTrace) {
//       _debugError('getMyRequests', e, stackTrace);
//       return [];
//     }
//   }
// }

// lib/features/stock_request/services/stock_request_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';
import '../models/stock_request_model.dart';

class StockRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String? get _currentUserId => authService.currentUserId;
  String? get _currentUserName => authService.currentSession?.fullName;

  void _debugPrint(String tag, dynamic data) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [STOCK_REQUEST][$tag] $data');
  }

  void _debugError(String tag, dynamic error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] [STOCK_REQUEST][$tag] ❌ ERROR: $error');
    if (stackTrace != null) {
      print('[$timestamp] [STOCK_REQUEST][$tag] 📚 STACKTRACE: $stackTrace');
    }
  }

  // Generate request number menggunakan function SQL
  Future<String> generateRequestNumber() async {
    try {
      _debugPrint('generateRequestNumber', 'Memanggil function SQL...');
      
      final response = await _supabase.rpc('generate_request_number');
      
      _debugPrint('generateRequestNumber', '✅ Generated: $response');
      return response as String;
    } catch (e, stackTrace) {
      _debugError('generateRequestNumber', e, stackTrace);
      // Fallback manual jika function error
      final today = DateTime.now();
      final datePart = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      return 'SR-$datePart-0001';
    }
  }

  // Get all rooms untuk dropdown
  Future<List<Map<String, dynamic>>> getAllRooms() async {
    try {
      _debugPrint('getAllRooms', 'Mengambil data rooms...');
      
      final response = await _supabase
          .from('rooms')
          .select('id, room_name')
          .order('room_name');
      
      _debugPrint('getAllRooms', '✅ Success, total rooms: ${response.length}');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      _debugError('getAllRooms', e, stackTrace);
      return [];
    }
  }

  // Get stocks untuk dropdown
  Future<List<Map<String, dynamic>>> getAvailableStocks() async {
    try {
      _debugPrint('getAvailableStocks', 'Mengambil data stocks...');
      
      final response = await _supabase
          .from('stocks')
          .select('id, stock_code, stock_name, unit, current_stock')
          .eq('is_active', true)
          .order('stock_name');
      
      _debugPrint('getAvailableStocks', '✅ Success, total stocks: ${response.length}');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      _debugError('getAvailableStocks', e, stackTrace);
      return [];
    }
  }

  // Get all employees (untuk dropdown admin)
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      _debugPrint('getAllEmployees', 'Mengambil data pegawai...');
      
      final response = await _supabase
          .from('profiles')
          .select('id, full_name, role')
          .order('full_name');
      
      _debugPrint('getAllEmployees', '✅ Success, total employees: ${response.length}');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e, stackTrace) {
      _debugError('getAllEmployees', e, stackTrace);
      return [];
    }
  }

  // Create new request
  Future<StockRequestModel> createRequest(StockRequestModel request) async {
    try {
      _debugPrint('createRequest', 'Membuat request baru...');
      _debugPrint('createRequest', 'Product: ${request.requestedStockName}');
      _debugPrint('createRequest', 'Quantity: ${request.requestedQuantity} ${request.requestedUnit}');
      _debugPrint('createRequest', 'Room: ${request.roomId}');
      _debugPrint('createRequest', 'Purpose: ${request.purpose}');
      
      final Map<String, dynamic> data = {};
      
      data['request_number'] = request.requestNumber;
      data['requester_id'] = _currentUserId;
      data['requester_name'] = _currentUserName;
      data['room_id'] = request.roomId;
      data['purpose'] = request.purpose;
      data['request_date'] = request.requestDate.toIso8601String();
      if (request.notes != null) data['notes'] = request.notes;
      data['requested_stock_id'] = request.requestedStockId;
      data['requested_stock_name'] = request.requestedStockName;
      data['requested_quantity'] = request.requestedQuantity;
      data['requested_unit'] = request.requestedUnit;
      if (request.requestedBatch != null) data['requested_batch'] = request.requestedBatch;
      data['status'] = 'PENDING';
      data['fulfilled_quantity'] = 0;
      
      data.removeWhere((key, value) => value == null);
      
      _debugPrint('createRequest', 'Data to insert: $data');
      
      final response = await _supabase
          .from('stock_requests')
          .insert(data)
          .select('''
            *,
            rooms!stock_requests_room_id_fkey (
              room_name
            )
          ''')
          .single();
      
      _debugPrint('createRequest', '✅ Success! Request ID: ${response['id']}');
      return StockRequestModel.fromJson(response);
    } catch (e, stackTrace) {
      _debugError('createRequest', e, stackTrace);
      rethrow;
    }
  }

  // Get my requests (untuk riwayat pegawai)
  Future<List<StockRequestModel>> getMyRequests() async {
    try {
      _debugPrint('getMyRequests', 'Mengambil request milik saya...');
      
      final response = await _supabase
          .from('stock_requests')
          .select('''
            *,
            rooms!stock_requests_room_id_fkey (
              room_name
            )
          ''')
          .eq('requester_id', _currentUserId ?? '')
          .order('created_at', ascending: false);
      
      _debugPrint('getMyRequests', '✅ Found ${response.length} requests');
      return (response as List)
          .map((json) => StockRequestModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getMyRequests', e, stackTrace);
      return [];
    }

    
  }

  // Get approved requests (APPROVED or PARTIALLY_FULFILLED)
Future<List<StockRequestModel>> getApprovedRequests() async {
  try {
    _debugPrint('getApprovedRequests', 'Mengambil request yang sudah APPROVED...');
    
    final response = await _supabase
        .from('stock_requests')
        .select('''
          *,
          rooms!stock_requests_room_id_fkey (
            room_name
          )
        ''')
        .inFilter('status', ['APPROVED', 'PARTIALLY_FULFILLED'])
        .order('created_at', ascending: true);
    
    _debugPrint('getApprovedRequests', '✅ Found ${response.length} requests');
    return (response as List)
        .map((json) => StockRequestModel.fromJson(json))
        .toList();
  } catch (e, stackTrace) {
    _debugError('getApprovedRequests', e, stackTrace);
    return [];
  }
}

// Get available stock in bins (yang masih punya quantity > 0)
// Di stock_request_service.dart - getAvailableStockInBins
// lib/features/stock_request/services/stock_request_service.dart
// Ganti method getAvailableStockInBins dengan yang ini:

Future<List<Map<String, dynamic>>> getAvailableStockInBins(String stockId) async {
  try {
    _debugPrint('getAvailableStockInBins', 'Mencari stok tersedia untuk stock_id: $stockId');
    
    // Query dengan JOIN yang benar untuk Supabase
    final response = await _supabase
        .from('stock_in_bins')
        .select('''
          id,
          bin_id,
          quantity,
          batch_number,
          expiry_date,
          stock_bins!inner (
            code,
            barcode
          )
        ''')
        .eq('stock_id', stockId)
        .gt('quantity', 0)
        .order('expiry_date', ascending: true);
    
    _debugPrint('getAvailableStockInBins', 'Raw response: ${response.length} items');
    
    final result = <Map<String, dynamic>>[];
    
    for (var item in response) {
      // Ekstrak data bin dari nested object
      final binData = item['stock_bins'] as Map?;
      final binCode = binData?['code'] as String? ?? 'Unknown';
      
      // Ambil full_location_name dari view stock_bins_full
      String? fullLocation;
      try {
        final binFull = await _supabase
            .from('stock_bins_full')
            .select('full_location_name')
            .eq('bin_id', item['bin_id'])
            .maybeSingle();
        
        fullLocation = binFull?['full_location_name'] as String?;
      } catch (e) {
        _debugPrint('getAvailableStockInBins', 'Error getting location: $e');
      }
      
      result.add({
        'stock_in_bins_id': item['id'],
        'bin_id': item['bin_id'],
        'bin_code': binCode,
        'full_location_name': fullLocation ?? binCode,
        'quantity': (item['quantity'] as num?)?.toDouble() ?? 0,
        'batch_number': item['batch_number'] ?? '',
        'expiry_date': item['expiry_date'],
      });
    }
    
    _debugPrint('getAvailableStockInBins', '✅ Found ${result.length} bins with stock');
    return result;
  } catch (e, stackTrace) {
    _debugError('getAvailableStockInBins', e, stackTrace);
    return [];
  }
}

// Get stock_in_bins by barcode
Future<Map<String, dynamic>?> getStockInBinsByBarcode(String stockId, String barcode) async {
  try {
    _debugPrint('getStockInBinsByBarcode', 'Mencari barcode: $barcode untuk stock_id: $stockId');
    
    // Cari bin dari view stock_bins_full
    final binFull = await _supabase
        .from('stock_bins_full')
        .select('bin_id, bin_code, full_location_name, current_quantity')
        .eq('barcode', barcode)
        .eq('bin_is_active', true)
        .maybeSingle();
    
    if (binFull == null) {
      _debugPrint('getStockInBinsByBarcode', '❌ Barcode tidak ditemukan');
      return null;
    }
    
    // Cari stock_in_bins untuk bin tersebut
    final stockInBins = await _supabase
        .from('stock_in_bins')
        .select('id, quantity, batch_number, expiry_date')
        .eq('bin_id', binFull['bin_id'])
        .eq('stock_id', stockId)
        .gt('quantity', 0)
        .maybeSingle();
    
    if (stockInBins == null) {
      _debugPrint('getStockInBinsByBarcode', '❌ Stok tidak tersedia di bin ini');
      return null;
    }
    
    return {
      'stock_in_bins_id': stockInBins['id'],
      'bin_id': binFull['bin_id'],
      'bin_code': binFull['bin_code'],
      'full_location_name': binFull['full_location_name'] ?? binFull['bin_code'],
      'quantity': stockInBins['quantity'],
      'batch_number': stockInBins['batch_number'],
      'expiry_date': stockInBins['expiry_date'],
    };
  } catch (e, stackTrace) {
    _debugError('getStockInBinsByBarcode', e, stackTrace);
    return null;
  }
}

// Create fulfillment
Future<void> createFulfillment(StockRequestFulfillmentModel fulfillment) async {
  try {
    _debugPrint('createFulfillment', 'Membuat fulfillment untuk request: ${fulfillment.stockRequestId}');
    
    // Ambil batch_number dan expiry_date dari stock_in_bins
    final stockInBins = await _supabase
        .from('stock_in_bins')
        .select('batch_number, expiry_date')
        .eq('id', fulfillment.stockInBinsId)
        .single();
    
    final data = fulfillment.toJson();
    data['batch_number'] = stockInBins['batch_number'];
    data['expiry_date'] = stockInBins['expiry_date'];
    data['taken_by'] = _currentUserId;
    
    await _supabase
        .from('stock_request_fulfillments')
        .insert(data);
    
    _debugPrint('createFulfillment', '✅ Fulfillment created');
  } catch (e, stackTrace) {
    _debugError('createFulfillment', e, stackTrace);
    rethrow;
  }
}

  // Get all requests (untuk admin)
  Future<List<StockRequestModel>> getAllRequests() async {
    try {
      _debugPrint('getAllRequests', 'Mengambil semua request...');
      
      final response = await _supabase
          .from('stock_requests')
          .select('''
            *,
            rooms!stock_requests_room_id_fkey (
              room_name
            )
          ''')
          .order('created_at', ascending: false);
      
      _debugPrint('getAllRequests', '✅ Found ${response.length} requests');
      return (response as List)
          .map((json) => StockRequestModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _debugError('getAllRequests', e, stackTrace);
      return [];
    }
  }

  // Approve request
  Future<void> approveRequest(
    String requestId,
    double approvedQuantity,
    String? approvedStockId,
    String? approvedStockName,
    String? approvedUnit,
    String? approvalNotes,
  ) async {
    try {
      _debugPrint('approveRequest', 'Approving request: $requestId');
      _debugPrint('approveRequest', 'Approved quantity: $approvedQuantity');
      
      final Map<String, dynamic> updateData = {
        'status': 'APPROVED',
        'approved_by': _currentUserId,
        'approved_date': DateTime.now().toIso8601String(),
        'approved_quantity': approvedQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (approvedStockId != null) updateData['approved_stock_id'] = approvedStockId;
      if (approvedStockName != null) updateData['approved_stock_name'] = approvedStockName;
      if (approvalNotes != null) updateData['approval_notes'] = approvalNotes;
      
      await _supabase
          .from('stock_requests')
          .update(updateData)
          .eq('id', requestId);
      
      _debugPrint('approveRequest', '✅ Request approved');
    } catch (e, stackTrace) {
      _debugError('approveRequest', e, stackTrace);
      rethrow;
    }
  }

  // Reject request
  Future<void> rejectRequest(
    String requestId,
    String rejectionReason,
    String rejectionType, // 'ADMIN' or 'LOGISTIC'
  ) async {
    try {
      _debugPrint('rejectRequest', 'Rejecting request: $requestId');
      _debugPrint('rejectRequest', 'Reason: $rejectionReason');
      
      await _supabase
          .from('stock_requests')
          .update({
            'status': rejectionType == 'ADMIN' ? 'REJECTED_BY_ADMIN' : 'REJECTED_BY_LOGISTIC',
            'rejected_by': _currentUserId,
            'rejected_at': DateTime.now().toIso8601String(),
            'rejection_reason': rejectionReason,
            'rejection_type': rejectionType,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);
      
      _debugPrint('rejectRequest', '✅ Request rejected');
    } catch (e, stackTrace) {
      _debugError('rejectRequest', e, stackTrace);
      rethrow;
    }
  }
}
