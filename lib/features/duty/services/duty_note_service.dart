import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DutyNoteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil scoring_category_id untuk 'duty_note'
  Future<String?> _getDutyNoteCategoryId() async {
    final response = await _supabase
        .from('scoring_categories')
        .select('id')
        .eq('category_code', 'duty_note')
        .maybeSingle();
    
    return response?['id']?.toString();
  }

  /// Ambil attendance_id untuk hari ini (check-in terbaru)
  Future<String?> getTodayAttendanceId(String profileId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from('attendance')
        .select('id')
        .eq('profile_id', profileId)
        .gte('check_in', today)
        .order('check_in', ascending: false)
        .limit(1)
        .maybeSingle();

    return response?['id']?.toString();
  }

  /// Cek apakah user sudah check-in hari ini
  Future<bool> isCheckedInToday(String profileId) async {
    final attendanceId = await getTodayAttendanceId(profileId);
    return attendanceId != null;
  }

  /// Simpan duty note
  Future<Map<String, String>> saveDutyNote({
    required String profileId,
    required String noteText,
  }) async {
    // Ambil attendance_id hari ini
    final attendanceId = await getTodayAttendanceId(profileId);
    
    if (attendanceId == null) {
      throw Exception('Anda belum check-in hari ini. Silakan check-in terlebih dahulu.');
    }

    final noteId = const Uuid().v4();

    await _supabase.from('duty_notes').insert({
      'id': noteId,
      'attendance_id': attendanceId,
      'profile_id': profileId,
      'note_text': noteText,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Tambahkan poin ke scoring
    await _addScoringPoint(profileId, noteId);

    return {'noteId': noteId};
  }

  /// Tambahkan poin ke employee_scoring
  Future<void> _addScoringPoint(String profileId, String noteId) async {
    final categoryId = await _getDutyNoteCategoryId();
    if (categoryId == null) {
      // Kategori belum ada, skip scoring
      return;
    }

    final today = DateTime.now();
    final periodStart = DateTime(today.year, today.month, today.day);
    final periodEnd = DateTime(today.year, today.month, today.day);

    // Cek apakah sudah ada scoring untuk kategori DUTY_NOTE hari ini
    final existing = await _supabase
        .from('employee_scoring')
        .select('id, score')
        .eq('profile_id', profileId)
        .eq('scoring_category_id', categoryId)
        .eq('period_start', periodStart.toIso8601String().split('T')[0])
        .maybeSingle();

    if (existing != null) {
      // Update existing score
      final currentScore = (existing['score'] as num).toDouble();
      await _supabase.from('employee_scoring').update({
        'score': currentScore + 5,
        'notes': 'Duty note recorded: $noteId',
        'calculated_at': DateTime.now().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      // Insert new scoring
      await _supabase.from('employee_scoring').insert({
        'profile_id': profileId,
        'scoring_category_id': categoryId,
        'score': 5,
        'max_score': 100,
        'period_start': periodStart.toIso8601String().split('T')[0],
        'period_end': periodEnd.toIso8601String().split('T')[0],
        'notes': 'Duty note recorded: $noteId',
        'calculated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Ambil riwayat duty notes untuk hari ini
  Future<List<Map<String, dynamic>>> getTodayDutyNotes(String profileId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from('duty_notes')
        .select('''
          id,
          note_text,
          created_at,
          attendance_id
        ''')
        .eq('profile_id', profileId)
        .gte('created_at', today)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}