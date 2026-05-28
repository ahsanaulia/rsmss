// lib/insights/profiles/services/services.dart

export 'base_service.dart';
export 'profile_service.dart';
export 'profile_summary_service.dart';
export 'profile_wellbeing_service.dart';
export 'profile_attendance_service.dart';
export 'profile_scoring_service.dart';
export 'profile_qualification_service.dart';
export 'profile_detail_service.dart';
export 'profile_shift_attendance_service.dart'; 
// 🔥 EXPORT CLASS DARI PROFILE_ATTENDANCE_SERVICE
export 'profile_attendance_service.dart' show 
    WorkingEmployeesResult, 
    WorkingEmployee;

    // Opsional - jika diperlukan
// export 'profile_qualification_service.dart' show
//     QualificationWithAssignment,
//     QualificationModel,
//     QualificationAssignmentModel;

// export 'profile_scoring_service.dart' show
//     ScoreSummary,
//     EmployeeScoringModel,
//     ScoringCategoryModel;