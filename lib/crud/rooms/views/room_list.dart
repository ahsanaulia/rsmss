import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/rooms/providers/room_provider.dart';
import 'package:rsmss/crud/rooms/providers/room_state.dart';
import 'package:rsmss/crud/rooms/models/room_model.dart';
import 'room_form.dart';
import 'room_detail.dart';

class RoomListPage extends ConsumerStatefulWidget {
  const RoomListPage({super.key});

  @override
  ConsumerState<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends ConsumerState<RoomListPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      ref.read(roomProvider.notifier).loadRooms();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(roomProvider.notifier).loadRooms();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    ref.read(roomProvider.notifier).clearError();
  }

  Future<void> _confirmDelete(BuildContext context, RoomModel room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ruangan'),
        content: Text('Apakah Anda yakin ingin menghapus ruangan "${room.roomName}"?'),
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
      final success = await ref.read(roomProvider.notifier).deleteRoom(room.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruangan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToForm({RoomModel? room}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomFormPage(
          room: room,
        ),
      ),
    ).then((_) => _refreshData());
  }

  void _navigateToDetail(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailPage(
          room: room,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(errorMessage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruangan'),
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

  Widget _buildBody(RoomState state) {
    if (state.isLoading && state.rooms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.rooms.isEmpty) {
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
              'Belum ada data ruangan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _navigateToForm(),
              child: const Text('Tambah Ruangan'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.rooms.length,
        itemBuilder: (context, index) {
          final room = state.rooms[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(room.categoryColorCode).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildIcon(room.categoryIconName),
              ),
              title: Text(
                room.roomName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (room.buildingName != null && room.floorName != null)
                    Text(
                      '${room.buildingName} - Lantai ${room.floorName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (room.categoryName != null)
                    Text(
                      'Kategori: ${room.categoryName}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (room.isEntryGate == true)
                    Chip(
                      label: const Text('Pintu Masuk'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.blue.shade100,
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _navigateToForm(room: room);
                      break;
                    case 'detail':
                      _navigateToDetail(room);
                      break;
                    case 'delete':
                      _confirmDelete(context, room);
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
              onTap: () => _navigateToDetail(room),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return const Icon(Icons.meeting_room, size: 24, color: Colors.orange);
    }
    final iconMap = {
      'meeting_room': Icons.meeting_room,
      'bed': Icons.bed,
      'local_hospital': Icons.local_hospital,
      'medical_services': Icons.medical_services,
      'vaccines': Icons.vaccines,
    };
    final iconData = iconMap[iconName.toLowerCase()];
    return Icon(iconData ?? Icons.meeting_room, size: 24, color: Colors.orange);
  }

  Color _getCategoryColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.orange;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.orange;
    }
  }
}