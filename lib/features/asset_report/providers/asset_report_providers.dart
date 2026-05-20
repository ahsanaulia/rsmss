// ============================================================
// PROVIDERS: Asset Report Providers (Riverpod)
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset_report_model.dart';
import '../services/asset_report_service.dart';

final assetReportServiceProvider = Provider<AssetReportService>((ref) {
  return AssetReportService();
});

class AssetReportState {
  final List<AssetReport> assets;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> assetTypes;
  final List<String> statusConditions;
  final List<String> availabilityStatusOptions;
  final String? selectedTypeId;
  final String? selectedStatusCondition;
  final String? selectedAvailabilityStatus;
  final bool onlyOverdueInspection;

  const AssetReportState({
    this.assets = const [],
    this.isLoading = false,
    this.error,
    this.assetTypes = const [],
    this.statusConditions = const [],
    this.availabilityStatusOptions = const [],
    this.selectedTypeId,
    this.selectedStatusCondition,
    this.selectedAvailabilityStatus,
    this.onlyOverdueInspection = false,
  });

  AssetReportState copyWith({
    List<AssetReport>? assets,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? assetTypes,
    List<String>? statusConditions,
    List<String>? availabilityStatusOptions,
    String? selectedTypeId,
    String? selectedStatusCondition,
    String? selectedAvailabilityStatus,
    bool? onlyOverdueInspection,
  }) {
    return AssetReportState(
      assets: assets ?? this.assets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      assetTypes: assetTypes ?? this.assetTypes,
      statusConditions: statusConditions ?? this.statusConditions,
      availabilityStatusOptions: availabilityStatusOptions ?? this.availabilityStatusOptions,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      selectedStatusCondition: selectedStatusCondition ?? this.selectedStatusCondition,
      selectedAvailabilityStatus: selectedAvailabilityStatus,  // ← PERBAIKAN
      onlyOverdueInspection: onlyOverdueInspection ?? this.onlyOverdueInspection,
    );
  }
}

class AssetReportNotifier extends StateNotifier<AssetReportState> {
  final AssetReportService _service;

  AssetReportNotifier(this._service) : super(const AssetReportState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final assetTypes = await _service.fetchAssetTypes();
    final statusConditions = await _service.fetchStatusConditions();
    final availabilityStatusOptions = _service.getAvailabilityStatusOptions();

    state = state.copyWith(
      assetTypes: assetTypes,
      statusConditions: statusConditions,
      availabilityStatusOptions: availabilityStatusOptions,
    );

    await loadReport();
  }

  Future<void> loadReport() async {
    final typeId = state.selectedTypeId;
    final statusCond = state.selectedStatusCondition;
    final availStatus = state.selectedAvailabilityStatus;
    final overdue = state.onlyOverdueInspection;

    print('========== LOAD REPORT ==========');
    print('typeId: $typeId');
    print('availStatus: $availStatus');
    print('==================================');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final assets = await _service.fetchFilteredAssets(
        typeId: typeId,
        statusCondition: statusCond,
        availabilityStatus: availStatus,
        onlyOverdueInspection: overdue,
      );

      state = state.copyWith(assets: assets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateTypeFilter(String? typeId) {
    state = state.copyWith(selectedTypeId: typeId);
    loadReport();
  }

  void updateStatusConditionFilter(String? condition) {
    state = state.copyWith(selectedStatusCondition: condition);
    loadReport();
  }

  void updateAvailabilityStatusFilter(String? status) {
    print('UPDATE AVAILABILITY - status: $status');
    state = state.copyWith(selectedAvailabilityStatus: status);
    loadReport();
  }

  void updateOverdueInspectionFilter(bool value) {
    state = state.copyWith(onlyOverdueInspection: value);
    loadReport();
  }

  void resetFilters() {
    print('========== RESET FILTERS ==========');
    
    state = AssetReportState(
      assets: state.assets,
      isLoading: state.isLoading,
      error: state.error,
      assetTypes: state.assetTypes,
      statusConditions: state.statusConditions,
      availabilityStatusOptions: state.availabilityStatusOptions,
      selectedTypeId: null,
      selectedStatusCondition: null,
      selectedAvailabilityStatus: null,
      onlyOverdueInspection: false,
    );
    
    print('AFTER reset - availStatus: ${state.selectedAvailabilityStatus}');
    print('===================================');
    
    loadReport();
  }
}

final assetReportProvider = StateNotifierProvider<AssetReportNotifier, AssetReportState>((ref) {
  final service = ref.read(assetReportServiceProvider);
  return AssetReportNotifier(service);
});