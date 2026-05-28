// lib/insights/profiles/services/employee_detail_service.dart

import 'base_service.dart';
import '../models/employee_detail_model.dart';

class EmployeeDetailService extends BaseService {
  
  // Ambil semua data detail pegawai
  Future<EmployeeDetail?> getEmployeeDetail(String profileId) async {
    log('Mengambil detail pegawai: $profileId');
    
    try {
      final profile = await _getProfileData(profileId);
      if (profile == null) return null;
      
      final kpi = await _getKpiData(profileId);
      final wellbeing = await _getWellbeingData(profileId);
      final score = await _getScoreData(profileId);
      final qualifications = await _getQualificationData(profileId);
      final activities = await _getActivityData(profileId);
      
      return EmployeeDetail(
        profile: profile,
        kpi: kpi,
        wellbeing: wellbeing,
        score: score,
        qualifications: qualifications,
        activities: activities,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil detail pegawai', e, stackTrace);
      return null;
    }
  }
  
  // MARK: - Private Methods (mudah ditambah nanti)
  
  Future<EmployeeProfileData?> _getProfileData(String profileId) async {
    final result = await supabase
        .from('profiles')
        .select('''
          id, full_name, employee_id, avatar_url, gender, phone,
          current_situation, join_date, join_year,
          unit_code,
          ref_positions!left(position_name)
        ''')
        .eq('id', profileId)
        .maybeSingle();
    
    if (result == null) return null;
    
    return EmployeeProfileData(
      id: result['id'].toString(),
      fullName: result['full_name'] ?? '',
      employeeId: result['employee_id'],
      avatarUrl: result['avatar_url'],
      positionName: result['ref_positions'] != null 
          ? result['ref_positions']['position_name'] 
          : null,
      unitCode: result['unit_code'],
      unitName: result['unit_code'],
      gender: result['gender'],
      phone: result['phone'],
      currentSituation: result['current_situation'],
      joinDate: result['join_date'] != null ? DateTime.parse(result['join_date']) : null,
      joinYear: result['join_year'],
    );
  }
  
  Future<EmployeeKpiData> _getKpiData(String profileId) async {
    // Fatigue hari ini
    final fatigueResult = await supabase
        .from('employee_wellbeing_logs')
        .select('fatigue_score')
        .eq('profile_id', profileId)
        .eq('log_date', today)
        .maybeSingle();
    
    final fatigueScore = fatigueResult != null 
        ? (fatigueResult['fatigue_score'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    
    // Attendance rate bulan ini
    final monthStart = firstDayOfMonth;
    final attendanceResult = await supabase
        .from('attendance')
        .select('id')
        .eq('profile_id', profileId)
        .gte('check_in', monthStart);
    
    final workingDays = DateTime.now().day;
    final attendanceRate = workingDays > 0 
        ? (attendanceResult.length / workingDays) * 100 
        : 0.0;
    
    // Task completion
    final tasksResult = await supabase
        .from('tasks')
        .select('status')
        .eq('assignee_id', profileId);
    
    final tasksCompleted = tasksResult.where((t) => t['status'] == 'done').length;
    final tasksTotal = tasksResult.length;
    
    // Score
    final scoreResult = await supabase
        .from('employee_score_summary')
        .select('total_percentage')
        .eq('profile_id', profileId)
        .eq('period_start', today)
        .maybeSingle();
    
    final scorePercentage = scoreResult != null 
        ? (scoreResult['total_percentage'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    
    String scoreLabel = 'Perlu Perhatian';
    if (scorePercentage >= 70) scoreLabel = 'Excellent';
    else if (scorePercentage >= 50) scoreLabel = 'Baik';
    else if (scorePercentage >= 30) scoreLabel = 'Cukup';
    
    return EmployeeKpiData(
      fatigueScore: fatigueScore,
      attendanceRate: attendanceRate,
      tasksCompleted: tasksCompleted,
      tasksTotal: tasksTotal,
      scorePercentage: scorePercentage,
      scoreLabel: scoreLabel,
    );
  }
  
  Future<EmployeeWellbeingData> _getWellbeingData(String profileId) async {
    final sevenDaysAgoDate = sevenDaysAgo;
    
    final result = await supabase
        .from('employee_wellbeing_logs')
        .select('log_date, fatigue_score, stress_score, mood_score')
        .eq('profile_id', profileId)
        .gte('log_date', sevenDaysAgoDate)
        .lte('log_date', today)
        .order('log_date', ascending: true);
    
    final history = <WellbeingHistoryItem>[];
    double totalFatigue = 0.0;
    double totalStress = 0.0;
    double totalMood = 0.0;
    int fatigueCount = 0;
    int stressCount = 0;
    int moodCount = 0;
    
    for (final row in result) {
      final date = DateTime.parse(row['log_date']);
      
      // 🔥 PERBAIKAN: Konversi num ke double dengan aman
      double? fatigue;
      if (row['fatigue_score'] != null) {
        fatigue = (row['fatigue_score'] as num).toDouble();
        totalFatigue += fatigue;
        fatigueCount++;
      }
      
      double? stress;
      if (row['stress_score'] != null) {
        stress = (row['stress_score'] as num).toDouble();
        totalStress += stress;
        stressCount++;
      }
      
      double? mood;
      if (row['mood_score'] != null) {
        mood = (row['mood_score'] as num).toDouble();
        totalMood += mood;
        moodCount++;
      }
      
      history.add(WellbeingHistoryItem(
        date: date,
        fatigue: fatigue,
        stress: stress,
        mood: mood,
      ));
    }
    
    return EmployeeWellbeingData(
      history: history,
      averageFatigue: fatigueCount > 0 ? totalFatigue / fatigueCount : 0.0,
      averageStress: stressCount > 0 ? totalStress / stressCount : 0.0,
      averageMood: moodCount > 0 ? totalMood / moodCount : 0.0,
    );
  }
  
  Future<EmployeeScoreData> _getScoreData(String profileId) async {
    final result = await supabase
        .from('employee_score_summary')
        .select('*')
        .eq('profile_id', profileId)
        .eq('period_start', today)
        .maybeSingle();
    
    if (result == null) {
      return EmployeeScoreData(
        totalPercentage: 0.0,
        totalScore: 0.0,
        totalMaxScore: 0.0,
        categories: [],
      );
    }
    
    final scoringResult = await supabase
        .from('employee_scoring')
        .select('*, scoring_categories!inner(*)')
        .eq('profile_id', profileId)
        .eq('period_start', today);
    
    final categories = <CategoryScoreItem>[];
    for (final row in scoringResult) {
      final category = row['scoring_categories'] as Map<String, dynamic>;
      
      // 🔥 PERBAIKAN: Konversi num ke double
      final scoreValue = (row['score'] as num).toDouble();
      final maxScoreValue = (row['max_score'] as num).toDouble();
      final percentageValue = maxScoreValue > 0 ? (scoreValue / maxScoreValue) * 100 : 0.0;
      
      categories.add(CategoryScoreItem(
        name: category['category_name'] ?? 'Unknown',
        score: scoreValue,
        maxScore: maxScoreValue,
        percentage: percentageValue,
        notes: row['notes'],
      ));
    }
    
    return EmployeeScoreData(
      totalPercentage: (result['total_percentage'] as num?)?.toDouble() ?? 0.0,
      totalScore: (result['total_score'] as num?)?.toDouble() ?? 0.0,
      totalMaxScore: (result['total_max_score'] as num?)?.toDouble() ?? 0.0,
      categories: categories,
    );
  }
  
  Future<EmployeeQualificationData> _getQualificationData(String profileId) async {
    final result = await supabase
        .from('employee_qualification_assignments')
        .select('''
          *,
          employee_qualifications!inner(*)
        ''')
        .eq('profile_id', profileId)
        .eq('is_active', true);
    
    final qualifications = <QualificationItem>[];
    for (final row in result) {
      final qual = row['employee_qualifications'] as Map<String, dynamic>;
      
      // 🔥 PERBAIKAN: Konversi score ke double dengan aman
      double? scoreValue;
      if (row['score'] != null) {
        scoreValue = (row['score'] as num).toDouble();
      }
      
      qualifications.add(QualificationItem(
        name: qual['qualification_name'] ?? '',
        category: qual['category'],
        acquiredDate: row['acquired_date'] != null ? DateTime.parse(row['acquired_date']) : null,
        expiryDate: row['expiry_date'] != null ? DateTime.parse(row['expiry_date']) : null,
        score: scoreValue,
        isActive: row['is_active'] ?? true,
      ));
    }
    
    return EmployeeQualificationData(qualifications: qualifications);
  }
  
  Future<EmployeeActivityData> _getActivityData(String profileId) async {
    // Tasks terbaru
    final tasksResult = await supabase
        .from('tasks')
        .select('id, object_name, status, created_at')
        .eq('assignee_id', profileId)
        .order('created_at', ascending: false)
        .limit(5);
    
    final recentTasks = tasksResult.map((row) => ActivityItem(
      id: row['id'].toString(),
      title: row['object_name'] ?? '',
      status: row['status'] ?? 'pending',
      createdAt: DateTime.parse(row['created_at']),
      type: 'task',
    )).toList();
    
    // Duty notes terbaru
    final dutyResult = await supabase
        .from('duty_notes')
        .select('id, note_text, created_at')
        .eq('profile_id', profileId)
        .order('created_at', ascending: false)
        .limit(5);
    
    final recentDutyNotes = dutyResult.map((row) => ActivityItem(
      id: row['id'].toString(),
      title: row['note_text'] ?? '',
      status: 'recorded',
      createdAt: DateTime.parse(row['created_at']),
      type: 'duty_note',
    )).toList();
    
    // Incidents terbaru
    final incidentResult = await supabase
        .from('incidents')
        .select('id, title, status, created_at')
        .eq('reported_by', profileId)
        .order('created_at', ascending: false)
        .limit(5);
    
    final recentIncidents = incidentResult.map((row) => ActivityItem(
      id: row['id'].toString(),
      title: row['title'] ?? '',
      status: row['status'] ?? 'reported',
      createdAt: DateTime.parse(row['created_at']),
      type: 'incident',
    )).toList();
    
    return EmployeeActivityData(
      recentTasks: recentTasks,
      recentDutyNotes: recentDutyNotes,
      recentIncidents: recentIncidents,
    );
  }
}