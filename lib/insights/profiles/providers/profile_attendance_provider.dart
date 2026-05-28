// lib/insights/profiles/providers/profile_attendance_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// Service instance provider
final profileAttendanceServiceProvider = Provider<ProfileAttendanceService>((ref) {
  return ProfileAttendanceService();
});

// Attendance Summary Provider (Future - untuk sekali ambil)
final attendanceSummaryProvider = FutureProvider<AttendanceSummary>((ref) async {
  print('📊 [attendanceSummaryProvider] Memanggil service...');
  final service = ref.read(profileAttendanceServiceProvider);
  final result = await service.getAttendanceSummary();
  print('📊 [attendanceSummaryProvider] Selesai');
  return result;
});

// 🔥 WORKING EMPLOYEES PROVIDER (Future - untuk sekali ambil)
final workingEmployeesProvider = FutureProvider<WorkingEmployeesResult>((ref) async {
  print('📊 [workingEmployeesProvider] Memanggil service untuk pegawai bertugas...');
  final service = ref.read(profileAttendanceServiceProvider);
  final result = await service.getWorkingEmployeesToday();
  print('📊 [workingEmployeesProvider] Selesai. Total bertugas: ${result.total}');
  return result;
});

// 🔥 WORKING EMPLOYEES STREAM PROVIDER (REALTIME) - YANG DIPAKAI VIEW
final workingEmployeesStreamProvider = StreamProvider<WorkingEmployeesResult>((ref) {
  print('🔄 [workingEmployeesStreamProvider] Memulai stream realtime pegawai bertugas...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileAttendanceServiceProvider);
  
  // Subscribe ke tabel attendance
  final stream = supabase
      .from('attendance')
      .stream(primaryKey: ['id']);
  
  // Setiap perubahan, panggil service untuk mengambil data terbaru
  return stream.asyncMap((_) async {
    print('🔄 [workingEmployeesStreamProvider] Ada perubahan attendance, mengambil data terbaru...');
    return await service.getWorkingEmployeesToday();
  });
});

// Stream provider untuk realtime attendance summary
final attendanceStreamProvider = StreamProvider<AttendanceSummary>((ref) async* {
  final supabase = ref.read(supabaseClientProvider);
  
  print('🔄 [attendanceStreamProvider] Memulai stream realtime untuk absensi...');
  
  final stream = supabase
      .from('attendance')
      .stream(primaryKey: ['id']);
  
  await for (final _ in stream) {
    print('🔄 [attendanceStreamProvider] Ada perubahan pada tabel attendance');
    final result = await ref.read(attendanceSummaryProvider.future);
    yield result;
  }
});

// Location Summary Provider
final locationSummaryProvider = FutureProvider<LocationSummary>((ref) async {
  print('📍 [locationSummaryProvider] Memanggil service...');
  final service = ref.read(profileAttendanceServiceProvider);
  return await service.getLocationSummary();
});

// Stream provider untuk realtime location
final locationStreamProvider = StreamProvider<LocationSummary>((ref) async* {
  final supabase = ref.read(supabaseClientProvider);
  
  print('🔄 [locationStreamProvider] Memulai stream realtime untuk lokasi...');
  
  final stream = supabase
      .from('profiles')
      .stream(primaryKey: ['id']);
  
  await for (final _ in stream) {
    print('🔄 [locationStreamProvider] Ada perubahan pada tabel profiles');
    final result = await ref.read(locationSummaryProvider.future);
    yield result;
  }
});