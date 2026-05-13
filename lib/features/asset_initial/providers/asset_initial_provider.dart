import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/asset_service.dart';
import 'asset_initial_state.dart';
import '../models/asset_input_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService();
});

final assetInitialStateProvider = StateNotifierProvider<AssetInitialNotifier, AssetInitialState>((ref) {
  final assetService = ref.read(assetServiceProvider);
  final authService = getIt<AuthService>();
  return AssetInitialNotifier(assetService, authService);
});

class AssetInitialNotifier extends StateNotifier<AssetInitialState> {
  final AssetService _assetService;
  final AuthService _authService;
  
  AssetInitialNotifier(this._assetService, this._authService) : super(AssetInitialState()) {
    _loadInitialData();
    _generateInitialRfidTag();
  }
  
  void _generateInitialRfidTag() {
    final newTag = _assetService.generateRfidTag();
    state = state.copyWith(rfidTag: newTag);
  }
  
  void updateRfidTag(String value) {
    state = state.copyWith(rfidTag: value);
    _updateQrPreview();
  }
  
  void _updateQrPreview() {
    if (state.assetName.isNotEmpty && 
        state.selectedTypeName != null && 
        state.selectedRoomName != null &&
        state.rfidTag.isNotEmpty) {
      final previewData = '''
RFID:${state.rfidTag}
NAMA:${state.assetName}
TIPE:${state.selectedTypeName}
RUANGAN:${state.selectedRoomName}
''';
      state = state.copyWith(qrPreviewData: previewData);
    } else {
      state = state.copyWith(qrPreviewData: null);
    }
  }
  
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final types = await _assetService.loadAssetTypes();
      final rooms = await _assetService.loadRooms();
      
      state = state.copyWith(
        isLoading: false,
        assetTypes: types,
        rooms: rooms,
      );
      _updateQrPreview();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load data: $e',
      );
    }
  }
  
  void updateAssetName(String value) {
    state = state.copyWith(assetName: value);
    _updateQrPreview();
  }
  
  void updateDescription(String value) {
    state = state.copyWith(description: value.isEmpty ? null : value);
  }
  
  void updateHandlingInstruction(String value) {
    state = state.copyWith(handlingInstruction: value.isEmpty ? null : value);
  }
  
  void updateMaintenancePattern(String value) {
    state = state.copyWith(maintenancePattern: value.isEmpty ? null : value);
  }
  
  void updateInspectionDay(String value) {
    state = state.copyWith(inspectionDayOfMonth: value.isEmpty ? null : value);
  }
  
  void toggleDangerous(bool value) {
    state = state.copyWith(isDangerous: value);
  }
  
  void updatePhoto(File? photo) {
    state = state.copyWith(photo: photo);
  }
  
  void updateCondition(String condition) {
    state = state.copyWith(condition: condition);
  }
  
  void updateContaminationLevel(int level) {
    state = state.copyWith(contaminationLevel: level);
  }
  
  void selectAssetType(String id, String name) {
    state = state.copyWith(
      selectedTypeId: id,
      selectedTypeName: name,
    );
    _updateQrPreview();
  }
  
  void selectRoom(String id, String name) {
    state = state.copyWith(
      selectedRoomId: id,
      selectedRoomName: name,
    );
    _updateQrPreview();
  }
  
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
  
  Future<bool> saveAsset() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Lengkapi semua data wajib');
      return false;
    }
    
    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired, silakan login ulang');
      return false;
    }
    
    state = state.copyWith(isSaving: true, errorMessage: null);
    
    try {
      final input = AssetInputModel(
        assetName: state.assetName,
        description: state.description,
        handlingInstruction: state.handlingInstruction,
        maintenancePattern: state.maintenancePattern,
        inspectionDayOfMonth: state.inspectionDayOfMonth != null 
            ? int.tryParse(state.inspectionDayOfMonth!) 
            : null,
        isDangerous: state.isDangerous,
        photo: state.photo,
        condition: state.condition,
        contaminationLevel: state.contaminationLevel,
        typeId: state.selectedTypeId!,
        typeName: state.selectedTypeName!,
        roomId: state.selectedRoomId!,
        roomName: state.selectedRoomName!,
        rfidTag: state.rfidTag,
      );
      
      final result = await _assetService.saveAsset(
        input: input,
        registeredBy: userId,
      );
      
      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        savedAssetId: result['assetId'],
        savedDate: DateTime.now(),
        successMessage: 'Asset berhasil disimpan',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan asset: $e',
      );
      return false;
    }
  }
  
  void resetToForm() {
    state = AssetInitialState();
    _loadInitialData();
    _generateInitialRfidTag();
  }
}