// ============================================================
// PAGE: Asset List Page
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan daftar aset dalam bentuk card (seperti TasksTable)
// 2. Search berdasarkan RFID, Nama Aset, Tipe, Kategori, Sub Kategori
// 3. Filter berdasarkan status kondisi
// 4. Tombol tambah aset (buka dialog)
// 5. Aksi edit (dialog), delete (konfirmasi), detail (navigasi)
// 6. Pull-to-refresh untuk reload data
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/asset_providers.dart';
// import '../../providers/asset_state.dart';
import '../../models/asset_model.dart';
import '../dialogs/asset_form_dialog.dart';
import 'asset_detail_page.dart';
import '../../widgets/asset_card.dart';

class AssetListPage extends ConsumerStatefulWidget {
  const AssetListPage({super.key});

  @override
  ConsumerState<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends ConsumerState<AssetListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all';
  
  // Data untuk dropdown filter tipe (opsional)
  String _filterType = 'all';
  List<Map<String, dynamic>> _assetTypes = [];
  
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _authService = getIt<AuthService>();
    
    // Load asset types untuk filter
    _loadAssetTypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(assetListProvider.notifier);
      notifier.loadAssets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssetTypes() async {
    try {
      final assetService = ref.read(assetServiceProvider);
      final types = await assetService.fetchAllAssetTypes();
      setState(() {
        _assetTypes = types;
      });
    } catch (e) {
      // Ignore error, filter tipe tetap bisa digunakan tanpa data
    }
  }

  String? get _currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  /// Filter aset berdasarkan search query dan filter status
  List<Asset> _filterAssets(List<Asset> assets) {
    return assets.where((asset) {
      // Search query (RFID atau Nama Aset)
      if (_searchQuery.isNotEmpty) {
        final matchRfid = asset.rfidTagId.toLowerCase().contains(_searchQuery);
        final matchName = asset.assetName.toLowerCase().contains(_searchQuery);
        final matchType = asset.typeName?.toLowerCase().contains(_searchQuery) ?? false;
        final matchCategory = asset.categoryName?.toLowerCase().contains(_searchQuery) ?? false;
        final matchSubCategory = asset.subCategoryName?.toLowerCase().contains(_searchQuery) ?? false;
        
        if (!(matchRfid || matchName || matchType || matchCategory || matchSubCategory)) {
          return false;
        }
      }
      
      // Filter status kondisi
      if (_filterStatus != 'all' && asset.statusCondition != _filterStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetListProvider);
    final notifier = ref.read(assetListProvider.notifier);

    // Handle error message
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red.shade700),
        );
        // Clear error after showing (tidak ada method clear di state, akan direset oleh load berikutnya)
      });
    }

    final filteredAssets = _filterAssets(state.assets);

    return Column(
      children: [
        // ==========================================================
        // HEADER: Search, Filter, Tombol Tambah
        // ==========================================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
          ),
          child: Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari RFID, Nama, Tipe, Kategori...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Filter Status Dropdown
              Container(
                width: 160,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                      DropdownMenuItem(value: 'Good', child: Text('Good')),
                      DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                      DropdownMenuItem(value: 'Damage', child: Text('Damage')),
                      DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                    ],
                    onChanged: (v) => setState(() => _filterStatus = v!),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Tombol Tambah Aset
              ElevatedButton.icon(
                onPressed: () {
                  final userId = _currentUserId;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Session expired, silakan login ulang'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _showAssetFormDialog(
                    context: context,
                    ref: ref,
                    isEditing: false,
                    onSuccess: () {
                      notifier.loadAssets();
                    },
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Aset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // ==========================================================
        // BODY: Loading, Empty, atau List
        // ==========================================================
        if (state.isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF01579B)),
            ),
          ),

        if (!state.isLoading && filteredAssets.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Belum ada data aset',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

        if (!state.isLoading && filteredAssets.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await notifier.loadAssets();
              },
              color: const Color(0xFF01579B),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredAssets.length,
                itemBuilder: (context, index) {
                  final asset = filteredAssets[index];
                  return AssetCard(
                    asset: asset,
                    onTap: () {
                      // Navigasi ke halaman detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetDetailPage(
                            assetId: asset.id,
                            onAssetUpdated: () {
                              // Refresh list saat kembali dari detail jika ada perubahan
                              notifier.loadAssets();
                            },
                          ),
                        ),
                      );
                    },
                    onEdit: () {
                      final userId = _currentUserId;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session expired, silakan login ulang'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _showAssetFormDialog(
                        context: context,
                        ref: ref,
                        isEditing: true,
                        existingAsset: asset,
                        onSuccess: () {
                          notifier.loadAssets();
                        },
                      );
                    },
                    onDelete: () {
                      _confirmDelete(
                        context: context,
                        assetId: asset.id,
                        assetName: asset.assetName,
                        onConfirm: () async {
                          final userId = _currentUserId;
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Session expired, silakan login ulang'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          final success = await notifier.deleteAsset(asset.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Aset berhasil dihapus'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  /// Menampilkan dialog form untuk create/edit aset
  void _showAssetFormDialog({
    required BuildContext context,
    required WidgetRef ref,
    required bool isEditing,
    Asset? existingAsset,
    required VoidCallback onSuccess,
  }) {
    final assetService = ref.read(assetServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AssetFormDialog(
          isEditing: isEditing,
          existingAsset: existingAsset,
          assetService: assetService,
          currentUserId: _currentUserId,
          onSuccess: () {
            Navigator.pop(dialogContext);
            onSuccess();
          },
        );
      },
    );
  }

  /// Konfirmasi delete aset
  void _confirmDelete({
    required BuildContext context,
    required String assetId,
    required String assetName,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus aset "$assetName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}