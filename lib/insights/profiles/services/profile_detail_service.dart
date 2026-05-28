// lib/insights/profiles/services/profile_detail_service.dart

import 'base_service.dart';
import '../models/models.dart';
import 'profile_scoring_service.dart';
import 'profile_qualification_service.dart';
import 'profile_wellbeing_service.dart';
import 'profile_attendance_service.dart';

class ProfileDetailService extends BaseService {
  final ProfileScoringService _scoringService = ProfileScoringService();
  final ProfileQualificationService _qualificationService = ProfileQualificationService();
  final ProfileWellbeingService _wellbeingService = ProfileWellbeingService();
  final ProfileAttendanceService _attendanceService = ProfileAttendanceService();
  
  // Ambil detail lengkap profile
  Future<ProfileDetailModel?> getProfileDetail(String profileId) async {
    log('Mengambil detail profile: $profileId');
    
    try {
      // 1. Ambil data profile
      final profileResult = await supabase
          .from('profiles')
          .select('*')
          .eq('id', profileId)
          .maybeSingle();
      
      if (profileResult == null) {
        logError('Profile tidak ditemukan: $profileId');
        return null;
      }
      
      final profile = ProfileModel.fromJson(profileResult);
      log('Profile: ${profile.fullName} (${profile.employeeId})');
      
      // 2. Ambil data posisi
      PositionModel? position;
      final positionId = profile.positionId;
      if (positionId != null && positionId.isNotEmpty) {
        final positionResult = await supabase
            .from('ref_positions')
            .select('*')
            .eq('id', positionId)
            .maybeSingle();
        
        if (positionResult != null) {
          position = PositionModel.fromJson(positionResult);
          log('Posisi: ${position.positionName} (Level: ${position.level})');
        }
      }
      
      // 3. Ambil semua data terkait secara parallel
      final results = await Future.wait([
        _scoringService.getProfileScoreSummary(profileId),
        _wellbeingService.getProfileWellbeing(profileId),
        _attendanceService.getProfileAttendance(profileId),
        _qualificationService.getProfileQualifications(profileId),
        _getWellbeingHistory(profileId),
        _getRecentScoring(profileId),
      ]);
      
      final scoreSummary = results[0] as ScoreSummary?;
      final latestWellbeing = results[1] as WellbeingLogModel?;
      final todayAttendance = results[2] as AttendanceModel?;
      final qualifications = results[3] as List<QualificationWithAssignment>;
      final wellbeingHistory = results[4] as List<WellbeingLogModel>;
      final recentScoringList = results[5] as List<EmployeeScoringModel>;
      
      log('Detail profile lengkap berhasil diambil');
      
      return ProfileDetailModel(
        profile: profile,
        position: position,
        scoreSummary: scoreSummary,
        latestWellbeing: latestWellbeing,
        todayAttendance: todayAttendance,
        qualifications: qualifications,
        recentScoring: recentScoringList,
        wellbeingHistory: wellbeingHistory,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil detail profile $profileId', e, stackTrace);
      return null;
    }
  }
  
  // Ambil history wellbeing 14 hari
  Future<List<WellbeingLogModel>> _getWellbeingHistory(String profileId) async {
    try {
      final result = await supabase
          .from('employee_wellbeing_logs')
          .select('*')
          .eq('profile_id', profileId)
          .order('log_date', ascending: true)
          .limit(14);
      
      return result.map<WellbeingLogModel>((json) {
        return WellbeingLogModel.fromJson(json);
      }).toList();
      
    } catch (e) {
      logError('Gagal mengambil wellbeing history $profileId', e);
      return [];
    }
  }
  
  // Ambil recent scoring
  Future<List<EmployeeScoringModel>> _getRecentScoring(String profileId) async {
    try {
      final result = await supabase
          .from('employee_scoring')
          .select('*')
          .eq('profile_id', profileId)
          .order('period_start', ascending: false)
          .limit(10);
      
      return result.map<EmployeeScoringModel>((json) {
        return EmployeeScoringModel.fromJson(json);
      }).toList();
      
    } catch (e) {
      logError('Gagal mengambil recent scoring $profileId', e);
      return [];
    }
  }
}