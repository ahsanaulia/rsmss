// lib/insights/profiles/services/profile_scoring_service.dart

import 'base_service.dart';
import '../models/models.dart';

class ProfileScoringService extends BaseService {
  
  // Ambil semua kategori scoring
  Future<List<ScoringCategoryModel>> getScoringCategories() async {
    log('Mengambil kategori scoring...');
    
    try {
      final result = await supabase
          .from('scoring_categories')
          .select('*')
          .eq('is_active', true);
      
      log('Ditemukan ${result.length} kategori', 1);
      
      for (final cat in result) {
        log('  - ${cat['category_code']}: ${cat['category_name']}', 2);
      }
      
      return result.map<ScoringCategoryModel>((json) {
        return ScoringCategoryModel.fromJson(json);
      }).toList();
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil kategori scoring', e, stackTrace);
      return [];
    }
  }
  
  // Ambil periode tersedia (bulan/tahun)
  Future<Map<String, dynamic>> getAvailablePeriods() async {
    log('Mengambil periode yang tersedia...');
    
    try {
      // Ambil periode terbaru dari employee_scoring
      final result = await supabase
          .from('employee_scoring')
          .select('period_start, period_end')
          .order('period_start', ascending: false)
          .limit(1);
      
      if (result.isEmpty) {
        log('Tidak ada data scoring', 1);
        return {
          'period_start': null,
          'period_end': null,
          'is_monthly': false,
          'is_yearly': false,
        };
      }
      
      final periodStart = result[0]['period_start'];
      final periodEnd = result[0]['period_end'];
      
      // Cek apakah periode bulanan atau tahunan
      final startDate = DateTime.parse(periodStart);
      final endDate = DateTime.parse(periodEnd);
      final isMonthly = startDate.month == endDate.month && startDate.year == endDate.year;
      final isYearly = startDate.year == endDate.year && startDate.month == 1 && endDate.month == 12;
      
      log('Periode tersedia: $periodStart s/d $periodEnd', 1);
      log('  - Bulanan: $isMonthly', 2);
      log('  - Tahunan: $isYearly', 2);
      
      return {
        'period_start': periodStart,
        'period_end': periodEnd,
        'is_monthly': isMonthly,
        'is_yearly': isYearly,
      };
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil periode', e, stackTrace);
      return {
        'period_start': null,
        'period_end': null,
        'is_monthly': false,
        'is_yearly': false,
      };
    }
  }
  
  // Ambil semua ringkasan skor (data terbaru yang tersedia)
  Future<List<ScoreSummary>> getAllScoreSummaries() async {
    log('Mengambil semua ringkasan skor...');
    
    try {
      final categories = await getScoringCategories();
      
      // 🔥 Ambil periode terbaru yang tersedia
      final periodInfo = await getAvailablePeriods();
      final periodDate = periodInfo['period_start'];
      
      if (periodDate == null) {
        log('Tidak ada data scoring sama sekali', 1);
        return [];
      }
      
      log('Periode: $periodDate', 1);
      
      final summaryResult = await supabase
          .from('employee_score_summary')
          .select('*')
          .eq('period_start', periodDate);
      
      log('Ditemukan ${summaryResult.length} summary', 1);
      
      if (summaryResult.isEmpty) {
        log('Tidak ada data summary untuk periode $periodDate', 1);
        return [];
      }
      
      final scoringResult = await supabase
          .from('employee_scoring')
          .select('*')
          .eq('period_start', periodDate);
      
      log('Ditemukan ${scoringResult.length} scoring detail', 1);
      
      final Map<String, List<EmployeeScoringModel>> scoringByProfile = {};
      for (final row in scoringResult) {
        final profileId = row['profile_id'].toString();
        final scoring = EmployeeScoringModel.fromJson(row);
        scoringByProfile.putIfAbsent(profileId, () => []);
        scoringByProfile[profileId]!.add(scoring);
      }
      
      final summaries = <ScoreSummary>[];
      
      for (final row in summaryResult) {
        final profileId = row['profile_id'].toString();
        final profileScorings = scoringByProfile[profileId] ?? [];
        
        log('Memproses profile: ${row['full_name']} (${row['employee_id']})', 2);
        
        final categoryScores = <CategoryScore>[];
        for (final category in categories) {
          EmployeeScoringModel? foundScoring;
          for (final s in profileScorings) {
            if (s.scoringCategoryId == category.id) {
              foundScoring = s;
              break;
            }
          }
          
          final scoring = foundScoring ?? EmployeeScoringModel(
            id: '',
            profileId: profileId,
            scoringCategoryId: category.id,
            score: 0.0,
            maxScore: 100.0,
            periodStart: DateTime.now(),
            periodEnd: DateTime.now(),
          );
          
          categoryScores.add(CategoryScore(
            categoryId: category.id,
            categoryName: category.categoryName,
            score: scoring.score,
            maxScore: scoring.maxScore,
            percentage: scoring.percentage,
            notes: scoring.notes,
          ));
          
          if (scoring.score > 0) {
            log('    ${category.categoryName}: ${scoring.score}/${scoring.maxScore} (${scoring.percentage.toStringAsFixed(1)}%)', 3);
          }
        }
        
        summaries.add(ScoreSummary(
          profileId: profileId,
          fullName: row['full_name'] ?? '',
          employeeId: row['employee_id'],
          unitCode: row['unit_code'],
          totalPercentage: (row['total_percentage'] as num?)?.toDouble() ?? 0.0,
          totalScore: (row['total_score'] as num?)?.toDouble() ?? 0.0,
          totalMaxScore: (row['total_max_score'] as num?)?.toDouble() ?? 0.0,
          periodStart: DateTime.parse(row['period_start']),
          periodEnd: DateTime.parse(row['period_end']),
          categoryScores: categoryScores,
        ));
      }
      
      summaries.sort((a, b) => b.totalPercentage.compareTo(a.totalPercentage));
      
      log('Selesai, total ${summaries.length} summary', 1);
      if (summaries.isNotEmpty) {
        log('🏆 Top performer: ${summaries.first.fullName} (${summaries.first.totalPercentage.toStringAsFixed(1)}%)', 1);
        log('📉 Bottom performer: ${summaries.last.fullName} (${summaries.last.totalPercentage.toStringAsFixed(1)}%)', 1);
      }
      
      return summaries;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan skor', e, stackTrace);
      return [];
    }
  }
  
  // Ambil ringkasan skor per profile (data terbaru)
  Future<ScoreSummary?> getProfileScoreSummary(String profileId) async {
    log('Mengambil ringkasan skor untuk profile $profileId');
    
    try {
      // 🔥 Ambil periode terbaru yang tersedia
      final periodInfo = await getAvailablePeriods();
      final periodDate = periodInfo['period_start'];
      
      if (periodDate == null) {
        log('Tidak ada data scoring', 1);
        return null;
      }
      
      final result = await supabase
          .from('employee_score_summary')
          .select('*')
          .eq('profile_id', profileId)
          .eq('period_start', periodDate)
          .maybeSingle();
      
      if (result == null) {
        log('Tidak ada ringkasan skor untuk profile $profileId pada periode $periodDate', 1);
        return null;
      }
      
      final categories = await getScoringCategories();
      
      final scoringResult = await supabase
          .from('employee_scoring')
          .select('*')
          .eq('profile_id', profileId)
          .eq('period_start', periodDate);
      
      final categoryScores = <CategoryScore>[];
      
      for (final category in categories) {
        Map<String, dynamic>? foundScoring;
        for (final s in scoringResult) {
          if (s['scoring_category_id'] == category.id) {
            foundScoring = s;
            break;
          }
        }
        
        final scoreValue = foundScoring != null 
            ? (foundScoring['score'] as num).toDouble() 
            : 0.0;
        final maxScoreValue = foundScoring != null 
            ? (foundScoring['max_score'] as num).toDouble() 
            : 100.0;
        final percentageValue = maxScoreValue > 0 
            ? (scoreValue / maxScoreValue) * 100 
            : 0.0;
        
        categoryScores.add(CategoryScore(
          categoryId: category.id,
          categoryName: category.categoryName,
          score: scoreValue,
          maxScore: maxScoreValue,
          percentage: percentageValue,
          notes: foundScoring?['notes'],
        ));
      }
      
      log('Ringkasan skor untuk ${result['full_name']}: ${result['total_percentage']}% (Periode: $periodDate)', 1);
      
      return ScoreSummary(
        profileId: profileId,
        fullName: result['full_name'] ?? '',
        employeeId: result['employee_id'],
        unitCode: result['unit_code'],
        totalPercentage: (result['total_percentage'] as num?)?.toDouble() ?? 0.0,
        totalScore: (result['total_score'] as num?)?.toDouble() ?? 0.0,
        totalMaxScore: (result['total_max_score'] as num?)?.toDouble() ?? 0.0,
        periodStart: DateTime.parse(result['period_start']),
        periodEnd: DateTime.parse(result['period_end']),
        categoryScores: categoryScores,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan skor profile $profileId', e, stackTrace);
      return null;
    }
  }
  
  // Ambil top 5 performers
  Future<List<ScoreSummary>> getTopPerformers() async {
    log('Mengambil top 5 performers...');
    final summaries = await getAllScoreSummaries();
    final top5 = summaries.take(5).toList();
    
    for (int i = 0; i < top5.length; i++) {
      log('  ${i+1}. ${top5[i].fullName} - ${top5[i].totalPercentage.toStringAsFixed(1)}%', 2);
    }
    
    return top5;
  }
  
  // Ambil bottom 5 performers
  Future<List<ScoreSummary>> getBottomPerformers() async {
    log('Mengambil bottom 5 performers...');
    final summaries = await getAllScoreSummaries();
    final bottom5 = summaries.reversed.take(5).toList();
    
    for (int i = 0; i < bottom5.length; i++) {
      log('  ${i+1}. ${bottom5[i].fullName} - ${bottom5[i].totalPercentage.toStringAsFixed(1)}%', 2);
    }
    
    return bottom5;
  }
}