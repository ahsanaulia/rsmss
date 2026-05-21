// // lib/features/stock_request/providers/stock_request_providers.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/stock_request_model.dart';
// import '../services/stock_request_service.dart';

// void _debugProvider(String tag, dynamic data) {
//   final timestamp = DateTime.now().toIso8601String();
//   print('[$timestamp] [STOCK_REQUEST_PROVIDER][$tag] $data');
// }

// // Service provider
// final stockRequestServiceProvider = Provider<StockRequestService>((ref) {
//   _debugProvider('stockRequestServiceProvider', 'Initializing');
//   return StockRequestService();
// });

// // Rooms dropdown provider
// final roomsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   _debugProvider('roomsProvider', 'Fetching rooms...');
//   final service = ref.read(stockRequestServiceProvider);
//   final result = await service.getAllRooms();
//   _debugProvider('roomsProvider', 'Fetched ${result.length} rooms');
//   return result;
// });

// // Stocks dropdown provider
// final stockRequestStocksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   _debugProvider('stockRequestStocksProvider', 'Fetching stocks...');
//   final service = ref.read(stockRequestServiceProvider);
//   final result = await service.getAvailableStocks();
//   _debugProvider('stockRequestStocksProvider', 'Fetched ${result.length} stocks');
//   return result;
// });

// // My requests provider (riwayat)
// final myRequestsProvider = FutureProvider<List<StockRequestModel>>((ref) async {
//   _debugProvider('myRequestsProvider', 'Fetching my requests...');
//   final service = ref.read(stockRequestServiceProvider);
//   final result = await service.getMyRequests();
//   _debugProvider('myRequestsProvider', 'Fetched ${result.length} requests');
//   return result;
// });

// // Controller untuk create request
// class StockRequestController {
//   final Ref ref;
  
//   StockRequestController(this.ref);
  
//   Future<StockRequestModel> createRequest(StockRequestModel request) async {
//     _debugProvider('createRequest', 'Creating new request...');
//     final service = ref.read(stockRequestServiceProvider);
//     final result = await service.createRequest(request);
//     _debugProvider('createRequest', '✅ Created with ID: ${result.id}');
    
//     // Refresh my requests
//     ref.invalidate(myRequestsProvider);
    
//     return result;
//   }
  
//   Future<String> generateRequestNumber() async {
//     final service = ref.read(stockRequestServiceProvider);
//     return await service.generateRequestNumber();
//   }
// }

// final stockRequestControllerProvider = Provider<StockRequestController>((ref) {
//   return StockRequestController(ref);
// });

// lib/features/stock_request/providers/stock_request_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_request_model.dart';
import '../services/stock_request_service.dart';

void _debugProvider(String tag, dynamic data) {
  final timestamp = DateTime.now().toIso8601String();
  print('[$timestamp] [STOCK_REQUEST_PROVIDER][$tag] $data');
}

// Service provider
final stockRequestServiceProvider = Provider<StockRequestService>((ref) {
  _debugProvider('stockRequestServiceProvider', 'Initializing');
  return StockRequestService();
});

// Rooms dropdown provider
final roomsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _debugProvider('roomsProvider', 'Fetching rooms...');
  final service = ref.read(stockRequestServiceProvider);
  final result = await service.getAllRooms();
  _debugProvider('roomsProvider', 'Fetched ${result.length} rooms');
  return result;
});

// Stocks dropdown provider
final stockRequestStocksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _debugProvider('stockRequestStocksProvider', 'Fetching stocks...');
  final service = ref.read(stockRequestServiceProvider);
  final result = await service.getAvailableStocks();
  _debugProvider('stockRequestStocksProvider', 'Fetched ${result.length} stocks');
  return result;
});

// All employees untuk dropdown admin
final allEmployeesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _debugProvider('allEmployeesProvider', 'Fetching all employees...');
  final service = ref.read(stockRequestServiceProvider);
  final result = await service.getAllEmployees();
  _debugProvider('allEmployeesProvider', 'Fetched ${result.length} employees');
  return result;
});

// My requests provider (riwayat pegawai)
final myRequestsProvider = FutureProvider<List<StockRequestModel>>((ref) async {
  _debugProvider('myRequestsProvider', 'Fetching my requests...');
  final service = ref.read(stockRequestServiceProvider);
  final result = await service.getMyRequests();
  _debugProvider('myRequestsProvider', 'Fetched ${result.length} requests');
  return result;
});

// All requests provider (untuk admin)
final allRequestsProvider = FutureProvider<List<StockRequestModel>>((ref) async {
  _debugProvider('allRequestsProvider', 'Fetching all requests for admin...');
  final service = ref.read(stockRequestServiceProvider);
  final result = await service.getAllRequests();
  _debugProvider('allRequestsProvider', 'Fetched ${result.length} requests');
  return result;
});

// =====================================================
// CONTROLLER (Logic Bisnis + Invalidate Provider)
// =====================================================
class StockRequestController {
  final Ref ref;
  
  StockRequestController(this.ref);
  
  Future<StockRequestModel> createRequest(StockRequestModel request) async {
    _debugProvider('createRequest', 'Creating new request...');
    final service = ref.read(stockRequestServiceProvider);
    final result = await service.createRequest(request);
    _debugProvider('createRequest', '✅ Created with ID: ${result.id}');
    
    // Refresh providers
    ref.invalidate(myRequestsProvider);
    ref.invalidate(allRequestsProvider);
    
    return result;
  }
  
  Future<String> generateRequestNumber() async {
    final service = ref.read(stockRequestServiceProvider);
    return await service.generateRequestNumber();
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
    _debugProvider('approveRequest', 'Approving request: $requestId');
    final service = ref.read(stockRequestServiceProvider);
    await service.approveRequest(
      requestId,
      approvedQuantity,
      approvedStockId,
      approvedStockName,
      approvedUnit,
      approvalNotes,
    );
    _debugProvider('approveRequest', '✅ Request approved');
    
    // Refresh providers
    ref.invalidate(allRequestsProvider);
    ref.invalidate(myRequestsProvider);
  }
  
  // Reject request
  Future<void> rejectRequest(
    String requestId,
    String rejectionReason,
    String rejectionType, // 'ADMIN' or 'LOGISTIC'
  ) async {
    _debugProvider('rejectRequest', 'Rejecting request: $requestId');
    final service = ref.read(stockRequestServiceProvider);
    await service.rejectRequest(requestId, rejectionReason, rejectionType);
    _debugProvider('rejectRequest', '✅ Request rejected');
    
    // Refresh providers
    ref.invalidate(allRequestsProvider);
    ref.invalidate(myRequestsProvider);
  }
}

final stockRequestControllerProvider = Provider<StockRequestController>((ref) {
  return StockRequestController(ref);
});