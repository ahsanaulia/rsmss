import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_shelves/providers/stock_shelf_provider.dart';
import 'package:rsmss/crud/stock_shelves/providers/stock_shelf_state.dart';
import 'package:rsmss/crud/stock_shelves/models/stock_shelf_model.dart';
import 'stock_shelf_form.dart';
import 'stock_shelf_detail.dart';

class StockShelfListPage extends ConsumerStatefulWidget {
  const StockShelfListPage({super.key});

  @override
  ConsumerState<StockShelfListPage> createState() => _StockShelfListPageState();
}

class _StockShelfListPageState extends ConsumerState<StockShelfListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(stockShelfProvider.notifier).loadShelves();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(stockShelfProvider.notifier).loadShelves();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(stockShelfProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, StockShelfModel shelf) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Shelf'),
        content: Text('Apakah Anda yakin ingin menghapus shelf "${shelf.code}" (Level ${shelf.levelNumber})?\n\nPerhatian: Shelf yang memiliki bin TIDAK dapat dihapus.'),
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
      final success = await ref.read(stockShelfProvider.notifier).deleteShelf(shelf.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shelf berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({StockShelfModel? shelf}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockShelfFormPage(
          shelf: shelf,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(StockShelfModel shelf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockShelfDetailPage(
          shelf: shelf,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockShelfProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelf / Rak Level'),
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

  Widget _buildBody(StockShelfState state) {
    if (state.isLoading && state.shelves.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.shelves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shelves,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data shelf',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Shelf'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.shelves.length,
        itemBuilder: (context, index) {
          final shelf = state.shelves[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shelves, color: Colors.cyan),
              ),
              title: Text(
                'Level ${shelf.levelNumber} - ${shelf.code}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shelf.rackCode != null)
                    Text(
                      'Rak: ${shelf.rackCode}${shelf.rackName != null ? " - ${shelf.rackName}" : ""}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (shelf.zoneName != null && shelf.warehouseName != null)
                    Text(
                      'Lokasi: ${shelf.warehouseName} / ${shelf.zoneName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (shelf.maxHeightCm != null)
                    Text(
                      'Tinggi Maks: ${shelf.maxHeightCm} cm',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(shelf: shelf);
                      break;
                    case 'detail':
                      _navigateToDetail(shelf);
                      break;
                    case 'delete':
                      _confirmDelete(context, shelf);
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
              onTap: () => _navigateToDetail(shelf),
            ),
          );
        },
      ),
    );
  }
}