// ============================================================
// PROVIDERS: Asset Providers (Riverpod)
// ============================================================
// TANGGUNG JAWAB:
// 1. State management untuk list aset
// 2. State management untuk detail aset
// 3. State management untuk form (loading, error, submit)
// 4. Mengintegrasikan AssetService dengan AuthService
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset_model.dart';
import '../services/asset_service.dart';
import '../../../../core/services/auth_service.dart';

// ============================================================
// SECTION 1: SERVICE PROVIDERS
// ============================================================

/// Provider untuk AssetService (singleton)
final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService();
});

/// Provider untuk AuthService (mengambil dari core/services yang sudah ada)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ============================================================
// SECTION 2: LIST ASET PROVIDER
// ============================================================

/// State untuk list aset
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
}

/// Notifier untuk mengelola list aset
class AssetListNotifier extends StateNotifier<AssetListState> {
  final Ref _ref;
  final AssetService _assetService;

  AssetListNotifier(this._ref, this._assetService) : super(const AssetListState());

  /// Load semua aset
  Future<void> loadAssets() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final assets = await _assetService.fetchAllAssets();
      state = state.copyWith(
        assets: assets,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search aset berdasarkan keyword
  Future<void> searchAssets(String keyword) async {
    state = state.copyWith(isLoading: true, error: null, searchKeyword: keyword);
    
    try {
      final assets = await _assetService.searchAssets(keyword);
      state = state.copyWith(
        assets: assets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filter aset berdasarkan status
  Future<void> filterByStatus(String? status) async {
    state = state.copyWith(isLoading: true, error: null, filterStatus: status);
    
    try {
      List<Asset> assets;
      if (status == null || status.isEmpty) {
        assets = await _assetService.fetchAllAssets();
      } else {
        assets = await _assetService.filterAssetsByStatus(status);
      }
      state = state.copyWith(
        assets: assets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset filter dan search
  Future<void> resetFilter() async {
    state = state.copyWith(searchKeyword: null, filterStatus: null);
    await loadAssets();
  }

  /// Hapus aset (soft delete)
  Future<bool> deleteAsset(String assetId) async {
    try {
      final userId = _ref.read(authServiceProvider).currentUserId;
      if (userId == null) {
        state = state.copyWith(error: 'User tidak ditemukan');
        return false;
      }
      
      final success = await _assetService.deleteAsset(assetId, userId);
      if (success) {
        await loadAssets();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider untuk list aset
final assetListProvider = StateNotifierProvider<AssetListNotifier, AssetListState>((ref) {
  final assetService = ref.read(assetServiceProvider);
  return AssetListNotifier(ref, assetService);
});

// ============================================================
// SECTION 3: DETAIL ASET PROVIDER
// ============================================================

/// State untuk detail aset
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
      error: error,
    );
  }
}

/// Notifier untuk mengelola detail aset
class AssetDetailNotifier extends StateNotifier<AssetDetailState> {
  final AssetService _assetService;

  AssetDetailNotifier(this._assetService) : super(const AssetDetailState());

  /// Load detail aset berdasarkan ID
  Future<void> loadAsset(String assetId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final asset = await _assetService.fetchAssetById(assetId);
      state = state.copyWith(
        asset: asset,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear state (untuk navigasi keluar)
  void clear() {
    state = const AssetDetailState();
  }
}

/// Provider untuk detail aset (menerima parameter assetId)
final assetDetailProvider = StateNotifierProviderFamily<AssetDetailNotifier, AssetDetailState, String>((ref, assetId) {
  final assetService = ref.read(assetServiceProvider);
  final notifier = AssetDetailNotifier(assetService);
  notifier.loadAsset(assetId);
  return notifier;
});

// ============================================================
// SECTION 4: FORM ASET PROVIDER
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
}

/// Notifier untuk mengelola form aset
class AssetFormNotifier extends StateNotifier<AssetFormState> {
  final Ref _ref;
  final AssetService _assetService;

  AssetFormNotifier(this._ref, this._assetService)
      : super(AssetFormState(asset: Asset.empty())) {
    loadDropdownData();
  }

  /// Load data untuk dropdown
  Future<void> loadDropdownData() async {
    // Load rooms
    state = state.copyWith(isLoadingRooms: true);
    try {
      final roomsData = await _assetService.fetchAllRooms();
      final rooms = roomsData.map((json) => RoomDropdownData.fromJson(json)).toList();
      state = state.copyWith(rooms: rooms, isLoadingRooms: false);
    } catch (e) {
      state = state.copyWith(isLoadingRooms: false);
    }

    // Load asset types
    state = state.copyWith(isLoadingTypes: true);
    try {
      final typesData = await _assetService.fetchAllAssetTypes();
      final assetTypes = typesData.map((json) => AssetTypeDropdownData.fromJson(json)).toList();
      state = state.copyWith(assetTypes: assetTypes, isLoadingTypes: false);
    } catch (e) {
      state = state.copyWith(isLoadingTypes: false);
    }

    // Load maintenance patterns
    state = state.copyWith(isLoadingPatterns: true);
    try {
      final patterns = await _assetService.fetchMaintenancePatterns();
      state = state.copyWith(maintenancePatterns: patterns, isLoadingPatterns: false);
    } catch (e) {
      state = state.copyWith(isLoadingPatterns: false);
    }

    // Load danger levels
    state = state.copyWith(isLoadingDangerLevels: true);
    try {
      final dangerLevelsData = await _assetService.fetchAllDangerLevels();
      final dangerLevels = dangerLevelsData.map((json) => DangerLevelDropdownData.fromJson(json)).toList();
      state = state.copyWith(dangerLevels: dangerLevels, isLoadingDangerLevels: false);
    } catch (e) {
      state = state.copyWith(isLoadingDangerLevels: false);
    }
  }

  /// Set data untuk edit mode
  void setEditingAsset(Asset asset) {
    state = state.copyWith(
      asset: asset,
      isEditing: true,
      selectedDangerLevelId: asset.dangerLevelId,
    );
  }

  /// Update field form
  void updateField({
    String? rfidTagId,
    String? assetName,
    String? typeId,
    String? fotoUrl,
    String? statusCondition,
    int? levelContaminated,
    bool? isDangerous,
    String? handlingInstruction,
    String? maintenancePattern,
    int? inspectionDayOfMonth,
    bool? isActive,
    String? description,
    String? lastRoomId,
  }) {
    final updatedAsset = state.asset.copyWith(
      rfidTagId: rfidTagId ?? state.asset.rfidTagId,
      assetName: assetName ?? state.asset.assetName,
      typeId: typeId ?? state.asset.typeId,
      fotoUrl: fotoUrl ?? state.asset.fotoUrl,
      statusCondition: statusCondition ?? state.asset.statusCondition,
      levelContaminated: levelContaminated ?? state.asset.levelContaminated,
      isDangerous: isDangerous ?? state.asset.isDangerous,
      handlingInstruction: handlingInstruction ?? state.asset.handlingInstruction,
      maintenancePattern: maintenancePattern ?? state.asset.maintenancePattern,
      inspectionDayOfMonth: inspectionDayOfMonth ?? state.asset.inspectionDayOfMonth,
      isActive: isActive ?? state.asset.isActive,
      description: description ?? state.asset.description,
      lastRoomId: lastRoomId ?? state.asset.lastRoomId,
    );
    
    state = state.copyWith(asset: updatedAsset, error: null);
  }

  /// Update danger level
  void updateDangerLevel(String? dangerLevelId) {
    final updatedAsset = state.asset.copyWith(dangerLevelId: dangerLevelId);
    state = state.copyWith(
      asset: updatedAsset,
      selectedDangerLevelId: dangerLevelId,
      error: null,
    );
  }

  /// Update foto URL setelah upload
  void updateFotoUrl(String fotoUrl) {
    final updatedAsset = state.asset.copyWith(fotoUrl: fotoUrl);
    state = state.copyWith(asset: updatedAsset);
  }

  /// Submit form (create atau update)
  Future<bool> submit() async {
    // Validasi
    if (state.asset.rfidTagId.isEmpty) {
      state = state.copyWith(error: 'RFID Tag ID wajib diisi');
      return false;
    }
    if (state.asset.assetName.isEmpty) {
      state = state.copyWith(error: 'Nama aset wajib diisi');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userId = _ref.read(authServiceProvider).currentUserId;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'User tidak ditemukan');
        return false;
      }

      if (state.isEditing) {
        await _assetService.updateAsset(state.asset, userId);
      } else {
        await _assetService.createAsset(state.asset, userId);
      }
      
      state = state.copyWith(isLoading: false);
      return true;
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset form ke empty state
  void resetForm() {
    state = AssetFormState(asset: Asset.empty());
    loadDropdownData();
  }
}

/// Provider untuk form aset
final assetFormProvider = StateNotifierProvider<AssetFormNotifier, AssetFormState>((ref) {
  final assetService = ref.read(assetServiceProvider);
  return AssetFormNotifier(ref, assetService);
});