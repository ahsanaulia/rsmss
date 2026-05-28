// lib/insights/profiles/models/profile_wellbeing_model.dart
class WellbeingLogModel {
  final String id;
  final String profileId;
  final DateTime logDate;
  final double? fatigueScore;
  final double? stressScore;
  final double? moodScore;
  final double? energyScore;
  final double? sleepHours;
  final String? selfReport;
  final double? aiBurnoutRisk;
  final String? aiRecommendation;
  final bool requiresAttention;

  WellbeingLogModel({
    required this.id,
    required this.profileId,
    required this.logDate,
    this.fatigueScore,
    this.stressScore,
    this.moodScore,
    this.energyScore,
    this.sleepHours,
    this.selfReport,
    this.aiBurnoutRisk,
    this.aiRecommendation,
    required this.requiresAttention,
  });

  factory WellbeingLogModel.fromJson(Map<String, dynamic> json) {
    return WellbeingLogModel(
      id: json['id'].toString(),
      profileId: json['profile_id'].toString(),
      logDate: json['log_date'] != null
          ? DateTime.parse(json['log_date'])
          : DateTime.now(),
      fatigueScore: json['fatigue_score']?.toDouble(),
      stressScore: json['stress_score']?.toDouble(),
      moodScore: json['mood_score']?.toDouble(),
      energyScore: json['energy_score']?.toDouble(),
      sleepHours: json['sleep_hours']?.toDouble(),
      selfReport: json['self_report'],
      aiBurnoutRisk: json['ai_burnout_risk']?.toDouble(),
      aiRecommendation: json['ai_recommendation'],
      requiresAttention: json['requires_attention'] ?? false,
    );
  }
}

class WellbeingSummary {
  final double averageFatigueScore;
  final double averageStressScore;
  final double averageMoodScore;
  final List<WellbeingLogModel> last7Days;
  final List<HighRiskEmployee> highRiskEmployees;
  final List<AttentionRequiredEmployee> requiresAttentionToday;

  WellbeingSummary({
    required this.averageFatigueScore,
    required this.averageStressScore,
    required this.averageMoodScore,
    required this.last7Days,
    required this.highRiskEmployees,
    required this.requiresAttentionToday,
  });
}

class HighRiskEmployee {
  final String profileId;
  final String fullName;
  final String? avatarUrl;
  final String? unitCode;
  final double fatigueScore;
  final String? aiRecommendation;

  HighRiskEmployee({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
    this.unitCode,
    required this.fatigueScore,
    this.aiRecommendation,
  });
}

class AttentionRequiredEmployee {
  final String profileId;
  final String fullName;
  final String? avatarUrl;
  final String? unitCode;
  final double fatigueScore;
  final double stressScore;
  final String? aiRecommendation;

  AttentionRequiredEmployee({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
    this.unitCode,
    required this.fatigueScore,
    required this.stressScore,
    this.aiRecommendation,
  });
}