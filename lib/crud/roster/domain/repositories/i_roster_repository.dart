// lib/features/roster/domain/repositories/i_roster_repository.dart
import '../entities/roster_entity.dart';
import '../entities/shift_entity.dart';

abstract class IRosterRepository {
  // Roster operations
  Future<List<RosterEntity>> getRosters({
    DateTime? startDate,
    DateTime? endDate,
    String? profileId,
    String? shiftId,
    String? attendanceStatus,
    String? approvalStatus,
  });
  
  Future<List<RosterEntity>> getRostersByProfile(String profileId, {DateTime? startDate, DateTime? endDate});
  
  Future<List<RosterEntity>> getRostersByDate(DateTime date);
  
  Future<RosterEntity?> getRosterById(String id);
  
  Future<void> createRoster(RosterEntity roster);
  
  Future<void> updateRoster(RosterEntity roster);
  
  Future<void> deleteRoster(String id);
  
  Future<void> bulkCreateRosters(List<RosterEntity> rosters);
  
  Future<void> bulkUpdateRosters(List<RosterEntity> rosters);
  
  Future<void> bulkDeleteRosters(List<String> ids);
  
  // Shift operations
  Future<List<ShiftEntity>> getShifts({bool onlyActive = true});
  
  Future<ShiftEntity?> getShiftById(String id);
  
  // Employee operations (for dropdown)
  Future<List<Map<String, dynamic>>> getEmployees({
    String? unitId,
    String? positionId,
    String? searchQuery,
  });
  
  // Validation
  Future<bool> isShiftConflict(String profileId, DateTime date, String shiftId, {String? excludeRosterId});
  
  Future<Map<String, dynamic>> getEmployeeWorkload(String profileId, DateTime startDate, DateTime endDate);
  
  // Statistics
  Future<Map<String, dynamic>> getRosterStatistics(DateTime startDate, DateTime endDate);
  
  Future<Map<String, dynamic>> getEmployeeRosterSummary(String profileId, DateTime startDate, DateTime endDate);
}