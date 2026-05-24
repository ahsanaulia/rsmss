import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_people_categories/models/ref_people_category_model.dart';

class RefPeopleCategoryDetailPage extends StatelessWidget {
  final RefPeopleCategoryModel item;

  const RefPeopleCategoryDetailPage({
    super.key,
    required this.item,
  });

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    final color = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$color', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final markerColor = _getColorFromHex(item.markerColor);
    final isInsider = item.isInsider ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${item.categoryName}'),
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
                          color: markerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isInsider ? Icons.business : Icons.people,
                          size: 48,
                          color: markerColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.categoryName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isInsider ? Colors.blue.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isInsider ? 'Internal' : 'Eksternal',
                          style: TextStyle(
                            color: isInsider ? Colors.blue.shade800 : Colors.orange.shade800,
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
                _buildDetailRow('Nama Kategori', item.categoryName),
                const SizedBox(height: 12),
                _buildDetailRow('Warna Marker', item.markerColor ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Tipe', isInsider ? 'Internal' : 'Eksternal'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  item.createdAt != null
                      ? _formatDateTime(item.createdAt!)
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