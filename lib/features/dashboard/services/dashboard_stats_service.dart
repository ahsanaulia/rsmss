import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStatsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ambil total points pegawai untuk periode berjalan (bulan ini)
  Future<Map<String, dynamic>> getEmployeePoints(String profileId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final response = await _supabase
        .from('employee_scoring')
        .select('score, scoring_categories!inner(category_name, category_code)')
        .eq('profile_id', profileId)
        .gte('period_start', startOfMonth.toIso8601String().split('T')[0])
        .lte('period_end', endOfMonth.toIso8601String().split('T')[0]);

    final List<Map<String, dynamic>> data = List.from(response);
    
    double totalScore = 0;
    final Map<String, double> categoryScores = {};

    for (var item in data) {
      final score = (item['score'] as num).toDouble();
      totalScore += score;
      
      final category = item['scoring_categories'] as Map<String, dynamic>;
      final categoryCode = category['category_code'] ?? 'other';
      categoryScores[categoryCode] = (categoryScores[categoryCode] ?? 0) + score;
    }

    return {
      'totalScore': totalScore,
      'categoryScores': categoryScores,
      'period': '${startOfMonth.day}/${startOfMonth.month} - ${endOfMonth.day}/${endOfMonth.month}',
    };
  }

  /// Ambil fatigue score untuk hari ini
  Future<Map<String, dynamic>> getTodayFatigue(String profileId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Cek dari employee_shift_rosters
    final rosterResponse = await _supabase
        .from('employee_shift_rosters')
        .select('predicted_fatigue_score, wellbeing_risk_level')
        .eq('profile_id', profileId)
        .eq('roster_date', today)
        .maybeSingle();

    if (rosterResponse != null) {
      final fatigueScore = rosterResponse['predicted_fatigue_score'] as num?;
      return {
        'fatigueScore': fatigueScore?.toDouble() ?? 0,
        'riskLevel': rosterResponse['wellbeing_risk_level'] ?? 'normal',
        'source': 'roster',
      };
    }

    // Fallback: ambil dari wellbeing_logs
    final fallbackResponse = await _supabase
        .from('employee_wellbeing_logs')
        .select('fatigue_score')
        .eq('profile_id', profileId)
        .eq('log_date', today)
        .maybeSingle();

    if (fallbackResponse != null) {
      return {
        'fatigueScore': (fallbackResponse['fatigue_score'] as num?)?.toDouble() ?? 0,
        'riskLevel': 'normal',
        'source': 'wellbeing',
      };
    }

    return {
      'fatigueScore': 0,
      'riskLevel': 'normal',
      'source': null,
    };
  }
}