// // lib/insights/profiles/providers/profile_scoring_provider.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/models.dart';
// import '../services/services.dart';
// import 'supabase_provider.dart';

// // Service instance provider
// final profileScoringServiceProvider = Provider<ProfileScoringService>((ref) {
//   return ProfileScoringService();
// });

// // Scoring Categories Provider (menggunakan service)
// final scoringCategoriesProvider = FutureProvider<List<ScoringCategoryModel>>((ref) async {
//   print('📊 [scoringCategoriesProvider] Memanggil service...');
  
//   final service = ref.read(profileScoringServiceProvider);
//   final result = await service.getScoringCategories();
  
//   print('📊 [scoringCategoriesProvider] Selesai. Total: ${result.length} kategori');
//   return result;
// });

// // Score Summary List Provider (menggunakan service)
// final scoreSummaryListProvider = FutureProvider<List<ScoreSummary>>((ref) async {
//   print('📊 [scoreSummaryListProvider] Memanggil service...');
  
//   final service = ref.read(profileScoringServiceProvider);
//   final result = await service.getAllScoreSummaries();
  
//   print('📊 [scoreSummaryListProvider] Selesai. Total: ${result.length} summary');
//   return result;
// });

// // Top Performers Provider (menggunakan service)
// final topPerformersProvider = FutureProvider<List<ScoreSummary>>((ref) async {
//   print('🏆 [topPerformersProvider] Memanggil service...');
  
//   final service = ref.read(profileScoringServiceProvider);
//   final result = await service.getTopPerformers();
  
//   print('🏆 [topPerformersProvider] Selesai. Top 5 performers diambil');
//   return result;
// });

// // Bottom Performers Provider (menggunakan service)
// final bottomPerformersProvider = FutureProvider<List<ScoreSummary>>((ref) async {
//   print('📉 [bottomPerformersProvider] Memanggil service...');
  
//   final service = ref.read(profileScoringServiceProvider);
//   final result = await service.getBottomPerformers();
  
//   print('📉 [bottomPerformersProvider] Selesai. Bottom 5 performers diambil');
//   return result;
// });

// // Stream provider untuk realtime scoring changes
// final scoringStreamProvider = StreamProvider<List<ScoreSummary>>((ref) async* {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('🔄 [scoringStreamProvider] Memulai stream realtime untuk scoring...');
  
//   yield* supabase
//       .from('employee_scoring')
//       .stream(primaryKey: ['id'])
//       .asyncMap((_) async {
//         print('🔄 [scoringStreamProvider] Ada perubahan pada tabel scoring');
//         return await ref.read(scoreSummaryListProvider.future);
//       });
// });
// lib/insights/profiles/providers/profile_scoring_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// Service instance provider
final profileScoringServiceProvider = Provider<ProfileScoringService>((ref) {
  return ProfileScoringService();
});

// ==================== FUTURE PROVIDERS ====================

// Scoring Categories Provider
final scoringCategoriesProvider = FutureProvider<List<ScoringCategoryModel>>((ref) async {
  print('📊 [scoringCategoriesProvider] Memanggil service...');
  final service = ref.read(profileScoringServiceProvider);
  final result = await service.getScoringCategories();
  print('📊 [scoringCategoriesProvider] Selesai. Total: ${result.length} kategori');
  return result;
});

// Score Summary List Provider
final scoreSummaryListProvider = FutureProvider<List<ScoreSummary>>((ref) async {
  print('📊 [scoreSummaryListProvider] Memanggil service...');
  final service = ref.read(profileScoringServiceProvider);
  final result = await service.getAllScoreSummaries();
  print('📊 [scoreSummaryListProvider] Selesai. Total: ${result.length} summary');
  return result;
});

// Top Performers Provider
final topPerformersProvider = FutureProvider<List<ScoreSummary>>((ref) async {
  print('🏆 [topPerformersProvider] Memanggil service...');
  final service = ref.read(profileScoringServiceProvider);
  final result = await service.getTopPerformers();
  print('🏆 [topPerformersProvider] Selesai. Top 5 performers diambil');
  return result;
});

// Bottom Performers Provider
final bottomPerformersProvider = FutureProvider<List<ScoreSummary>>((ref) async {
  print('📉 [bottomPerformersProvider] Memanggil service...');
  final service = ref.read(profileScoringServiceProvider);
  final result = await service.getBottomPerformers();
  print('📉 [bottomPerformersProvider] Selesai. Bottom 5 performers diambil');
  return result;
});

// ==================== STREAM PROVIDERS (REALTIME) ====================

// 🔥 STREAM PROVIDER untuk Score Summary List (REALTIME)
final scoreSummaryListStreamProvider = StreamProvider<List<ScoreSummary>>((ref) {
  print('🔄 [scoreSummaryListStreamProvider] Memulai stream realtime untuk scoring...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileScoringServiceProvider);
  
  // Subscribe ke tabel employee_scoring dan employee_score_summary
  final scoringStream = supabase.from('employee_scoring').stream(primaryKey: ['id']);
  final summaryStream = supabase.from('employee_score_summary').stream(primaryKey: ['profile_id']);
  
  // Merge kedua stream
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  scoringStream.listen((_) => triggerReload());
  summaryStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [scoreSummaryListStreamProvider] Ada perubahan data scoring');
    return await service.getAllScoreSummaries();
  });
});

// 🔥 STREAM PROVIDER untuk Top Performers (REALTIME)
final topPerformersStreamProvider = StreamProvider<List<ScoreSummary>>((ref) {
  print('🔄 [topPerformersStreamProvider] Memulai stream realtime untuk top performers...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileScoringServiceProvider);
  
  final scoringStream = supabase.from('employee_scoring').stream(primaryKey: ['id']);
  final summaryStream = supabase.from('employee_score_summary').stream(primaryKey: ['profile_id']);
  
  final controller = StreamController<List<Object?>>.broadcast();
  
  void triggerReload() {
    controller.add([]);
  }
  
  scoringStream.listen((_) => triggerReload());
  summaryStream.listen((_) => triggerReload());
  
  return controller.stream.asyncMap((_) async {
    print('🔄 [topPerformersStreamProvider] Ada perubahan data, mengambil top performers...');
    return await service.getTopPerformers();
  });
});

// 🔥 STREAM PROVIDER untuk Scoring Categories (REALTIME)
final scoringCategoriesStreamProvider = StreamProvider<List<ScoringCategoryModel>>((ref) {
  print('🔄 [scoringCategoriesStreamProvider] Memulai stream realtime untuk kategori scoring...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileScoringServiceProvider);
  
  final stream = supabase.from('scoring_categories').stream(primaryKey: ['id']);
  
  return stream.asyncMap((_) async {
    print('🔄 [scoringCategoriesStreamProvider] Ada perubahan pada kategori scoring');
    return await service.getScoringCategories();
  });
});

// Stream provider untuk realtime scoring changes (alternatif)
final scoringStreamProvider = StreamProvider<List<ScoreSummary>>((ref) async* {
  final supabase = ref.read(supabaseClientProvider);
  
  print('🔄 [scoringStreamProvider] Memulai stream realtime untuk scoring...');
  
  final stream = supabase.from('employee_scoring').stream(primaryKey: ['id']);
  
  await for (final _ in stream) {
    print('🔄 [scoringStreamProvider] Ada perubahan pada tabel scoring');
    final result = await ref.read(scoreSummaryListProvider.future);
    yield result;
  }
});