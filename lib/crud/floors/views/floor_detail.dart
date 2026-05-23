import 'package:flutter/material.dart';
import 'package:rsmss/crud/floors/models/floor_model.dart';

class FloorDetailPage extends StatelessWidget {
  final FloorModel floor;

  const FloorDetailPage({
    super.key,
    required this.floor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          floor.floorAlias != null && floor.floorAlias!.isNotEmpty
              ? 'Detail: Lantai ${floor.floorNumber} - ${floor.floorAlias}'
              : 'Detail: Lantai ${floor.floorNumber}',
        ),
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
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.view_comfortable, size: 48, color: Colors.green),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        floor.floorAlias != null && floor.floorAlias!.isNotEmpty
                            ? 'Lantai ${floor.floorNumber} - ${floor.floorAlias}'
                            : 'Lantai ${floor.floorNumber}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (floor.buildingName != null)
                        Chip(
                          label: Text(floor.buildingName!),
                          avatar: const Icon(Icons.business, size: 16),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', floor.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nomor Lantai', floor.floorNumber.toString()),
                const SizedBox(height: 12),
                if (floor.floorAlias != null && floor.floorAlias!.isNotEmpty)
                  _buildDetailRow('Alias Lantai', floor.floorAlias!),
                if (floor.floorAlias != null && floor.floorAlias!.isNotEmpty)
                  const SizedBox(height: 12),
                if (floor.mapImageUrl != null && floor.mapImageUrl!.isNotEmpty)
                  _buildDetailRow('URL Peta', floor.mapImageUrl!),
                if (floor.mapImageUrl != null && floor.mapImageUrl!.isNotEmpty)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  floor.createdAt != null
                      ? _formatDateTime(floor.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', floor.createdBy ?? '-'),
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
}