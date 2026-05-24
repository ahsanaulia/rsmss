import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_incident_categories/models/ref_incident_category_model.dart';

class RefIncidentCategoryDetailPage extends StatelessWidget {
  final RefIncidentCategoryModel item;

  const RefIncidentCategoryDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${item.name}'),
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
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.warning_amber,
                          size: 48,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(item.code),
                        avatar: const Icon(Icons.code, size: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                _buildDetailRow('ID', item.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kode Kategori', item.code),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Kategori', item.name),
                const SizedBox(height: 12),
                _buildDetailRow('Deskripsi', item.description ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Icon', item.icon ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Warna', item.color ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Status', isActive ? 'Aktif' : 'Nonaktif'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  item.createdAt != null
                      ? _formatDateTime(item.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Terakhir Diupdate',
                  item.updatedAt != null
                      ? _formatDateTime(item.updatedAt!)
                      : '-',
                ),
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