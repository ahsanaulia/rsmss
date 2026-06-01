// File: lib/insights/hospital/services/occupancy_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/occupancy_summary.dart';

class OccupancyRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY KPI - REALTIME
  // ============================================================
  Stream<OccupancySummary> watchSummary() {
    debugPrint('🟢 [REALTIME] watchOccupancySummary: initializing...');
    final controller = StreamController<OccupancySummary>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchOccupancySummary: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchOccupancySummary: initial error - $e');
      if (!controller.isClosed) controller.add(OccupancySummary.empty());
    });
    
    final channel = _supabase
        .channel('occupancy_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'beds',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchOccupancySummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchOccupancySummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<OccupancySummary> _fetchSummary() async {
    try {
      final beds = await _supabase.from('beds').select('status');
      final bedsData = beds as List;
      
      int total = bedsData.length;
      int occupied = 0;
      int empty = 0;
      int maintenance = 0;
      
      for (final bed in bedsData) {
        final status = bed['status']?.toString().toUpperCase() ?? 'EMPTY';
        if (status == 'OCCUPIED') occupied++;
        else if (status == 'EMPTY') empty++;
        else if (status == 'MAINTENANCE') maintenance++;
      }
      
      final occupancyRate = total > 0 ? (occupied / total) * 100 : 0.0;
      
      return OccupancySummary(
        totalBeds: total,
        occupiedBeds: occupied,
        emptyBeds: empty,
        maintenanceBeds: maintenance,
        occupancyRate: occupancyRate,
      );
    } catch (e) {
      debugPrint('❌ _fetchSummary error: $e');
      return OccupancySummary.empty();
    }
  }

  // ============================================================
  // 2. OKUPANSI PER KAMAR - REALTIME
  // ============================================================
  Stream<List<OccupancyPerRoom>> watchOccupancyPerRoom() {
    debugPrint('🟢 [REALTIME] watchOccupancyPerRoom: initializing...');
    final controller = StreamController<List<OccupancyPerRoom>>.broadcast();
    
    _fetchOccupancyPerRoom().then((value) {
      debugPrint('✅ [REALTIME] watchOccupancyPerRoom: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchOccupancyPerRoom: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('occupancy_per_room')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'beds',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchOccupancyPerRoom: change detected, refetching...');
            final newData = await _fetchOccupancyPerRoom();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchOccupancyPerRoom: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<OccupancyPerRoom>> _fetchOccupancyPerRoom() async {
    try {
      final response = await _supabase
          .from('beds')
          .select('''
            status,
            rooms!beds_room_id_fkey(
              id,
              room_name
            )
          ''');
      
      final data = response as List;
      final Map<String, Map<String, dynamic>> roomMap = {};
      
      for (final item in data) {
        final room = item['rooms'];
        if (room == null) continue;
        
        final roomId = room['id'].toString();
        final roomName = room['room_name'] ?? 'Unknown';
        final status = item['status']?.toString().toUpperCase() ?? 'EMPTY';
        
        if (!roomMap.containsKey(roomId)) {
          roomMap[roomId] = {
            'roomName': roomName,
            'totalBeds': 0,
            'occupiedBeds': 0,
          };
        }
        
        roomMap[roomId]!['totalBeds'] = roomMap[roomId]!['totalBeds'] + 1;
        if (status == 'OCCUPIED') {
          roomMap[roomId]!['occupiedBeds'] = roomMap[roomId]!['occupiedBeds'] + 1;
        }
      }
      
      final List<OccupancyPerRoom> result = [];
      for (final entry in roomMap.entries) {
        final total = entry.value['totalBeds'];
        final occupied = entry.value['occupiedBeds'];
        final rate = total > 0 ? (occupied / total) * 100 : 0.0;
        
        result.add(OccupancyPerRoom(
          roomId: entry.key,
          roomName: entry.value['roomName'],
          totalBeds: total,
          occupiedBeds: occupied,
          occupancyRate: rate,
        ));
      }
      
      result.sort((a, b) => b.occupancyRate.compareTo(a.occupancyRate));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchOccupancyPerRoom error: $e');
      return [];
    }
  }

  // ============================================================
  // 3. DISTRIBUSI BED PER KATEGORI KAMAR - REALTIME
  // ============================================================
  Stream<List<BedCategoryDistribution>> watchBedCategoryDistribution() {
    debugPrint('🟢 [REALTIME] watchBedCategoryDistribution: initializing...');
    final controller = StreamController<List<BedCategoryDistribution>>.broadcast();
    
    _fetchBedCategoryDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchBedCategoryDistribution: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchBedCategoryDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('bed_category_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'beds',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchBedCategoryDistribution: change detected, refetching...');
            final newData = await _fetchBedCategoryDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchBedCategoryDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<BedCategoryDistribution>> _fetchBedCategoryDistribution() async {
    try {
      final response = await _supabase
          .from('beds')
          .select('''
            status,
            rooms!beds_room_id_fkey(
              category_id,
              ref_room_categories!rooms_category_id_fkey(
                category_name,
                color_code
              )
            )
          ''');
      
      final data = response as List;
      final Map<String, Map<String, dynamic>> categoryMap = {};
      
      for (final item in data) {
        final room = item['rooms'];
        if (room == null) continue;
        
        final category = room['ref_room_categories'];
        final categoryName = category?['category_name']?.toString() ?? 'Unknown';
        final colorCode = category?['color_code']?.toString();
        final status = item['status']?.toString().toUpperCase() ?? 'EMPTY';
        
        if (!categoryMap.containsKey(categoryName)) {
          categoryMap[categoryName] = {
            'colorCode': colorCode,
            'totalBeds': 0,
            'occupiedBeds': 0,
          };
        }
        
        categoryMap[categoryName]!['totalBeds'] = categoryMap[categoryName]!['totalBeds'] + 1;
        if (status == 'OCCUPIED') {
          categoryMap[categoryName]!['occupiedBeds'] = categoryMap[categoryName]!['occupiedBeds'] + 1;
        }
      }
      
      final List<BedCategoryDistribution> result = [];
      for (final entry in categoryMap.entries) {
        final total = entry.value['totalBeds'];
        final occupied = entry.value['occupiedBeds'];
        final rate = total > 0 ? (occupied / total) * 100 : 0.0;
        
        result.add(BedCategoryDistribution(
          categoryName: entry.key,
          colorCode: entry.value['colorCode'],
          totalBeds: total,
          occupiedBeds: occupied,
          occupancyRate: rate,
        ));
      }
      
      result.sort((a, b) => b.totalBeds.compareTo(a.totalBeds));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchBedCategoryDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. PASIEN AKTIF (TERISI BED) - REALTIME
  // ============================================================
  Stream<List<ActivePatient>> watchActivePatients() {
    debugPrint('🟢 [REALTIME] watchActivePatients: initializing...');
    final controller = StreamController<List<ActivePatient>>.broadcast();
    
    _fetchActivePatients().then((value) {
      debugPrint('✅ [REALTIME] watchActivePatients: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchActivePatients: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('active_patients')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'beds_assignments',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchActivePatients: change detected, refetching...');
            final newData = await _fetchActivePatients();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchActivePatients: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<ActivePatient>> _fetchActivePatients() async {
    try {
      final response = await _supabase
          .from('beds_assignments')
          .select('''
            id,
            bed_id,
            assigned_at,
            predicted_until,
            notes,
            beds!beds_assignments_bed_id_fkey(
              bed_number,
              rooms!beds_room_id_fkey(
                room_name
              )
            ),
            people!beds_assignments_people_id_fkey(
              id,
              full_name
            )
          ''')
          .filter('discharged_at', 'is', null);
      
      final data = response as List;
      final List<ActivePatient> patients = [];
      
      for (final item in data) {
        final bed = item['beds'];
        final room = bed?['rooms'];
        final person = item['people'];
        
        if (bed == null || person == null) continue;
        
        patients.add(ActivePatient(
          assignmentId: item['id'].toString(),
          bedId: item['bed_id'].toString(),
          bedNumber: bed['bed_number']?.toString() ?? 'Unknown',
          roomName: room?['room_name']?.toString() ?? 'Unknown',
          patientId: person['id'].toString(),
          patientName: person['full_name'] ?? 'Unknown',
          assignedAt: DateTime.tryParse(item['assigned_at']?.toString() ?? '') ?? DateTime.now(),
          predictedUntil: item['predicted_until'] != null
              ? DateTime.tryParse(item['predicted_until'].toString())
              : null,
          notes: item['notes']?.toString(),
        ));
      }
      
      patients.sort((a, b) => a.assignedAt.compareTo(b.assignedAt));
      return patients;
    } catch (e) {
      debugPrint('❌ _fetchActivePatients error: $e');
      return [];
    }
  }
}