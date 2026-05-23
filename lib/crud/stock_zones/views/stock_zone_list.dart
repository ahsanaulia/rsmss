import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_zones/providers/stock_zone_provider.dart';
import 'package:rsmss/crud/stock_zones/providers/stock_zone_state.dart';
import 'package:rsmss/crud/stock_zones/models/stock_zone_model.dart';
import 'stock_zone_form.dart';
import 'stock_zone_detail.dart';

class StockZoneListPage extends ConsumerStatefulWidget {
  const StockZoneListPage({super.key});

  @override
  ConsumerState<StockZoneListPage> createState() => _StockZoneListPageState();
}

class _StockZoneListPageState extends ConsumerState<StockZoneListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(stockZoneProvider.notifier).loadZones();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(stockZoneProvider.notifier).loadZones();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(stockZoneProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, StockZoneModel zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Zona'),
        content: Text('Apakah Anda yakin ingin menghapus zona "${zone.name}"?\n\nPerhatian: Zona yang memiliki rak TIDAK dapat dihapus.'),
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
      final success = await ref.read(stockZoneProvider.notifier).deleteZone(zone.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zona berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({StockZoneModel? zone}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockZoneFormPage(
          zone: zone,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(StockZoneModel zone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockZoneDetailPage(
          zone: zone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockZoneProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zona Gudang'),
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

  Widget _buildBody(StockZoneState state) {
    if (state.isLoading && state.zones.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.zones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data zona',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Zona'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.zones.length,
        itemBuilder: (context, index) {
          final zone = state.zones[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: zone.isRestricted == true 
                      ? Colors.red.shade50 
                      : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  zone.isRestricted == true ? Icons.lock : Icons.map,
                  color: zone.isRestricted == true ? Colors.red : Colors.teal,
                ),
              ),
              title: Text(
                zone.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kode: ${zone.code} | Gudang: ${zone.warehouseCode ?? zone.warehouseName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (zone.zoneType != null)
                    Text(
                      'Tipe: ${zone.zoneType}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (zone.temperatureMin != null || zone.temperatureMax != null)
                    Text(
                      'Suhu: ${zone.temperatureMin?.toString() ?? "?"} - ${zone.temperatureMax?.toString() ?? "?"} °C',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (zone.roomName != null)
                    Text(
                      'Ruangan: ${zone.roomName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(zone: zone);
                      break;
                    case 'detail':
                      _navigateToDetail(zone);
                      break;
                    case 'delete':
                      _confirmDelete(context, zone);
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
              onTap: () => _navigateToDetail(zone),
            ),
          );
        },
      ),
    );
  }
}