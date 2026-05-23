import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_stock_types/providers/ref_stock_type_provider.dart';
import 'package:rsmss/crud/ref_stock_types/providers/ref_stock_type_state.dart';
import 'package:rsmss/crud/ref_stock_types/models/ref_stock_type_model.dart';
import 'ref_stock_type_form.dart';
import 'ref_stock_type_detail.dart';

class RefStockTypeListPage extends ConsumerStatefulWidget {
  const RefStockTypeListPage({super.key});

  @override
  ConsumerState<RefStockTypeListPage> createState() => _RefStockTypeListPageState();
}

class _RefStockTypeListPageState extends ConsumerState<RefStockTypeListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(refStockTypeProvider.notifier).loadTypes();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(refStockTypeProvider.notifier).loadTypes();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(refStockTypeProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RefStockTypeModel type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tipe Stok'),
        content: Text('Apakah Anda yakin ingin menghapus "${type.typeName}"?'),
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
      final success = await ref.read(refStockTypeProvider.notifier).deleteType(type.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tipe stok berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RefStockTypeModel? type}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefStockTypeFormPage(
          type: type,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RefStockTypeModel type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefStockTypeDetailPage(
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refStockTypeProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipe Stok'),
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

  Widget _buildBody(RefStockTypeState state) {
    if (state.isLoading && state.types.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.types.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.label_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data tipe stok',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Tipe Stok'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.types.length,
        itemBuilder: (context, index) {
          final type = state.types[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: _buildIcon(type.iconName),
              title: Text(
                type.typeName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type.subCategoryName != null)
                    Text(
                      'Sub-Kategori: ${type.subCategoryName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (type.categoryName != null)
                    Text(
                      'Kategori: ${type.categoryName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (type.description != null && type.description!.isNotEmpty)
                    Text(
                      type.description!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (type.markerColor != null)
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _parseColor(type.markerColor),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type.markerColor!,
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
                      _navigateToForm(type: type);
                      break;
                    case 'detail':
                      _navigateToDetail(type);
                      break;
                    case 'delete':
                      _confirmDelete(context, type);
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
              onTap: () => _navigateToDetail(type),
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
        child: const Icon(Icons.label, color: Colors.teal),
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
      child: const Icon(Icons.label, color: Colors.teal),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'label': Icons.label,
      'category': Icons.category,
      'inventory': Icons.inventory_2,
      'local_shipping': Icons.local_shipping,
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