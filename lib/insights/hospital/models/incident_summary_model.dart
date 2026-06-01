// File: lib/insights/hospital/models/incident_summary_model.dart

class IncidentSummaryModel {
  final int totalIncidents;
  final int openIncidents;
  final int resolvedIncidents;
  final int criticalIncidents;
  final int highIncidents;
  final int mediumIncidents;
  final int lowIncidents;
  final double avgResponseTimeMinutes;

  IncidentSummaryModel({
    required this.totalIncidents,
    required this.openIncidents,
    required this.resolvedIncidents,
    required this.criticalIncidents,
    required this.highIncidents,
    required this.mediumIncidents,
    required this.lowIncidents,
    required this.avgResponseTimeMinutes,
  });

  factory IncidentSummaryModel.empty() {
    return IncidentSummaryModel(
      totalIncidents: 0,
      openIncidents: 0,
      resolvedIncidents: 0,
      criticalIncidents: 0,
      highIncidents: 0,
      mediumIncidents: 0,
      lowIncidents: 0,
      avgResponseTimeMinutes: 0.0,
    );
  }
}

class IncidentCategoryDistribution {
  final String categoryId;
  final String categoryName;
  final String? icon;
  final String? color;
  final int totalIncidents;

  IncidentCategoryDistribution({
    required this.categoryId,
    required this.categoryName,
    this.icon,
    this.color,
    required this.totalIncidents,
  });
}

class IncidentReporterStats {
  final String profileId;
  final String fullName;
  final int totalReports;
  final String? unitName;

  IncidentReporterStats({
    required this.profileId,
    required this.fullName,
    required this.totalReports,
    this.unitName,
  });
}

class IncidentRecentModel {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String status;
  final DateTime occurredAt;
  final String reporterName;
  final String? categoryName;
  final String? roomName;
  final String? actionTaken;

  IncidentRecentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.occurredAt,
    required this.reporterName,
    this.categoryName,
    this.roomName,
    this.actionTaken,
  });

  String get severityColor {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return '#EF4444';
      case 'HIGH':
        return '#F97316';
      case 'MEDIUM':
        return '#F59E0B';
      default:
        return '#10B981';
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'reported':
        return '#EF4444';
      case 'in_progress':
        return '#F59E0B';
      case 'resolved':
        return '#10B981';
      default:
        return '#6B7280';
    }
  }
}