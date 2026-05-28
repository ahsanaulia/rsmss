// lib/insights/profiles/providers/employee_detail_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_detail_model.dart';
import '../services/employee_detail_service.dart';
import 'supabase_provider.dart';

// ============================================
// SERVICE PROVIDER
// ============================================
final employeeDetailServiceProvider = Provider<EmployeeDetailService>((ref) {
  return EmployeeDetailService();
});

// ============================================
// SELECTED EMPLOYEE ID PROVIDER
// ============================================
final selectedEmployeeIdProvider = StateProvider<String?>((ref) => null);

// ============================================
// FUTURE PROVIDER (UNTUK POPUP - SEKALI AMBIL, LEBIH AMAN)
// ============================================
final employeeDetailFutureProvider = FutureProvider.family<EmployeeDetail?, String>((ref, profileId) async {
  final service = ref.read(employeeDetailServiceProvider);
  print('📦 [employeeDetailFutureProvider] Mengambil detail pegawai: $profileId (sekali ambil)');
  
  try {
    final result = await service.getEmployeeDetail(profileId);
    return result;
  } catch (e) {
    print('❌ [employeeDetailFutureProvider] Error: $e');
    return null;
  }
});

// ============================================
// STREAM PROVIDER (UNTUK SUBMENU 1-4 - REALTIME)
// ============================================
final employeeDetailStreamProvider = StreamProvider<EmployeeDetail?>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final selectedId = ref.watch(selectedEmployeeIdProvider);
  final service = ref.read(employeeDetailServiceProvider);
  
  if (selectedId == null) {
    print('⚠️ [employeeDetailStreamProvider] Tidak ada profile yang dipilih');
    return Stream.value(null);
  }
  
  print('🔄 [employeeDetailStreamProvider] Memulai stream realtime untuk profile: $selectedId');
  
  // Buat controller untuk menggabungkan beberapa stream
  final controller = StreamController<EmployeeDetail?>.broadcast();
  
  bool isClosed = false;
  
  // Subscribe ke tabel profiles
  final profilesSubscription = supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel profiles');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Subscribe ke tabel attendance untuk profile ini
  final attendanceSubscription = supabase
      .from('attendance')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel attendance');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Subscribe ke tabel employee_wellbeing_logs untuk profile ini
  final wellbeingSubscription = supabase
      .from('employee_wellbeing_logs')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel wellbeing');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Subscribe ke tabel employee_scoring untuk profile ini
  final scoringSubscription = supabase
      .from('employee_scoring')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel scoring');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Subscribe ke tabel employee_qualification_assignments untuk profile ini
  final qualificationSubscription = supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel qualifications');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Subscribe ke tabel tasks untuk profile ini (sebagai assignee)
  final tasksSubscription = supabase
      .from('tasks')
      .stream(primaryKey: ['id'])
      .eq('assignee_id', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel tasks');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Subscribe ke tabel incidents untuk profile ini (sebagai reporter)
  final incidentsSubscription = supabase
      .from('incidents')
      .stream(primaryKey: ['id'])
      .eq('reported_by', selectedId)
      .listen((_) async {
        if (isClosed) return;
        print('🔄 [employeeDetailStreamProvider] Perubahan di tabel incidents');
        final data = await service.getEmployeeDetail(selectedId);
        if (!controller.isClosed) {
          controller.add(data);
        }
      });
  
  // Load initial data
  service.getEmployeeDetail(selectedId).then((data) {
    if (!controller.isClosed) {
      controller.add(data);
    }
  }).catchError((error) {
    print('❌ [employeeDetailStreamProvider] Error loading initial data: $error');
    if (!controller.isClosed) {
      controller.add(null);
    }
  });
  
  // Cleanup saat provider dibuang
  ref.onDispose(() {
    print('🛑 [employeeDetailStreamProvider] Menutup stream untuk profile: $selectedId');
    isClosed = true;
    profilesSubscription.cancel();
    attendanceSubscription.cancel();
    wellbeingSubscription.cancel();
    scoringSubscription.cancel();
    qualificationSubscription.cancel();
    tasksSubscription.cancel();
    incidentsSubscription.cancel();
    controller.close();
  });
  
  return controller.stream;
});

// ============================================
// EMPLOYEE KPI SUMMARY PROVIDER (UNTUK DASHBOARD)
// ============================================
final employeeKpiSummaryProvider = FutureProvider.family<EmployeeKpiData?, String>((ref, profileId) async {
  final service = ref.read(employeeDetailServiceProvider);
  print('📊 [employeeKpiSummaryProvider] Mengambil KPI untuk profile: $profileId');
  
  try {
    final detail = await service.getEmployeeDetail(profileId);
    return detail?.kpi;
  } catch (e) {
    print('❌ [employeeKpiSummaryProvider] Error: $e');
    return null;
  }
});

// ============================================
// EMPLOYEE WELLBEING PROVIDER (UNTUK DASHBOARD)
// ============================================
final employeeWellbeingProvider = FutureProvider.family<EmployeeWellbeingData?, String>((ref, profileId) async {
  final service = ref.read(employeeDetailServiceProvider);
  print('📊 [employeeWellbeingProvider] Mengambil wellbeing untuk profile: $profileId');
  
  try {
    final detail = await service.getEmployeeDetail(profileId);
    return detail?.wellbeing;
  } catch (e) {
    print('❌ [employeeWellbeingProvider] Error: $e');
    return null;
  }
});

// ============================================
// EMPLOYEE SCORE PROVIDER (UNTUK DASHBOARD)
// ============================================
final employeeScoreProvider = FutureProvider.family<EmployeeScoreData?, String>((ref, profileId) async {
  final service = ref.read(employeeDetailServiceProvider);
  print('📊 [employeeScoreProvider] Mengambil score untuk profile: $profileId');
  
  try {
    final detail = await service.getEmployeeDetail(profileId);
    return detail?.score;
  } catch (e) {
    print('❌ [employeeScoreProvider] Error: $e');
    return null;
  }
});

// ============================================
// EMPLOYEE QUALIFICATION PROVIDER (UNTUK DASHBOARD)
// ============================================
final employeeQualificationProvider = FutureProvider.family<EmployeeQualificationData?, String>((ref, profileId) async {
  final service = ref.read(employeeDetailServiceProvider);
  print('📊 [employeeQualificationProvider] Mengambil kualifikasi untuk profile: $profileId');
  
  try {
    final detail = await service.getEmployeeDetail(profileId);
    return detail?.qualifications;
  } catch (e) {
    print('❌ [employeeQualificationProvider] Error: $e');
    return null;
  }
});

// ============================================
// EMPLOYEE ACTIVITIES PROVIDER (UNTUK DASHBOARD)
// ============================================
final employeeActivitiesProvider = FutureProvider.family<EmployeeActivityData?, String>((ref, profileId) async {
  final service = ref.read(employeeDetailServiceProvider);
  print('📊 [employeeActivitiesProvider] Mengambil aktivitas untuk profile: $profileId');
  
  try {
    final detail = await service.getEmployeeDetail(profileId);
    return detail?.activities;
  } catch (e) {
    print('❌ [employeeActivitiesProvider] Error: $e');
    return null;
  }
});