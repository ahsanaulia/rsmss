// // lib/insights/profiles/services/profile_service.dart

// import 'base_service.dart';
// import '../models/models.dart';

// class ProfileService extends BaseService {
//   // Ambil semua profile dengan data terkait
//   Future<List<ProfileListItem>> getAllProfiles() async {
//     log('Mengambil semua profiles...');
    
//     try {
//       final response = await supabase
//           .from('profiles')
//           .select('''
//             id,
//             full_name,
//             avatar_url,
//             employee_id,
//             unit_code,
//             current_situation,
//             position_id,
//             ref_positions!left(
//               position_name,
//               level,
//               color,
//               icon_name
//             ),
//             employee_score_summary!left(
//               total_percentage
//             )
//           ''')
//           .eq('is_approved', true);
      
//       log('Ditemukan ${response.length} profiles');
      
//       final List<ProfileListItem> result = [];
      
//       for (final json in response) {
//         result.add(_parseProfileListItem(json));
//       }
      
//       return result;
      
//     } catch (e, stackTrace) {
//       logError('Gagal mengambil profiles', e, stackTrace);
//       return [];
//     }
//   }
  
//   // Ambil profile summary untuk hari ini
//   Future<ProfileSummaryModel> getProfileSummary() async {
//     log('Mengambil ringkasan profile...');
    
//     try {
//       final profiles = await supabase
//           .from('profiles')
//           .select('id, unit_code, position_id, gender, join_year, current_situation, ref_positions!left(position_name)')
//           .eq('is_approved', true);
      
//       final totalEmployees = profiles.length;
//       log('Total pegawai: $totalEmployees');
      
//       final employeesByUnit = <String, int>{};
//       final employeesByPosition = <String, int>{};
//       final employeesByGender = <String, int>{};
//       final employeesByJoinYear = <String, int>{};
//       final employeesBySituation = <String, int>{};
      
//       for (final row in profiles) {
//         // By Unit
//         final unitCode = row['unit_code'] as String? ?? 'Tidak Ada Unit';
//         employeesByUnit[unitCode] = (employeesByUnit[unitCode] ?? 0) + 1;
        
//         // By Position
//         String positionName = 'Tidak Ada Posisi';
//         if (row['ref_positions'] != null && row['ref_positions'] is Map) {
//           positionName = row['ref_positions']['position_name'] ?? 'Tidak Ada Posisi';
//         }
//         employeesByPosition[positionName] = (employeesByPosition[positionName] ?? 0) + 1;
        
//         // By Gender
//         final gender = row['gender'] as String?;
//         if (gender != null && gender.isNotEmpty && gender != 'null') {
//           employeesByGender[gender] = (employeesByGender[gender] ?? 0) + 1;
//         } else {
//           employeesByGender['Tidak Diketahui'] = (employeesByGender['Tidak Diketahui'] ?? 0) + 1;
//         }
        
//         // By Join Year
//         final joinYear = row['join_year'];
//         if (joinYear != null && joinYear.toString().isNotEmpty) {
//           final yearStr = joinYear.toString();
//           employeesByJoinYear[yearStr] = (employeesByJoinYear[yearStr] ?? 0) + 1;
//         } else {
//           employeesByJoinYear['Tidak Diketahui'] = (employeesByJoinYear['Tidak Diketahui'] ?? 0) + 1;
//         }
        
//         // By Situation
//         final situation = row['current_situation'] as String? ?? 'ACTIVE';
//         employeesBySituation[situation] = (employeesBySituation[situation] ?? 0) + 1;
//       }
      
//       return ProfileSummaryModel(
//         totalEmployees: totalEmployees,
//         employeesByUnit: employeesByUnit,
//         employeesByPosition: employeesByPosition,
//         employeesByGender: employeesByGender,
//         employeesByJoinYear: employeesByJoinYear,
//         employeesBySituation: employeesBySituation,
//       );
      
//     } catch (e, stackTrace) {
//       logError('Gagal mengambil ringkasan profile', e, stackTrace);
//       return ProfileSummaryModel.empty();
//     }
//   }
  
//   // Parse single profile item
//   ProfileListItem _parseProfileListItem(Map<String, dynamic> json) {
//     String fullPosition = json['full_name'] ?? '';
//     String? positionName;
//     int positionLevel = 99;
//     String? positionColor;
//     String? positionIcon;
    
//     if (json['ref_positions'] != null && json['ref_positions'] is Map) {
//       final posData = json['ref_positions'] as Map<String, dynamic>;
//       positionName = posData['position_name'];
//       positionLevel = posData['level'] ?? 99;
//       positionColor = posData['color'];
//       positionIcon = posData['icon_name'];
//       final unitPart = json['unit_code'] != null && json['unit_code'].toString().isNotEmpty
//           ? ' - ${json['unit_code']}'
//           : '';
//       fullPosition = '${json['full_name']} - $positionName$unitPart';
//     }
    
//     double? scorePercentage;
//     if (json['employee_score_summary'] != null) {
//       if (json['employee_score_summary'] is List && json['employee_score_summary'].isNotEmpty) {
//         scorePercentage = (json['employee_score_summary'][0]['total_percentage'] as num?)?.toDouble();
//       } else if (json['employee_score_summary'] is Map) {
//         scorePercentage = (json['employee_score_summary']['total_percentage'] as num?)?.toDouble();
//       }
//     }
    
//     return ProfileListItem(
//       id: json['id'].toString(),
//       fullName: json['full_name'] ?? '',
//       avatarUrl: json['avatar_url'],
//       employeeId: json['employee_id'],
//       positionName: positionName,
//       unitCode: json['unit_code'],
//       unitName: json['unit_code'],
//       fullPosition: fullPosition,
//       positionLevel: positionLevel,
//       positionColor: positionColor,
//       positionIcon: positionIcon,
//       scorePercentage: scorePercentage,
//       isActiveToday: false,
//       currentSituation: json['current_situation'] ?? 'ACTIVE',
//     );
//   }
// }

// lib/insights/profiles/services/profile_service.dart
// lib/insights/profiles/services/profile_service.dart

import 'base_service.dart';
import '../models/models.dart';

class ProfileService extends BaseService {
  // Ambil semua profile dengan data terkait
  Future<List<ProfileListItem>> getAllProfiles() async {
    log('Mengambil semua profiles...');
    
    try {
      final response = await supabase
          .from('profiles')
          .select('''
            id,
            full_name,
            avatar_url,
            employee_id,
            unit_code,
            current_situation,
            position_id,
            ref_positions!left(
              position_name,
              level,
              color,
              icon_name
            ),
            employee_scoring!employee_scoring_profile_id_fkey!inner(
              score,
              max_score
            )
          ''')
          .eq('is_approved', true);
      
      log('Ditemukan ${response.length} profiles');
      
      final List<ProfileListItem> result = [];
      
      for (final json in response) {
        result.add(_parseProfileListItem(json));
      }
      
      return result;
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil profiles', e, stackTrace);
      return [];
    }
  }
  
  // Ambil profile summary untuk hari ini
  Future<ProfileSummaryModel> getProfileSummary() async {
    log('Mengambil ringkasan profile...');
    
    try {
      final profiles = await supabase
          .from('profiles')
          .select('id, unit_code, position_id, gender, join_year, current_situation, ref_positions!left(position_name)')
          .eq('is_approved', true);
      
      final totalEmployees = profiles.length;
      log('Total pegawai: $totalEmployees');
      
      final employeesByUnit = <String, int>{};
      final employeesByPosition = <String, int>{};
      final employeesByGender = <String, int>{};
      final employeesByJoinYear = <String, int>{};
      final employeesBySituation = <String, int>{};
      
      for (final row in profiles) {
        // By Unit
        final unitCode = row['unit_code'] as String? ?? 'Tidak Ada Unit';
        employeesByUnit[unitCode] = (employeesByUnit[unitCode] ?? 0) + 1;
        
        // By Position
        String positionName = 'Tidak Ada Posisi';
        if (row['ref_positions'] != null && row['ref_positions'] is Map) {
          positionName = row['ref_positions']['position_name'] ?? 'Tidak Ada Posisi';
        }
        employeesByPosition[positionName] = (employeesByPosition[positionName] ?? 0) + 1;
        
        // By Gender
        final gender = row['gender'] as String?;
        if (gender != null && gender.isNotEmpty && gender != 'null') {
          employeesByGender[gender] = (employeesByGender[gender] ?? 0) + 1;
        } else {
          employeesByGender['Tidak Diketahui'] = (employeesByGender['Tidak Diketahui'] ?? 0) + 1;
        }
        
        // By Join Year
        final joinYear = row['join_year'];
        if (joinYear != null && joinYear.toString().isNotEmpty) {
          final yearStr = joinYear.toString();
          employeesByJoinYear[yearStr] = (employeesByJoinYear[yearStr] ?? 0) + 1;
        } else {
          employeesByJoinYear['Tidak Diketahui'] = (employeesByJoinYear['Tidak Diketahui'] ?? 0) + 1;
        }
        
        // By Situation
        final situation = row['current_situation'] as String? ?? 'ACTIVE';
        employeesBySituation[situation] = (employeesBySituation[situation] ?? 0) + 1;
      }
      
      return ProfileSummaryModel(
        totalEmployees: totalEmployees,
        employeesByUnit: employeesByUnit,
        employeesByPosition: employeesByPosition,
        employeesByGender: employeesByGender,
        employeesByJoinYear: employeesByJoinYear,
        employeesBySituation: employeesBySituation,
      );
      
    } catch (e, stackTrace) {
      logError('Gagal mengambil ringkasan profile', e, stackTrace);
      return ProfileSummaryModel.empty();
    }
  }
  
  // Parse single profile item
  ProfileListItem _parseProfileListItem(Map<String, dynamic> json) {
    String fullPosition = json['full_name'] ?? '';
    String? positionName;
    int positionLevel = 99;
    String? positionColor;
    String? positionIcon;
    
    if (json['ref_positions'] != null && json['ref_positions'] is Map) {
      final posData = json['ref_positions'] as Map<String, dynamic>;
      positionName = posData['position_name'];
      positionLevel = posData['level'] ?? 99;
      positionColor = posData['color'];
      positionIcon = posData['icon_name'];
      final unitPart = json['unit_code'] != null && json['unit_code'].toString().isNotEmpty
          ? ' - ${json['unit_code']}'
          : '';
      fullPosition = '${json['full_name']} - $positionName$unitPart';
    }
    
    // Hitung total persentase dari employee_scoring (array)
    double? scorePercentage;
    if (json['employee_scoring'] != null && json['employee_scoring'] is List) {
      final scorings = json['employee_scoring'] as List;
      if (scorings.isNotEmpty) {
        double totalScore = 0;
        double totalMaxScore = 0;
        for (final scoring in scorings) {
          totalScore += (scoring['score'] as num?)?.toDouble() ?? 0;
          totalMaxScore += (scoring['max_score'] as num?)?.toDouble() ?? 0;
        }
        if (totalMaxScore > 0) {
          scorePercentage = (totalScore / totalMaxScore) * 100;
        }
      }
    }
    
    return ProfileListItem(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      employeeId: json['employee_id'],
      positionName: positionName,
      unitCode: json['unit_code'],
      unitName: json['unit_code'],
      fullPosition: fullPosition,
      positionLevel: positionLevel,
      positionColor: positionColor,
      positionIcon: positionIcon,
      scorePercentage: scorePercentage,
      isActiveToday: false,
      currentSituation: json['current_situation'] ?? 'ACTIVE',
    );
  }
}