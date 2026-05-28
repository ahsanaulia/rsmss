// lib/insights/profiles/services/profile_summary_service.dart

import 'base_service.dart';
import '../models/models.dart';

class ProfileSummaryService extends BaseService {
  // Ambil ringkasan profile (untuk sub-menu 1)
  Future<ProfileSummaryModel> getProfileSummary() async {
    log('Mengambil ringkasan profile...');
    
    try {
      // 🔥 PERBAIKAN: Spesifikkan foreign key yang digunakan
      final profiles = await supabase
          .from('profiles')
          .select('''
            id,
            unit_id,
            position_id,
            gender,
            join_year,
            current_situation,
            ref_positions!left(position_name),
            employee_units!profiles_unit_id_fkey(
              unit_name, 
              unit_code
            )
          ''')
          .eq('is_approved', true);
      
      final totalEmployees = profiles.length;
      log('Total pegawai: $totalEmployees');
      
      final employeesByUnit = <String, int>{};
      final employeesByPosition = <String, int>{};
      final employeesByGender = <String, int>{};
      final employeesByJoinYear = <String, int>{};
      final employeesBySituation = <String, int>{};
      
      for (final row in profiles) {
        // Group by Unit Name (dari employee_units)
        String unitDisplay = 'Tidak Ada Unit';
        if (row['employee_units'] != null && row['employee_units'] is Map) {
          final unitData = row['employee_units'] as Map<String, dynamic>;
          unitDisplay = unitData['unit_name'] ?? 'Tidak Ada Unit';
          log('Unit ditemukan: $unitDisplay (${unitData['unit_code']})', 1);
        } else {
          log('Tidak ada unit untuk profile ini (unit_id: ${row['unit_id']})', 1);
        }
        employeesByUnit[unitDisplay] = (employeesByUnit[unitDisplay] ?? 0) + 1;
        
        // Group by Position
        String positionName = 'Tidak Ada Posisi';
        if (row['ref_positions'] != null && row['ref_positions'] is Map) {
          final posData = row['ref_positions'] as Map<String, dynamic>;
          positionName = posData['position_name'] ?? 'Tidak Ada Posisi';
        }
        employeesByPosition[positionName] = (employeesByPosition[positionName] ?? 0) + 1;
        
        // Group by Gender
        final gender = row['gender'] as String?;
        if (gender != null && gender.isNotEmpty && gender != 'null') {
          employeesByGender[gender] = (employeesByGender[gender] ?? 0) + 1;
        } else {
          employeesByGender['Tidak Diketahui'] = (employeesByGender['Tidak Diketahui'] ?? 0) + 1;
        }
        
        // Group by Join Year
        final joinYear = row['join_year'];
        if (joinYear != null && joinYear.toString().isNotEmpty) {
          final yearStr = joinYear.toString();
          employeesByJoinYear[yearStr] = (employeesByJoinYear[yearStr] ?? 0) + 1;
        } else {
          employeesByJoinYear['Tidak Diketahui'] = (employeesByJoinYear['Tidak Diketahui'] ?? 0) + 1;
        }
        
        // Group by Current Situation
        final situation = row['current_situation'] as String? ?? 'ACTIVE';
        employeesBySituation[situation] = (employeesBySituation[situation] ?? 0) + 1;
      }
      
      // Sort join years
      final sortedJoinYears = <String, int>{};
      final years = employeesByJoinYear.keys.where((k) => k != 'Tidak Diketahui').toList()..sort();
      for (final year in years) {
        sortedJoinYears[year] = employeesByJoinYear[year]!;
      }
      if (employeesByJoinYear.containsKey('Tidak Diketahui')) {
        sortedJoinYears['Tidak Diketahui'] = employeesByJoinYear['Tidak Diketahui']!;
      }
      
      log('Unit: ${employeesByUnit.length} jenis');
      for (final entry in employeesByUnit.entries) {
        log('  - ${entry.key}: ${entry.value} pegawai', 1);
      }
      log('Posisi: ${employeesByPosition.length} jenis');
      log('Gender: L=${employeesByGender['L'] ?? 0}, P=${employeesByGender['P'] ?? 0}');
      log('Join Year: ${years.length} tahun berbeda');
      log('Situasi: ACTIVE=${employeesBySituation['ACTIVE'] ?? 0}');
      
      return ProfileSummaryModel(
        totalEmployees: totalEmployees,
        employeesByUnit: employeesByUnit,
        employeesByPosition: employeesByPosition,
        employeesByGender: employeesByGender,
        employeesByJoinYear: sortedJoinYears,
        employeesBySituation: employeesBySituation,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan profile', e, stackTrace);
      return ProfileSummaryModel.empty();
    }
  }
  
  // Ambil ringkasan profile per unit
  Future<Map<String, ProfileSummaryModel>> getProfileSummaryByUnit() async {
    log('Mengambil ringkasan profile per unit...');
    
    try {
      final profiles = await supabase
          .from('profiles')
          .select('''
            id,
            unit_id,
            position_id,
            gender,
            join_year,
            current_situation,
            ref_positions!left(position_name),
            employee_units!profiles_unit_id_fkey(
              unit_name, 
              unit_code
            )
          ''')
          .eq('is_approved', true);
      
      final Map<String, ProfileSummaryModel> result = {};
      
      // Group profiles by unit_name
      final Map<String, List<Map<String, dynamic>>> profilesByUnit = {};
      for (final row in profiles) {
        String unitDisplay = 'Tidak Ada Unit';
        if (row['employee_units'] != null && row['employee_units'] is Map) {
          final unitData = row['employee_units'] as Map<String, dynamic>;
          unitDisplay = unitData['unit_name'] ?? 'Tidak Ada Unit';
        }
        profilesByUnit.putIfAbsent(unitDisplay, () => []);
        profilesByUnit[unitDisplay]!.add(row);
      }
      
      for (final entry in profilesByUnit.entries) {
        final unitName = entry.key;
        final unitProfiles = entry.value;
        
        final employeesByPosition = <String, int>{};
        final employeesByGender = <String, int>{};
        final employeesByJoinYear = <String, int>{};
        final employeesBySituation = <String, int>{};
        
        for (final row in unitProfiles) {
          String positionName = 'Tidak Ada Posisi';
          if (row['ref_positions'] != null && row['ref_positions'] is Map) {
            final posData = row['ref_positions'] as Map<String, dynamic>;
            positionName = posData['position_name'] ?? 'Tidak Ada Posisi';
          }
          employeesByPosition[positionName] = (employeesByPosition[positionName] ?? 0) + 1;
          
          final gender = row['gender'] as String?;
          if (gender != null && gender.isNotEmpty && gender != 'null') {
            employeesByGender[gender] = (employeesByGender[gender] ?? 0) + 1;
          } else {
            employeesByGender['Tidak Diketahui'] = (employeesByGender['Tidak Diketahui'] ?? 0) + 1;
          }
          
          final joinYear = row['join_year'];
          if (joinYear != null && joinYear.toString().isNotEmpty) {
            final yearStr = joinYear.toString();
            employeesByJoinYear[yearStr] = (employeesByJoinYear[yearStr] ?? 0) + 1;
          } else {
            employeesByJoinYear['Tidak Diketahui'] = (employeesByJoinYear['Tidak Diketahui'] ?? 0) + 1;
          }
          
          final situation = row['current_situation'] as String? ?? 'ACTIVE';
          employeesBySituation[situation] = (employeesBySituation[situation] ?? 0) + 1;
        }
        
        result[unitName] = ProfileSummaryModel(
          totalEmployees: unitProfiles.length,
          employeesByUnit: {},
          employeesByPosition: employeesByPosition,
          employeesByGender: employeesByGender,
          employeesByJoinYear: employeesByJoinYear,
          employeesBySituation: employeesBySituation,
        );
        
        log('Unit $unitName: ${unitProfiles.length} pegawai', 1);
      }
      
      return result;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan profile per unit', e, stackTrace);
      return {};
    }
  }
  
  // Ambil statistik ringkasan cepat (untuk KPI cards)
  Future<Map<String, dynamic>> getQuickStats() async {
    log('Mengambil quick stats...');
    
    try {
      final allProfiles = await supabase
          .from('profiles')
          .select('id, current_situation, gender')
          .eq('is_approved', true);
      
      final total = allProfiles.length;
      final active = allProfiles.where((p) => p['current_situation'] == 'ACTIVE').length;
      final onLeave = allProfiles.where((p) => p['current_situation'] == 'LEAVE').length;
      final male = allProfiles.where((p) => p['gender'] == 'L').length;
      final female = allProfiles.where((p) => p['gender'] == 'P').length;
      
      log('Quick stats: total=$total, active=$active, onLeave=$onLeave, male=$male, female=$female');
      
      return {
        'total': total,
        'active': active,
        'onLeave': onLeave,
        'male': male,
        'female': female,
      };
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil quick stats', e, stackTrace);
      return {
        'total': 0,
        'active': 0,
        'onLeave': 0,
        'male': 0,
        'female': 0,
      };
    }
  }
}