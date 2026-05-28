// lib/insights/profiles/services/profile_attendance_service.dart

import 'base_service.dart';
import '../models/models.dart';

// Model untuk hasil pegawai bertugas
class WorkingEmployeesResult {
  final int normal;
  final int overshift;
  final int total;
  final List<WorkingEmployee> normalEmployees;
  final List<WorkingEmployee> overshiftEmployees;

  WorkingEmployeesResult({
    required this.normal,
    required this.overshift,
    required this.total,
    required this.normalEmployees,
    required this.overshiftEmployees,
  });
}

class WorkingEmployee {
  final String profileId;
  final String? shiftId;
  final bool isOvershift;

  WorkingEmployee({
    required this.profileId,
    this.shiftId,
    required this.isOvershift,
  });
}

class ProfileAttendanceService extends BaseService {
  // Ambil ringkasan absensi hari ini
  Future<AttendanceSummary> getAttendanceSummary() async {
    log('Mengambil ringkasan absensi...');
    
    try {
      final attendanceToday = await supabase
          .from('attendance')
          .select('''
            *,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .gte('check_in', today)
          .lte('check_in', '$today 23:59:59');
      
      log('Attendance hari ini: ${attendanceToday.length} record');
      
      int presentToday = 0;
      int absentToday = 0;
      int lateToday = 0;
      final List<LateEmployee> lateEmployeesToday = [];
      
      for (final row in attendanceToday) {
        try {
          final checkIn = DateTime.parse(row['check_in']);
          final isPresent = row['check_out'] == null;
          
          if (isPresent) {
            presentToday++;
          } else {
            absentToday++;
          }
          
          final status = row['status'] as String? ?? 'present';
          if (status == 'late') {
            lateToday++;
            
            final profile = row['profiles'] as Map<String, dynamic>;
            
            int lateMinutes = 0;
            final shiftId = row['shift_id'];
            if (shiftId != null) {
              final shift = await supabase
                  .from('ref_shifts')
                  .select('start_time')
                  .eq('id', shiftId)
                  .maybeSingle();
              
              if (shift != null) {
                final startTimeValue = shift['start_time'];
                if (startTimeValue != null) {
                  final startTimeStr = startTimeValue.toString();
                  final startTime = DateTime.parse('$today $startTimeStr');
                  lateMinutes = checkIn.difference(startTime).inMinutes;
                  if (lateMinutes < 0) lateMinutes = 0;
                }
              }
            }
            
            lateEmployeesToday.add(LateEmployee(
              profileId: profile['id'].toString(),
              fullName: profile['full_name'] ?? '',
              avatarUrl: profile['avatar_url'],
              unitCode: profile['unit_code'],
              lateMinutes: lateMinutes,
              checkIn: checkIn,
            ));
          }
        } catch (e) {
          logError('Error processing attendance row: $e');
        }
      }
      
      lateEmployeesToday.sort((a, b) => b.lateMinutes.compareTo(a.lateMinutes));
      
      log('Present: $presentToday, Absent: $absentToday, Late: $lateToday');
      
      // Ambil cuti hari ini
      final leaveToday = await supabase
          .from('employee_leave_requests')
          .select('profile_id')
          .lte('start_date', today)
          .gte('end_date', today)
          .eq('approval_status', 'approved');
      
      final onLeaveToday = leaveToday.length;
      log('Cuti hari ini: $onLeaveToday');
      
      // Ambil attendance bulan ini
      final attendanceThisMonth = await supabase
          .from('attendance')
          .select('id')
          .gte('check_in', firstDayOfMonth)
          .lte('check_in', '$today 23:59:59');
      
      final workingDaysThisMonth = DateTime.now().day;
      final attendanceRate = workingDaysThisMonth > 0 
          ? attendanceThisMonth.length / workingDaysThisMonth * 100 
          : 0.0;
      
      log('Attendance rate bulan ini: ${attendanceRate.toStringAsFixed(1)}% (${attendanceThisMonth.length}/$workingDaysThisMonth)');
      
      // Ambil recent check-ins
      final recentCheckIns = await supabase
          .from('attendance')
          .select('''
            *,
            profiles!inner(
              id,
              full_name,
              avatar_url,
              unit_code
            )
          ''')
          .order('check_in', ascending: false)
          .limit(5);
      
      final recentCheckInsList = recentCheckIns.map<AttendanceModel>((row) {
        return AttendanceModel.fromJson(row);
      }).toList();
      
      return AttendanceSummary(
        presentToday: presentToday,
        absentToday: absentToday,
        onLeaveToday: onLeaveToday,
        lateToday: lateToday,
        attendanceRateThisMonth: attendanceRate,
        lateEmployeesToday: lateEmployeesToday,
        recentCheckIns: recentCheckInsList,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan absensi', e, stackTrace);
      return AttendanceSummary(
        presentToday: 0,
        absentToday: 0,
        onLeaveToday: 0,
        lateToday: 0,
        attendanceRateThisMonth: 0.0,
        lateEmployeesToday: [],
        recentCheckIns: [],
      );
    }
  }
  
  // Ambil ringkasan lokasi
  Future<LocationSummary> getLocationSummary() async {
    log('Mengambil ringkasan lokasi...');
    
    try {
      final profiles = await supabase
          .from('profiles')
          .select('unit_code, current_situation')
          .eq('is_approved', true);
      
      log('Jumlah profile: ${profiles.length}');
      
      final employeesByLocation = <String, int>{};
      final employeesByUnit = <String, int>{};
      
      for (final row in profiles) {
        final unitCode = row['unit_code'] as String? ?? 'Tidak Ada Unit';
        employeesByUnit[unitCode] = (employeesByUnit[unitCode] ?? 0) + 1;
        
        final situation = row['current_situation'] as String? ?? 'ACTIVE';
        employeesByLocation[situation] = (employeesByLocation[situation] ?? 0) + 1;
      }
      
      log('Unit: ${employeesByUnit.length} jenis');
      log('Situasi: ACTIVE=${employeesByLocation['ACTIVE'] ?? 0}');
      
      return LocationSummary(
        employeesByLocation: employeesByLocation,
        employeesByUnit: employeesByUnit,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan lokasi', e, stackTrace);
      return LocationSummary(
        employeesByLocation: {},
        employeesByUnit: {},
      );
    }
  }
  
  // Ambil attendance per profile untuk hari ini
  Future<AttendanceModel?> getProfileAttendance(String profileId) async {
    try {
      final result = await supabase
          .from('attendance')
          .select('*')
          .eq('profile_id', profileId)
          .gte('check_in', today)
          .lte('check_in', '$today 23:59:59')
          .maybeSingle();
      
      if (result != null) {
        return AttendanceModel.fromJson(result);
      }
      return null;
    } catch (e) {
      logError('Gagal mengambil attendance profile $profileId', e);
      return null;
    }
  }

  // 🔥 METHOD INI HARUS DI DALAM CLASS
  Future<WorkingEmployeesResult> getWorkingEmployeesToday() async {
    log('Mengambil pegawai yang sedang bertugas hari ini...');
    
    final todayDate = today;
    
    try {
      // 1. Ambil semua attendance yang check_out = null (masih bertugas)
      final attendanceToday = await supabase
          .from('attendance')
          .select('''
            id,
            profile_id,
            check_in,
            shift_id
          ''')
          .filter('check_out', 'is', null)
          .gte('check_in', todayDate)
          .lte('check_in', '$todayDate 23:59:59');
      
      log('Attendance dengan check_out null hari ini: ${attendanceToday.length}');
      
      if (attendanceToday.isEmpty) {
        return WorkingEmployeesResult(
          normal: 0,
          overshift: 0,
          total: 0,
          normalEmployees: [],
          overshiftEmployees: [],
        );
      }
      
      // 2. Ambil semua roster untuk hari ini
      final rostersToday = await supabase
          .from('employee_shift_rosters')
          .select('profile_id, shift_id, is_day_off')
          .eq('roster_date', todayDate);
      
      // 3. Buat map roster shift (hanya yang bukan day off)
      final Map<String, String?> rosterShiftMap = {};
      for (final roster in rostersToday) {
        final profileId = roster['profile_id'].toString();
        final isDayOff = roster['is_day_off'] ?? false;
        if (!isDayOff) {
          rosterShiftMap[profileId] = roster['shift_id']?.toString();
        }
      }
      
      int normalCount = 0;
      int overshiftCount = 0;
      final List<WorkingEmployee> normalEmployees = [];
      final List<WorkingEmployee> overshiftEmployees = [];
      
      for (final att in attendanceToday) {
        final profileId = att['profile_id'].toString();
        final actualShiftId = att['shift_id']?.toString();
        final expectedShiftId = rosterShiftMap[profileId];
        
        // Cek apakah shift sesuai dengan roster
        if (expectedShiftId != null && actualShiftId == expectedShiftId) {
          normalCount++;
          normalEmployees.add(WorkingEmployee(
            profileId: profileId,
            shiftId: actualShiftId,
            isOvershift: false,
          ));
        } else if (actualShiftId != null) {
          overshiftCount++;
          overshiftEmployees.add(WorkingEmployee(
            profileId: profileId,
            shiftId: actualShiftId,
            isOvershift: true,
          ));
        }
      }
      
      log('Normal: $normalCount, Overshift: $overshiftCount, Total Bertugas: ${normalCount + overshiftCount}');
      
      return WorkingEmployeesResult(
        normal: normalCount,
        overshift: overshiftCount,
        total: normalCount + overshiftCount,
        normalEmployees: normalEmployees,
        overshiftEmployees: overshiftEmployees,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil pegawai bertugas', e, stackTrace);
      return WorkingEmployeesResult(
        normal: 0,
        overshift: 0,
        total: 0,
        normalEmployees: [],
        overshiftEmployees: [],
      );
    }
  }
}