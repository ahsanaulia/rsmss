// lib/features/roster/data/repositories/roster_repository.dart
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';
import '../../domain/repositories/i_roster_repository.dart';
import '../datasources/roster_remote_datasource.dart';
import '../models/shift_model.dart';

class RosterRepository implements IRosterRepository {
  final RosterRemoteDatasource _datasource;

  RosterRepository(this._datasource);

  @override
  Future<List<RosterEntity>> getRosters({
    DateTime? startDate,
    DateTime? endDate,
    String? profileId,
    String? shiftId,
    String? attendanceStatus,
    String? approvalStatus,
  }) async {
    return await _datasource.getRosters(
      startDate: startDate,
      endDate: endDate,
      profileId: profileId,
      shiftId: shiftId,
      attendanceStatus: attendanceStatus,
      approvalStatus: approvalStatus,
    );
  }

  @override
  Future<List<RosterEntity>> getRostersByProfile(String profileId, {DateTime? startDate, DateTime? endDate}) async {
    return await _datasource.getRostersByProfile(profileId, startDate: startDate, endDate: endDate);
  }

  @override
  Future<List<RosterEntity>> getRostersByDate(DateTime date) async {
    return await _datasource.getRostersByDate(date);
  }

  @override
  Future<RosterEntity?> getRosterById(String id) async {
    return await _datasource.getRosterById(id);
  }

  @override
  Future<void> createRoster(RosterEntity roster) async {
    await _datasource.createRoster(roster);
  }

  @override
  Future<void> updateRoster(RosterEntity roster) async {
    await _datasource.updateRoster(roster);
  }

  @override
  Future<void> deleteRoster(String id) async {
    await _datasource.deleteRoster(id);
  }

  @override
  Future<void> bulkCreateRosters(List<RosterEntity> rosters) async {
    await _datasource.bulkCreateRosters(rosters);
  }

  @override
  Future<void> bulkUpdateRosters(List<RosterEntity> rosters) async {
    for (final roster in rosters) {
      await _datasource.updateRoster(roster);
    }
  }

  @override
  Future<void> bulkDeleteRosters(List<String> ids) async {
    await _datasource.bulkDeleteRosters(ids);
  }

  // lib/features/roster/data/repositories/roster_repository.dart

@override
Future<List<ShiftEntity>> getShifts({bool onlyActive = true}) async {
  final shiftModels = await _datasource.getShifts(onlyActive: onlyActive);
  // ShiftModel sudah extends ShiftEntity, jadi bisa langsung return
  return shiftModels;
}

  @override
  Future<ShiftEntity?> getShiftById(String id) async {
    return await _datasource.getShiftById(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getEmployees({
    String? unitId,
    String? positionId,
    String? searchQuery,
  }) async {
    return await _datasource.getEmployees(
      unitId: unitId,
      positionId: positionId,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<bool> isShiftConflict(String profileId, DateTime date, String shiftId, {String? excludeRosterId}) async {
    return await _datasource.isShiftConflict(profileId, date, shiftId, excludeRosterId: excludeRosterId);
  }

  @override
  Future<Map<String, dynamic>> getEmployeeWorkload(String profileId, DateTime startDate, DateTime endDate) async {
    return await _datasource.getEmployeeWorkload(profileId, startDate, endDate);
  }

  @override
  Future<Map<String, dynamic>> getRosterStatistics(DateTime startDate, DateTime endDate) async {
    return await _datasource.getRosterStatistics(startDate, endDate);
  }

  @override
  Future<Map<String, dynamic>> getEmployeeRosterSummary(String profileId, DateTime startDate, DateTime endDate) async {
    final rosters = await _datasource.getRostersByProfile(profileId, startDate: startDate, endDate: endDate);
    
    int total = rosters.length;
    int present = rosters.where((r) => r.attendanceStatus.value == 'present').length;
    int absent = rosters.where((r) => r.attendanceStatus.value == 'absent').length;
    int late = rosters.where((r) => r.attendanceStatus.value == 'late').length;
    int leave = rosters.where((r) => r.attendanceStatus.value == 'leave').length;
    int dayOff = rosters.where((r) => r.isDayOff).length;
    int overtime = rosters.where((r) => r.overtimeMinutes > 0).length;

    return {
      'total_rosters': total,
      'present': present,
      'absent': absent,
      'late': late,
      'leave': leave,
      'day_off': dayOff,
      'overtime': overtime,
    };
  }
}