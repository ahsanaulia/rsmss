import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_warehouses/providers/stock_warehouse_provider.dart';
import 'package:rsmss/crud/stock_warehouses/providers/stock_warehouse_state.dart';
import 'package:rsmss/crud/stock_warehouses/models/stock_warehouse_model.dart';
import 'stock_warehouse_form.dart';
import 'stock_warehouse_detail.dart';

// rsmss\lib\crud\stock_warehouses\views\stock_warehouse_list.dart

class StockWarehouseListPage extends ConsumerStatefulWidget {
  const StockWarehouseListPage({super.key});

  @override
  ConsumerState<StockWarehouseListPage> createState() => _StockWarehouseListPageState();
}

class _StockWarehouseListPageState extends ConsumerState<StockWarehouseListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(stockWarehouseProvider.notifier).loadWarehouses();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(stockWarehouseProvider.notifier).loadWarehouses();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(stockWarehouseProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, StockWarehouseModel warehouse) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Gudang'),
        content: Text('Apakah Anda yakin ingin menghapus gudang "${warehouse.name}"?\n\nPerhatian: Gudang yang memiliki zona TIDAK dapat dihapus.'),
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
      final success = await ref.read(stockWarehouseProvider.notifier).deleteWarehouse(warehouse.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gudang berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({StockWarehouseModel? warehouse}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockWarehouseFormPage(
          warehouse: warehouse,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(StockWarehouseModel warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockWarehouseDetailPage(
          warehouse: warehouse,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockWarehouseProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gudang'),
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

  Widget _buildBody(StockWarehouseState state) {
    if (state.isLoading && state.warehouses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.warehouses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warehouse_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data gudang',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Gudang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.warehouses.length,
        itemBuilder: (context, index) {
          final warehouse = state.warehouses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warehouse, color: Colors.indigo),
              ),
              title: Text(
                warehouse.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kode: ${warehouse.code}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (warehouse.buildingName != null && warehouse.floorName != null)
                    Text(
                      'Lokasi: ${warehouse.buildingName} - Lantai ${warehouse.floorName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (warehouse.managerName != null)
                    Text(
                      'Manager: ${warehouse.managerName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (warehouse.isActive == false)
                    Chip(
                      label: const Text('Nonaktif'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.red.shade100,
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(warehouse: warehouse);
                      break;
                    case 'detail':
                      _navigateToDetail(warehouse);
                      break;
                    case 'delete':
                      _confirmDelete(context, warehouse);
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
              onTap: () => _navigateToDetail(warehouse),
            ),
          );
        },
      ),
    );
  }
}