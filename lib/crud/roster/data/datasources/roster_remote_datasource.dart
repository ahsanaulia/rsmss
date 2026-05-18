// lib/features/roster/data/datasources/roster_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';
import '../models/roster_model.dart';

class RosterRemoteDatasource {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // ==================== ROSTER QUERIES ====================
  
  Future<List<RosterModel>> getRosters({
    DateTime? startDate,
    DateTime? endDate,
    String? profileId,
    String? shiftId,
    String? attendanceStatus,
    String? approvalStatus,
  }) async {
    try {
      var query = _supabase.from('employee_shift_rosters').select('''
        *,
        profile:profiles!fk_employee_shift_profile(full_name, employee_id),
        shift:ref_shifts!fk_employee_shift_shift(shift_name, shift_code, start_time, end_time),
        approved_by_profile:profiles!fk_employee_shift_approved_by(full_name),
        created_by_profile:profiles!fk_employee_shift_created_by(full_name),
        location_room:rooms!employee_shift_rosters_location_room_id_fkey(room_name)
      ''');

      if (startDate != null) {
        query = query.gte('roster_date', startDate.toIso8601String().split('T').first);
      }
      if (endDate != null) {
        query = query.lte('roster_date', endDate.toIso8601String().split('T').first);
      }
      if (profileId != null) {
        query = query.eq('profile_id', profileId);
      }
      if (shiftId != null) {
        query = query.eq('shift_id', shiftId);
      }
      if (attendanceStatus != null) {
        query = query.eq('attendance_status', attendanceStatus);
      }
      if (approvalStatus != null) {
        query = query.eq('approval_status', approvalStatus);
      }

      final data = await query.order('roster_date', ascending: true);
      
      return List<RosterModel>.from(
        data.map((e) => RosterModel.fromJson(e))
      );
    } catch (e) {
      print('Error getRosters: $e');
      rethrow;
    }
  }

  Future<List<RosterModel>> getRostersByProfile(String profileId, {DateTime? startDate, DateTime? endDate}) async {
    return getRosters(
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<RosterModel>> getRostersByDate(DateTime date) async {
    return getRosters(
      startDate: date,
      endDate: date,
    );
  }

  Future<RosterModel?> getRosterById(String id) async {
    try {
      final data = await _supabase.from('employee_shift_rosters').select('''
        *,
        profile:profiles!fk_employee_shift_profile(full_name, employee_id),
        shift:ref_shifts!fk_employee_shift_shift(shift_name, shift_code, start_time, end_time),
        approved_by_profile:profiles!fk_employee_shift_approved_by(full_name),
        created_by_profile:profiles!fk_employee_shift_created_by(full_name),
        location_room:rooms!employee_shift_rosters_location_room_id_fkey(room_name)
      ''').eq('id', id).maybeSingle();

      if (data == null) return null;
      return RosterModel.fromJson(data);
    } catch (e) {
      print('Error getRosterById: $e');
      rethrow;
    }
  }

  // ==================== ROSTER MUTATIONS ====================

  Future<void> createRoster(RosterEntity roster) async {
    try {
      final model = RosterModel(
        id: _uuid.v4(),
        profileId: roster.profileId,
        shiftId: roster.shiftId,
        rosterDate: roster.rosterDate,
        scheduledStart: roster.scheduledStart,
        scheduledEnd: roster.scheduledEnd,
        isDayOff: roster.isDayOff,
        isOvertimePlanned: roster.isOvertimePlanned,
        isEmergencyShift: roster.isEmergencyShift,
        isOnCall: roster.isOnCall,
        notes: roster.notes,
        locationName: roster.locationName,
        locationRoomId: roster.locationRoomId,
        requiredEquipment: roster.requiredEquipment,
        specialInstructions: roster.specialInstructions,
        qualificationRequired: roster.qualificationRequired,
        minScoreRequired: roster.minScoreRequired,
        createdBy: roster.createdBy,
        createdAt: DateTime.now(),
      );

      await _supabase.from('employee_shift_rosters').insert(model.toJson());
    } catch (e) {
      print('Error createRoster: $e');
      rethrow;
    }
  }

  Future<void> updateRoster(RosterEntity roster) async {
    try {
      final model = RosterModel(
        id: roster.id,
        profileId: roster.profileId,
        shiftId: roster.shiftId,
        rosterDate: roster.rosterDate,
        scheduledStart: roster.scheduledStart,
        scheduledEnd: roster.scheduledEnd,
        isDayOff: roster.isDayOff,
        isOvertimePlanned: roster.isOvertimePlanned,
        isEmergencyShift: roster.isEmergencyShift,
        isOnCall: roster.isOnCall,
        aiGenerated: roster.aiGenerated,
        aiConfidenceScore: roster.aiConfidenceScore,
        aiReason: roster.aiReason,
        predictedFatigueScore: roster.predictedFatigueScore,
        predictedWorkloadScore: roster.predictedWorkloadScore,
        predictedStressScore: roster.predictedStressScore,
        wellbeingRiskLevel: roster.wellbeingRiskLevel,
        approvalStatus: roster.approvalStatus,
        approvedBy: roster.approvedBy,
        approvedAt: roster.approvedAt,
        rejectionReason: roster.rejectionReason,
        actualCheckIn: roster.actualCheckIn,
        actualCheckOut: roster.actualCheckOut,
        attendanceStatus: roster.attendanceStatus,
        totalWorkMinutes: roster.totalWorkMinutes,
        overtimeMinutes: roster.overtimeMinutes,
        latenessMinutes: roster.latenessMinutes,
        earlyLeaveMinutes: roster.earlyLeaveMinutes,
        notes: roster.notes,
        locationName: roster.locationName,
        locationRoomId: roster.locationRoomId,
        requiredEquipment: roster.requiredEquipment,
        specialInstructions: roster.specialInstructions,
        leaveRequestId: roster.leaveRequestId,
        qualificationRequired: roster.qualificationRequired,
        minScoreRequired: roster.minScoreRequired,
        updatedAt: DateTime.now(),
      );

      await _supabase.from('employee_shift_rosters').update(model.toJson()).eq('id', roster.id);
    } catch (e) {
      print('Error updateRoster: $e');
      rethrow;
    }
  }

  Future<void> deleteRoster(String id) async {
    try {
      await _supabase.from('employee_shift_rosters').delete().eq('id', id);
    } catch (e) {
      print('Error deleteRoster: $e');
      rethrow;
    }
  }

  Future<void> bulkCreateRosters(List<RosterEntity> rosters) async {
    try {
      final models = rosters.map((roster) => RosterModel(
        id: _uuid.v4(),
        profileId: roster.profileId,
        shiftId: roster.shiftId,
        rosterDate: roster.rosterDate,
        scheduledStart: roster.scheduledStart,
        scheduledEnd: roster.scheduledEnd,
        isDayOff: roster.isDayOff,
        isOvertimePlanned: roster.isOvertimePlanned,
        isEmergencyShift: roster.isEmergencyShift,
        isOnCall: roster.isOnCall,
        notes: roster.notes,
        locationName: roster.locationName,
        locationRoomId: roster.locationRoomId,
        requiredEquipment: roster.requiredEquipment,
        specialInstructions: roster.specialInstructions,
        createdBy: roster.createdBy,
        createdAt: DateTime.now(),
      ).toJson()).toList();

      await _supabase.from('employee_shift_rosters').insert(models);
    } catch (e) {
      print('Error bulkCreateRosters: $e');
      rethrow;
    }
  }

  Future<void> bulkDeleteRosters(List<String> ids) async {
    try {
      await _supabase.from('employee_shift_rosters').delete().inFilter('id', ids);
    } catch (e) {
      print('Error bulkDeleteRosters: $e');
      rethrow;
    }
  }

  // ==================== SHIFT QUERIES ====================

  // PERBAIKAN: return type menjadi List<ShiftEntity> (bukan ShiftModel)
  Future<List<ShiftEntity>> getShifts({bool onlyActive = true}) async {
    try {
      var query = _supabase.from('ref_shifts').select('*');
      if (onlyActive) {
        query = query.eq('is_active', true);
      }
      final data = await query.order('start_time', ascending: true);
      
      // Langsung return ShiftEntity menggunakan fromJson
      return List<ShiftEntity>.from(
        data.map((e) => ShiftEntity.fromJson(e))
      );
    } catch (e) {
      print('Error getShifts: $e');
      rethrow;
    }
  }

  // PERBAIKAN: return type menjadi ShiftEntity? (bukan ShiftModel)
  Future<ShiftEntity?> getShiftById(String id) async {
    try {
      final data = await _supabase.from('ref_shifts').select('*').eq('id', id).maybeSingle();
      if (data == null) return null;
      return ShiftEntity.fromJson(data);
    } catch (e) {
      print('Error getShiftById: $e');
      rethrow;
    }
  }

  // ==================== EMPLOYEE QUERIES ====================

  Future<List<Map<String, dynamic>>> getEmployees({
    String? unitId,
    String? positionId,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase.from('profiles').select('''
        id, 
        full_name, 
        employee_id,
        unit_id,
        position_id,
        unit:employee_units!unit_id(unit_name),
        position:ref_positions!position_id(position_name)
      ''').eq('role', 'operation');

      if (unitId != null) {
        query = query.eq('unit_id', unitId);
      }
      if (positionId != null) {
        query = query.eq('position_id', positionId);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchQuery%,employee_id.ilike.%$searchQuery%');
      }

      final data = await query.order('full_name', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error getEmployees: $e');
      rethrow;
    }
  }

  // ==================== VALIDATION ====================

  Future<bool> isShiftConflict(String profileId, DateTime date, String shiftId, {String? excludeRosterId}) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      var query = _supabase.from('employee_shift_rosters')
          .select('id')
          .eq('profile_id', profileId)
          .eq('roster_date', dateStr)
          .eq('is_day_off', false);

      if (excludeRosterId != null) {
        query = query.neq('id', excludeRosterId);
      }

      final data = await query;
      return data.isNotEmpty;
    } catch (e) {
      print('Error isShiftConflict: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getEmployeeWorkload(String profileId, DateTime startDate, DateTime endDate) async {
    try {
      final rosters = await getRostersByProfile(profileId, startDate: startDate, endDate: endDate);
      
      int totalHours = 0;
      int overtimeHours = 0;
      int lateCount = 0;
      int absentCount = 0;

      for (final roster in rosters) {
        if (roster.shiftStartTime != null && roster.shiftEndTime != null && !roster.isDayOff) {
          int startHour = roster.shiftStartTime!.hour;
          int endHour = roster.shiftEndTime!.hour;
          if (endHour < startHour) endHour += 24;
          totalHours += (endHour - startHour);
        }
        overtimeHours += roster.overtimeMinutes ~/ 60;
        if (roster.attendanceStatus.value == 'late') lateCount++;
        if (roster.attendanceStatus.value == 'absent') absentCount++;
      }

      return {
        'total_hours': totalHours,
        'overtime_hours': overtimeHours,
        'late_count': lateCount,
        'absent_count': absentCount,
        'total_rosters': rosters.length,
      };
    } catch (e) {
      print('Error getEmployeeWorkload: $e');
      return {};
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getRosterStatistics(DateTime startDate, DateTime endDate) async {
    try {
      final rosters = await getRosters(startDate: startDate, endDate: endDate);
      
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
        'attendance_rate': total > 0 ? (present / total * 100).toStringAsFixed(1) : '0',
      };
    } catch (e) {
      print('Error getRosterStatistics: $e');
      return {};
    }
  }
}