// lib/insights/profiles/providers/shift_attendance_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// Service instance provider
final shiftAttendanceServiceProvider = Provider<ProfileShiftAttendanceService>((ref) {
  return ProfileShiftAttendanceService();
});

// 🔥 STREAM PROVIDER UNTUK OVERVIEW ATTENDANCE PER SHIFT (REALTIME)
final shiftAttendanceOverviewStreamProvider = StreamProvider<AttendanceOverview>((ref) {
  print('🔄 [shiftAttendanceOverviewStreamProvider] Memulai stream realtime untuk overview shift...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(shiftAttendanceServiceProvider);
  
  // Subscribe ke tabel yang relevan
  final attendanceStream = supabase.from('attendance').stream(primaryKey: ['id']);
  final rosterStream = supabase.from('employee_shift_rosters').stream(primaryKey: ['id']);
  final tasksStream = supabase.from('tasks').stream(primaryKey: ['id']);
  final leaveStream = supabase.from('employee_leave_requests').stream(primaryKey: ['id']);
  final profilesStream = supabase.from('profiles').stream(primaryKey: ['id']);
  
  // 🔥 PERBAIKAN: Merge streams secara manual menggunakan StreamController
  final controller = StreamController<dynamic>.broadcast();
  
  // Function untuk trigger reload
  void triggerReload() {
    print('🔄 [shiftAttendanceOverviewStreamProvider] Ada perubahan data, mengambil data terbaru...');
    controller.add(null);
  }
  
  // Subscribe ke semua stream
  attendanceStream.listen((_) => triggerReload());
  rosterStream.listen((_) => triggerReload());
  tasksStream.listen((_) => triggerReload());
  leaveStream.listen((_) => triggerReload());
  profilesStream.listen((_) => triggerReload());
  
  // Return stream yang sudah di-map ke AttendanceOverview
  return controller.stream.asyncMap((_) async {
    return await service.getAttendanceOverview();
  });
});

// Future provider untuk sekali ambil
final shiftAttendanceOverviewProvider = FutureProvider<AttendanceOverview>((ref) async {
  print('📊 [shiftAttendanceOverviewProvider] Memanggil service...');
  final service = ref.read(shiftAttendanceServiceProvider);
  return await service.getAttendanceOverview();
});

// Provider untuk list pegawai terlambat per shift
final lateEmployeesByShiftProvider = FutureProvider.family<List<LateEmployeeShift>, String>((ref, shiftId) async {
  print('📊 [lateEmployeesByShiftProvider] Mencari pegawai terlambat untuk shift: $shiftId');
  final service = ref.read(shiftAttendanceServiceProvider);
  return await service.getLateEmployeesByShift(shiftId);
});

// Provider untuk list overshift pegawai
final overshiftEmployeesProvider = FutureProvider<List<OvershiftEmployee>>((ref) async {
  print('📊 [overshiftEmployeesProvider] Mencari pegawai overshift...');
  final service = ref.read(shiftAttendanceServiceProvider);
  return await service.getOvershiftEmployees();
});

// Provider untuk recent check-ins
final recentCheckInsProvider = FutureProvider<List<RecentCheckIn>>((ref) async {
  print('📊 [recentCheckInsProvider] Mengambil recent check-ins...');
  final service = ref.read(shiftAttendanceServiceProvider);
  return await service.getRecentCheckIns();
});