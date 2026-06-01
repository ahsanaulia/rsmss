// File: lib/insights/hospital/models/incident_response_model.dart

class IncidentResponseStats {
  final int responded; // Sudah ada action_taken
  final int notResponded; // Belum ada action_taken
  final double responseRate;

  IncidentResponseStats({
    required this.responded,
    required this.notResponded,
    required this.responseRate,
  });

  factory IncidentResponseStats.empty() {
    return IncidentResponseStats(
      responded: 0,
      notResponded: 0,
      responseRate: 0.0,
    );
  }
}

class IncidentSeverityDistribution {
  final String severity;
  final int count;

  IncidentSeverityDistribution({
    required this.severity,
    required this.count,
  });
}