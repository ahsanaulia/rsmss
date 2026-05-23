import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/buildings/providers/building_provider.dart';
import 'package:rsmss/crud/buildings/providers/building_state.dart';
import 'package:rsmss/crud/buildings/models/building_model.dart';
import 'building_form.dart';
import 'building_detail.dart';

class BuildingListPage extends ConsumerStatefulWidget {
  const BuildingListPage({super.key});

  @override
  ConsumerState<BuildingListPage> createState() => _BuildingListPageState();
}

class _BuildingListPageState extends ConsumerState<BuildingListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(buildingProvider.notifier).loadBuildings();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(buildingProvider.notifier).loadBuildings();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(buildingProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, BuildingModel building) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Gedung'),
        content: Text('Apakah Anda yakin ingin menghapus "${building.buildingName}"?\n\nPerhatian: Gedung yang memiliki lantai TIDAK dapat dihapus.'),
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
      final success = await ref.read(buildingProvider.notifier).deleteBuilding(building.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gedung berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({BuildingModel? building}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingFormPage(
          building: building,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(BuildingModel building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingDetailPage(
          building: building,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buildingProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gedung'),
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

  Widget _buildBody(BuildingState state) {
    if (state.isLoading && state.buildings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.buildings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data gedung',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Gedung'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.buildings.length,
        itemBuilder: (context, index) {
          final building = state.buildings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: Colors.blue),
              ),
              title: Text(
                building.buildingName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (building.hospitalName != null)
                    Text(
                      'RS: ${building.hospitalName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (building.functionName != null)
                    Text(
                      'Fungsi: ${building.functionName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (building.totalFloors != null)
                    Text(
                      'Jumlah Lantai: ${building.totalFloors}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(building: building);
                      break;
                    case 'detail':
                      _navigateToDetail(building);
                      break;
                    case 'delete':
                      _confirmDelete(context, building);
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
              onTap: () => _navigateToDetail(building),
            ),
          );
        },
      ),
    );
  }
}