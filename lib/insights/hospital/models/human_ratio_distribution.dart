// File: lib/insights/hospital/models/human_ratio_distribution.dart

class PeopleCategoryDistribution {
  final String categoryId;
  final String categoryName;
  final int totalCount;
  final String? markerColor;

  PeopleCategoryDistribution({
    required this.categoryId,
    required this.categoryName,
    required this.totalCount,
    this.markerColor,
  });
}

class PositionDistribution {
  final String positionId;
  final String positionName;
  final int employeeCount;
  final int? level;

  PositionDistribution({
    required this.positionId,
    required this.positionName,
    required this.employeeCount,
    this.level,
  });
}

class EmployeePerUnit {
  final String unitId;
  final String unitName;
  final int employeeCount;

  EmployeePerUnit({
    required this.unitId,
    required this.unitName,
    required this.employeeCount,
  });
}