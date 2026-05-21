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