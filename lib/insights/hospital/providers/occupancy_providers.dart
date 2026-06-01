// File: lib/insights/hospital/providers/occupancy_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/occupancy_realtime_service.dart';
import '../models/occupancy_summary.dart';

final occupancyServiceProvider = Provider<OccupancyRealtimeService>((ref) {
  return OccupancyRealtimeService();
});

final realtimeOccupancySummaryProvider = StreamProvider<OccupancySummary>((ref) {
  final service = ref.watch(occupancyServiceProvider);
  return service.watchSummary();
});

final realtimeOccupancyPerRoomProvider = StreamProvider<List<OccupancyPerRoom>>((ref) {
  final service = ref.watch(occupancyServiceProvider);
  return service.watchOccupancyPerRoom();
});

final realtimeBedCategoryDistributionProvider = StreamProvider<List<BedCategoryDistribution>>((ref) {
  final service = ref.watch(occupancyServiceProvider);
  return service.watchBedCategoryDistribution();
});

final realtimeActivePatientsProvider = StreamProvider<List<ActivePatient>>((ref) {
  final service = ref.watch(occupancyServiceProvider);
  return service.watchActivePatients();
});

final occupancyStateProvider = Provider<OccupancyState>((ref) {
  final summaryAsync = ref.watch(realtimeOccupancySummaryProvider);
  final perRoomAsync = ref.watch(realtimeOccupancyPerRoomProvider);
  final categoryAsync = ref.watch(realtimeBedCategoryDistributionProvider);
  final patientsAsync = ref.watch(realtimeActivePatientsProvider);

  final summary = summaryAsync.valueOrNull ?? OccupancySummary.empty();
  final perRoom = perRoomAsync.valueOrNull ?? [];
  final categoryDistribution = categoryAsync.valueOrNull ?? [];
  final activePatients = patientsAsync.valueOrNull ?? [];

  final isLoading = 
      summaryAsync.isLoading ||
      perRoomAsync.isLoading ||
      categoryAsync.isLoading ||
      patientsAsync.isLoading;

  final errors = <String>[];
  if (summaryAsync.hasError) errors.add('summary');
  if (perRoomAsync.hasError) errors.add('perRoom');
  if (categoryAsync.hasError) errors.add('category');
  if (patientsAsync.hasError) errors.add('patients');

  final errorMessage = errors.isNotEmpty ? 'Error in: ${errors.join(', ')}' : null;

  return OccupancyState(
    summary: summary,
    perRoom: perRoom,
    categoryDistribution: categoryDistribution,
    activePatients: activePatients,
    isLoading: isLoading && summary.totalBeds == 0,
    errorMessage: errorMessage,
  );
});

class OccupancyState {
  final OccupancySummary summary;
  final List<OccupancyPerRoom> perRoom;
  final List<BedCategoryDistribution> categoryDistribution;
  final List<ActivePatient> activePatients;
  final bool isLoading;
  final String? errorMessage;

  OccupancyState({
    required this.summary,
    required this.perRoom,
    required this.categoryDistribution,
    required this.activePatients,
    this.isLoading = true,
    this.errorMessage,
  });
}

final occupancySummaryProvider = Provider<OccupancySummary>((ref) {
  return ref.watch(occupancyStateProvider).summary;
});

final occupancyPerRoomProvider = Provider<List<OccupancyPerRoom>>((ref) {
  return ref.watch(occupancyStateProvider).perRoom;
});

final occupancyCategoryDistributionProvider = Provider<List<BedCategoryDistribution>>((ref) {
  return ref.watch(occupancyStateProvider).categoryDistribution;
});

final occupancyActivePatientsProvider = Provider<List<ActivePatient>>((ref) {
  return ref.watch(occupancyStateProvider).activePatients;
});

final isOccupancyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(occupancyStateProvider).isLoading;
});

final occupancyErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(occupancyStateProvider).errorMessage;
});