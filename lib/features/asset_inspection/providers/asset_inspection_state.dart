import 'dart:io';

class AssetInspectionState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  // List asset
  final List<Map<String, dynamic>> assets;
  final String? selectedAssetId;
  final Map<String, dynamic>? selectedAsset;

  // Form fields
  final String inspectionType;
  final String inspectionResult;
  final String conditionStatus;
  final int contaminationLevel;
  final String notes;
  final String actionTaken;
  final String recommendation;
  final DateTime? nextInspectionAt;
  final int inspectionDurationMinutes;
  final File? photo;

  // UI state
  final bool isSaved;

  AssetInspectionState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.assets = const [],
    this.selectedAssetId,
    this.selectedAsset,
    this.inspectionType = 'Routine',
    this.inspectionResult = 'Pass',
    this.conditionStatus = 'Good',
    this.contaminationLevel = 0,
    this.notes = '',
    this.actionTaken = '',
    this.recommendation = '',
    this.nextInspectionAt,
    this.inspectionDurationMinutes = 0,
    this.photo,
    this.isSaved = false,
  });

  bool get isValid {
    return selectedAssetId != null &&
        selectedAssetId!.isNotEmpty &&
        conditionStatus.isNotEmpty;
  }

  AssetInspectionState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<Map<String, dynamic>>? assets,
    String? selectedAssetId,
    Map<String, dynamic>? selectedAsset,
    String? inspectionType,
    String? inspectionResult,
    String? conditionStatus,
    int? contaminationLevel,
    String? notes,
    String? actionTaken,
    String? recommendation,
    DateTime? nextInspectionAt,
    int? inspectionDurationMinutes,
    File? photo,
    bool? isSaved,
  }) {
    return AssetInspectionState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      assets: assets ?? this.assets,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      inspectionType: inspectionType ?? this.inspectionType,
      inspectionResult: inspectionResult ?? this.inspectionResult,
      conditionStatus: conditionStatus ?? this.conditionStatus,
      contaminationLevel: contaminationLevel ?? this.contaminationLevel,
      notes: notes ?? this.notes,
      actionTaken: actionTaken ?? this.actionTaken,
      recommendation: recommendation ?? this.recommendation,
      nextInspectionAt: nextInspectionAt ?? this.nextInspectionAt,
      inspectionDurationMinutes: inspectionDurationMinutes ?? this.inspectionDurationMinutes,
      photo: photo ?? this.photo,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}