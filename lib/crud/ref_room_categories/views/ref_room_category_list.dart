import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_room_categories/providers/ref_room_category_provider.dart';
import 'package:rsmss/crud/ref_room_categories/providers/ref_room_category_state.dart';
import 'package:rsmss/crud/ref_room_categories/models/ref_room_category_model.dart';
import 'ref_room_category_form.dart';
import 'ref_room_category_detail.dart';

class RefRoomCategoryListPage extends ConsumerStatefulWidget {
  const RefRoomCategoryListPage({super.key});

  @override
  ConsumerState<RefRoomCategoryListPage> createState() => _RefRoomCategoryListPageState();
}

class _RefRoomCategoryListPageState extends ConsumerState<RefRoomCategoryListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(refRoomCategoryProvider.notifier).loadCategories();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(refRoomCategoryProvider.notifier).loadCategories();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(refRoomCategoryProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RefRoomCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori Ruangan'),
        content: Text('Apakah Anda yakin ingin menghapus "${category.categoryName}"?'),
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
      final success = await ref.read(refRoomCategoryProvider.notifier).deleteCategory(category.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori ruangan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RefRoomCategoryModel? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefRoomCategoryFormPage(
          category: category,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RefRoomCategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RefRoomCategoryDetailPage(
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refRoomCategoryProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Ruangan'),
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

  Widget _buildBody(RefRoomCategoryState state) {
    if (state.isLoading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data kategori ruangan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Kategori Ruangan'),
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
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(category.colorCode).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildIcon(category.iconName),
              ),
              title: Text(
                category.categoryName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Row(
                children: [
                  if (category.colorCode != null)
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _parseColor(category.colorCode),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  if (category.colorCode != null)
                    const SizedBox(width: 8),
                  if (category.colorCode != null)
                    Text(
                      category.colorCode!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
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
    final iconData = _getIconData(iconName);
    if (iconData != null) {
      return Icon(iconData, size: 24, color: Colors.orange);
    }
    return const Icon(Icons.meeting_room, size: 24, color: Colors.orange);
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'meeting_room': Icons.meeting_room,
      'bed': Icons.bed,
      'local_hospital': Icons.local_hospital,
      'medical_services': Icons.medical_services,
      'vaccines': Icons.vaccines,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.orange;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.orange;
    }
  }
}