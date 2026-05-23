import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/floors/providers/floor_provider.dart';
import 'package:rsmss/crud/floors/providers/floor_state.dart';
import 'package:rsmss/crud/floors/models/floor_model.dart';
import 'floor_form.dart';
import 'floor_detail.dart';

class FloorListPage extends ConsumerStatefulWidget {
  const FloorListPage({super.key});

  @override
  ConsumerState<FloorListPage> createState() => _FloorListPageState();
}

class _FloorListPageState extends ConsumerState<FloorListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(floorProvider.notifier).loadFloors();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(floorProvider.notifier).loadFloors();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(floorProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, FloorModel floor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lantai'),
        content: Text('Apakah Anda yakin ingin menghapus Lantai ${floor.floorNumber}?'),
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
      final success = await ref.read(floorProvider.notifier).deleteFloor(floor.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lantai berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({FloorModel? floor}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloorFormPage(
          floor: floor,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(FloorModel floor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloorDetailPage(
          floor: floor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(floorProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lantai'),
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

  Widget _buildBody(FloorState state) {
    if (state.isLoading && state.floors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.floors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_comfortable_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data lantai',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Lantai'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.floors.length,
        itemBuilder: (context, index) {
          final floor = state.floors[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.view_comfortable, color: Colors.green),
              ),
              title: Text(
                floor.floorAlias != null && floor.floorAlias!.isNotEmpty
                    ? '${floor.floorNumber} - ${floor.floorAlias}'
                    : 'Lantai ${floor.floorNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: floor.buildingName != null
                  ? Text(
                      'Gedung: ${floor.buildingName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    )
                  : null,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(floor: floor);
                      break;
                    case 'detail':
                      _navigateToDetail(floor);
                      break;
                    case 'delete':
                      _confirmDelete(context, floor);
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
              onTap: () => _navigateToDetail(floor),
            ),
          );
        },
      ),
    );
  }
}