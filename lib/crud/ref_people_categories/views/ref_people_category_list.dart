import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_people_categories/providers/ref_people_category_provider.dart';
import 'package:rsmss/crud/ref_people_categories/providers/ref_people_category_state.dart';
import 'package:rsmss/crud/ref_people_categories/models/ref_people_category_model.dart';
import 'ref_people_category_form.dart';
import 'ref_people_category_detail.dart';

class RefPeopleCategoryListPage extends ConsumerStatefulWidget {
  const RefPeopleCategoryListPage({super.key});

  @override
  ConsumerState<RefPeopleCategoryListPage> createState() => _RefPeopleCategoryListPageState();
}

class _RefPeopleCategoryListPageState extends ConsumerState<RefPeopleCategoryListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(refPeopleCategoryProvider.notifier).loadItems();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(refPeopleCategoryProvider.notifier).loadItems();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(refPeopleCategoryProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RefPeopleCategoryModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori Orang'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.categoryName}"?'),
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
      final success = await ref.read(refPeopleCategoryProvider.notifier).delete(item.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori orang berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RefPeopleCategoryModel? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefPeopleCategoryFormPage(
          item: item,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RefPeopleCategoryModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefPeopleCategoryDetailPage(
          item: item,
        ),
      ),
    );
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    final color = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$color', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refPeopleCategoryProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Orang'),
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

  Widget _buildBody(RefPeopleCategoryState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data kategori orang',
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
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          final markerColor = _getColorFromHex(item.markerColor);
          final isInsider = item.isInsider ?? false;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: markerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isInsider ? Icons.business : Icons.people,
                  color: markerColor,
                ),
              ),
              title: Text(
                item.categoryName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.markerColor != null)
                    Text(
                      'Warna Marker: ${item.markerColor}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isInsider ? Colors.blue.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isInsider ? 'Internal' : 'Eksternal',
                      style: TextStyle(
                        fontSize: 10,
                        color: isInsider ? Colors.blue.shade800 : Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(item: item);
                      break;
                    case 'detail':
                      _navigateToDetail(item);
                      break;
                    case 'delete':
                      _confirmDelete(context, item);
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
              onTap: () => _navigateToDetail(item),
            ),
          );
        },
      ),
    );
  }
}