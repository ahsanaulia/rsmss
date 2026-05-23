import 'package:flutter/material.dart';
import 'package:rsmss/crud/stock_shelves/models/stock_shelf_model.dart';

class StockShelfDetailPage extends StatelessWidget {
  final StockShelfModel shelf;

  const StockShelfDetailPage({
    super.key,
    required this.shelf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: Level ${shelf.levelNumber} - ${shelf.code}'),
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
                          color: Colors.cyan.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shelves, size: 48, color: Colors.cyan),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Level ${shelf.levelNumber} - ${shelf.code}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (shelf.rackCode != null)
                        Chip(
                          label: Text('Rak: ${shelf.rackCode}'),
                          backgroundColor: Colors.cyan.shade100,
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', shelf.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kode Shelf', shelf.code),
                const SizedBox(height: 12),
                _buildDetailRow('Level Nomor', shelf.levelNumber.toString()),
                const SizedBox(height: 12),
                if (shelf.rackCode != null)
                  _buildDetailRow('Rak', '${shelf.rackCode}${shelf.rackName != null ? " - ${shelf.rackName}" : ""}'),
                if (shelf.rackCode != null)
                  const SizedBox(height: 12),
                if (shelf.zoneName != null && shelf.warehouseName != null)
                  _buildDetailRow('Lokasi', '${shelf.warehouseName} / ${shelf.zoneName}'),
                if (shelf.zoneName != null && shelf.warehouseName != null)
                  const SizedBox(height: 12),
                if (shelf.maxHeightCm != null)
                  _buildDetailRow('Tinggi Maksimal', '${shelf.maxHeightCm} cm'),
                if (shelf.maxHeightCm != null)
                  const SizedBox(height: 12),
                if (shelf.metadata != null)
                  _buildDetailRow('Metadata', shelf.metadata.toString()),
                if (shelf.metadata != null)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  shelf.createdAt != null
                      ? _formatDateTime(shelf.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', shelf.createdBy ?? '-'),
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
          width: 140,
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