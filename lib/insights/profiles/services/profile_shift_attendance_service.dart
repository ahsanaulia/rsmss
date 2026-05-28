// lib/insights/profiles/services/profile_shift_attendance_service.dart

import 'base_service.dart';
import '../models/models.dart';

class ProfileShiftAttendanceService extends BaseService {
  
  // Ambil overview attendance per shift
  Future<AttendanceOverview> getAttendanceOverview() async {
    log('Mengambil overview attendance per shift...');
    
    try {
      final todayDate = today;
      
      // 1. Ambil semua shift aktif
      final shiftsResult = await supabase
          .from('ref_shifts')
          .select('*')
          .eq('is_active', true);
      
      final shifts = shiftsResult.map<ShiftModel>((json) {
        return ShiftModel.fromJson(json);
      }).toList();
      
      log('Ditemukan ${shifts.length} shift aktif', 1);
      
      // DEBUG: Tampilkan daftar shift
      for (final shift in shifts) {
        log('  - Shift: ${shift.shiftName} (${shift.startTime} - ${shift.endTime})', 2);
      }
      
      // 2. Ambil semua roster untuk hari ini
      final rostersResult = await supabase
          .from('employee_shift_rosters')
          .select('profile_id, shift_id, is_day_off')
          .eq('roster_date', todayDate);
      
      log('Total roster hari ini: ${rostersResult.length}', 1);
      
      // DEBUG: Tampilkan roster per shift
      final rosterByShift = <String, int>{};
      for (final roster in rostersResult) {
        final shiftId = roster['shift_id'].toString();
        rosterByShift[shiftId] = (rosterByShift[shiftId] ?? 0) + 1;
      }
      for (final entry in rosterByShift.entries) {
        final shift = shifts.firstWhere((s) => s.id == entry.key, orElse: () => shifts.first);
        log('  - Roster ${shift.shiftName}: ${entry.value} pegawai', 2);
      }
      
      // 3. Ambil semua attendance hari ini
      final attendanceResult = await supabase
          .from('attendance')
          .select('''
            id,
            profile_id,
            shift_id,
            check_in,
            check_out,
            status,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .gte('check_in', todayDate)
          .lte('check_in', '$todayDate 23:59:59');
      
      log('Total attendance hari ini: ${attendanceResult.length}', 1);
      
      // DEBUG: Tampilkan attendance per shift
      final attendanceByShiftDebug = <String, int>{};
      for (final att in attendanceResult) {
        final shiftId = att['shift_id']?.toString() ?? 'no_shift';
        attendanceByShiftDebug[shiftId] = (attendanceByShiftDebug[shiftId] ?? 0) + 1;
      }
      for (final entry in attendanceByShiftDebug.entries) {
        if (entry.key == 'no_shift') {
          log('  - Attendance tanpa shift: ${entry.value} pegawai', 2);
        } else {
          final shift = shifts.firstWhere((s) => s.id == entry.key, orElse: () => shifts.first);
          log('  - Attendance ${shift.shiftName}: ${entry.value} pegawai', 2);
        }
      }
      
      // 4. Ambil semua cuti hari ini
      final leaveResult = await supabase
          .from('employee_leave_requests')
          .select('profile_id')
          .lte('start_date', todayDate)
          .gte('end_date', todayDate)
          .eq('approval_status', 'approved');
      
      final leaveProfileIds = leaveResult.map((row) => row['profile_id'].toString()).toSet();
      log('Total cuti hari ini: ${leaveProfileIds.length}', 1);
      
      // 5. Ambil semua task aktif (belum selesai)
      final tasksResult = await supabase
          .from('tasks')
          .select('''
            id,
            assignee_id,
            object_name,
            status,
            created_at,
            profiles!tasks_assignee_fkey(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .not('status', 'eq', 'done');
      
      log('Total task aktif: ${tasksResult.length}', 1);
      
      // Buat map attendance per shift
      final Map<String, List<Map<String, dynamic>>> attendanceByShift = {};
      
      for (final row in attendanceResult) {
        final shiftId = row['shift_id']?.toString() ?? '';
        if (shiftId.isEmpty) continue;
        
        if (!attendanceByShift.containsKey(shiftId)) {
          attendanceByShift[shiftId] = [];
        }
        attendanceByShift[shiftId]!.add(row);
      }
      
      // Buat map roster per profile
      final Map<String, String?> rosterShiftMap = {};
      for (final roster in rostersResult) {
        final profileId = roster['profile_id'].toString();
        final isDayOff = roster['is_day_off'] ?? false;
        if (!isDayOff) {
          rosterShiftMap[profileId] = roster['shift_id']?.toString();
        }
      }
      
      // Buat map task per assignee
      final Map<String, List<Map<String, dynamic>>> tasksByProfile = {};
      for (final task in tasksResult) {
        final assigneeId = task['assignee_id'].toString();
        if (!tasksByProfile.containsKey(assigneeId)) {
          tasksByProfile[assigneeId] = [];
        }
        tasksByProfile[assigneeId]!.add(task);
      }
      
      // 6. Proses setiap shift untuk menghitung statistik
      final List<ShiftAttendanceSummary> shiftSummaries = [];
      
      for (final shift in shifts) {
        final shiftId = shift.id;
        final shiftName = shift.shiftName;
        
        // 🔥 PERBAIKAN: Cari profile yang dijadwalkan untuk shift ini
        final scheduledProfiles = rostersResult
            .where((r) => r['shift_id'] == shiftId)
            .map((r) => r['profile_id'].toString())
            .toSet();
        
        log('Shift $shiftName: ${scheduledProfiles.length} pegawai dijadwalkan', 2);
        
        // Cari attendance untuk shift ini
        final shiftAttendances = attendanceByShift[shiftId] ?? [];
        final hadirSet = shiftAttendances
            .map((a) => a['profile_id'].toString())
            .toSet();
        
        log('  - Hadir dari attendance: ${hadirSet.length} pegawai', 3);
        
        // Hitung cuti yang dijadwalkan shift ini
        final cutiSet = scheduledProfiles.where((p) => leaveProfileIds.contains(p)).toSet();
        log('  - Cuti: ${cutiSet.length} pegawai', 3);
        
        // 🔥 PERBAIKAN: Hitung tidak hadir (tidak boleh negatif)
        int tidakHadirCount = scheduledProfiles.length - hadirSet.length - cutiSet.length;
        if (tidakHadirCount < 0) tidakHadirCount = 0;
        log('  - Tidak hadir: $tidakHadirCount pegawai', 3);
        
        // Hitung terlambat
        final lateAttendances = shiftAttendances.where((a) {
          final status = a['status'] as String? ?? 'present';
          return status == 'late';
        }).toList();
        
        final terlambatCount = lateAttendances.length;
        
        // Hitung bertugas (check_out null)
        final bertugasAttendances = shiftAttendances.where((a) => a['check_out'] == null).toList();
        final bertugasCount = bertugasAttendances.length;
        
        // Hitung hadir
        final hadirCount = shiftAttendances.length;
        
        // Daftar terlambat (max 3)
        final lateEmployees = <LateEmployeeShift>[];
        for (final att in lateAttendances.take(3)) {
          final profile = att['profiles'] as Map<String, dynamic>;
          final checkIn = DateTime.parse(att['check_in']);
          
          int lateMinutes = 0;
          final shiftIdAtt = att['shift_id'];
          if (shiftIdAtt != null) {
            final shiftData = shifts.firstWhere(
              (s) => s.id == shiftIdAtt,
              orElse: () => shift,
            );
            final startTimeStr = shiftData.startTime;
            final startTime = DateTime.parse('$todayDate $startTimeStr');
            lateMinutes = checkIn.difference(startTime).inMinutes;
            if (lateMinutes < 0) lateMinutes = 0;
          }
          
          lateEmployees.add(LateEmployeeShift(
            profileId: profile['id'].toString(),
            fullName: profile['full_name'] ?? '',
            avatarUrl: profile['avatar_url'],
            unitCode: profile['unit_code'],
            lateMinutes: lateMinutes,
            checkIn: checkIn,
            shiftName: shiftName,
          ));
        }
        
        // Daftar overshift untuk shift ini
        final overshiftEmployees = <OvershiftEmployee>[];
        
        for (final att in bertugasAttendances) {
          final profileId = att['profile_id'].toString();
          final actualShiftId = att['shift_id']?.toString();
          final expectedShiftId = rosterShiftMap[profileId];
          
          if (expectedShiftId != null && actualShiftId != null && actualShiftId != expectedShiftId) {
            final profile = att['profiles'] as Map<String, dynamic>;
            final profileTasks = tasksByProfile[profileId] ?? [];
            
            for (final task in profileTasks.take(2)) {
              final expectedShift = shifts.firstWhere(
                (s) => s.id == expectedShiftId,
                orElse: () => shift,
              );
              final actualShift = shifts.firstWhere(
                (s) => s.id == actualShiftId,
                orElse: () => shift,
              );
              
              overshiftEmployees.add(OvershiftEmployee(
                profileId: profileId,
                fullName: profile['full_name'] ?? '',
                avatarUrl: profile['avatar_url'],
                unitCode: profile['unit_code'],
                taskId: task['id'].toString(),
                taskName: task['object_name'] ?? '',
                taskStatus: task['status'] ?? 'pending',
                taskCreatedAt: DateTime.parse(task['created_at']),
                expectedShiftName: expectedShift.shiftName,
                actualShiftName: actualShift.shiftName,
              ));
            }
          }
        }
        
        log('Shift $shiftName: Hadir=$hadirCount, Tidak=$tidakHadirCount, Terlambat=$terlambatCount, Bertugas=$bertugasCount, Cuti=${cutiSet.length}', 2);
        
        shiftSummaries.add(ShiftAttendanceSummary(
          shiftId: shiftId,
          shiftName: shiftName,
          shiftStart: shift.startTime,
          shiftEnd: shift.endTime,
          hadir: hadirCount,
          tidakHadir: tidakHadirCount,
          terlambat: terlambatCount,
          bertugas: bertugasCount,
          cuti: cutiSet.length,
          lateEmployees: lateEmployees,
          overshiftEmployees: overshiftEmployees,
        ));
      }
      
      // 7. Recent Check-ins (5 terbaru)
      final recentCheckIns = <RecentCheckIn>[];
      final sortedAttendances = [...attendanceResult]
        ..sort((a, b) => b['check_in'].compareTo(a['check_in']));
      
      for (final att in sortedAttendances.take(5)) {
        final profile = att['profiles'] as Map<String, dynamic>;
        final shiftId = att['shift_id']?.toString();
        final shift = shifts.firstWhere(
          (s) => s.id == shiftId,
          orElse: () => ShiftModel(
            id: '',
            shiftName: '',
            shiftCode: '',
            startTime: '',
            endTime: '',
            isCrossDay: false,
            toleranceLateMinutes: 15,
            isActive: false,
          ),
        );
        
        recentCheckIns.add(RecentCheckIn(
          profileId: profile['id'].toString(),
          fullName: profile['full_name'] ?? '',
          avatarUrl: profile['avatar_url'],
          unitCode: profile['unit_code'],
          checkIn: DateTime.parse(att['check_in']),
          shiftName: shift.shiftName.isNotEmpty ? shift.shiftName : null,
          address: att['address_at_check_in'],
        ));
      }
      
      // 8. Status situasi pegawai
      final profilesResult = await supabase
          .from('profiles')
          .select('current_situation')
          .eq('is_approved', true);
      
      final employeesBySituation = <String, int>{};
      for (final row in profilesResult) {
        final situation = row['current_situation'] as String? ?? 'ACTIVE';
        employeesBySituation[situation] = (employeesBySituation[situation] ?? 0) + 1;
      }
      
      log('Selesai mengambil overview attendance', 1);
      
      return AttendanceOverview(
        shifts: shiftSummaries,
        recentCheckIns: recentCheckIns,
        employeesBySituation: employeesBySituation,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil overview attendance', e, stackTrace);
      return AttendanceOverview(
        shifts: [],
        recentCheckIns: [],
        employeesBySituation: {},
      );
    }
  }
  
  // Ambil daftar pegawai terlambat per shift (lengkap)
  Future<List<LateEmployeeShift>> getLateEmployeesByShift(String shiftId) async {
    log('Mengambil pegawai terlambat untuk shift: $shiftId');
    
    try {
      final todayDate = today;
      
      final shiftResult = await supabase
          .from('ref_shifts')
          .select('*')
          .eq('id', shiftId)
          .maybeSingle();
      
      if (shiftResult == null) {
        return [];
      }
      
      final shift = ShiftModel.fromJson(shiftResult);
      
      final attendanceResult = await supabase
          .from('attendance')
          .select('''
            id,
            profile_id,
            shift_id,
            check_in,
            status,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .eq('shift_id', shiftId)
          .eq('status', 'late')
          .gte('check_in', todayDate)
          .lte('check_in', '$todayDate 23:59:59');
      
      final lateEmployees = <LateEmployeeShift>[];
      
      for (final row in attendanceResult) {
        final profile = row['profiles'] as Map<String, dynamic>;
        final checkIn = DateTime.parse(row['check_in']);
        
        int lateMinutes = 0;
        final startTimeStr = shift.startTime;
        final startTime = DateTime.parse('$todayDate $startTimeStr');
        lateMinutes = checkIn.difference(startTime).inMinutes;
        if (lateMinutes < 0) lateMinutes = 0;
        
        lateEmployees.add(LateEmployeeShift(
          profileId: profile['id'].toString(),
          fullName: profile['full_name'] ?? '',
          avatarUrl: profile['avatar_url'],
          unitCode: profile['unit_code'],
          lateMinutes: lateMinutes,
          checkIn: checkIn,
          shiftName: shift.shiftName,
        ));
      }
      
      lateEmployees.sort((a, b) => b.lateMinutes.compareTo(a.lateMinutes));
      
      log('Ditemukan ${lateEmployees.length} pegawai terlambat untuk shift ${shift.shiftName}', 1);
      
      return lateEmployees;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil pegawai terlambat untuk shift $shiftId', e, stackTrace);
      return [];
    }
  }
  
  // Ambil daftar pegawai overshift
  Future<List<OvershiftEmployee>> getOvershiftEmployees() async {
    log('Mengambil pegawai overshift...');
    
    try {
      final todayDate = today;
      
      final shiftsResult = await supabase
          .from('ref_shifts')
          .select('*')
          .eq('is_active', true);
      
      final shifts = shiftsResult.map<ShiftModel>((json) => ShiftModel.fromJson(json)).toList();
      
      final rostersResult = await supabase
          .from('employee_shift_rosters')
          .select('profile_id, shift_id')
          .eq('roster_date', todayDate)
          .eq('is_day_off', false);
      
      final Map<String, String> expectedShiftMap = {};
      for (final roster in rostersResult) {
        expectedShiftMap[roster['profile_id'].toString()] = roster['shift_id'].toString();
      }
      
      final attendanceResult = await supabase
          .from('attendance')
          .select('''
            id,
            profile_id,
            shift_id,
            check_in,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .filter('check_out', 'is', null)
          .gte('check_in', todayDate)
          .lte('check_in', '$todayDate 23:59:59');
      
      final tasksResult = await supabase
          .from('tasks')
          .select('''
            id,
            assignee_id,
            object_name,
            status,
            created_at
          ''')
          .not('status', 'eq', 'done');
      
      final Map<String, List<Map<String, dynamic>>> tasksByProfile = {};
      for (final task in tasksResult) {
        final assigneeId = task['assignee_id'].toString();
        if (!tasksByProfile.containsKey(assigneeId)) {
          tasksByProfile[assigneeId] = [];
        }
        tasksByProfile[assigneeId]!.add(task);
      }
      
      final overshiftEmployees = <OvershiftEmployee>[];
      
      for (final att in attendanceResult) {
        final profileId = att['profile_id'].toString();
        final actualShiftId = att['shift_id']?.toString();
        final expectedShiftId = expectedShiftMap[profileId];
        
        if (expectedShiftId != null && actualShiftId != null && actualShiftId != expectedShiftId) {
          final profile = att['profiles'] as Map<String, dynamic>;
          final profileTasks = tasksByProfile[profileId] ?? [];
          
          final expectedShift = shifts.firstWhere(
            (s) => s.id == expectedShiftId,
            orElse: () => shifts.first,
          );
          final actualShift = shifts.firstWhere(
            (s) => s.id == actualShiftId,
            orElse: () => shifts.first,
          );
          
          for (final task in profileTasks.take(3)) {
            overshiftEmployees.add(OvershiftEmployee(
              profileId: profileId,
              fullName: profile['full_name'] ?? '',
              avatarUrl: profile['avatar_url'],
              unitCode: profile['unit_code'],
              taskId: task['id'].toString(),
              taskName: task['object_name'] ?? '',
              taskStatus: task['status'] ?? 'pending',
              taskCreatedAt: DateTime.parse(task['created_at']),
              expectedShiftName: expectedShift.shiftName,
              actualShiftName: actualShift.shiftName,
            ));
          }
        }
      }
      
      log('Ditemukan ${overshiftEmployees.length} pegawai overshift', 1);
      
      return overshiftEmployees;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil pegawai overshift', e, stackTrace);
      return [];
    }
  }
  
  // Ambil recent check-ins (lebih banyak)
  Future<List<RecentCheckIn>> getRecentCheckIns({int limit = 20}) async {
    log('Mengambil recent check-ins...');
    
    try {
      final todayDate = today;
      
      final shiftsResult = await supabase
          .from('ref_shifts')
          .select('*')
          .eq('is_active', true);
      
      final shifts = shiftsResult.map<ShiftModel>((json) => ShiftModel.fromJson(json)).toList();
      
      final attendanceResult = await supabase
          .from('attendance')
          .select('''
            id,
            profile_id,
            shift_id,
            check_in,
            address_at_check_in,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .gte('check_in', todayDate)
          .lte('check_in', '$todayDate 23:59:59')
          .order('check_in', ascending: false)
          .limit(limit);
      
      final recentCheckIns = <RecentCheckIn>[];
      
      for (final row in attendanceResult) {
        final profile = row['profiles'] as Map<String, dynamic>;
        final shiftId = row['shift_id']?.toString();
        final shift = shifts.firstWhere(
          (s) => s.id == shiftId,
          orElse: () => ShiftModel(
            id: '',
            shiftName: '',
            shiftCode: '',
            startTime: '',
            endTime: '',
            isCrossDay: false,
            toleranceLateMinutes: 15,
            isActive: false,
          ),
        );
        
        recentCheckIns.add(RecentCheckIn(
          profileId: profile['id'].toString(),
          fullName: profile['full_name'] ?? '',
          avatarUrl: profile['avatar_url'],
          unitCode: profile['unit_code'],
          checkIn: DateTime.parse(row['check_in']),
          shiftName: shift.shiftName.isNotEmpty ? shift.shiftName : null,
          address: row['address_at_check_in'],
        ));
      }
      
      log('Ditemukan ${recentCheckIns.length} recent check-ins', 1);
      
      return recentCheckIns;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil recent check-ins', e, stackTrace);
      return [];
    }
  }
}