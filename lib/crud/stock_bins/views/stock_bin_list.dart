import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_bins/providers/stock_bin_provider.dart';
import 'package:rsmss/crud/stock_bins/providers/stock_bin_state.dart';
import 'package:rsmss/crud/stock_bins/models/stock_bin_model.dart';
import 'stock_bin_form.dart';
import 'stock_bin_detail.dart';

class StockBinListPage extends ConsumerStatefulWidget {
  const StockBinListPage({super.key});

  @override
  ConsumerState<StockBinListPage> createState() => _StockBinListPageState();
}

class _StockBinListPageState extends ConsumerState<StockBinListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(stockBinProvider.notifier).loadBins();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(stockBinProvider.notifier).loadBins();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(stockBinProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, StockBinModel bin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bin'),
        content: Text('Apakah Anda yakin ingin menghapus bin "${bin.code}"?'),
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
      final success = await ref.read(stockBinProvider.notifier).deleteBin(bin.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bin berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({StockBinModel? bin}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockBinFormPage(
          bin: bin,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(StockBinModel bin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockBinDetailPage(
          bin: bin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockBinProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin / Lokasi Detail'),
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

  Widget _buildBody(StockBinState state) {
    if (state.isLoading && state.bins.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.bins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data bin',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Bin'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.bins.length,
        itemBuilder: (context, index) {
          final bin = state.bins[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bin.isActive == true 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  color: bin.isActive == true ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                bin.code,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bin.rackCode != null && bin.shelfCode != null)
                    Text(
                      'Lokasi: ${bin.rackCode} - Level ${bin.shelfLevelNumber} - ${bin.shelfCode}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  // if (bin.currentProductName != null)
                  //   Text(
                  //     'Isi: ${bin.currentProductName}',
                  //     style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  //   ),
                  if (bin.currentQuantity != null && bin.maxQuantity != null)
                    Text(
                      'Stok: ${bin.currentQuantity} / ${bin.maxQuantity}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (bin.assetName != null)
                    Text(
                      'Aset: ${bin.assetName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (bin.isActive == false)
                    Chip(
                      label: const Text('Nonaktif'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      _navigateToForm(bin: bin);
                      break;
                    case 'detail':
                      _navigateToDetail(bin);
                      break;
                    case 'delete':
                      _confirmDelete(context, bin);
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
              onTap: () => _navigateToDetail(bin),
            ),
          );
        },
      ),
    );
  }
}