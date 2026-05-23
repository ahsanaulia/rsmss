import 'package:flutter/material.dart';
import 'package:rsmss/crud/stock_racks/models/stock_rack_model.dart';

class StockRackDetailPage extends StatelessWidget {
  final StockRackModel rack;

  const StockRackDetailPage({
    super.key,
    required this.rack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${rack.name ?? rack.code}'),
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
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.archive_outlined, size: 48, color: Colors.amber),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rack.name ?? rack.code,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Kode: ${rack.code}'),
                        backgroundColor: Colors.amber.shade100,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', rack.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kode Rak', rack.code),
                const SizedBox(height: 12),
                if (rack.name != null)
                  _buildDetailRow('Nama Rak', rack.name!),
                if (rack.name != null)
                  const SizedBox(height: 12),
                if (rack.warehouseName != null && rack.zoneName != null)
                  _buildDetailRow('Lokasi', '${rack.warehouseName} - ${rack.zoneName}'),
                if (rack.warehouseName != null && rack.zoneName != null)
                  const SizedBox(height: 12),
                if (rack.zoneName != null && rack.warehouseName == null)
                  _buildDetailRow('Zona', rack.zoneName!),
                if (rack.zoneName != null && rack.warehouseName == null)
                  const SizedBox(height: 12),
                if (rack.capacityKg != null)
                  _buildDetailRow('Kapasitas', '${rack.capacityKg} kg'),
                if (rack.capacityKg != null)
                  const SizedBox(height: 12),
                if (rack.metadata != null)
                  _buildDetailRow('Metadata', rack.metadata.toString()),
                if (rack.metadata != null)
                  const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  rack.createdAt != null
                      ? _formatDateTime(rack.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', rack.createdBy ?? '-'),
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