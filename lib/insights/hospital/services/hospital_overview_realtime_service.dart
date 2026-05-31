// File: lib/insights/hospital/services/hospital_overview_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hospital_overview_summary.dart';
import '../models/hospital_profile_model.dart';
import '../models/hospital_organization_model.dart';

class HospitalOverviewRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. HOSPITAL PROFILE - REALTIME
  // ============================================================
  Stream<HospitalProfileModel> watchHospitalProfile() {
    debugPrint('🟢 [REALTIME] watchHospitalProfile: initializing...');
    final controller = StreamController<HospitalProfileModel>.broadcast();
    
    _fetchHospitalProfile().then((value) {
      debugPrint('✅ [REALTIME] watchHospitalProfile: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchHospitalProfile: initial error - $e');
      if (!controller.isClosed) controller.add(HospitalProfileModel.empty());
    });
    
    final channel = _supabase
        .channel('hospital_profile')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'hospital_profile',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchHospitalProfile: change detected, refetching...');
            final newData = await _fetchHospitalProfile();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchHospitalProfile: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<HospitalProfileModel> _fetchHospitalProfile() async {
    try {
      final response = await _supabase
          .from('hospital_profile')
          .select()
          .maybeSingle();
      
      if (response != null) {
        return HospitalProfileModel.fromJson(response);
      }
      return HospitalProfileModel.empty();
    } catch (e) {
      debugPrint('❌ _fetchHospitalProfile error: $e');
      return HospitalProfileModel.empty();
    }
  }

  // ============================================================
  // 2. SUMMARY KPI - REALTIME
  // ============================================================
  Stream<HospitalOverviewSummary> watchSummary() {
    debugPrint('🟢 [REALTIME] watchHospitalSummary: initializing...');
    final controller = StreamController<HospitalOverviewSummary>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchHospitalSummary: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchHospitalSummary: initial error - $e');
      if (!controller.isClosed) controller.add(HospitalOverviewSummary.empty());
    });
    
    final channel = _supabase
        .channel('hospital_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'buildings',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchHospitalSummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchHospitalSummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<HospitalOverviewSummary> _fetchSummary() async {
  try {
    debugPrint('📊 FETCH SUMMARY START');
    
    final buildings = await _supabase.from('buildings').select('id');
    debugPrint('📊 buildings: ${(buildings as List).length}');
    
    final floors = await _supabase.from('floors').select('id');
    debugPrint('📊 floors: ${(floors as List).length}');
    
    final rooms = await _supabase.from('rooms').select('id');
    debugPrint('📊 rooms: ${(rooms as List).length}');
    
    final employees = await _supabase
        .from('profiles')
        .select('id');
        // .eq('is_active', true);
    debugPrint('📊 employees: ${(employees as List).length}');
    
    final units = await _supabase
        .from('employee_units')
        .select('id')
        .eq('is_active', true);
    debugPrint('📊 units: ${(units as List).length}');
    
    final todayStart = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final attendanceData = await _supabase
        .from('attendance')
        .select('id, check_out')
        .gte('check_in', todayStart)
        .lt('check_in', todayStart + 'T23:59:59');
    
    debugPrint('📊 attendanceData: ${(attendanceData as List).length}');
    
    final presentToday = (attendanceData as List).where((a) => a['check_out'] == null).length;
    debugPrint('📊 presentToday: $presentToday');
    
    return HospitalOverviewSummary(
      totalBuildings: (buildings as List).length,
      totalFloors: (floors as List).length,
      totalRooms: (rooms as List).length,
      totalEmployees: (employees as List).length,
      totalUnits: (units as List).length,
      presentToday: presentToday,
      occupancyRate: 0.0,
    );
  } catch (e) {
    debugPrint('❌ _fetchSummary error: $e');
    return HospitalOverviewSummary.empty();
  }
}

  // ============================================================
  // 3. ROOM CATEGORY DISTRIBUTION - REALTIME
  // ============================================================
  Stream<List<RoomCategoryDistribution>> watchRoomCategoryDistribution() {
    debugPrint('🟢 [REALTIME] watchRoomCategoryDistribution: initializing...');
    final controller = StreamController<List<RoomCategoryDistribution>>.broadcast();
    
    _fetchRoomCategoryDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchRoomCategoryDistribution: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchRoomCategoryDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('room_category_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchRoomCategoryDistribution: change detected, refetching...');
            final newData = await _fetchRoomCategoryDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchRoomCategoryDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<RoomCategoryDistribution>> _fetchRoomCategoryDistribution() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            category_id,
            ref_room_categories!rooms_category_id_fkey(
              category_name,
              color_code
            )
          ''');
      
      final data = response as List;
      final Map<String, RoomCategoryDistribution> categoryMap = {};
      
      for (final item in data) {
        final category = item['ref_room_categories'];
        if (category == null) continue;
        
        final categoryName = category['category_name'] ?? 'Unknown';
        final colorCode = category['color_code']?.toString();
        
        if (!categoryMap.containsKey(categoryName)) {
          categoryMap[categoryName] = RoomCategoryDistribution(
            categoryName: categoryName,
            colorCode: colorCode,
            totalRooms: 0,
          );
        }
        
        final existing = categoryMap[categoryName]!;
        categoryMap[categoryName] = RoomCategoryDistribution(
          categoryName: categoryName,
          colorCode: colorCode,
          totalRooms: existing.totalRooms + 1,
        );
      }
      
      var result = categoryMap.values.toList();
      result.sort((a, b) => b.totalRooms.compareTo(a.totalRooms));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchRoomCategoryDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. EMPLOYEE PER UNIT - REALTIME (HANYA UNIT YANG ADA PEGAWAI)
  // ============================================================
  Stream<List<EmployeePerUnit>> watchEmployeePerUnit() {
    debugPrint('🟢 [REALTIME] watchEmployeePerUnit: initializing...');
    final controller = StreamController<List<EmployeePerUnit>>.broadcast();
    
    _fetchEmployeePerUnit().then((value) {
      debugPrint('✅ [REALTIME] watchEmployeePerUnit: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchEmployeePerUnit: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('employee_per_unit')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchEmployeePerUnit: change detected, refetching...');
            final newData = await _fetchEmployeePerUnit();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchEmployeePerUnit: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<EmployeePerUnit>> _fetchEmployeePerUnit() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            unit_id,
            employee_units!profiles_unit_id_fkey(
              id,
              unit_name
            )
          ''')
          .eq('is_active', true)
          .not('unit_id', 'is', null);  // Hanya profile yang punya unit
      
      final data = response as List;
      final Map<String, EmployeePerUnit> unitMap = {};
      
      for (final item in data) {
        final unit = item['employee_units'];
        if (unit == null) continue;
        
        final unitId = unit['id']?.toString() ?? '';
        final unitName = unit['unit_name'] ?? 'Unknown';
        
        if (!unitMap.containsKey(unitId)) {
          unitMap[unitId] = EmployeePerUnit(
            unitId: unitId,
            unitName: unitName,
            employeeCount: 0,
          );
        }
        
        final existing = unitMap[unitId]!;
        unitMap[unitId] = EmployeePerUnit(
          unitId: unitId,
          unitName: unitName,
          employeeCount: existing.employeeCount + 1,
        );
      }
      
      var result = unitMap.values.toList();
      result.sort((a, b) => b.employeeCount.compareTo(a.employeeCount));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchEmployeePerUnit error: $e');
      return [];
    }
  }

  // ============================================================
  // 5. EMPLOYEE UNITS HIERARCHY - REALTIME
  // ============================================================
  Stream<List<EmployeeUnitNode>> watchEmployeeHierarchy() {
    debugPrint('🟢 [REALTIME] watchEmployeeHierarchy: initializing...');
    final controller = StreamController<List<EmployeeUnitNode>>.broadcast();
    
    _fetchEmployeeHierarchy().then((value) {
      debugPrint('✅ [REALTIME] watchEmployeeHierarchy: initial data loaded, roots=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchEmployeeHierarchy: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('employee_hierarchy')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'employee_units',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchEmployeeHierarchy: change detected, refetching...');
            final newData = await _fetchEmployeeHierarchy();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchEmployeeHierarchy: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<EmployeeUnitNode>> _fetchEmployeeHierarchy() async {
    try {
      final unitsResponse = await _supabase
          .from('employee_units')
          .select('''
            id,
            unit_code,
            unit_name,
            parent_unit_id,
            head_of_unit_id,
            profiles!employee_units_head_of_unit_id_fkey(
              full_name
            )
          ''')
          .eq('is_active', true);
      
      final unitsData = unitsResponse as List;
      final Map<String, EmployeeUnitNode> unitMap = {};
      final List<EmployeeUnitNode> roots = [];
      
      // Get employee counts per unit
      final profilesResponse = await _supabase
          .from('profiles')
          .select('unit_id')
          .eq('is_active', true)
          .not('unit_id', 'is', null);
      
      final profilesData = profilesResponse as List;
      final Map<String, int> employeeCountMap = {};
      for (final profile in profilesData) {
        final unitId = profile['unit_id']?.toString();
        if (unitId != null) {
          employeeCountMap[unitId] = (employeeCountMap[unitId] ?? 0) + 1;
        }
      }
      
      for (final unit in unitsData) {
        final id = unit['id']?.toString() ?? '';
        final unitCode = unit['unit_code'] ?? '';
        final unitName = unit['unit_name'] ?? 'Unknown';
        final headData = unit['profiles'];
        final headOfUnitName = headData?['full_name']?.toString();
        final employeeCount = employeeCountMap[id] ?? 0;
        
        unitMap[id] = EmployeeUnitNode(
          id: id,
          unitCode: unitCode,
          unitName: unitName,
          headOfUnitName: headOfUnitName,
          employeeCount: employeeCount,
          children: [],
        );
      }
      
      for (final unit in unitsData) {
        final id = unit['id']?.toString() ?? '';
        final parentId = unit['parent_unit_id']?.toString();
        
        final node = unitMap[id];
        if (node == null) continue;
        
        if (parentId != null && unitMap.containsKey(parentId)) {
          final parent = unitMap[parentId]!;
          final children = List<EmployeeUnitNode>.from(parent.children)..add(node);
          unitMap[parentId] = EmployeeUnitNode(
            id: parent.id,
            unitCode: parent.unitCode,
            unitName: parent.unitName,
            headOfUnitName: parent.headOfUnitName,
            employeeCount: parent.employeeCount,
            children: children,
          );
        } else {
          roots.add(node);
        }
      }
      
      roots.sort((a, b) => a.unitName.compareTo(b.unitName));
      return roots;
    } catch (e) {
      debugPrint('❌ _fetchEmployeeHierarchy error: $e');
      return [];
    }
  }

  // ============================================================
  // 6. BUILDING HIERARCHY - REALTIME
  // ============================================================
  Stream<List<BuildingNode>> watchBuildingHierarchy() {
    debugPrint('🟢 [REALTIME] watchBuildingHierarchy: initializing...');
    final controller = StreamController<List<BuildingNode>>.broadcast();
    
    _fetchBuildingHierarchy().then((value) {
      debugPrint('✅ [REALTIME] watchBuildingHierarchy: initial data loaded, buildings=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchBuildingHierarchy: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('building_hierarchy')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'buildings',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchBuildingHierarchy: change detected, refetching...');
            final newData = await _fetchBuildingHierarchy();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchBuildingHierarchy: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<BuildingNode>> _fetchBuildingHierarchy() async {
    try {
      final buildingsResponse = await _supabase
          .from('buildings')
          .select('id, building_name')
          .order('building_name');
      
      final buildingsData = buildingsResponse as List;
      final List<BuildingNode> buildings = [];
      
      for (final building in buildingsData) {
        final buildingId = building['id']?.toString() ?? '';
        final buildingName = building['building_name'] ?? 'Unknown';
        
        final floorsResponse = await _supabase
            .from('floors')
            .select('id, floor_number, floor_alias')
            .eq('building_id', buildingId)
            .order('floor_number');
        
        final floorsData = floorsResponse as List;
        final List<FloorNode> floors = [];
        int buildingTotalRooms = 0;
        
        for (final floor in floorsData) {
          final floorId = floor['id']?.toString() ?? '';
          final floorNumber = (floor['floor_number'] ?? 0) as int;
          final floorAlias = floor['floor_alias']?.toString();
          
          final roomsResponse = await _supabase
              .from('rooms')
              .select('''
                id,
                room_name,
                category_id,
                ref_room_categories!rooms_category_id_fkey(
                  category_name,
                  color_code
                )
              ''')
              .eq('floor_id', floorId)
              .order('room_name');
          
          final roomsData = roomsResponse as List;
          final List<RoomNode> rooms = [];
          
          for (final room in roomsData) {
            final category = room['ref_room_categories'];
            rooms.add(RoomNode(
              id: room['id']?.toString() ?? '',
              roomName: room['room_name'] ?? 'Unknown',
              categoryName: category?['category_name']?.toString(),
              categoryColor: category?['color_code']?.toString(),
            ));
          }
          
          floors.add(FloorNode(
            id: floorId,
            floorNumber: floorNumber,
            floorAlias: floorAlias,
            totalRooms: rooms.length,
            rooms: rooms,
          ));
          
          buildingTotalRooms += rooms.length;
        }
        
        buildings.add(BuildingNode(
          id: buildingId,
          buildingName: buildingName,
          totalFloors: floors.length,
          totalRooms: buildingTotalRooms,
          floors: floors,
        ));
      }
      
      return buildings;
    } catch (e) {
      debugPrint('❌ _fetchBuildingHierarchy error: $e');
      return [];
    }
  }
}