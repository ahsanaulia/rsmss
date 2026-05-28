// lib/insights/profiles/models/profile_detail_model.dart

import 'profile_model.dart';
import 'position_model.dart';
import 'profile_scoring_model.dart';  // ScoreSummary, EmployeeScoringModel
import 'profile_wellbeing_model.dart'; // WellbeingLogModel
import 'profile_attendance_model.dart'; // AttendanceModel
import 'profile_qualification_model.dart'; // QualificationWithAssignment

class ProfileDetailModel {
  final ProfileModel profile;
  final PositionModel? position;
  final ScoreSummary? scoreSummary;
  final WellbeingLogModel? latestWellbeing;
  final AttendanceModel? todayAttendance;
  final List<QualificationWithAssignment> qualifications;
  final List<EmployeeScoringModel> recentScoring;
  final List<WellbeingLogModel> wellbeingHistory;

  ProfileDetailModel({
    required this.profile,
    this.position,
    this.scoreSummary,
    this.latestWellbeing,
    this.todayAttendance,
    required this.qualifications,
    required this.recentScoring,
    required this.wellbeingHistory,
  });

  double get fatigueScore => latestWellbeing?.fatigueScore ?? 0;
  double get stressScore => latestWellbeing?.stressScore ?? 0;
  bool get isPresentToday => todayAttendance?.isPresent ?? false;
  bool get requiresAttention => latestWellbeing?.requiresAttention ?? false;
}