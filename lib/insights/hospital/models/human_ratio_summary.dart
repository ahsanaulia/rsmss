// File: lib/insights/hospital/models/human_ratio_summary.dart

class HumanRatioSummary {
  final int totalEmployees;
  final int totalPeople;
  final Map<String, int> categoryCounts;  // FLEKSIBEL: dinamis per kategori
  final double employeeVsPatientRatio;
  final double nurseVsPatientRatio;
  final double employeeVsNonEmployee;

  HumanRatioSummary({
    required this.totalEmployees,
    required this.totalPeople,
    required this.categoryCounts,
    required this.employeeVsPatientRatio,
    required this.nurseVsPatientRatio,
    required this.employeeVsNonEmployee,
  });

  factory HumanRatioSummary.empty() {
    return HumanRatioSummary(
      totalEmployees: 0,
      totalPeople: 0,
      categoryCounts: {},
      employeeVsPatientRatio: 0.0,
      nurseVsPatientRatio: 0.0,
      employeeVsNonEmployee: 0.0,
    );
  }
  
  // Helper untuk mendapatkan total pasien (jika ada kategori PASIEN)
  int get totalPatients {
    int count = 0;
    for (final entry in categoryCounts.entries) {
      if (entry.key.toUpperCase().contains('PASIEN') || 
          entry.key.toUpperCase().contains('PATIENT')) {
        count += entry.value;
      }
    }
    return count;
  }
  
  // Helper untuk mendapatkan total pengunjung
  int get totalVisitors {
    int count = 0;
    for (final entry in categoryCounts.entries) {
      if (entry.key.toUpperCase().contains('VISITOR') || 
          entry.key.toUpperCase().contains('PENGUNJUNG')) {
        count += entry.value;
      }
    }
    return count;
  }
  
  // Helper untuk mendapatkan total lainnya
  int get totalOthers {
    int count = 0;
    for (final entry in categoryCounts.entries) {
      if (!entry.key.toUpperCase().contains('PASIEN') && 
          !entry.key.toUpperCase().contains('PATIENT') &&
          !entry.key.toUpperCase().contains('VISITOR') && 
          !entry.key.toUpperCase().contains('PENGUNJUNG')) {
        count += entry.value;
      }
    }
    return count;
  }
}