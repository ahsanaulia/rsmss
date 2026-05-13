import 'dart:io';

class AssetInitialState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  
  final String assetName;
  final String? description;
  final String? handlingInstruction;
  final String? maintenancePattern;
  final String? inspectionDayOfMonth;
  final bool isDangerous;
  final File? photo;
  final String condition;
  final int contaminationLevel;
  final String rfidTag;
  
  final List<Map<String, dynamic>> assetTypes;
  final List<Map<String, dynamic>> rooms;
  final String? selectedTypeId;
  final String? selectedTypeName;
  final String? selectedRoomId;
  final String? selectedRoomName;
  
  final String? qrPreviewData;
  final bool isSaved;
  final String? savedAssetId;
  final DateTime? savedDate;
  
  AssetInitialState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.assetName = '',
    this.description,
    this.handlingInstruction,
    this.maintenancePattern,
    this.inspectionDayOfMonth,
    this.isDangerous = false,
    this.photo,
    this.condition = 'Good',
    this.contaminationLevel = 0,
    this.rfidTag = '',
    this.assetTypes = const [],
    this.rooms = const [],
    this.selectedTypeId,
    this.selectedTypeName,
    this.selectedRoomId,
    this.selectedRoomName,
    this.qrPreviewData,
    this.isSaved = false,
    this.savedAssetId,
    this.savedDate,
  });
  
  bool get isValid {
    return assetName.trim().isNotEmpty && 
           selectedTypeId != null && 
           selectedRoomId != null &&
           rfidTag.trim().isNotEmpty;
  }
  
  String get finalQrData {
    return '''
KODE ASSET: ${savedAssetId ?? ''}
RFID: $rfidTag
NAMA ASSET: $assetName
TIPE: ${selectedTypeName ?? ''}
RUANGAN: ${selectedRoomName ?? ''}
TANGGAL: ${savedDate != null ? _formatDate(savedDate!) : ''}
''';
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}';
  }
  
  AssetInitialState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    String? assetName,
    String? description,
    String? handlingInstruction,
    String? maintenancePattern,
    String? inspectionDayOfMonth,
    bool? isDangerous,
    File? photo,
    String? condition,
    int? contaminationLevel,
    String? rfidTag,
    List<Map<String, dynamic>>? assetTypes,
    List<Map<String, dynamic>>? rooms,
    String? selectedTypeId,
    String? selectedTypeName,
    String? selectedRoomId,
    String? selectedRoomName,
    String? qrPreviewData,
    bool? isSaved,
    String? savedAssetId,
    DateTime? savedDate,
  }) {
    return AssetInitialState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      assetName: assetName ?? this.assetName,
      description: description ?? this.description,
      handlingInstruction: handlingInstruction ?? this.handlingInstruction,
      maintenancePattern: maintenancePattern ?? this.maintenancePattern,
      inspectionDayOfMonth: inspectionDayOfMonth ?? this.inspectionDayOfMonth,
      isDangerous: isDangerous ?? this.isDangerous,
      photo: photo ?? this.photo,
      condition: condition ?? this.condition,
      contaminationLevel: contaminationLevel ?? this.contaminationLevel,
      rfidTag: rfidTag ?? this.rfidTag,
      assetTypes: assetTypes ?? this.assetTypes,
      rooms: rooms ?? this.rooms,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      selectedTypeName: selectedTypeName ?? this.selectedTypeName,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      selectedRoomName: selectedRoomName ?? this.selectedRoomName,
      qrPreviewData: qrPreviewData ?? this.qrPreviewData,
      isSaved: isSaved ?? this.isSaved,
      savedAssetId: savedAssetId ?? this.savedAssetId,
      savedDate: savedDate ?? this.savedDate,
    );
  }
}