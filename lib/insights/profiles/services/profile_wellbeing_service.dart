// lib/insights/profiles/services/profile_wellbeing_service.dart

import 'base_service.dart';
import '../models/models.dart';

class ProfileWellbeingService extends BaseService {
  // Ambil ringkasan wellbeing
  Future<WellbeingSummary> getWellbeingSummary() async {
    log('Mengambil ringkasan wellbeing...');
    
    try {
      log('Periode: $sevenDaysAgo s/d $today', 1);
      
      final wellbeingResult = await supabase
          .from('employee_wellbeing_logs')
          .select('''
            *,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .gte('log_date', sevenDaysAgo)
          .lte('log_date', today)
          .order('log_date', ascending: true);
      
      log('Total records wellbeing: ${wellbeingResult.length}', 1);
      
      // DEBUG: Print sample data
      if (wellbeingResult.isNotEmpty) {
        log('Sample data pertama:', 1);
        log('  - profile_id: ${wellbeingResult[0]['profile_id']}', 2);
        log('  - log_date: ${wellbeingResult[0]['log_date']}', 2);
        log('  - fatigue_score: ${wellbeingResult[0]['fatigue_score']}', 2);
        log('  - stress_score: ${wellbeingResult[0]['stress_score']}', 2);
        log('  - mood_score: ${wellbeingResult[0]['mood_score']}', 2);
      } else {
        log('TIDAK ADA DATA wellbeing untuk periode ini!', 1);
      }
      
      final List<WellbeingLogModel> last7Days = [];
      double totalFatigue = 0.0;
      double totalStress = 0.0;
      double totalMood = 0.0;
      int fatigueCount = 0;
      int stressCount = 0;
      int moodCount = 0;
      
      for (final row in wellbeingResult) {
        final logEntry = WellbeingLogModel.fromJson(row);
        last7Days.add(logEntry);
        
        if (logEntry.fatigueScore != null) {
          totalFatigue += logEntry.fatigueScore!.toDouble();
          fatigueCount++;
        }
        if (logEntry.stressScore != null) {
          totalStress += logEntry.stressScore!.toDouble();
          stressCount++;
        }
        if (logEntry.moodScore != null) {
          totalMood += logEntry.moodScore!.toDouble();
          moodCount++;
        }
      }
      
      final avgFatigue = fatigueCount > 0 ? totalFatigue / fatigueCount : 0.0;
      final avgStress = stressCount > 0 ? totalStress / stressCount : 0.0;
      final avgMood = moodCount > 0 ? totalMood / moodCount : 0.0;
      
      log('Rata-rata: Fatigue=${avgFatigue.toStringAsFixed(1)}, Stress=${avgStress.toStringAsFixed(1)}, Mood=${avgMood.toStringAsFixed(1)}', 1);
      log('Jumlah data: Fatigue=$fatigueCount, Stress=$stressCount, Mood=$moodCount', 1);
      
      // Pegawai fatigue tinggi (hari ini)
      log('Mencari pegawai fatigue tinggi untuk tanggal $today', 1);
      
      final highRiskResult = await supabase
          .from('employee_wellbeing_logs')
          .select('''
            *,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .eq('log_date', today)
          .gte('fatigue_score', 70)
          .order('fatigue_score', ascending: false)
          .limit(5);
      
      log('Pegawai fatigue tinggi: ${highRiskResult.length}', 1);
      
      final highRiskEmployees = highRiskResult.map<HighRiskEmployee>((row) {
        final profile = row['profiles'] as Map<String, dynamic>;
        double fatigueScore = 0.0;
        if (row['fatigue_score'] != null) {
          fatigueScore = (row['fatigue_score'] as num).toDouble();
        }
        log('  - ${profile['full_name']}: Fatigue $fatigueScore', 2);
        return HighRiskEmployee(
          profileId: profile['id'].toString(),
          fullName: profile['full_name'] ?? '',
          avatarUrl: profile['avatar_url'],
          unitCode: profile['unit_code'],
          fatigueScore: fatigueScore,
          aiRecommendation: row['ai_recommendation'],
        );
      }).toList();
      
      // Pegawai butuh perhatian
      log('Mencari pegawai butuh perhatian untuk tanggal $today', 1);
      
      final attentionResult = await supabase
          .from('employee_wellbeing_logs')
          .select('''
            *,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .eq('log_date', today)
          .eq('requires_attention', true)
          .limit(5);
      
      log('Pegawai butuh perhatian: ${attentionResult.length}', 1);
      
      final requiresAttentionToday = attentionResult.map<AttentionRequiredEmployee>((row) {
        final profile = row['profiles'] as Map<String, dynamic>;
        double fatigueScore = 0.0;
        double stressScore = 0.0;
        if (row['fatigue_score'] != null) {
          fatigueScore = (row['fatigue_score'] as num).toDouble();
        }
        if (row['stress_score'] != null) {
          stressScore = (row['stress_score'] as num).toDouble();
        }
        log('  - ${profile['full_name']}: Fatigue=$fatigueScore, Stress=$stressScore', 2);
        return AttentionRequiredEmployee(
          profileId: profile['id'].toString(),
          fullName: profile['full_name'] ?? '',
          avatarUrl: profile['avatar_url'],
          unitCode: profile['unit_code'],
          fatigueScore: fatigueScore,
          stressScore: stressScore,
          aiRecommendation: row['ai_recommendation'],
        );
      }).toList();
      
      log('Selesai mengambil ringkasan wellbeing');
      
      return WellbeingSummary(
        averageFatigueScore: avgFatigue,
        averageStressScore: avgStress,
        averageMoodScore: avgMood,
        last7Days: last7Days,
        highRiskEmployees: highRiskEmployees,
        requiresAttentionToday: requiresAttentionToday,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan wellbeing', e, stackTrace);
      return WellbeingSummary(
        averageFatigueScore: 0.0,
        averageStressScore: 0.0,
        averageMoodScore: 0.0,
        last7Days: [],
        highRiskEmployees: [],
        requiresAttentionToday: [],
      );
    }
  }
  
  // Ambil wellbeing per profile
  Future<WellbeingLogModel?> getProfileWellbeing(String profileId) async {
    log('Mengambil wellbeing untuk profile $profileId');
    
    try {
      final result = await supabase
          .from('employee_wellbeing_logs')
          .select('*')
          .eq('profile_id', profileId)
          .eq('log_date', today)
          .maybeSingle();
      
      if (result != null) {
        log('Data ditemukan: fatigue=${result['fatigue_score']}', 1);
        return WellbeingLogModel.fromJson(result);
      }
      log('Tidak ada data wellbeing untuk profile ini', 1);
      return null;
    } catch (e) {
      logError('Gagal mengambil wellbeing profile $profileId', e);
      return null;
    }
  }
}