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
  // Menggunakan AuthService yang sudah ada di project
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
    // Set loading state
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
        // Reload list setelah delete
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
  // Load otomatis saat provider dipanggil
  notifier.loadAsset(assetId);
  return notifier;
});

// ============================================================
// SECTION 4: FORM ASET PROVIDER
// ============================================================

/// State untuk form (create/edit)
class AssetFormState {
  final Asset asset;
  final bool isLoading;
  final String? error;
  final bool isEditing;
  
  // Data untuk dropdown
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> assetTypes;
  final List<String> maintenancePatterns;
  final bool isLoadingRooms;
  final bool isLoadingTypes;
  final bool isLoadingPatterns;

  const AssetFormState({
    required this.asset,
    this.isLoading = false,
    this.error,
    this.isEditing = false,
    this.rooms = const [],
    this.assetTypes = const [],
    this.maintenancePatterns = const [],
    this.isLoadingRooms = false,
    this.isLoadingTypes = false,
    this.isLoadingPatterns = false,
  });

  AssetFormState copyWith({
    Asset? asset,
    bool? isLoading,
    String? error,
    bool? isEditing,
    List<Map<String, dynamic>>? rooms,
    List<Map<String, dynamic>>? assetTypes,
    List<String>? maintenancePatterns,
    bool? isLoadingRooms,
    bool? isLoadingTypes,
    bool? isLoadingPatterns,
  }) {
    return AssetFormState(
      asset: asset ?? this.asset,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      rooms: rooms ?? this.rooms,
      assetTypes: assetTypes ?? this.assetTypes,
      maintenancePatterns: maintenancePatterns ?? this.maintenancePatterns,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
      isLoadingTypes: isLoadingTypes ?? this.isLoadingTypes,
      isLoadingPatterns: isLoadingPatterns ?? this.isLoadingPatterns,
    );
  }
}

/// Notifier untuk mengelola form aset
class AssetFormNotifier extends StateNotifier<AssetFormState> {
  final Ref _ref;
  final AssetService _assetService;

  AssetFormNotifier(this._ref, this._assetService)
      : super(AssetFormState(asset: Asset.empty())) {
    // Load data dropdown saat form dibuat
    loadDropdownData();
  }

  /// Load data untuk dropdown (rooms, types, maintenance patterns)
  Future<void> loadDropdownData() async {
    // Load rooms
    state = state.copyWith(isLoadingRooms: true);
    try {
      final rooms = await _assetService.fetchAllRooms();
      state = state.copyWith(rooms: rooms, isLoadingRooms: false);
    } catch (e) {
      state = state.copyWith(isLoadingRooms: false);
    }

    // Load asset types
    state = state.copyWith(isLoadingTypes: true);
    try {
      final types = await _assetService.fetchAllAssetTypes();
      state = state.copyWith(assetTypes: types, isLoadingTypes: false);
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
  }

  /// Set data untuk edit mode
  void setEditingAsset(Asset asset) {
    state = state.copyWith(
      asset: asset,
      isEditing: true,
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