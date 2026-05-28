// // lib/insights/profiles/providers/profile_wellbeing_provider.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/models.dart';
// import '../services/services.dart';
// import 'supabase_provider.dart';

// // Service instance provider
// final profileWellbeingServiceProvider = Provider<ProfileWellbeingService>((ref) {
//   return ProfileWellbeingService();
// });

// // Wellbeing Summary Provider (menggunakan service)
// final wellbeingSummaryProvider = FutureProvider<WellbeingSummary>((ref) async {
//   print('💚 [wellbeingSummaryProvider] Memanggil service...');
  
//   final service = ref.read(profileWellbeingServiceProvider);
//   final result = await service.getWellbeingSummary();
  
//   print('💚 [wellbeingSummaryProvider] Selesai. Rata-rata Fatigue: ${result.averageFatigueScore.toStringAsFixed(1)}');
//   return result;
// });

// // Wellbeing Trend Provider (menggunakan service)
// final wellbeingTrendProvider = FutureProvider<List<WellbeingLogModel>>((ref) async {
//   print('📈 [wellbeingTrendProvider] Memanggil service...');
  
//   final service = ref.read(profileWellbeingServiceProvider);
//   final summary = await service.getWellbeingSummary();
  
//   print('📈 [wellbeingTrendProvider] Selesai. Trend: ${summary.last7Days.length} records');
//   return summary.last7Days;
// });

// // Stream provider untuk realtime wellbeing
// final wellbeingStreamProvider = StreamProvider<WellbeingSummary>((ref) async* {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('🔄 [wellbeingStreamProvider] Memulai stream realtime untuk wellbeing...');
  
//   yield* supabase
//       .from('employee_wellbeing_logs')
//       .stream(primaryKey: ['id'])
//       .asyncMap((_) async {
//         print('🔄 [wellbeingStreamProvider] Ada perubahan pada tabel wellbeing');
//         return await ref.read(wellbeingSummaryProvider.future);
//       });
// });

// // Provider untuk wellbeing per profile tertentu (menggunakan service)
// final profileWellbeingProvider = FutureProvider.family<WellbeingLogModel?, String>((ref, profileId) async {
//   print('💚 [profileWellbeingProvider] Memanggil service untuk profile: $profileId');
  
//   final service = ref.read(profileWellbeingServiceProvider);
//   final result = await service.getProfileWellbeing(profileId);
  
//   if (result != null) {
//     print('💚 [profileWellbeingProvider] Fatigue score: ${result.fatigueScore}');
//   } else {
//     print('💚 [profileWellbeingProvider] Tidak ada data wellbeing');
//   }
  
//   return result;
// });
// lib/insights/profiles/providers/profile_wellbeing_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// Service instance provider
final profileWellbeingServiceProvider = Provider<ProfileWellbeingService>((ref) {
  return ProfileWellbeingService();
});

// 🔥 FUTURE PROVIDER (untuk sekali ambil - bisa dipertahankan)
final wellbeingSummaryProvider = FutureProvider<WellbeingSummary>((ref) async {
  print('💚 [wellbeingSummaryProvider] Memanggil service...');
  final service = ref.read(profileWellbeingServiceProvider);
  return await service.getWellbeingSummary();
});

// 🔥 STREAM PROVIDER (REALTIME) - UNTUK WELLBEING
final wellbeingSummaryStreamProvider = StreamProvider<WellbeingSummary>((ref) {
  print('🔄 [wellbeingSummaryStreamProvider] Memulai stream realtime untuk wellbeing...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileWellbeingServiceProvider);
  
  // Subscribe ke tabel employee_wellbeing_logs
  final stream = supabase
      .from('employee_wellbeing_logs')
      .stream(primaryKey: ['id']);
  
  // Setiap perubahan, panggil service untuk mengambil data terbaru
  return stream.asyncMap((_) async {
    print('🔄 [wellbeingSummaryStreamProvider] Ada perubahan pada tabel wellbeing, mengambil data terbaru...');
    return await service.getWellbeingSummary();
  });
});

// Wellbeing Trend Stream
final wellbeingTrendStreamProvider = StreamProvider<List<WellbeingLogModel>>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  
  return supabase
      .from('employee_wellbeing_logs')
      .stream(primaryKey: ['id'])
      .asyncMap((_) async {
        print('🔄 [wellbeingTrendStreamProvider] Ada perubahan, mengambil trend...');
        final summary = await ref.read(wellbeingSummaryStreamProvider.future);
        return summary.last7Days;
      });
});

// Profile Wellbeing per profile (Stream)
final profileWellbeingStreamProvider = StreamProvider.family<WellbeingLogModel?, String>((ref, profileId) {
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileWellbeingServiceProvider);
  
  return supabase
      .from('employee_wellbeing_logs')
      .stream(primaryKey: ['id'])
      .eq('profile_id', profileId)
      .asyncMap((_) async {
        print('🔄 [profileWellbeingStreamProvider] Ada perubahan untuk profile $profileId');
        return await service.getProfileWellbeing(profileId);
      });
});