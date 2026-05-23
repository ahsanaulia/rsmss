import 'package:flutter/material.dart';
import '../models/ref_asset_category_model.dart';

class RefAssetCategoryDetailPage extends StatelessWidget {
  final RefAssetCategoryModel category;

  const RefAssetCategoryDetailPage({
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
                // Header with icon
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
                      if (category.markerColor != null)
                        Chip(
                          label: Text(category.markerColor!),
                          avatar: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(category.markerColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                // Detail Information
                _buildDetailRow('ID', category.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Kategori', category.categoryName),
                const SizedBox(height: 12),
                _buildDetailRow('Icon', category.iconName ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Warna Marker', category.markerColor ?? '-'),
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
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.category,
          size: 48,
          color: _parseColor(category.markerColor),
        ),
      );
    }

    final iconData = _getIconData(category.iconName);
    if (iconData != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          iconData,
          size: 48,
          color: _parseColor(category.markerColor),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.category,
        size: 48,
        color: _parseColor(category.markerColor),
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
      'category': Icons.category,
      'home': Icons.home,
      'work': Icons.work,
      'business': Icons.business,
      'computer': Icons.computer,
      'phone': Icons.phone_android,
      'build': Icons.build,
      'inventory': Icons.inventory,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}