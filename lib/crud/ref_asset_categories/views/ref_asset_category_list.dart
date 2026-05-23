import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ref_asset_category_provider.dart';
import '../providers/ref_asset_category_state.dart';
import '../models/ref_asset_category_model.dart';
import 'ref_asset_category_form.dart';
import 'ref_asset_category_detail.dart';

class RefAssetCategoryListPage extends ConsumerStatefulWidget {
  const RefAssetCategoryListPage({super.key});

  @override
  ConsumerState<RefAssetCategoryListPage> createState() => _RefAssetCategoryListPageState();
}

class _RefAssetCategoryListPageState extends ConsumerState<RefAssetCategoryListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(refAssetCategoryProvider.notifier).loadCategories();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(refAssetCategoryProvider.notifier).loadCategories();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(refAssetCategoryProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RefAssetCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(refAssetCategoryProvider.notifier).deleteCategory(category.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RefAssetCategoryModel? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefAssetCategoryFormPage(
          category: category,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RefAssetCategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefAssetCategoryDetailPage(
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refAssetCategoryProvider);
    final errorMessage = state.errorMessage;

    // Show error snackbar if any
    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Aset'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(RefAssetCategoryState state) {
    if (state.isLoading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data kategori',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Kategori'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: _buildIcon(category.iconName),
              title: Text(
                category.categoryName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: category.markerColor != null
                  ? Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _parseColor(category.markerColor),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(category.markerColor!),
                      ],
                    )
                  : null,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(category: category);
                      break;
                    case 'detail':
                      _navigateToDetail(category);
                      break;
                    case 'delete':
                      _confirmDelete(context, category);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _navigateToDetail(category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.category, color: Colors.blue),
      );
    }

    // Try to get IconData from Material Icons
    final iconData = _getIconData(iconName);
    if (iconData != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: Colors.blue),
      );
    }

    // Fallback
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.category, color: Colors.blue),
    );
  }

  IconData? _getIconData(String iconName) {
    // Mapping string ke Icons
    final iconMap = {
      'category': Icons.category,
      'home': Icons.home,
      'work': Icons.work,
      'business': Icons.business,
      'computer': Icons.computer,
      'phone': Icons.phone_android,
      'build': Icons.build,
      'inventory': Icons.inventory,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}