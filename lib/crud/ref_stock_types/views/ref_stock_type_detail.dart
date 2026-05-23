import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_stock_types/models/ref_stock_type_model.dart';

class RefStockTypeDetailPage extends StatelessWidget {
  final RefStockTypeModel type;

  const RefStockTypeDetailPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${type.typeName}'),
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
                        type.typeName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (type.subCategoryName != null)
                        Chip(
                          label: Text(type.subCategoryName!),
                          avatar: const Icon(Icons.subdirectory_arrow_right, size: 16),
                        ),
                      if (type.categoryName != null)
                        Chip(
                          label: Text(type.categoryName!),
                          avatar: const Icon(Icons.category, size: 16),
                        ),
                      if (type.markerColor != null)
                        Chip(
                          label: Text(type.markerColor!),
                          avatar: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(type.markerColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                _buildDetailRow('ID', type.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Tipe Stok', type.typeName),
                const SizedBox(height: 12),
                if (type.description != null && type.description!.isNotEmpty)
                  _buildDetailRow('Deskripsi', type.description!),
                if (type.description != null && type.description!.isNotEmpty)
                  const SizedBox(height: 12),
                _buildDetailRow('Icon', type.iconName ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Warna Marker', type.markerColor ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibuat Pada',
                  type.createdAt != null
                      ? _formatDateTime(type.createdAt!)
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat Oleh', type.createdBy ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailIcon() {
    if (type.iconName == null || type.iconName!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.label,
          size: 48,
          color: _parseColor(type.markerColor),
        ),
      );
    }

    final iconData = _getIconData(type.iconName);
    if (iconData != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          iconData,
          size: 48,
          color: _parseColor(type.markerColor),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.label,
        size: 48,
        color: _parseColor(type.markerColor),
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
      'label': Icons.label,
      'category': Icons.category,
      'inventory': Icons.inventory_2,
      'local_shipping': Icons.local_shipping,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.teal;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.teal;
    }
  }
}