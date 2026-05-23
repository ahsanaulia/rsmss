import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_racks/providers/stock_rack_provider.dart';
import 'package:rsmss/crud/stock_racks/providers/stock_rack_state.dart';
import 'package:rsmss/crud/stock_racks/models/stock_rack_model.dart';
import 'stock_rack_form.dart';
import 'stock_rack_detail.dart';

class StockRackListPage extends ConsumerStatefulWidget {
  const StockRackListPage({super.key});

  @override
  ConsumerState<StockRackListPage> createState() => _StockRackListPageState();
}

class _StockRackListPageState extends ConsumerState<StockRackListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(stockRackProvider.notifier).loadRacks();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(stockRackProvider.notifier).loadRacks();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(stockRackProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, StockRackModel rack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rak'),
        content: Text('Apakah Anda yakin ingin menghapus rak "${rack.name ?? rack.code}"?\n\nPerhatian: Rak yang memiliki shelf TIDAK dapat dihapus.'),
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
      final success = await ref.read(stockRackProvider.notifier).deleteRack(rack.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rak berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({StockRackModel? rack}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockRackFormPage(
          rack: rack,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(StockRackModel rack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockRackDetailPage(
          rack: rack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockRackProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rak Penyimpanan'),
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

  Widget _buildBody(StockRackState state) {
    if (state.isLoading && state.racks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.racks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data rak',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Rak'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.racks.length,
        itemBuilder: (context, index) {
          final rack = state.racks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.archive_outlined, color: Colors.amber),
              ),
              title: Text(
                rack.name ?? rack.code,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kode: ${rack.code}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (rack.warehouseName != null && rack.zoneName != null)
                    Text(
                      'Lokasi: ${rack.warehouseName} - ${rack.zoneName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (rack.capacityKg != null)
                    Text(
                      'Kapasitas: ${rack.capacityKg} kg',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(rack: rack);
                      break;
                    case 'detail':
                      _navigateToDetail(rack);
                      break;
                    case 'delete':
                      _confirmDelete(context, rack);
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
              onTap: () => _navigateToDetail(rack),
            ),
          );
        },
      ),
    );
  }
}