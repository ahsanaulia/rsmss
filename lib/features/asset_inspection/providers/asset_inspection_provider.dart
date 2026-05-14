import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/asset_inspection_service.dart';
import 'asset_inspection_state.dart';
import '../models/asset_inspection_input_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final assetInspectionServiceProvider = Provider<AssetInspectionService>((ref) {
  return AssetInspectionService();
});

final assetInspectionStateProvider =
    StateNotifierProvider<AssetInspectionNotifier, AssetInspectionState>((ref) {
  final service = ref.read(assetInspectionServiceProvider);
  final authService = getIt<AuthService>();
  return AssetInspectionNotifier(service, authService);
});

class AssetInspectionNotifier extends StateNotifier<AssetInspectionState> {
  final AssetInspectionService _service;
  final AuthService _authService;

  AssetInspectionNotifier(this._service, this._authService)
      : super(AssetInspectionState()) {
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    state = state.copyWith(isLoading: true);

    try {
      final assets = await _service.loadActiveAssets();
      state = state.copyWith(
        isLoading: false,
        assets: assets,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load asset: $e',
      );
    }
  }

  void selectAsset(String assetId) {
    final asset = state.assets.firstWhere((a) => a['id'] == assetId);
    state = state.copyWith(
      selectedAssetId: assetId,
      selectedAsset: asset,
    );
  }

  void updateInspectionType(String value) {
    state = state.copyWith(inspectionType: value);
  }

  void updateInspectionResult(String value) {
    state = state.copyWith(inspectionResult: value);
  }

  void updateConditionStatus(String value) {
    state = state.copyWith(conditionStatus: value);
  }

  void updateContaminationLevel(int value) {
    state = state.copyWith(contaminationLevel: value);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void updateActionTaken(String value) {
    state = state.copyWith(actionTaken: value);
  }

  void updateRecommendation(String value) {
    state = state.copyWith(recommendation: value);
  }

  void updateNextInspectionAt(DateTime? date) {
    state = state.copyWith(nextInspectionAt: date);
  }

  void updateInspectionDurationMinutes(int value) {
    state = state.copyWith(inspectionDurationMinutes: value);
  }

  void updatePhoto(File? photo) {
    state = state.copyWith(photo: photo);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetToForm() {
    state = AssetInspectionState();
    _loadAssets();
  }

  Future<bool> saveInspection() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Pilih asset terlebih dahulu');
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired, silakan login ulang');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final input = AssetInspectionInputModel(
        assetId: state.selectedAssetId!,
        inspectedBy: userId,
        inspectionType: state.inspectionType,
        inspectionResult: state.inspectionResult,
        conditionStatus: state.conditionStatus,
        contaminationLevel: state.contaminationLevel,
        notes: state.notes.isEmpty ? null : state.notes,
        actionTaken: state.actionTaken.isEmpty ? null : state.actionTaken,
        recommendation: state.recommendation.isEmpty ? null : state.recommendation,
        nextInspectionAt: state.nextInspectionAt,
        inspectionDurationMinutes: state.inspectionDurationMinutes > 0
            ? state.inspectionDurationMinutes
            : null,
        photo: state.photo,
      );

      await _service.saveInspection(input: input, photo: state.photo);

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage: 'Inspeksi berhasil disimpan',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan inspeksi: $e',
      );
      return false;
    }
  }
}