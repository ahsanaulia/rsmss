// File: lib/insights/stocks/services/stock_requests_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/stock_request_model.dart';
import '../models/stock_request_summary_model.dart';
import '../models/stock_requester_model.dart';

class StockRequestsService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. AMBIL SEMUA REQUESTS
  // ============================================================
  Future<List<StockRequestModel>> getAllRequests({String? status}) async {
    try {
      var query = _supabase
          .from('stock_requests')
          .select('''
            id,
            request_number,
            requester_id,
            requested_stock_name,
            requested_quantity,
            requested_unit,
            status,
            request_date,
            approved_date,
            approved_by,
            rejection_reason,
            approved_quantity,
            fulfilled_quantity,
            profiles:requester_id (
              full_name,
              position_id,
              unit_id
            ),
            rooms:room_id (
              room_name
            )
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('request_date', ascending: false);
      final data = response as List;
      
      final List<StockRequestModel> requests = [];

      for (final item in data) {
        final profile = item['profiles'];
        final room = item['rooms'];
        
        String? positionName;
        String? unitName;
        
        if (profile != null) {
          final positionId = profile['position_id'];
          if (positionId != null) {
            final positionData = await _supabase
                .from('ref_positions')
                .select('position_name')
                .eq('id', positionId)
                .maybeSingle();
            if (positionData != null) {
              positionName = positionData['position_name']?.toString();
            }
          }
          
          final unitId = profile['unit_id'];
          if (unitId != null) {
            final unitData = await _supabase
                .from('employee_units')
                .select('unit_name')
                .eq('id', unitId)
                .maybeSingle();
            if (unitData != null) {
              unitName = unitData['unit_name']?.toString();
            }
          }
        }

        requests.add(StockRequestModel(
          id: item['id']?.toString() ?? '',
          requestNumber: item['request_number'] ?? '',
          requesterId: item['requester_id']?.toString() ?? '',
          requesterName: profile?['full_name'] ?? 'Unknown',
          requesterPosition: positionName,
          unitName: unitName,
          roomName: room?['room_name']?.toString(),
          requestedStockName: item['requested_stock_name'] ?? '',
          requestedQuantity: (item['requested_quantity'] ?? 0).toDouble(),
          unit: item['requested_unit'] ?? '',
          status: item['status'] ?? 'PENDING',
          requestDate: item['request_date'] != null
              ? DateTime.parse(item['request_date'].toString())
              : DateTime.now(),
          approvedDate: item['approved_date'] != null
              ? DateTime.tryParse(item['approved_date'].toString())
              : null,
          approvedBy: item['approved_by']?.toString(),
          rejectionReason: item['rejection_reason']?.toString(),
          approvedQuantity: (item['approved_quantity'] as num?)?.toDouble(),
          fulfilledQuantity: (item['fulfilled_quantity'] as num?)?.toDouble(),
        ));
      }

      return requests;
    } catch (e) {
      debugPrint('Error getAllRequests: $e');
      return [];
    }
  }

  // ============================================================
  // 2. SUMMARY KPI
  // ============================================================
  Future<StockRequestSummaryModel> getSummary() async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select('status, requested_quantity, approved_date, request_date');

      final data = response as List;
      
      int total = data.length;
      int pending = 0;
      int completed = 0;
      int rejected = 0;
      double totalProcessingHours = 0.0;
      int processedCount = 0;

      for (final item in data) {
        final status = item['status'] ?? 'PENDING';
        
        if (status == 'PENDING') {
          pending++;
        } else if (status == 'COMPLETED') {
          completed++;
        } else if (status == 'REJECTED') {
          rejected++;
        }

        // Hitung processing time untuk yang sudah diproses (COMPLETED atau REJECTED)
        if (status == 'COMPLETED' || status == 'REJECTED') {
          final requestDateStr = item['request_date']?.toString();
          final approvedDateStr = item['approved_date']?.toString();
          
          if (requestDateStr != null && approvedDateStr != null) {
            final requestDate = DateTime.tryParse(requestDateStr);
            final approvedDate = DateTime.tryParse(approvedDateStr);
            
            if (requestDate != null && approvedDate != null) {
              final hours = approvedDate.difference(requestDate).inHours;
              totalProcessingHours += hours.toDouble();
              processedCount++;
            }
          }
        }
      }

      final averageProcessingHours = processedCount > 0 ? totalProcessingHours / processedCount : 0.0;
      final approvalRate = total > 0 ? (completed / total) * 100 : 0.0;

      return StockRequestSummaryModel(
        totalRequests: total,
        pending: pending,
        approved: completed,  // COMPLETED = approved + fulfilled
        rejected: rejected,
        fulfilled: completed, // COMPLETED = fulfilled
        approvalRate: approvalRate,
        averageProcessingHours: averageProcessingHours,
      );
    } catch (e) {
      debugPrint('Error getSummary: $e');
      return StockRequestSummaryModel.empty();
    }
  }

  // ============================================================
  // 3. TREND REQUEST PER HARI
  // ============================================================
  Future<List<StockRequestTrendModel>> getTrend() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final dateFormat = DateFormat('yyyy-MM-dd');

      final response = await _supabase
          .from('stock_requests')
          .select('request_date, requested_quantity')
          .gte('request_date', thirtyDaysAgo.toIso8601String());

      final data = response as List;
      final Map<String, StockRequestTrendModel> trendMap = {};

      for (final item in data) {
        final requestDate = item['request_date']?.toString();
        if (requestDate == null) continue;
        
        final date = DateTime.parse(requestDate);
        final dateKey = dateFormat.format(date);
        final qty = (item['requested_quantity'] ?? 0).toDouble();

        if (!trendMap.containsKey(dateKey)) {
          trendMap[dateKey] = StockRequestTrendModel(
            date: date,
            totalRequests: 0,
            totalQuantity: 0,
          );
        }

        final existing = trendMap[dateKey]!;
        trendMap[dateKey] = StockRequestTrendModel(
          date: date,
          totalRequests: existing.totalRequests + 1,
          totalQuantity: existing.totalQuantity + qty,
        );
      }

      var result = trendMap.values.toList();
      result.sort((a, b) => a.date.compareTo(b.date));
      return result;
    } catch (e) {
      debugPrint('Error getTrend: $e');
      return [];
    }
  }

  // ============================================================
  // 4. PENDING REQUESTS
  // ============================================================
  Future<List<StockRequestModel>> getPendingRequests() async {
    return await getAllRequests(status: 'PENDING');
  }

  // ============================================================
  // 5. REQUEST PER UNIT (COMPLETED saja)
  // ============================================================
  Future<List<StockRequestPerUnitModel>> getRequestsPerUnit() async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select('requester_id, requested_quantity')
          .eq('status', 'COMPLETED');

      final data = response as List;
      
      final Map<String, double> requestQuantities = {};
      final Map<String, int> requestCounts = {};
      
      for (final item in data) {
        final requesterId = item['requester_id']?.toString();
        if (requesterId != null) {
          requestQuantities[requesterId] = (requestQuantities[requesterId] ?? 0) + (item['requested_quantity'] ?? 0).toDouble();
          requestCounts[requesterId] = (requestCounts[requesterId] ?? 0) + 1;
        }
      }
      
      if (requestQuantities.isEmpty) return [];
      
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, unit_id')
          .inFilter('id', requestQuantities.keys.toList());
      
      final profilesData = profilesResponse as List;
      final Map<String, String?> profileUnitMap = {};
      for (final profile in profilesData) {
        profileUnitMap[profile['id'].toString()] = profile['unit_id']?.toString();
      }
      
      final unitIds = profileUnitMap.values.whereType<String>().toList();
      final Map<String, String> unitNameMap = {};
      
      if (unitIds.isNotEmpty) {
        final unitsResponse = await _supabase
            .from('employee_units')
            .select('id, unit_name')
            .inFilter('id', unitIds);
        
        final unitsData = unitsResponse as List;
        for (final unit in unitsData) {
          unitNameMap[unit['id'].toString()] = unit['unit_name']?.toString() ?? 'Unknown';
        }
      }
      
      final Map<String, StockRequestPerUnitModel> unitMap = {};
      
      for (final entry in requestQuantities.entries) {
        final requesterId = entry.key;
        final qty = entry.value;
        final unitId = profileUnitMap[requesterId];
        final unitName = unitId != null ? (unitNameMap[unitId] ?? 'Unknown') : 'Unknown';
        final reqCount = requestCounts[requesterId] ?? 0;
        
        if (!unitMap.containsKey(unitName)) {
          unitMap[unitName] = StockRequestPerUnitModel(
            unitName: unitName,
            totalRequests: 0,
            totalQuantity: 0,
          );
        }
        
        final existing = unitMap[unitName]!;
        unitMap[unitName] = StockRequestPerUnitModel(
          unitName: unitName,
          totalRequests: existing.totalRequests + reqCount,
          totalQuantity: existing.totalQuantity + qty,
        );
      }
      
      var result = unitMap.values.toList();
      result.sort((a, b) => b.totalRequests.compareTo(a.totalRequests));
      return result.take(10).toList();
    } catch (e) {
      debugPrint('Error getRequestsPerUnit: $e');
      return [];
    }
  }

  // ============================================================
  // 6. REQUEST PER ROOM (COMPLETED saja)
  // ============================================================
  Future<List<StockRequestPerRoomModel>> getRequestsPerRoom() async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select('room_id, requested_quantity')
          .eq('status', 'COMPLETED')
          .not('room_id', 'is', null);

      final data = response as List;
      
      final Map<String, double> requestQuantities = {};
      final Map<String, int> requestCounts = {};
      
      for (final item in data) {
        final roomId = item['room_id']?.toString();
        if (roomId != null) {
          requestQuantities[roomId] = (requestQuantities[roomId] ?? 0) + (item['requested_quantity'] ?? 0).toDouble();
          requestCounts[roomId] = (requestCounts[roomId] ?? 0) + 1;
        }
      }
      
      if (requestQuantities.isEmpty) return [];
      
      final roomsResponse = await _supabase
          .from('rooms')
          .select('id, room_name')
          .inFilter('id', requestQuantities.keys.toList());
      
      final roomsData = roomsResponse as List;
      final Map<String, String> roomNameMap = {};
      for (final room in roomsData) {
        roomNameMap[room['id'].toString()] = room['room_name']?.toString() ?? 'Unknown';
      }
      
      final Map<String, StockRequestPerRoomModel> roomMap = {};
      
      for (final entry in requestQuantities.entries) {
        final roomId = entry.key;
        final qty = entry.value;
        final roomName = roomNameMap[roomId] ?? 'Unknown';
        final reqCount = requestCounts[roomId] ?? 0;
        
        if (!roomMap.containsKey(roomName)) {
          roomMap[roomName] = StockRequestPerRoomModel(
            roomName: roomName,
            totalRequests: 0,
            totalQuantity: 0,
          );
        }
        
        final existing = roomMap[roomName]!;
        roomMap[roomName] = StockRequestPerRoomModel(
          roomName: roomName,
          totalRequests: existing.totalRequests + reqCount,
          totalQuantity: existing.totalQuantity + qty,
        );
      }
      
      var result = roomMap.values.toList();
      result.sort((a, b) => b.totalRequests.compareTo(a.totalRequests));
      return result.take(10).toList();
    } catch (e) {
      debugPrint('Error getRequestsPerRoom: $e');
      return [];
    }
  }

  // ============================================================
  // 7. TOP REQUESTER (COMPLETED saja)
  // ============================================================
  Future<List<StockRequesterModel>> getTopRequesters({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select('requester_id, requested_quantity')
          .eq('status', 'COMPLETED');

      final data = response as List;
      
      final Map<String, double> requestQuantities = {};
      final Map<String, int> requestCounts = {};
      
      for (final item in data) {
        final requesterId = item['requester_id']?.toString();
        if (requesterId != null) {
          requestQuantities[requesterId] = (requestQuantities[requesterId] ?? 0) + (item['requested_quantity'] ?? 0).toDouble();
          requestCounts[requesterId] = (requestCounts[requesterId] ?? 0) + 1;
        }
      }
      
      if (requestQuantities.isEmpty) return [];
      
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', requestQuantities.keys.toList());
      
      final profilesData = profilesResponse as List;
      final Map<String, String> requesterNameMap = {};
      for (final profile in profilesData) {
        requesterNameMap[profile['id'].toString()] = profile['full_name'] ?? 'Unknown';
      }
      
      final List<StockRequesterModel> requesters = [];
      
      for (final entry in requestQuantities.entries) {
        final requesterId = entry.key;
        final name = requesterNameMap[requesterId] ?? 'Unknown';
        
        requesters.add(StockRequesterModel(
          requesterId: requesterId,
          requesterName: name,
          positionName: null,
          unitName: null,
          totalRequests: requestCounts[requesterId] ?? 0,
          totalQuantity: entry.value,
        ));
      }
      
      requesters.sort((a, b) => b.totalRequests.compareTo(a.totalRequests));
      return requesters.take(limit).toList();
    } catch (e) {
      debugPrint('Error getTopRequesters: $e');
      return [];
    }
  }

  // ============================================================
  // 8. REQUEST PER POSITION (COMPLETED saja)
  // ============================================================
  Future<List<StockRequestPerPositionModel>> getRequestsPerPosition() async {
    try {
      final response = await _supabase
          .from('stock_requests')
          .select('requester_id, requested_quantity')
          .eq('status', 'COMPLETED');

      final data = response as List;
      
      final Map<String, double> requestQuantities = {};
      final Map<String, int> requestCounts = {};
      
      for (final item in data) {
        final requesterId = item['requester_id']?.toString();
        if (requesterId != null) {
          requestQuantities[requesterId] = (requestQuantities[requesterId] ?? 0) + (item['requested_quantity'] ?? 0).toDouble();
          requestCounts[requesterId] = (requestCounts[requesterId] ?? 0) + 1;
        }
      }
      
      if (requestQuantities.isEmpty) return [];
      
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, position_id')
          .inFilter('id', requestQuantities.keys.toList());
      
      final profilesData = profilesResponse as List;
      final Map<String, String?> profilePositionMap = {};
      for (final profile in profilesData) {
        profilePositionMap[profile['id'].toString()] = profile['position_id']?.toString();
      }
      
      final positionIds = profilePositionMap.values.whereType<String>().toList();
      final Map<String, String> positionNameMap = {};
      
      if (positionIds.isNotEmpty) {
        final positionsResponse = await _supabase
            .from('ref_positions')
            .select('id, position_name')
            .inFilter('id', positionIds);
        
        final positionsData = positionsResponse as List;
        for (final position in positionsData) {
          positionNameMap[position['id'].toString()] = position['position_name']?.toString() ?? 'Unknown';
        }
      }
      
      final Map<String, StockRequestPerPositionModel> positionMap = {};
      
      for (final entry in requestQuantities.entries) {
        final requesterId = entry.key;
        final qty = entry.value;
        final positionId = profilePositionMap[requesterId];
        final positionName = positionId != null ? (positionNameMap[positionId] ?? 'Unknown') : 'Unknown';
        final reqCount = requestCounts[requesterId] ?? 0;
        
        if (!positionMap.containsKey(positionName)) {
          positionMap[positionName] = StockRequestPerPositionModel(
            positionName: positionName,
            totalRequests: 0,
            totalQuantity: 0,
          );
        }
        
        final existing = positionMap[positionName]!;
        positionMap[positionName] = StockRequestPerPositionModel(
          positionName: positionName,
          totalRequests: existing.totalRequests + reqCount,
          totalQuantity: existing.totalQuantity + qty,
        );
      }
      
      var result = positionMap.values.toList();
      result.sort((a, b) => b.totalRequests.compareTo(a.totalRequests));
      return result.take(10).toList();
    } catch (e) {
      debugPrint('Error getRequestsPerPosition: $e');
      return [];
    }
  }
}