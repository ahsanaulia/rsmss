import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_room_categories/models/ref_room_category_model.dart';

class RefRoomCategoryDetailPage extends StatelessWidget {
  final RefRoomCategoryModel category;

  const RefRoomCategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${category.categoryName}'),
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
                      _buildDetailIcon(),
                      const SizedBox(height: 12),
                      Text(
                        category.categoryName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (category.colorCode != null)
                        Chip(
                          label: Text(category.colorCode!),
                          avatar: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(category.colorCode),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', category.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Kategori', category.categoryName),
                const SizedBox(height: 12),
                _buildDetailRow('Icon', category.iconName ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Warna', category.colorCode ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  category.createdAt != null
                      ? _formatDateTime(category.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', category.createdBy ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailIcon() {
    if (category.iconName == null || category.iconName!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.meeting_room,
          size: 48,
          color: _parseColor(category.colorCode),
        ),
      );
    }

    final iconData = _getIconData(category.iconName);
    if (iconData != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          iconData,
          size: 48,
          color: _parseColor(category.colorCode),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.meeting_room,
        size: 48,
        color: _parseColor(category.colorCode),
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

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'meeting_room': Icons.meeting_room,
      'bed': Icons.bed,
      'local_hospital': Icons.local_hospital,
      'medical_services': Icons.medical_services,
      'vaccines': Icons.vaccines,
    };
    return iconMap[iconName.toLowerCase()];
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