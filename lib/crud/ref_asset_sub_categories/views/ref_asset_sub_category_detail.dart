import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_asset_sub_categories/models/ref_asset_sub_category_model.dart';

class RefAssetSubCategoryDetailPage extends StatelessWidget {
  final RefAssetSubCategoryModel subCategory;

  const RefAssetSubCategoryDetailPage({
    super.key,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${subCategory.subCategoryName}'),
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
                        subCategory.subCategoryName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (subCategory.categoryName != null)
                        Chip(
                          label: Text(subCategory.categoryName!),
                          avatar: const Icon(Icons.category, size: 16),
                        ),
                      if (subCategory.markerColor != null)
                        Chip(
                          label: Text(subCategory.markerColor!),
                          avatar: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(subCategory.markerColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', subCategory.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Kategori ID', subCategory.categoryId),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Sub-Kategori', subCategory.subCategoryName),
                const SizedBox(height: 12),
                _buildDetailRow('Icon', subCategory.iconName ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Warna Marker', subCategory.markerColor ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  subCategory.createdAt != null
                      ? _formatDateTime(subCategory.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', subCategory.createdBy ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailIcon() {
    if (subCategory.iconName == null || subCategory.iconName!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.subdirectory_arrow_right,
          size: 48,
          color: _parseColor(subCategory.markerColor),
        ),
      );
    }

    final iconData = _getIconData(subCategory.iconName);
    if (iconData != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          iconData,
          size: 48,
          color: _parseColor(subCategory.markerColor),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.subdirectory_arrow_right,
        size: 48,
        color: _parseColor(subCategory.markerColor),
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
      'subdirectory': Icons.subdirectory_arrow_right,
      'label': Icons.label,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.green;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.green;
    }
  }
}