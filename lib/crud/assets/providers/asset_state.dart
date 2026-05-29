// ============================================================
// ASSET STATE
// ============================================================
// TANGGUNG JAWAB:
// 1. Mendefinisikan semua state class untuk Asset management
// 2. Memisahkan state dari logic (separation of concerns)
// 3. Digunakan oleh asset_providers.dart
// ============================================================

import '../models/asset_model.dart';

// ============================================================
// STATE UNTUK ASSET LIST PAGE
// ============================================================

/// State untuk halaman daftar aset
class AssetListState {
  final List<Asset> assets;
  final bool isLoading;
  final String? error;
  final String? searchKeyword;
  final String? filterStatus;

  const AssetListState({
    this.assets = const [],
    this.isLoading = false,
    this.error,
    this.searchKeyword,
    this.filterStatus,
  });

  AssetListState copyWith({
    List<Asset>? assets,
    bool? isLoading,
    String? error,
    String? searchKeyword,
    String? filterStatus,
  }) {
    return AssetListState(
      assets: assets ?? this.assets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  String toString() {
    return 'AssetListState(assets: ${assets.length}, isLoading: $isLoading, error: $error)';
  }
}

// ============================================================
// STATE UNTUK ASSET DETAIL PAGE
// ============================================================

/// State untuk halaman detail aset
class AssetDetailState {
  final Asset? asset;
  final bool isLoading;
  final String? error;

  const AssetDetailState({
    this.asset,
    this.isLoading = false,
    this.error,
  });

  AssetDetailState copyWith({
    Asset? asset,
    bool? isLoading,
    String? error,
  }) {
    return AssetDetailState(
      asset: asset ?? this.asset,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AssetDetailState(assetId: ${asset?.id}, isLoading: $isLoading, error: $error)';
  }
}

// ============================================================
// STATE UNTUK ASSET FORM (CREATE/EDIT)
// ============================================================

/// Data untuk dropdown room
class RoomDropdownData {
  final String id;
  final String roomName;

  const RoomDropdownData({
    required this.id,
    required this.roomName,
  });

  factory RoomDropdownData.fromJson(Map<String, dynamic> json) {
    return RoomDropdownData(
      id: json['id'] as String,
      roomName: json['room_name'] as String,
    );
  }
}

/// Data untuk dropdown asset type (dengan hierarki kategori)
class AssetTypeDropdownData {
  final String id;
  final String typeName;
  final String displayName;
  final String categoryName;
  final String subCategoryName;

  const AssetTypeDropdownData({
    required this.id,
    required this.typeName,
    required this.displayName,
    required this.categoryName,
    required this.subCategoryName,
  });

  factory AssetTypeDropdownData.fromJson(Map<String, dynamic> json) {
    return AssetTypeDropdownData(
      id: json['id'] as String,
      typeName: json['type_name'] as String,
      displayName: json['display_name'] as String,
      categoryName: json['category_name'] as String,
      subCategoryName: json['sub_category_name'] as String,
    );
  }
}

/// Data untuk dropdown danger level
class DangerLevelDropdownData {
  final String id;
  final String levelCode;
  final String levelName;
  final String? colorHex;

  const DangerLevelDropdownData({
    required this.id,
    required this.levelCode,
    required this.levelName,
    this.colorHex,
  });

  factory DangerLevelDropdownData.fromJson(Map<String, dynamic> json) {
    return DangerLevelDropdownData(
      id: json['id'] as String,
      levelCode: json['level_code'] as String,
      levelName: json['level_name'] as String,
      colorHex: json['color_hex'] as String?,
    );
  }
}

/// State untuk form aset (create/edit)
class AssetFormState {
  final Asset asset;
  final bool isLoading;
  final String? error;
  final bool isEditing;
  
  // Data untuk dropdown
  final List<RoomDropdownData> rooms;
  final List<AssetTypeDropdownData> assetTypes;
  final List<String> maintenancePatterns;
  final List<DangerLevelDropdownData> dangerLevels;
  
  // Selected values
  final String? selectedDangerLevelId;
  
  // Loading status untuk masing-masing dropdown
  final bool isLoadingRooms;
  final bool isLoadingTypes;
  final bool isLoadingPatterns;
  final bool isLoadingDangerLevels;

  const AssetFormState({
    required this.asset,
    this.isLoading = false,
    this.error,
    this.isEditing = false,
    this.rooms = const [],
    this.assetTypes = const [],
    this.maintenancePatterns = const [],
    this.dangerLevels = const [],
    this.selectedDangerLevelId,
    this.isLoadingRooms = false,
    this.isLoadingTypes = false,
    this.isLoadingPatterns = false,
    this.isLoadingDangerLevels = false,
  });

  AssetFormState copyWith({
    Asset? asset,
    bool? isLoading,
    String? error,
    bool? isEditing,
    List<RoomDropdownData>? rooms,
    List<AssetTypeDropdownData>? assetTypes,
    List<String>? maintenancePatterns,
    List<DangerLevelDropdownData>? dangerLevels,
    String? selectedDangerLevelId,
    bool? isLoadingRooms,
    bool? isLoadingTypes,
    bool? isLoadingPatterns,
    bool? isLoadingDangerLevels,
  }) {
    return AssetFormState(
      asset: asset ?? this.asset,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      rooms: rooms ?? this.rooms,
      assetTypes: assetTypes ?? this.assetTypes,
      maintenancePatterns: maintenancePatterns ?? this.maintenancePatterns,
      dangerLevels: dangerLevels ?? this.dangerLevels,
      selectedDangerLevelId: selectedDangerLevelId ?? this.selectedDangerLevelId,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
      isLoadingTypes: isLoadingTypes ?? this.isLoadingTypes,
      isLoadingPatterns: isLoadingPatterns ?? this.isLoadingPatterns,
      isLoadingDangerLevels: isLoadingDangerLevels ?? this.isLoadingDangerLevels,
    );
  }

  @override
  String toString() {
    return 'AssetFormState(assetName: ${asset.assetName}, isLoading: $isLoading, error: $error)';
  }
}