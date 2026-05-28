// lib/insights/profiles/models/profile_scoring_model.dart
class ScoringCategoryModel {
  final String id;
  final String categoryCode;
  final String categoryName;
  final double weight;
  final bool isActive;

  ScoringCategoryModel({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    required this.weight,
    required this.isActive,
  });

  factory ScoringCategoryModel.fromJson(Map<String, dynamic> json) {
    return ScoringCategoryModel(
      id: json['id'].toString(),
      categoryCode: json['category_code'] ?? '',
      categoryName: json['category_name'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class EmployeeScoringModel {
  final String id;
  final String profileId;
  final String scoringCategoryId;
  final double score;
  final double maxScore;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? notes;
  final DateTime? calculatedAt;
  final String? calculatedBy;

  EmployeeScoringModel({
    required this.id,
    required this.profileId,
    required this.scoringCategoryId,
    required this.score,
    required this.maxScore,
    required this.periodStart,
    required this.periodEnd,
    this.notes,
    this.calculatedAt,
    this.calculatedBy,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;

  factory EmployeeScoringModel.fromJson(Map<String, dynamic> json) {
    return EmployeeScoringModel(
      id: json['id'].toString(),
      profileId: json['profile_id'].toString(),
      scoringCategoryId: json['scoring_category_id'].toString(),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 100,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'])
          : DateTime.now(),
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'])
          : DateTime.now(),
      notes: json['notes'],
      calculatedAt: json['calculated_at'] != null
          ? DateTime.parse(json['calculated_at'])
          : null,
      calculatedBy: json['calculated_by']?.toString(),
    );
  }
}

class ScoreSummary {
  final String profileId;
  final String fullName;
  final String? employeeId;
  final String? unitCode;
  final double totalPercentage;
  final double totalScore;
  final double totalMaxScore;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<CategoryScore> categoryScores;

  ScoreSummary({
    required this.profileId,
    required this.fullName,
    this.employeeId,
    this.unitCode,
    required this.totalPercentage,
    required this.totalScore,
    required this.totalMaxScore,
    required this.periodStart,
    required this.periodEnd,
    required this.categoryScores,
  });
}

class CategoryScore {
  final String categoryId;
  final String categoryName;
  final double score;
  final double maxScore;
  final double percentage;
  final String? notes;

  CategoryScore({
    required this.categoryId,
    required this.categoryName,
    required this.score,
    required this.maxScore,
    required this.percentage,
    this.notes,
  });
}