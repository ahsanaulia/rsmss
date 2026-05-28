// lib/insights/profiles/models/employee_detail_model.dart

// import 'package:equatable/equatable.dart';

// ==================== DATA CLASS UNTUK POPUP ====================
// Semua data dikelompokkan dalam class terpisah agar mudah ditambah nanti

class EmployeeProfileData {
  final String id;
  final String fullName;
  final String? employeeId;
  final String? avatarUrl;
  final String? positionName;
  final String? unitCode;
  final String? unitName;
  final String? gender;
  final String? phone;
  final String? email;
  final String? currentSituation;
  final DateTime? joinDate;
  final int? joinYear;

  EmployeeProfileData({
    required this.id,
    required this.fullName,
    this.employeeId,
    this.avatarUrl,
    this.positionName,
    this.unitCode,
    this.unitName,
    this.gender,
    this.phone,
    this.email,
    this.currentSituation,
    this.joinDate,
    this.joinYear,
  });
}

class EmployeeKpiData {
  final double fatigueScore;
  final double attendanceRate;
  final int tasksCompleted;
  final int tasksTotal;
  final double scorePercentage;
  final String scoreLabel;

  EmployeeKpiData({
    required this.fatigueScore,
    required this.attendanceRate,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.scorePercentage,
    required this.scoreLabel,
  });

  int get tasksRemaining => tasksTotal - tasksCompleted;
  double get attendancePercent => attendanceRate;
}

class EmployeeWellbeingData {
  final List<WellbeingHistoryItem> history;
  final double averageFatigue;
  final double averageStress;
  final double averageMood;

  EmployeeWellbeingData({
    required this.history,
    required this.averageFatigue,
    required this.averageStress,
    required this.averageMood,
  });
}

class WellbeingHistoryItem {
  final DateTime date;
  final double? fatigue;
  final double? stress;
  final double? mood;

  WellbeingHistoryItem({
    required this.date,
    this.fatigue,
    this.stress,
    this.mood,
  });
}

class EmployeeScoreData {
  final double totalPercentage;
  final double totalScore;
  final double totalMaxScore;
  final List<CategoryScoreItem> categories;

  EmployeeScoreData({
    required this.totalPercentage,
    required this.totalScore,
    required this.totalMaxScore,
    required this.categories,
  });
}

class CategoryScoreItem {
  final String name;
  final double score;
  final double maxScore;
  final double percentage;
  final String? notes;

  CategoryScoreItem({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.percentage,
    this.notes,
  });
}

class EmployeeQualificationData {
  final List<QualificationItem> qualifications;

  EmployeeQualificationData({
    required this.qualifications,
  });
}

class QualificationItem {
  final String name;
  final String? category;
  final DateTime? acquiredDate;
  final DateTime? expiryDate;
  final double? score;
  final bool isActive;

  QualificationItem({
    required this.name,
    this.category,
    this.acquiredDate,
    this.expiryDate,
    this.score,
    required this.isActive,
  });

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft <= 30 && daysLeft > 0;
  }
}

class EmployeeActivityData {
  final List<ActivityItem> recentTasks;
  final List<ActivityItem> recentDutyNotes;
  final List<ActivityItem> recentIncidents;

  EmployeeActivityData({
    required this.recentTasks,
    required this.recentDutyNotes,
    required this.recentIncidents,
  });
}

class ActivityItem {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;
  final String type; // 'task', 'duty_note', 'incident'

  ActivityItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    required this.type,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

// 🔥 MODEL UTAMA UNTUK DETAIL PEGAWAI
class EmployeeDetail {
  final EmployeeProfileData profile;
  final EmployeeKpiData kpi;
  final EmployeeWellbeingData wellbeing;
  final EmployeeScoreData score;
  final EmployeeQualificationData qualifications;
  final EmployeeActivityData activities;

  EmployeeDetail({
    required this.profile,
    required this.kpi,
    required this.wellbeing,
    required this.score,
    required this.qualifications,
    required this.activities,
  });
}