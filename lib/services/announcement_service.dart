import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementService {
  final _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getFilteredAnnouncements(
    String userId, 
    String? positionId
  ) {
    // Ambil waktu sekarang dalam format ISO8601 untuk filter database
    // final String now = DateTime.now().toUtc().toIso8601String();

    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(30) // Ambil buffer lebih banyak karena akan difilter lagi di map
        .map((list) {
      return list.where((ann) {
        // --- 1. FILTER EXPIRED (Client-side Safety Check) ---
        // Kita cek lagi di sini untuk memastikan reaktivitas stream tetap akurat
        if (ann['expires_at'] != null) {
          final expiryDate = DateTime.parse(ann['expires_at']);
          if (expiryDate.isBefore(DateTime.now())) return false;
        }

        // --- 2. FILTER TARGET ---
        final targetProfile = ann['target_profile_id'];
        final targetPos = ann['target_position_id'];

        // Pesan khusus untuk User ID ini
        if (targetProfile != null) return targetProfile == userId;

        // Pesan khusus untuk Posisi/Jabatan ini
        if (targetPos != null) return targetPos == positionId;

        // Broadcast Global (Semua filter target bernilai null)
        if (ann['target_building_id'] == null &&
            ann['target_floor_id'] == null &&
            ann['target_room_id'] == null &&
            ann['target_position_id'] == null &&
            ann['target_profile_id'] == null) {
          return true;
        }

        return false;
      }).toList();
    });
  }
}