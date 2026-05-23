import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/providers/ref_stock_sub_category_provider.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/providers/ref_stock_sub_category_state.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/models/ref_stock_sub_category_model.dart';
import 'ref_stock_sub_category_form.dart';
import 'ref_stock_sub_category_detail.dart';

class RefStockSubCategoryListPage extends ConsumerStatefulWidget {
  const RefStockSubCategoryListPage({super.key});

  @override
  ConsumerState<RefStockSubCategoryListPage> createState() => _RefStockSubCategoryListPageState();
}

class _RefStockSubCategoryListPageState extends ConsumerState<RefStockSubCategoryListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(refStockSubCategoryProvider.notifier).loadSubCategories();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(refStockSubCategoryProvider.notifier).loadSubCategories();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(refStockSubCategoryProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RefStockSubCategoryModel subCategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Sub-Kategori Stok'),
        content: Text('Apakah Anda yakin ingin menghapus "${subCategory.subCategoryName}"?'),
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
      final success = await ref.read(refStockSubCategoryProvider.notifier).deleteSubCategory(subCategory.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sub-kategori stok berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RefStockSubCategoryModel? subCategory}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefStockSubCategoryFormPage(
          subCategory: subCategory,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RefStockSubCategoryModel subCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefStockSubCategoryDetailPage(
          subCategory: subCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refStockSubCategoryProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub-Kategori Stok'),
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

  Widget _buildBody(RefStockSubCategoryState state) {
    if (state.isLoading && state.subCategories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.subCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subdirectory_arrow_right_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data sub-kategori stok',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Sub-Kategori Stok'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = state.subCategories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: _buildIcon(subCategory.iconName),
              title: Text(
                subCategory.subCategoryName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subCategory.categoryName != null)
                    Text(
                      'Kategori: ${subCategory.categoryName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (subCategory.markerColor != null)
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _parseColor(subCategory.markerColor),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subCategory.markerColor!,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(subCategory: subCategory);
                      break;
                    case 'detail':
                      _navigateToDetail(subCategory);
                      break;
                    case 'delete':
                      _confirmDelete(context, subCategory);
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
              onTap: () => _navigateToDetail(subCategory),
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
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.subdirectory_arrow_right, color: Colors.teal),
      );
    }

    final iconData = _getIconData(iconName);
    if (iconData != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: Colors.teal),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.subdirectory_arrow_right, color: Colors.teal),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'subdirectory': Icons.subdirectory_arrow_right,
      'label': Icons.label,
      'category': Icons.category,
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