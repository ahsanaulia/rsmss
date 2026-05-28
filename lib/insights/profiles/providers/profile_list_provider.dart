// // lib/insights/profiles/providers/profile_list_provider.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/models.dart';
// import '../services/services.dart';
// import 'supabase_provider.dart';

// // Service instance provider
// final profileServiceProvider = Provider<ProfileService>((ref) {
//   return ProfileService();
// });

// // Profile List Provider (menggunakan service)
// final profileListProvider = FutureProvider<List<ProfileListItem>>((ref) async {
//   print('📊 [profileListProvider] Memanggil service...');
  
//   final service = ref.read(profileServiceProvider);
//   final result = await service.getAllProfiles();
  
//   print('📊 [profileListProvider] Selesai. Total profile: ${result.length}');
//   return result;
// });

// // Stream provider untuk realtime profile list
// final profileListStreamProvider = StreamProvider<List<ProfileListItem>>((ref) {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('🔄 [profileListStreamProvider] Memulai stream realtime...');
  
//   return supabase
//       .from('profiles')
//       .stream(primaryKey: ['id'])
//       .map((response) {
//         print('🔄 [profileListStreamProvider] Ada perubahan pada tabel profiles');
        
//         return response.map<ProfileListItem>((json) {
//           return ProfileListItem(
//             id: json['id'].toString(),
//             fullName: json['full_name'] ?? '',
//             avatarUrl: json['avatar_url'],
//             employeeId: json['employee_id'],
//             positionName: json['position_name'],
//             unitCode: json['unit_code'],
//             unitName: json['unit_code'],
//             fullPosition: json['full_name'] ?? '',
//             positionLevel: 99,
//             positionColor: null,
//             positionIcon: null,
//             scorePercentage: null,
//             isActiveToday: false,
//             currentSituation: json['current_situation'] ?? 'ACTIVE',
//           );
//         }).toList();
//       });
// });

// // Search and filter providers
// final profileSearchProvider = StateProvider<String>((ref) => '');
// final profileFilterUnitProvider = StateProvider<String?>((ref) => null);

// // Filtered Profile List Provider (menggunakan service + filter)
// final filteredProfileListProvider = FutureProvider<List<ProfileListItem>>((ref) async {
//   final profiles = await ref.watch(profileListProvider.future);
//   final searchQuery = ref.watch(profileSearchProvider);
//   final filterUnit = ref.watch(profileFilterUnitProvider);
  
//   print('🔍 [filteredProfileListProvider] Search: "$searchQuery", Filter Unit: $filterUnit');
  
//   if (searchQuery.isEmpty && filterUnit == null) {
//     print('📊 [filteredProfileListProvider] Tidak ada filter, return ${profiles.length} profile');
//     return profiles;
//   }
  
//   final filtered = profiles.where((profile) {
//     bool matches = true;
    
//     if (searchQuery.isNotEmpty) {
//       final query = searchQuery.toLowerCase();
//       matches = profile.fullName.toLowerCase().contains(query) ||
//           (profile.employeeId?.toLowerCase().contains(query) ?? false) ||
//           profile.fullPosition.toLowerCase().contains(query);
//     }
    
//     if (filterUnit != null && matches) {
//       matches = profile.unitCode == filterUnit;
//     }
    
//     return matches;
//   }).toList();
  
//   print('📊 [filteredProfileListProvider] Hasil filter: ${filtered.length} dari ${profiles.length} profile');
//   return filtered;
// });

// // Profile Tree Provider (group by level)
// final profileTreeProvider = FutureProvider<Map<int, List<ProfileListItem>>>((ref) async {
//   final profiles = await ref.watch(filteredProfileListProvider.future);
  
//   print('🌳 [profileTreeProvider] Membangun tree dari ${profiles.length} profile');
  
//   final Map<int, List<ProfileListItem>> grouped = {};
  
//   for (final profile in profiles) {
//     final level = profile.positionLevel;
//     if (!grouped.containsKey(level)) {
//       grouped[level] = [];
//     }
//     grouped[level]!.add(profile);
//   }
  
//   final sortedKeys = grouped.keys.toList()..sort();
//   final sortedGrouped = <int, List<ProfileListItem>>{};
//   for (final key in sortedKeys) {
//     sortedGrouped[key] = grouped[key]!..sort((a, b) => a.fullName.compareTo(b.fullName));
//     print('🌳 Level $key: ${sortedGrouped[key]!.length} profile');
//   }
  
//   return sortedGrouped;
// });

// // lib/insights/profiles/providers/profile_list_provider.dart

// // Tambahkan provider ini di bagian bawah file (setelah profileTreeProvider)

// // 🔥 Provider untuk mendapatkan nama level dari database
// final levelNamesProvider = FutureProvider<Map<int, String>>((ref) async {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('📊 [levelNamesProvider] Mengambil nama level dari database...');
  
//   try {
//     // Ambil semua posisi yang memiliki level
//     final result = await supabase
//         .from('ref_positions')
//         .select('level, position_name')
//         .not('level', 'is', null)
//         .order('level', ascending: true);
    
//     final Map<int, String> levelNames = {};
//     for (final row in result) {
//       final level = row['level'] as int;
//       final positionName = row['position_name'] as String;
      
//       // Jika level belum ada, gunakan posisi pertama sebagai nama level
//       if (!levelNames.containsKey(level)) {
//         levelNames[level] = positionName.toUpperCase();
//       }
//     }
    
//     print('📊 [levelNamesProvider] Ditemukan ${levelNames.length} level');
//     for (final entry in levelNames.entries) {
//       print('  - Level ${entry.key}: ${entry.value}');
//     }
    
//     return levelNames;
    
//   } catch (e) {
//     print('❌ [levelNamesProvider] Error: $e');
//     return {};
//   }
// });

// // Level names stream provider (realtime)
// final levelNamesStreamProvider = StreamProvider<Map<int, String>>((ref) {
//   final supabase = ref.read(supabaseClientProvider);
  
//   final stream = supabase
//       .from('ref_positions')
//       .stream(primaryKey: ['id']);
  
//   return stream.asyncMap((_) async {
//     print('🔄 [levelNamesStreamProvider] Ada perubahan pada tabel positions');
    
//     final result = await supabase
//         .from('ref_positions')
//         .select('level, position_name')
//         .not('level', 'is', null)
//         .order('level', ascending: true);
    
//     final Map<int, String> levelNames = {};
//     for (final row in result) {
//       final level = row['level'] as int;
//       final positionName = row['position_name'] as String;
      
//       if (!levelNames.containsKey(level)) {
//         levelNames[level] = positionName.toUpperCase();
//       }
//     }
    
//     return levelNames;
//   });
// });

// // ============================================
// // PROVIDER BARU UNTUK SUBMENU 5
// // ============================================

// // Provider untuk mendapatkan semua level dari ref_positions (1-10)
// final allLevelsProvider = FutureProvider<List<LevelItem>>((ref) async {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('📊 [allLevelsProvider] Mengambil semua level dari ref_positions...');
  
//   // Step 1: Ambil semua level dan posisi
//   final response = await supabase
//       .from('ref_positions')
//       .select('level, level_name, color, icon_name')
//       .not('level', 'is', null)
//       .order('level', ascending: true);
  
//   // Step 2: Ambil semua profile yang sudah di-approve
//   final profilesResponse = await supabase
//       .from('profiles')
//       .select('position_id')
//       .eq('is_approved', true);
  
//   // Step 3: Hitung jumlah profile per position_id
//   final Map<String, int> profileCountByPosition = {};
//   for (final profile in profilesResponse) {
//     final positionId = profile['position_id'] as String?;
//     if (positionId != null) {
//       profileCountByPosition[positionId] = (profileCountByPosition[positionId] ?? 0) + 1;
//     }
//   }
  
//   // Step 4: Ambil mapping position_id ke level
//   final positionsResponse = await supabase
//       .from('ref_positions')
//       .select('id, level');
  
//   final Map<String, int> positionLevelMap = {};
//   for (final pos in positionsResponse) {
//     positionLevelMap[pos['id'] as String] = pos['level'] as int;
//   }
  
//   // Step 5: Hitung jumlah pegawai per level
//   final Map<int, int> employeeCountByLevel = {};
//   for (final entry in profileCountByPosition.entries) {
//     final positionId = entry.key;
//     final count = entry.value;
//     final level = positionLevelMap[positionId];
//     if (level != null) {
//       employeeCountByLevel[level] = (employeeCountByLevel[level] ?? 0) + count;
//     }
//   }
  
//   // Step 6: Bangun LevelItem dengan employeeCount
//   final Map<int, LevelItem> levelMap = {};
  
//   for (final row in response) {
//     final level = row['level'] as int;
//     final levelName = row['level_name'] as String?;
//     final color = row['color'] as String?;
//     final iconName = row['icon_name'] as String?;
//     final employeeCount = employeeCountByLevel[level] ?? 0;
    
//     if (!levelMap.containsKey(level)) {
//       levelMap[level] = LevelItem(
//         level: level,
//         name: (levelName != null && levelName.isNotEmpty) 
//             ? levelName.toUpperCase() 
//             : 'LEVEL $level',
//         color: color ?? '#9E9E9E',
//         iconName: iconName ?? 'person',
//         employeeCount: employeeCount,  // 🔥 ISI JUMLAH PEGAWAI
//       );
//     }
//   }
  
//   final result = levelMap.values.toList()
//     ..sort((a, b) => a.level.compareTo(b.level));
  
//   print('📊 [allLevelsProvider] Ditemukan ${result.length} level');
//   for (final level in result) {
//     print('  - Level ${level.level}: ${level.name} (${level.employeeCount} pegawai)');
//   }
  
//   return result;
// });

// // Provider untuk mendapatkan pegawai berdasarkan level
// final employeesByLevelProvider = FutureProvider.family<List<ProfileListItem>, int>((ref, level) async {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('📊 [employeesByLevelProvider] Mengambil pegawai untuk level $level...');
  
//   // Step 1: Dapatkan semua position_id untuk level tersebut
//   final positionsResponse = await supabase
//       .from('ref_positions')
//       .select('id')
//       .eq('level', level);
  
//   final positionIds = positionsResponse.map((p) => p['id'] as String).toList();
  
//   if (positionIds.isEmpty) {
//     print('📊 [employeesByLevelProvider] Tidak ada position_id untuk level $level');
//     return [];
//   }
  
//   // Step 2: Dapatkan semua profile dengan position_id tersebut
//   final response = await supabase
//       .from('profiles')
//       .select('''
//         id,
//         full_name,
//         avatar_url,
//         employee_id,
//         unit_code,
//         current_situation,
//         position_id,
//         ref_positions!left(
//           position_name,
//           level,
//           color,
//           icon_name
//         )
//       ''')
//       .eq('is_approved', true)
//       .filter('position_id', 'in', '(${positionIds.map((id) => '"$id"').join(',')})');
  
//   print('📊 [employeesByLevelProvider] Ditemukan ${response.length} pegawai untuk level $level');
  
//   final List<ProfileListItem> result = [];
  
//   for (final json in response) {
//     String fullPosition = json['full_name'] ?? '';
//     String? positionName;
//     int positionLevel = level;
//     String? positionColor;
//     String? positionIcon;
    
//     if (json['ref_positions'] != null && json['ref_positions'] is Map) {
//       final posData = json['ref_positions'] as Map<String, dynamic>;
//       positionName = posData['position_name'];
//       positionLevel = posData['level'] ?? level;
//       positionColor = posData['color'];
//       positionIcon = posData['icon_name'];
//       final unitPart = json['unit_code'] != null && json['unit_code'].toString().isNotEmpty
//           ? ' - ${json['unit_code']}'
//           : '';
//       fullPosition = '${json['full_name']} - $positionName$unitPart';
//     }
    
//     result.add(ProfileListItem(
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
//       scorePercentage: null,
//       isActiveToday: false,
//       currentSituation: json['current_situation'] ?? 'ACTIVE',
//     ));
//   }
  
//   return result;
// });

// // Model untuk Level Item
// class LevelItem {
//   final int level;
//   final String name;
//   final String color;
//   final String iconName;
//   final int employeeCount; 
  
//   LevelItem({
//     required this.level,
//     required this.name,
//     required this.color,
//     required this.iconName,
//     required this.employeeCount, 
//   });
// }

// // ============================================
// // PROVIDER UNTUK UNIT TREE
// // ============================================

// // Model untuk Unit
// class UnitItem {
//   final String id;
//   final String unitCode;
//   final String unitName;
//   final int? unitLevel;
//   final String? parentUnitId;
//   final List<ProfileListItem> employees;
//   final List<UnitItem> subUnits;

//   UnitItem({
//     required this.id,
//     required this.unitCode,
//     required this.unitName,
//     this.unitLevel,
//     this.parentUnitId,
//     this.employees = const [],
//     this.subUnits = const [],
//   });

//   UnitItem copyWith({
//     String? id,
//     String? unitCode,
//     String? unitName,
//     int? unitLevel,
//     String? parentUnitId,
//     List<ProfileListItem>? employees,
//     List<UnitItem>? subUnits,
//   }) {
//     return UnitItem(
//       id: id ?? this.id,
//       unitCode: unitCode ?? this.unitCode,
//       unitName: unitName ?? this.unitName,
//       unitLevel: unitLevel ?? this.unitLevel,
//       parentUnitId: parentUnitId ?? this.parentUnitId,
//       employees: employees ?? this.employees,
//       subUnits: subUnits ?? this.subUnits,
//     );
//   }
// }

// // Provider untuk mendapatkan semua unit
// final allUnitsProvider = FutureProvider<List<UnitItem>>((ref) async {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('📊 [allUnitsProvider] Mengambil semua unit...');
  
//   final response = await supabase
//       .from('employee_units')
//       .select('''
//         id,
//         unit_code,
//         unit_name,
//         unit_level,
//         parent_unit_id
//       ''')
//       .eq('is_active', true)
//       .order('unit_level', ascending: true)
//       .order('unit_name', ascending: true);
  
//   final Map<String, UnitItem> unitMap = {};
  
//   // Buat semua unit terlebih dahulu
//   for (final row in response) {
//     final id = row['id'] as String;
//     unitMap[id] = UnitItem(
//       id: id,
//       unitCode: row['unit_code'] as String,
//       unitName: row['unit_name'] as String,
//       unitLevel: row['unit_level'] as int?,
//       parentUnitId: row['parent_unit_id'] as String?,
//     );
//   }
  
//   // Susun hierarki unit
//   final List<UnitItem> rootUnits = [];
  
//   for (final unit in unitMap.values) {
//     if (unit.parentUnitId == null || !unitMap.containsKey(unit.parentUnitId)) {
//       rootUnits.add(unit);
//     } else {
//       final parent = unitMap[unit.parentUnitId!];
//       if (parent != null) {
//         final updatedParent = parent.copyWith(
//           subUnits: [...parent.subUnits, unit],
//         );
//         unitMap[parent.id] = updatedParent;
//       }
//     }
//   }
  
//   print('📊 [allUnitsProvider] Ditemukan ${unitMap.length} unit, ${rootUnits.length} root unit');
  
//   return rootUnits;
// });

// // Provider untuk mendapatkan pegawai yang sudah dikelompokkan per unit berdasarkan level
// final employeesGroupedByUnitProvider = FutureProvider.family<List<UnitItem>, int>((ref, level) async {
//   final supabase = ref.read(supabaseClientProvider);
  
//   print('📊 [employeesGroupedByUnitProvider] Mengambil pegawai untuk level $level...');
  
//   // Step 1: Dapatkan semua position_id untuk level tersebut
//   final positionsResponse = await supabase
//       .from('ref_positions')
//       .select('id')
//       .eq('level', level);
  
//   final positionIds = positionsResponse.map((p) => p['id'] as String).toList();
  
//   if (positionIds.isEmpty) {
//     print('📊 [employeesGroupedByUnitProvider] Tidak ada position_id untuk level $level');
//     return [];
//   }
  
//   // Step 2: Dapatkan semua profile dengan position_id tersebut
//   final response = await supabase
//       .from('profiles')
//       .select('''
//         id,
//         full_name,
//         avatar_url,
//         employee_id,
//         unit_code,
//         current_situation,
//         position_id,
//         ref_positions!left(
//           position_name,
//           level,
//           color,
//           icon_name
//         )
//       ''')
//       .eq('is_approved', true)
//       .filter('position_id', 'in', '(${positionIds.map((id) => '"$id"').join(',')})');
  
//   print('📊 [employeesGroupedByUnitProvider] Ditemukan ${response.length} pegawai untuk level $level');
  
//   final List<ProfileListItem> allEmployees = [];
//   final Map<String, List<ProfileListItem>> employeesByUnit = {};
  
//   for (final json in response) {
//     String fullPosition = json['full_name'] ?? '';
//     String? positionName;
//     int positionLevel = level;
//     String? positionColor;
//     String? positionIcon;
//     final unitCode = json['unit_code'] as String?;
    
//     if (json['ref_positions'] != null && json['ref_positions'] is Map) {
//       final posData = json['ref_positions'] as Map<String, dynamic>;
//       positionName = posData['position_name'];
//       positionLevel = posData['level'] ?? level;
//       positionColor = posData['color'];
//       positionIcon = posData['icon_name'];
//       final unitPart = unitCode != null && unitCode.isNotEmpty ? ' - $unitCode' : '';
//       fullPosition = '${json['full_name']} - $positionName$unitPart';
//     }
    
//     final employee = ProfileListItem(
//       id: json['id'].toString(),
//       fullName: json['full_name'] ?? '',
//       avatarUrl: json['avatar_url'],
//       employeeId: json['employee_id'],
//       positionName: positionName,
//       unitCode: unitCode,
//       unitName: unitCode,
//       fullPosition: fullPosition,
//       positionLevel: positionLevel,
//       positionColor: positionColor,
//       positionIcon: positionIcon,
//       scorePercentage: null,
//       isActiveToday: false,
//       currentSituation: json['current_situation'] ?? 'ACTIVE',
//     );
    
//     allEmployees.add(employee);
    
//     // Kelompokkan berdasarkan unit
//     final key = unitCode ?? 'tanpa_unit';
//     if (!employeesByUnit.containsKey(key)) {
//       employeesByUnit[key] = [];
//     }
//     employeesByUnit[key]!.add(employee);
//   }
  
//   // Step 3: Dapatkan informasi unit untuk unit_code yang ada
//   final unitCodes = employeesByUnit.keys.where((k) => k != 'tanpa_unit').toList();
//   final Map<String, UnitItem> unitInfoMap = {};
  
//   if (unitCodes.isNotEmpty) {
//     final unitsResponse = await supabase
//         .from('employee_units')
//         .select('''
//           id,
//           unit_code,
//           unit_name,
//           unit_level,
//           parent_unit_id
//         ''')
//         .inFilter('unit_code', unitCodes);
    
//     for (final row in unitsResponse) {
//       final unitCode = row['unit_code'] as String;
//       unitInfoMap[unitCode] = UnitItem(
//         id: row['id'] as String,
//         unitCode: unitCode,
//         unitName: row['unit_name'] as String,
//         unitLevel: row['unit_level'] as int?,
//         parentUnitId: row['parent_unit_id'] as String?,
//       );
//     }
//   }
  
//   // Step 4: Bangun hasil grouped units
//   final List<UnitItem> result = [];
  
//   // Unit yang memiliki data
//   for (final entry in employeesByUnit.entries) {
//     final unitKey = entry.key;
//     final employees = entry.value;
    
//     if (unitKey == 'tanpa_unit') {
//       // Pegawai tanpa unit
//       if (employees.isNotEmpty) {
//         result.add(UnitItem(
//           id: 'tanpa_unit',
//           unitCode: 'tanpa_unit',
//           unitName: 'TANPA UNIT',
//           unitLevel: 99,
//           employees: employees,
//         ));
//       }
//     } else {
//       // Pegawai dengan unit
//       final unitInfo = unitInfoMap[unitKey];
//       if (unitInfo != null) {
//         result.add(unitInfo.copyWith(employees: employees));
//       } else {
//         // Unit tidak ditemukan di employee_units
//         result.add(UnitItem(
//           id: unitKey,
//           unitCode: unitKey,
//           unitName: unitKey,
//           unitLevel: 99,
//           employees: employees,
//         ));
//       }
//     }
//   }
  
//   // Urutkan berdasarkan unit_level
//   result.sort((a, b) {
//     final levelA = a.unitLevel ?? 99;
//     final levelB = b.unitLevel ?? 99;
//     if (levelA != levelB) return levelA.compareTo(levelB);
//     return a.unitName.compareTo(b.unitName);
//   });
  
//   print('📊 [employeesGroupedByUnitProvider] Terdapat ${result.length} grup unit');
  
//   return result;
// });
// lib/insights/profiles/providers/profile_list_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'supabase_provider.dart';

// ============================================
// SERVICE PROVIDER (TIDAK BERUBAH)
// ============================================
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// ============================================
// PROFILE LIST PROVIDER (TIDAK BERUBAH - UNTUK SUBMENU 1-4)
// ============================================
final profileListProvider = FutureProvider<List<ProfileListItem>>((ref) async {
  print('📊 [profileListProvider] Memanggil service...');
  final service = ref.read(profileServiceProvider);
  final result = await service.getAllProfiles();
  print('📊 [profileListProvider] Selesai. Total profile: ${result.length}');
  return result;
});

// ============================================
// STREAM PROVIDER (UNTUK REALTIME - TETAP ADA)
// ============================================
final profileListStreamProvider = StreamProvider<List<ProfileListItem>>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  print('🔄 [profileListStreamProvider] Memulai stream realtime...');
  return supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .map((response) {
        print('🔄 [profileListStreamProvider] Ada perubahan pada tabel profiles');
        return response.map<ProfileListItem>((json) {
          return ProfileListItem(
            id: json['id'].toString(),
            fullName: json['full_name'] ?? '',
            avatarUrl: json['avatar_url'],
            employeeId: json['employee_id'],
            positionName: null,
            unitCode: json['unit_code'],
            unitName: json['unit_code'],
            fullPosition: json['full_name'] ?? '',
            positionLevel: 99,
            positionColor: null,
            positionIcon: null,
            scorePercentage: null,
            isActiveToday: false,
            currentSituation: json['current_situation'] ?? 'ACTIVE',
          );
        }).toList();
      });
});

// ============================================
// SEARCH & FILTER PROVIDERS (TIDAK BERUBAH)
// ============================================
final profileSearchProvider = StateProvider<String>((ref) => '');
final profileFilterUnitProvider = StateProvider<String?>((ref) => null);

final filteredProfileListProvider = FutureProvider<List<ProfileListItem>>((ref) async {
  final profiles = await ref.watch(profileListProvider.future);
  final searchQuery = ref.watch(profileSearchProvider);
  final filterUnit = ref.watch(profileFilterUnitProvider);
  
  print('🔍 [filteredProfileListProvider] Search: "$searchQuery", Filter Unit: $filterUnit');
  
  if (searchQuery.isEmpty && filterUnit == null) {
    return profiles;
  }
  
  final filtered = profiles.where((profile) {
    bool matches = true;
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      matches = profile.fullName.toLowerCase().contains(query) ||
          (profile.employeeId?.toLowerCase().contains(query) ?? false) ||
          profile.fullPosition.toLowerCase().contains(query);
    }
    if (filterUnit != null && matches) {
      matches = profile.unitCode == filterUnit;
    }
    return matches;
  }).toList();
  
  print('📊 [filteredProfileListProvider] Hasil filter: ${filtered.length} dari ${profiles.length} profile');
  return filtered;
});

final profileTreeProvider = FutureProvider<Map<int, List<ProfileListItem>>>((ref) async {
  final profiles = await ref.watch(filteredProfileListProvider.future);
  print('🌳 [profileTreeProvider] Membangun tree dari ${profiles.length} profile');
  final Map<int, List<ProfileListItem>> grouped = {};
  for (final profile in profiles) {
    final level = profile.positionLevel;
    if (!grouped.containsKey(level)) grouped[level] = [];
    grouped[level]!.add(profile);
  }
  final sortedKeys = grouped.keys.toList()..sort();
  final sortedGrouped = <int, List<ProfileListItem>>{};
  for (final key in sortedKeys) {
    sortedGrouped[key] = grouped[key]!..sort((a, b) => a.fullName.compareTo(b.fullName));
  }
  return sortedGrouped;
});

// ============================================
// LEVEL NAMES PROVIDER (TIDAK BERUBAH)
// ============================================
final levelNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  print('📊 [levelNamesProvider] Mengambil nama level dari database...');
  try {
    final result = await supabase
        .from('ref_positions')
        .select('level, level_name')
        .not('level', 'is', null)
        .order('level', ascending: true);
    final Map<int, String> levelNames = {};
    for (final row in result) {
      final level = row['level'] as int;
      final levelName = row['level_name'] as String?;
      if (!levelNames.containsKey(level)) {
        levelNames[level] = (levelName != null && levelName.isNotEmpty) 
            ? levelName.toUpperCase() 
            : 'LEVEL $level';
      }
    }
    print('📊 [levelNamesProvider] Ditemukan ${levelNames.length} level');
    return levelNames;
  } catch (e) {
    print('❌ [levelNamesProvider] Error: $e');
    return {};
  }
});

// ============================================
// LEVEL NAMES STREAM (REALTIME - TETAP ADA)
// ============================================
final levelNamesStreamProvider = StreamProvider<Map<int, String>>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final stream = supabase.from('ref_positions').stream(primaryKey: ['id']);
  return stream.asyncMap((_) async {
    print('🔄 [levelNamesStreamProvider] Ada perubahan pada tabel positions');
    final result = await supabase
        .from('ref_positions')
        .select('level, level_name')
        .not('level', 'is', null)
        .order('level', ascending: true);
    final Map<int, String> levelNames = {};
    for (final row in result) {
      final level = row['level'] as int;
      final levelName = row['level_name'] as String?;
      if (!levelNames.containsKey(level)) {
        levelNames[level] = (levelName != null && levelName.isNotEmpty) 
            ? levelName.toUpperCase() 
            : 'LEVEL $level';
      }
    }
    return levelNames;
  });
});

// ============================================
// PROVIDER BARU UNTUK SUBMENU 5 (DENGAN CACHE)
// ============================================

// Model untuk Level Item
class LevelItem {
  final int level;
  final String name;
  final String color;
  final String iconName;
  final int employeeCount;

  LevelItem({
    required this.level,
    required this.name,
    required this.color,
    required this.iconName,
    required this.employeeCount,
  });
}

// Model untuk Unit Item
class UnitItem {
  final String id;
  final String unitCode;
  final String unitName;
  final int? unitLevel;
  final String? parentUnitId;
  final List<ProfileListItem> employees;
  final List<UnitItem> subUnits;

  UnitItem({
    required this.id,
    required this.unitCode,
    required this.unitName,
    this.unitLevel,
    this.parentUnitId,
    this.employees = const [],
    this.subUnits = const [],
  });

  UnitItem copyWith({
    String? id,
    String? unitCode,
    String? unitName,
    int? unitLevel,
    String? parentUnitId,
    List<ProfileListItem>? employees,
    List<UnitItem>? subUnits,
  }) {
    return UnitItem(
      id: id ?? this.id,
      unitCode: unitCode ?? this.unitCode,
      unitName: unitName ?? this.unitName,
      unitLevel: unitLevel ?? this.unitLevel,
      parentUnitId: parentUnitId ?? this.parentUnitId,
      employees: employees ?? this.employees,
      subUnits: subUnits ?? this.subUnits,
    );
  }
}

// CACHE untuk allLevelsProvider (agar tidak query ulang setiap saat)
final _allLevelsCacheProvider = StateProvider<AsyncValue<List<LevelItem>>?>((ref) => null);

// All Levels Provider dengan Cache
final allLevelsProvider = FutureProvider<List<LevelItem>>((ref) {
  // Cek cache terlebih dahulu
  final cached = ref.read(_allLevelsCacheProvider);
  if (cached != null && cached is AsyncData<List<LevelItem>>) {
    print('📦 [allLevelsProvider] Mengambil dari cache');
    return Future.value(cached.value);
  }
  
  print('📊 [allLevelsProvider] Mengambil dari database...');
  
  return _fetchAllLevels(ref).then((result) {
    // Simpan ke cache
    ref.read(_allLevelsCacheProvider.notifier).state = AsyncData(result);
    return result;
  });
});

Future<List<LevelItem>> _fetchAllLevels(Ref ref) async {
  final supabase = ref.read(supabaseClientProvider);
  
  // Step 1: Ambil semua level dari ref_positions
  final response = await supabase
      .from('ref_positions')
      .select('level, level_name, color, icon_name')
      .not('level', 'is', null)
      .order('level', ascending: true);
  
  // Step 2: Hitung jumlah pegawai per level
  final profilesResponse = await supabase
      .from('profiles')
      .select('position_id, ref_positions!inner(level)')
      .eq('is_approved', true);
  
  final Map<int, int> employeeCountByLevel = {};
  for (final profile in profilesResponse) {
    final positionData = profile['ref_positions'];
    if (positionData != null && positionData is Map) {
      final level = positionData['level'] as int?;
      if (level != null) {
        employeeCountByLevel[level] = (employeeCountByLevel[level] ?? 0) + 1;
      }
    }
  }
  
  // Step 3: Bangun LevelItem
  final Map<int, LevelItem> levelMap = {};
  for (final row in response) {
    final level = row['level'] as int;
    final levelName = row['level_name'] as String?;
    final color = row['color'] as String?;
    final iconName = row['icon_name'] as String?;
    final employeeCount = employeeCountByLevel[level] ?? 0;
    
    if (!levelMap.containsKey(level)) {
      levelMap[level] = LevelItem(
        level: level,
        name: (levelName != null && levelName.isNotEmpty) 
            ? levelName.toUpperCase() 
            : 'LEVEL $level',
        color: color ?? '#9E9E9E',
        iconName: iconName ?? 'person',
        employeeCount: employeeCount,
      );
    }
  }
  
  final result = levelMap.values.toList()
    ..sort((a, b) => a.level.compareTo(b.level));
  
  print('📊 [allLevelsProvider] Ditemukan ${result.length} level');
  for (final level in result) {
    print('  - Level ${level.level}: ${level.name} (${level.employeeCount} pegawai)');
  }
  
  return result;
}

// CACHE untuk employeesGroupedByUnitProvider
final _employeesGroupedCacheProvider = StateProvider<Map<int, AsyncValue<List<UnitItem>>>>((ref) => {});

// Employees Grouped By Unit Provider dengan Cache
final employeesGroupedByUnitProvider = FutureProvider.family<List<UnitItem>, int>((ref, level) async {
  // Cek cache
  final cache = ref.read(_employeesGroupedCacheProvider);
  if (cache.containsKey(level)) {
    final cachedValue = cache[level];
    if (cachedValue != null && cachedValue is AsyncData<List<UnitItem>>) {
      print('📦 [employeesGroupedByUnitProvider] Mengambil level $level dari cache');
      return cachedValue.value;
    }
  }
  
  print('📊 [employeesGroupedByUnitProvider] Mengambil pegawai untuk level $level dari database...');
  
  final result = await _fetchEmployeesGroupedByUnit(ref, level);
  
  // Simpan ke cache
  final newCache = Map<int, AsyncValue<List<UnitItem>>>.from(cache);
  newCache[level] = AsyncData(result);
  ref.read(_employeesGroupedCacheProvider.notifier).state = newCache;
  
  return result;
});

Future<List<UnitItem>> _fetchEmployeesGroupedByUnit(Ref ref, int level) async {
  final supabase = ref.read(supabaseClientProvider);
  
  // OPTIMASI: 1 Query dengan JOIN
  final positionsResponse = await supabase
      .from('ref_positions')
      .select('id')
      .eq('level', level);
  
  final positionIds = positionsResponse.map((p) => p['id'] as String).toList();
  
  if (positionIds.isEmpty) {
    print('📊 [employeesGroupedByUnitProvider] Tidak ada position_id untuk level $level');
    return [];
  }
  
  // Query tunggal dengan LEFT JOIN ke employee_units
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
        )
      ''')
      .eq('is_approved', true)
      .filter('position_id', 'in', '(${positionIds.map((id) => '"$id"').join(',')})');
  
  print('📊 [employeesGroupedByUnitProvider] Ditemukan ${response.length} pegawai untuk level $level');
  
  // Ambil informasi unit untuk semua unit_code yang ada
  final unitCodes = response
      .map((p) => p['unit_code'] as String?)
      .where((code) => code != null && code.isNotEmpty)
      .toSet()
      .toList();
  
  final Map<String, String> unitNameMap = {};
  
  if (unitCodes.isNotEmpty) {
    final unitsResponse = await supabase
        .from('employee_units')
        .select('unit_code, unit_name')
        .inFilter('unit_code', unitCodes);
    
    for (final unit in unitsResponse) {
      unitNameMap[unit['unit_code'] as String] = unit['unit_name'] as String;
    }
  }
  
  // Kelompokkan berdasarkan unit
  final Map<String, List<ProfileListItem>> employeesByUnit = {};
  
  for (final json in response) {
    String fullPosition = json['full_name'] ?? '';
    String? positionName;
    int positionLevel = level;
    String? positionColor;
    String? positionIcon;
    final unitCode = json['unit_code'] as String?;
    final unitName = (unitCode != null && unitNameMap.containsKey(unitCode))
        ? unitNameMap[unitCode]!
        : (unitCode ?? 'TANPA UNIT');
    
    if (json['ref_positions'] != null && json['ref_positions'] is Map) {
      final posData = json['ref_positions'] as Map<String, dynamic>;
      positionName = posData['position_name'];
      positionLevel = posData['level'] ?? level;
      positionColor = posData['color'];
      positionIcon = posData['icon_name'];
      final unitPart = unitCode != null && unitCode.isNotEmpty ? ' - $unitCode' : '';
      fullPosition = '${json['full_name']} - $positionName$unitPart';
    }
    
    final employee = ProfileListItem(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      employeeId: json['employee_id'],
      positionName: positionName,
      unitCode: unitCode,
      unitName: unitName,
      fullPosition: fullPosition,
      positionLevel: positionLevel,
      positionColor: positionColor,
      positionIcon: positionIcon,
      scorePercentage: null,
      isActiveToday: false,
      currentSituation: json['current_situation'] ?? 'ACTIVE',
    );
    
    final key = unitCode ?? 'tanpa_unit';
    if (!employeesByUnit.containsKey(key)) {
      employeesByUnit[key] = [];
    }
    employeesByUnit[key]!.add(employee);
  }
  
  // Bangun hasil
  final List<UnitItem> result = [];
  for (final entry in employeesByUnit.entries) {
    final unitKey = entry.key;
    final employees = entry.value;
    
    if (unitKey == 'tanpa_unit') {
      result.add(UnitItem(
        id: 'tanpa_unit',
        unitCode: 'tanpa_unit',
        unitName: 'TANPA UNIT',
        unitLevel: 99,
        employees: employees,
      ));
    } else {
      final firstEmployee = employees.first;
      result.add(UnitItem(
        id: unitKey,
        unitCode: unitKey,
        unitName: firstEmployee.unitName ?? firstEmployee.unitCode ?? 'TANPA UNIT',
        unitLevel: null,
        employees: employees,
      ));
    }
  }
  
  result.sort((a, b) => a.unitName.compareTo(b.unitName));
  
  print('📊 [employeesGroupedByUnitProvider] Terdapat ${result.length} grup unit');
  
  return result;
}