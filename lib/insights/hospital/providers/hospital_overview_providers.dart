// File: lib/insights/hospital/providers/hospital_overview_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hospital_overview_realtime_service.dart';
import '../models/hospital_overview_summary.dart';
import '../models/hospital_profile_model.dart';
import '../models/hospital_organization_model.dart';

final hospitalOverviewServiceProvider = Provider<HospitalOverviewRealtimeService>((ref) {
  return HospitalOverviewRealtimeService();
});

final realtimeHospitalProfileProvider = StreamProvider<HospitalProfileModel>((ref) {
  final service = ref.watch(hospitalOverviewServiceProvider);
  return service.watchHospitalProfile();
});

final realtimeHospitalSummaryProvider = StreamProvider<HospitalOverviewSummary>((ref) {
  final service = ref.watch(hospitalOverviewServiceProvider);
  return service.watchSummary();
});

final realtimeRoomCategoryDistributionProvider = StreamProvider<List<RoomCategoryDistribution>>((ref) {
  final service = ref.watch(hospitalOverviewServiceProvider);
  return service.watchRoomCategoryDistribution();
});

final realtimeEmployeePerUnitProvider = StreamProvider<List<EmployeePerUnit>>((ref) {
  final service = ref.watch(hospitalOverviewServiceProvider);
  return service.watchEmployeePerUnit();
});

final realtimeEmployeeHierarchyProvider = StreamProvider<List<EmployeeUnitNode>>((ref) {
  final service = ref.watch(hospitalOverviewServiceProvider);
  return service.watchEmployeeHierarchy();
});

final realtimeBuildingHierarchyProvider = StreamProvider<List<BuildingNode>>((ref) {
  final service = ref.watch(hospitalOverviewServiceProvider);
  return service.watchBuildingHierarchy();
});

final hospitalOverviewStateProvider = Provider<HospitalOverviewState>((ref) {
  final profileAsync = ref.watch(realtimeHospitalProfileProvider);
  final summaryAsync = ref.watch(realtimeHospitalSummaryProvider);
  final roomCategoryAsync = ref.watch(realtimeRoomCategoryDistributionProvider);
  final employeePerUnitAsync = ref.watch(realtimeEmployeePerUnitProvider);
  final employeeHierarchyAsync = ref.watch(realtimeEmployeeHierarchyProvider);
  final buildingHierarchyAsync = ref.watch(realtimeBuildingHierarchyProvider);

  final profile = profileAsync.valueOrNull ?? HospitalProfileModel.empty();
  final summary = summaryAsync.valueOrNull ?? HospitalOverviewSummary.empty();
  final roomCategories = roomCategoryAsync.valueOrNull ?? [];
  final employeePerUnit = employeePerUnitAsync.valueOrNull ?? [];
  final employeeHierarchy = employeeHierarchyAsync.valueOrNull ?? [];
  final buildingHierarchy = buildingHierarchyAsync.valueOrNull ?? [];



  // TAMBAHKAN DEBUG
  print('🏥 PROFILE: hasValue=${profileAsync.hasValue}, isLoading=${profileAsync.isLoading}, hasError=${profileAsync.hasError}');
  print('🏥 SUMMARY: hasValue=${summaryAsync.hasValue}, isLoading=${summaryAsync.isLoading}, hasError=${summaryAsync.hasError}');
  print('🏥 ROOM CATEGORY: hasValue=${roomCategoryAsync.hasValue}, isLoading=${roomCategoryAsync.isLoading}');
  print('🏥 EMPLOYEE PER UNIT: hasValue=${employeePerUnitAsync.hasValue}, isLoading=${employeePerUnitAsync.isLoading}');
  print('🏥 EMPLOYEE HIERARCHY: hasValue=${employeeHierarchyAsync.hasValue}, isLoading=${employeeHierarchyAsync.isLoading}');
  print('🏥 BUILDING HIERARCHY: hasValue=${buildingHierarchyAsync.hasValue}, isLoading=${buildingHierarchyAsync.isLoading}');


print('📊 PROFILE DATA: name=${profile.name}, totalBuildings=${summary.totalBuildings}');
 print('📊 ROOM CATEGORIES: ${roomCategories.length}');
  print('📊 EMPLOYEE PER UNIT: ${employeePerUnit.length}');
print('📊 EMPLOYEE HIERARCHY: ${employeeHierarchy.length}');
 print('📊 BUILDING HIERARCHY: ${buildingHierarchy.length}');

  final isLoading = 
      profileAsync.isLoading ||
      summaryAsync.isLoading ||
      roomCategoryAsync.isLoading ||
      employeePerUnitAsync.isLoading ||
      employeeHierarchyAsync.isLoading ||
      buildingHierarchyAsync.isLoading;

  final errors = <String>[];
  if (profileAsync.hasError) errors.add('profile');
  if (summaryAsync.hasError) errors.add('summary');
  if (roomCategoryAsync.hasError) errors.add('roomCategory');
  if (employeePerUnitAsync.hasError) errors.add('employeePerUnit');
  if (employeeHierarchyAsync.hasError) errors.add('employeeHierarchy');
  if (buildingHierarchyAsync.hasError) errors.add('buildingHierarchy');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return HospitalOverviewState(
    profile: profile,
    summary: summary,
    roomCategories: roomCategories,
    employeePerUnit: employeePerUnit,
    employeeHierarchy: employeeHierarchy,
    buildingHierarchy: buildingHierarchy,
    isLoading: isLoading && summary.totalBuildings == 0,
    errorMessage: errorMessage,
  );
});

class HospitalOverviewState {
  final HospitalProfileModel profile;
  final HospitalOverviewSummary summary;
  final List<RoomCategoryDistribution> roomCategories;
  final List<EmployeePerUnit> employeePerUnit;
  final List<EmployeeUnitNode> employeeHierarchy;
  final List<BuildingNode> buildingHierarchy;
  final bool isLoading;
  final String? errorMessage;

  HospitalOverviewState({
    required this.profile,
    required this.summary,
    required this.roomCategories,
    required this.employeePerUnit,
    required this.employeeHierarchy,
    required this.buildingHierarchy,
    this.isLoading = true,
    this.errorMessage,
  });
}

// Selectors
final hospitalProfileProvider = Provider<HospitalProfileModel>((ref) {
  return ref.watch(hospitalOverviewStateProvider).profile;
});

final hospitalSummaryProvider = Provider<HospitalOverviewSummary>((ref) {
  return ref.watch(hospitalOverviewStateProvider).summary;
});

final hospitalRoomCategoriesProvider = Provider<List<RoomCategoryDistribution>>((ref) {
  return ref.watch(hospitalOverviewStateProvider).roomCategories;
});

final hospitalEmployeePerUnitProvider = Provider<List<EmployeePerUnit>>((ref) {
  return ref.watch(hospitalOverviewStateProvider).employeePerUnit;
});

final hospitalEmployeeHierarchyProvider = Provider<List<EmployeeUnitNode>>((ref) {
  return ref.watch(hospitalOverviewStateProvider).employeeHierarchy;
});

final hospitalBuildingHierarchyProvider = Provider<List<BuildingNode>>((ref) {
  return ref.watch(hospitalOverviewStateProvider).buildingHierarchy;
});

final isHospitalOverviewLoadingProvider = Provider<bool>((ref) {
  return ref.watch(hospitalOverviewStateProvider).isLoading;
});

final hospitalOverviewErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(hospitalOverviewStateProvider).errorMessage;
});


