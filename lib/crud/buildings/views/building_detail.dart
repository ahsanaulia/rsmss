import 'package:flutter/material.dart';
import 'package:rsmss/crud/buildings/models/building_model.dart';

class BuildingDetailPage extends StatelessWidget {
  final BuildingModel building;

  const BuildingDetailPage({
    super.key,
    required this.building,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${building.buildingName}'),
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
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.business, size: 48, color: Colors.blue),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        building.buildingName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (building.hospitalName != null)
                        Chip(
                          label: Text(building.hospitalName!),
                          avatar: const Icon(Icons.local_hospital, size: 16),
                        ),
                      if (building.functionName != null)
                        Chip(
                          label: Text(building.functionName!),
                          avatar: const Icon(Icons.business_center, size: 16),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', building.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Gedung', building.buildingName),
                const SizedBox(height: 12),
                _buildDetailRow('Jumlah Lantai', building.totalFloors?.toString() ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  building.createdAt != null
                      ? _formatDateTime(building.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', building.createdBy ?? '-'),
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