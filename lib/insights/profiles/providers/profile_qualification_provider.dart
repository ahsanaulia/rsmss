// lib/insights/profiles/providers/profile_qualification_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// Service instance provider
final profileQualificationServiceProvider = Provider<ProfileQualificationService>((ref) {
  return ProfileQualificationService();
});

// ==================== FUTURE PROVIDERS ====================

// All Qualifications Provider (menggunakan service)
final allQualificationsProvider = FutureProvider<List<QualificationModel>>((ref) async {
  print('📋 [allQualificationsProvider] Memanggil service...');
  final service = ref.read(profileQualificationServiceProvider);
  final result = await service.getAllQualifications();
  print('📋 [allQualificationsProvider] Selesai. Total: ${result.length} kualifikasi');
  return result;
});

// 🔥 All Owned Qualifications Provider (SEMUA SERTIFIKASI YANG DIMILIKI)
final allOwnedQualificationsProvider = FutureProvider<List<QualificationWithAssignment>>((ref) async {
  print('📋 [allOwnedQualificationsProvider] Memanggil service...');
  final service = ref.read(profileQualificationServiceProvider);
  final result = await service.getAllOwnedQualifications();
  print('📋 [allOwnedQualificationsProvider] Selesai. Total dimiliki: ${result.length} kualifikasi');
  return result;
});

// Qualifications Summary Provider (menggunakan service)
final qualificationsSummaryProvider = FutureProvider<List<QualificationWithAssignment>>((ref) async {
  print('📋 [qualificationsSummaryProvider] Memanggil service...');
  final service = ref.read(profileQualificationServiceProvider);
  final result = await service.getAllQualificationsWithAssignments();
  print('📋 [qualificationsSummaryProvider] Selesai. Total: ${result.length} kualifikasi diproses');
  return result;
});

// Expiring Qualifications Provider (menggunakan service)
final expiringQualificationsProvider = FutureProvider<List<QualificationWithAssignment>>((ref) async {
  print('⏰ [expiringQualificationsProvider] Memanggil service...');
  final service = ref.read(profileQualificationServiceProvider);
  final result = await service.getExpiringQualifications();
  print('⏰ [expiringQualificationsProvider] Selesai. Ditemukan ${result.length} kualifikasi akan kadaluarsa');
  return result;
});

// Expired Qualifications Provider (menggunakan service)
final expiredQualificationsProvider = FutureProvider<List<QualificationWithAssignment>>((ref) async {
  print('⚠️ [expiredQualificationsProvider] Memanggil service...');
  final service = ref.read(profileQualificationServiceProvider);
  final result = await service.getExpiredQualifications();
  print('⚠️ [expiredQualificationsProvider] Selesai. Ditemukan ${result.length} kualifikasi sudah kadaluarsa');
  return result;
});

// ==================== STREAM PROVIDERS (REALTIME) ====================

// 🔥 STREAM PROVIDER untuk All Owned Qualifications (REALTIME)
final allOwnedQualificationsStreamProvider = StreamProvider<List<QualificationWithAssignment>>((ref) {
  print('🔄 [allOwnedQualificationsStreamProvider] Memulai stream realtime untuk semua kualifikasi dimiliki...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileQualificationServiceProvider);
  
  final assignmentsStream = supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id']);
  
  final qualificationsStream = supabase
      .from('employee_qualifications')
      .stream(primaryKey: ['id']);
  
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  assignmentsStream.listen((_) => triggerReload());
  qualificationsStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [allOwnedQualificationsStreamProvider] Ada perubahan data, mengambil semua kualifikasi dimiliki...');
    return await service.getAllOwnedQualifications();
  });
});

// 🔥 STREAM PROVIDER untuk Expiring Qualifications (REALTIME)
final expiringQualificationsStreamProvider = StreamProvider<List<QualificationWithAssignment>>((ref) {
  print('🔄 [expiringQualificationsStreamProvider] Memulai stream realtime untuk expiring qualifications...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileQualificationServiceProvider);
  
  final assignmentsStream = supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id']);
  
  final qualificationsStream = supabase
      .from('employee_qualifications')
      .stream(primaryKey: ['id']);
  
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  assignmentsStream.listen((_) => triggerReload());
  qualificationsStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [expiringQualificationsStreamProvider] Ada perubahan data, mengambil expiring qualifications...');
    return await service.getExpiringQualifications();
  });
});

// 🔥 STREAM PROVIDER untuk Expired Qualifications (REALTIME)
final expiredQualificationsStreamProvider = StreamProvider<List<QualificationWithAssignment>>((ref) {
  print('🔄 [expiredQualificationsStreamProvider] Memulai stream realtime untuk expired qualifications...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileQualificationServiceProvider);
  
  final assignmentsStream = supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id']);
  
  final qualificationsStream = supabase
      .from('employee_qualifications')
      .stream(primaryKey: ['id']);
  
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  assignmentsStream.listen((_) => triggerReload());
  qualificationsStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [expiredQualificationsStreamProvider] Ada perubahan data, mengambil expired qualifications...');
    return await service.getExpiredQualifications();
  });
});

// 🔥 STREAM PROVIDER untuk All Qualifications (REALTIME)
final allQualificationsStreamProvider = StreamProvider<List<QualificationModel>>((ref) {
  print('🔄 [allQualificationsStreamProvider] Memulai stream realtime untuk all qualifications...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileQualificationServiceProvider);
  
  final stream = supabase
      .from('employee_qualifications')
      .stream(primaryKey: ['id']);
  
  return stream.asyncMap((_) async {
    print('🔄 [allQualificationsStreamProvider] Ada perubahan pada tabel qualifications');
    return await service.getAllQualifications();
  });
});

// 🔥 STREAM PROVIDER untuk Qualifications Summary (REALTIME)
final qualificationsSummaryStreamProvider = StreamProvider<List<QualificationWithAssignment>>((ref) {
  print('🔄 [qualificationsSummaryStreamProvider] Memulai stream realtime untuk qualifications summary...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileQualificationServiceProvider);
  
  final assignmentsStream = supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id']);
  
  final qualificationsStream = supabase
      .from('employee_qualifications')
      .stream(primaryKey: ['id']);
  
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  assignmentsStream.listen((_) => triggerReload());
  qualificationsStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [qualificationsSummaryStreamProvider] Ada perubahan data, mengambil qualifications summary...');
    return await service.getAllQualificationsWithAssignments();
  });
});

// Stream provider untuk realtime qualification assignments (sederhana)
final qualificationAssignmentsStreamProvider = StreamProvider<List<QualificationAssignmentModel>>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  
  print('🔄 [qualificationAssignmentsStreamProvider] Memulai stream realtime...');
  
  return supabase
      .from('employee_qualification_assignments')
      .stream(primaryKey: ['id'])
      .map((response) {
        print('🔄 [qualificationAssignmentsStreamProvider] Ada perubahan pada tabel assignments');
        
        return response.map<QualificationAssignmentModel>((json) {
          return QualificationAssignmentModel.fromJson(json);
        }).toList();
      });
});