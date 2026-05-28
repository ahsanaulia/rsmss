// lib/insights/profiles/providers/profile_summary_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// Service instance provider
final profileSummaryServiceProvider = Provider<ProfileSummaryService>((ref) {
  return ProfileSummaryService();
});

// 🔥 FUTURE PROVIDER (untuk sekali ambil - bisa dipertahankan)
final profileSummaryProvider = FutureProvider<ProfileSummaryModel>((ref) async {
  print('📊 [profileSummaryProvider] Memanggil service...');
  final service = ref.read(profileSummaryServiceProvider);
  return await service.getProfileSummary();
});

// 🔥 STREAM PROVIDER (REALTIME) - TAMBAHKAN INI
final profileSummaryStreamProvider = StreamProvider<ProfileSummaryModel>((ref) {
  print('🔄 [profileSummaryStreamProvider] Memulai stream realtime untuk ringkasan profil...');
  
  final supabase = ref.read(supabaseClientProvider);
  final service = ref.read(profileSummaryServiceProvider);
  
  // Subscribe ke tabel profiles (karena data ringkasan dari tabel profiles)
  final stream = supabase
      .from('profiles')
      .stream(primaryKey: ['id']);
  
  // Setiap perubahan, panggil service untuk mengambil data terbaru
  return stream.asyncMap((_) async {
    print('🔄 [profileSummaryStreamProvider] Ada perubahan pada tabel profiles, mengambil data terbaru...');
    return await service.getProfileSummary();
  });
});