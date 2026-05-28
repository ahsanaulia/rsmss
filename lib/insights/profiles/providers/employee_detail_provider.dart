// lib/insights/profiles/providers/employee_detail_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_detail_model.dart';
import '../services/employee_detail_service.dart';
import 'supabase_provider.dart';

// Service instance provider
final employeeDetailServiceProvider = Provider<EmployeeDetailService>((ref) {
  return EmployeeDetailService();
});

// State provider untuk menyimpan ID pegawai yang dipilih
final selectedEmployeeIdProvider = StateProvider<String?>((ref) => null);

// 🔥 FUTURE PROVIDER untuk detail pegawai (sekali ambil)
final employeeDetailProvider = FutureProvider<EmployeeDetail?>((ref) async {
  final selectedId = ref.watch(selectedEmployeeIdProvider);
  
  print('📋 [employeeDetailProvider] Memanggil service untuk profile ID: $selectedId');
  
  if (selectedId == null) {
    print('⚠️ [employeeDetailProvider] Tidak ada profile yang dipilih');
    return null;
  }
  
  final service = ref.read(employeeDetailServiceProvider);
  final result = await service.getEmployeeDetail(selectedId);
  
  if (result != null) {
    print('✅ [employeeDetailProvider] Detail pegawai berhasil diambil');
  } else {
    print('⚠️ [employeeDetailProvider] Gagal mengambil detail pegawai');
  }
  
  return result;
});

// 🔥 STREAM PROVIDER untuk detail pegawai (REALTIME)
final employeeDetailStreamProvider = StreamProvider<EmployeeDetail?>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final selectedId = ref.watch(selectedEmployeeIdProvider);
  final service = ref.read(employeeDetailServiceProvider);
  
  if (selectedId == null) {
    print('⚠️ [employeeDetailStreamProvider] Tidak ada profile yang dipilih');
    return Stream.value(null);
  }
  
  print('🔄 [employeeDetailStreamProvider] Memulai stream realtime untuk profile: $selectedId');
  
  // Subscribe ke tabel-tabel yang relevan dengan profile ini
  final profileStream = supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', selectedId);
  
  final attendanceStream = supabase
      .from('attendance')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId);
  
  // 🔥 PERBAIKAN: Typo - primaryKey: ['id'] bukan primaryKey(['id'])
  final wellbeingStream = supabase
      .from('employee_wellbeing_logs')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId);
  
  final scoringStream = supabase
      .from('employee_scoring')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId);
  
  final tasksStream = supabase
      .from('tasks')
      .stream(primaryKey: ['id'])
      .eq('assignee_id', selectedId);
  
  final dutyNotesStream = supabase
      .from('duty_notes')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId);
  
  final incidentsStream = supabase
      .from('incidents')
      .stream(primaryKey: ['id'])
      .eq('reported_by', selectedId);
  
  final qualificationsStream = supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id'])
      .eq('profile_id', selectedId);
  
  // Merge semua stream
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  profileStream.listen((_) => triggerReload());
  attendanceStream.listen((_) => triggerReload());
  wellbeingStream.listen((_) => triggerReload());
  scoringStream.listen((_) => triggerReload());
  tasksStream.listen((_) => triggerReload());
  dutyNotesStream.listen((_) => triggerReload());
  incidentsStream.listen((_) => triggerReload());
  qualificationsStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [employeeDetailStreamProvider] Ada perubahan data, mengambil detail terbaru...');
    return await service.getEmployeeDetail(selectedId);
  });
});
// ============================================
// FUTURE PROVIDER FAMILY (UNTUK POPUP - TIDAK STREAMING)
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