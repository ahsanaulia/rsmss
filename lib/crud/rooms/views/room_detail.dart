
import 'package:flutter/material.dart';
import 'package:rsmss/crud/rooms/models/room_model.dart';

class RoomDetailPage extends StatelessWidget {
  final RoomModel room;

  const RoomDetailPage({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${room.roomName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _parseColor(room.categoryColorCode).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.meeting_room,
                          size: 48,
                          color: _parseColor(room.categoryColorCode),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        room.roomName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (room.isEntryGate == true)
                        Chip(
                          label: const Text('Pintu Masuk'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', room.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Ruangan', room.roomName),
                const SizedBox(height: 12),
                if (room.buildingName != null)
                  _buildDetailRow('Gedung', room.buildingName!),
                if (room.buildingName != null)
                  const SizedBox(height: 12),
                if (room.floorName != null)
                  _buildDetailRow('Lantai', 'Lantai ${room.floorName}'),
                if (room.floorName != null)
                  const SizedBox(height: 12),
                if (room.categoryName != null)
                  _buildDetailRow('Kategori', room.categoryName!),
                if (room.categoryName != null)
                  const SizedBox(height: 12),
                if (room.xPos != null)
                  _buildDetailRow('Posisi X', room.xPos!.toString()),
                if (room.xPos != null)
                  const SizedBox(height: 12),
                if (room.yPos != null)
                  _buildDetailRow('Posisi Y', room.yPos!.toString()),
                if (room.yPos != null)
                  const SizedBox(height: 12),
                if (room.xPosMax != null)
                  _buildDetailRow('Posisi Max X', room.xPosMax!.toString()),
                if (room.xPosMax != null)
                  const SizedBox(height: 12),
                if (room.yPosMax != null)
                  _buildDetailRow('Posisi Max Y', room.yPosMax!.toString()),
                if (room.yPosMax != null)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  room.createdAt != null
                      ? _formatDateTime(room.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', room.createdBy ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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