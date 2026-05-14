import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/roster_model.dart';

class RosterService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil profil user untuk cek tipe roster
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('''
          is_flexible_roster,
          default_shift_id,
          ref_shifts!default_shift_id (
            id,
            shift_name,
            shift_code,
            start_time,
            end_time
          )
        ''')
        .eq('id', userId)
        .single();

    return response;
  }

  /// Ambil jadwal hari ini untuk pegawai dengan roster dinamis
  Future<RosterModel?> getTodayRoster(String userId) async {
  final today = DateTime.now().toIso8601String().split('T')[0];

  final response = await _supabase
      .from('employee_shift_rosters')
      .select('''
        *,
        ref_shifts!shift_id (
          id,
          shift_name,
          shift_code,
          start_time,
          end_time
        )
      ''')
      .eq('profile_id', userId)
      .eq('roster_date', today)
      .maybeSingle();

  if (response == null) return null;
  return RosterModel.fromJson(response);
}

  /// Ambil jadwal berikutnya (setelah hari ini)
  Future<RosterModel?> getNextRoster(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from('employee_shift_rosters')
        .select('''
          *,
          ref_shifts!shift_id (
            id,
            shift_name,
            shift_code,
            start_time,
            end_time
          )
        ''')
        .eq('profile_id', userId)
        .gt('roster_date', today)
        .eq('is_day_off', false)
        .order('roster_date', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return RosterModel.fromJson(response);
  }

  /// Buat default shift model dari profile (untuk roster tetap)
  RosterModel? createDefaultShiftModel(Map<String, dynamic> profile) {
    final defaultShift = profile['ref_shifts'] as Map<String, dynamic>?;
    if (defaultShift == null) return null;

    final now = DateTime.now();
    final startTime = defaultShift['start_time'] as String;
    final endTime = defaultShift['end_time'] as String;

    final scheduledStart = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTime.split(':')[0]),
      int.parse(startTime.split(':')[1]),
    );

    var scheduledEnd = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endTime.split(':')[0]),
      int.parse(endTime.split(':')[1]),
    );

    // Jika end_time lebih kecil dari start_time (cross day)
    if (scheduledEnd.isBefore(scheduledStart)) {
      scheduledEnd = scheduledEnd.add(const Duration(days: 1));
    }

    return RosterModel(
      id: 'default_${profile['id']}',
      profileId: profile['id']?.toString() ?? '',
      shiftId: defaultShift['id']?.toString() ?? '',
      shiftName: defaultShift['shift_name'] ?? '-',
      shiftCode: defaultShift['shift_code'] ?? '-',
      rosterDate: now,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      locationName: null,
      locationRoomId: null,
      requiredEquipment: const [],
      specialInstructions: null,
      attendanceStatus: 'scheduled',
      predictedFatigueScore: null,
      wellbeingRiskLevel: null,
      isDayOff: false,
    );
  }
}