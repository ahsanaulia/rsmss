// File: lib/insights/hospital/services/human_ratio_realtime_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/human_ratio_summary.dart';
import '../models/human_ratio_distribution.dart';

class HumanRatioRealtimeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // 1. SUMMARY - REALTIME
  // ============================================================
  Stream<HumanRatioSummary> watchSummary() {
    debugPrint('🟢 [REALTIME] watchHumanRatioSummary: initializing...');
    final controller = StreamController<HumanRatioSummary>.broadcast();
    
    _fetchSummary().then((value) {
      debugPrint('✅ [REALTIME] watchHumanRatioSummary: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchHumanRatioSummary: initial error - $e');
      if (!controller.isClosed) controller.add(HumanRatioSummary.empty());
    });
    
    final channel = _supabase
        .channel('human_ratio_summary')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'people',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchHumanRatioSummary: change detected, refetching...');
            final newData = await _fetchSummary();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchHumanRatioSummary: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<HumanRatioSummary> _fetchSummary() async {
    try {
      // Total pegawai aktif (profiles)
      final employees = await _supabase
          .from('profiles')
          .select('id')
          .eq('is_active', true);
      final totalEmployees = (employees as List).length;
      debugPrint('📊 totalEmployees: $totalEmployees');
      
      // Total semua people aktif
      final allPeople = await _supabase
          .from('people')
          .select('id')
          .eq('is_active', true);
      final totalPeople = (allPeople as List).length;
      debugPrint('📊 totalPeople: $totalPeople');
      
      // Get all categories dynamically (TANPA HARDCODE)
      final categories = await _supabase.from('ref_people_categories').select('id, category_name');
      final categoriesData = categories as List;
      
      Map<String, String> categoryNames = {};
      Map<String, int> categoryCounts = {};
      
      for (final cat in categoriesData) {
        final catId = cat['id'].toString();
        final catName = cat['category_name'] ?? 'Unknown';
        categoryNames[catId] = catName;
        categoryCounts[catName] = 0;
      }
      
      // Count people per category (aktif)
      final peopleByCategory = await _supabase
          .from('people')
          .select('category_id')
          .eq('is_active', true);
      
      final peopleData = peopleByCategory as List;
      
      for (final person in peopleData) {
        final catId = person['category_id']?.toString();
        if (catId != null && categoryNames.containsKey(catId)) {
          final catName = categoryNames[catId]!;
          categoryCounts[catName] = (categoryCounts[catName] ?? 0) + 1;
        }
      }
      
      // Cari kategori PASIEN (jika ada) untuk rasio pegawai vs pasien
      int patientCount = 0;
      for (final entry in categoryCounts.entries) {
        if (entry.key.toUpperCase().contains('PASIEN') || 
            entry.key.toUpperCase().contains('PATIENT')) {
          patientCount += entry.value;
        }
      }
      
      // Hitung rasio pegawai vs pasien
      final employeeVsPatientRatio = patientCount > 0 
          ? totalEmployees / patientCount 
          : 0.0;
      
      // Cari jumlah perawat - dinamis
      final nursePositions = await _supabase
          .from('ref_positions')
          .select('id')
          .ilike('position_name', '%perawat%');
      
      int totalNurses = 0;
      if ((nursePositions as List).isNotEmpty) {
        final nurseId = nursePositions[0]['id'].toString();
        final nurses = await _supabase
            .from('profiles')
            .select('id')
            .eq('position_id', nurseId)
            .eq('is_active', true);
        totalNurses = (nurses as List).length;
      }
      
      final nurseVsPatientRatio = patientCount > 0 
          ? totalNurses / patientCount 
          : 0.0;
      
      final nonEmployees = totalPeople - totalEmployees;
      final employeeVsNonEmployee = nonEmployees > 0 
          ? totalEmployees / nonEmployees 
          : 0.0;
      
      debugPrint('📊 categoryCounts: $categoryCounts');
      debugPrint('📊 patientCount: $patientCount');
      debugPrint('📊 totalNurses: $totalNurses');
      
      return HumanRatioSummary(
        totalEmployees: totalEmployees,
        totalPeople: totalPeople,
        categoryCounts: categoryCounts,
        employeeVsPatientRatio: employeeVsPatientRatio,
        nurseVsPatientRatio: nurseVsPatientRatio,
        employeeVsNonEmployee: employeeVsNonEmployee,
      );
    } catch (e) {
      debugPrint('❌ _fetchSummary error: $e');
      return HumanRatioSummary.empty();
    }
  }

  // ============================================================
  // 2. DISTRIBUSI PEOPLE PER KATEGORI - REALTIME
  // ============================================================
  Stream<List<PeopleCategoryDistribution>> watchPeopleCategoryDistribution() {
    debugPrint('🟢 [REALTIME] watchPeopleCategoryDistribution: initializing...');
    final controller = StreamController<List<PeopleCategoryDistribution>>.broadcast();
    
    _fetchPeopleCategoryDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchPeopleCategoryDistribution: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchPeopleCategoryDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('people_category_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'people',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchPeopleCategoryDistribution: change detected, refetching...');
            final newData = await _fetchPeopleCategoryDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchPeopleCategoryDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<PeopleCategoryDistribution>> _fetchPeopleCategoryDistribution() async {
    try {
      final response = await _supabase
          .from('people')
          .select('''
            category_id,
            ref_people_categories!people_category_id_fkey(
              id,
              category_name,
              marker_color
            )
          ''')
          .eq('is_active', true);
      
      final data = response as List;
      final Map<String, PeopleCategoryDistribution> categoryMap = {};
      
      for (final item in data) {
        final category = item['ref_people_categories'];
        if (category == null) continue;
        
        final categoryId = category['id'].toString();
        final categoryName = category['category_name'] ?? 'Unknown';
        final markerColor = category['marker_color']?.toString();
        
        if (!categoryMap.containsKey(categoryId)) {
          categoryMap[categoryId] = PeopleCategoryDistribution(
            categoryId: categoryId,
            categoryName: categoryName,
            totalCount: 0,
            markerColor: markerColor,
          );
        }
        
        final existing = categoryMap[categoryId]!;
        categoryMap[categoryId] = PeopleCategoryDistribution(
          categoryId: categoryId,
          categoryName: categoryName,
          totalCount: existing.totalCount + 1,
          markerColor: markerColor,
        );
      }
      
      var result = categoryMap.values.toList();
      result.sort((a, b) => b.totalCount.compareTo(a.totalCount));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchPeopleCategoryDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 3. DISTRIBUSI PEGAWAI PER POSISI - REALTIME
  // ============================================================
  Stream<List<PositionDistribution>> watchPositionDistribution() {
    debugPrint('🟢 [REALTIME] watchPositionDistribution: initializing...');
    final controller = StreamController<List<PositionDistribution>>.broadcast();
    
    _fetchPositionDistribution().then((value) {
      debugPrint('✅ [REALTIME] watchPositionDistribution: initial data loaded, count=${value.length}');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchPositionDistribution: initial error - $e');
      if (!controller.isClosed) controller.add([]);
    });
    
    final channel = _supabase
        .channel('position_distribution')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchPositionDistribution: change detected, refetching...');
            final newData = await _fetchPositionDistribution();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchPositionDistribution: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<List<PositionDistribution>> _fetchPositionDistribution() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            position_id,
            ref_positions!profiles_position_id_fkey(
              id,
              position_name,
              level
            )
          ''')
          .eq('is_active', true)
          .not('position_id', 'is', null);
      
      final data = response as List;
      final Map<String, PositionDistribution> positionMap = {};
      
      for (final item in data) {
        final position = item['ref_positions'];
        if (position == null) continue;
        
        final positionId = position['id'].toString();
        final positionName = position['position_name'] ?? 'Unknown';
        final level = position['level'] as int?;
        
        if (!positionMap.containsKey(positionId)) {
          positionMap[positionId] = PositionDistribution(
            positionId: positionId,
            positionName: positionName,
            employeeCount: 0,
            level: level,
          );
        }
        
        final existing = positionMap[positionId]!;
        positionMap[positionId] = PositionDistribution(
          positionId: positionId,
          positionName: positionName,
          employeeCount: existing.employeeCount + 1,
          level: level,
        );
      }
      
      var result = positionMap.values.toList();
      result.sort((a, b) => b.employeeCount.compareTo(a.employeeCount));
      return result;
    } catch (e) {
      debugPrint('❌ _fetchPositionDistribution error: $e');
      return [];
    }
  }

  // ============================================================
  // 4. PEGAWAI PER UNIT - REALTIME
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
          .not('unit_id', 'is', null);
      
      final data = response as List;
      final Map<String, EmployeePerUnit> unitMap = {};
      
      for (final item in data) {
        final unit = item['employee_units'];
        if (unit == null) continue;
        
        final unitId = unit['id'].toString();
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
  // 5. TEKNISI IT VS TOTAL PEOPLE - INSIGHT CARD
  // ============================================================
  Stream<Map<String, dynamic>> watchTechInsight() {
    debugPrint('🟢 [REALTIME] watchTechInsight: initializing...');
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    
    _fetchTechInsight().then((value) {
      debugPrint('✅ [REALTIME] watchTechInsight: initial data loaded');
      if (!controller.isClosed) controller.add(value);
    }).catchError((e) {
      debugPrint('❌ [REALTIME] watchTechInsight: initial error - $e');
      if (!controller.isClosed) controller.add({});
    });
    
    final channel = _supabase
        .channel('tech_insight')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (_) async {
            debugPrint('🔄 [REALTIME] watchTechInsight: change detected, refetching...');
            final newData = await _fetchTechInsight();
            if (!controller.isClosed) controller.add(newData);
          },
        )
        .subscribe();
    
    controller.onCancel = () {
      debugPrint('🔴 [REALTIME] watchTechInsight: cancelled');
      _supabase.removeChannel(channel);
    };
    
    return controller.stream;
  }

  Future<Map<String, dynamic>> _fetchTechInsight() async {
    try {
      // Cari posisi yang berhubungan dengan IT - pakai List
      final techPositions = await _supabase
          .from('ref_positions')
          .select('id, position_name')
          .ilike('position_name', '%it%');
      
      int techCount = 0;
      String techName = 'IT';
      
      if ((techPositions as List).isNotEmpty) {
        final techPosition = techPositions[0];
        techName = techPosition['position_name'] ?? 'IT';
        final techs = await _supabase
            .from('profiles')
            .select('id')
            .eq('position_id', techPosition['id'].toString())
            .eq('is_active', true);
        techCount = (techs as List).length;
      }
      
      // Total people aktif
      final allPeople = await _supabase
          .from('people')
          .select('id')
          .eq('is_active', true);
      final totalPeople = (allPeople as List).length;
      
      // Total pegawai aktif
      final employees = await _supabase
          .from('profiles')
          .select('id')
          .eq('is_active', true);
      final totalEmployees = (employees as List).length;
      
      final ratio = techCount > 0 ? totalPeople / techCount : 0.0;
      
      return {
        'techCount': techCount,
        'techName': techName,
        'totalPeople': totalPeople,
        'totalEmployees': totalEmployees,
        'ratio': ratio,
      };
    } catch (e) {
      debugPrint('❌ _fetchTechInsight error: $e');
      return {};
    }
  }
}