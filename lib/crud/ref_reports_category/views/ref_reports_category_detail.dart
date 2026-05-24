import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_reports_category/models/ref_reports_category_model.dart';

class RefReportsCategoryDetailPage extends StatelessWidget {
  final RefReportsCategoryModel item;

  const RefReportsCategoryDetailPage({
    super.key,
    required this.item,
  });

  IconData _getIconFromString(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'report':
        return Icons.report;
      case 'assessment':
        return Icons.assessment;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'description':
        return Icons.description;
      case 'receipt':
        return Icons.receipt;
      case 'fact_check':
        return Icons.fact_check;
      case 'analytics':
        return Icons.analytics;
      case 'summarize':
        return Icons.summarize;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconFromString(item.iconName);

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
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          size: 48,
                          color: Colors.green,
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
                    ],
                  ),
                ),
                const Divider(height: 32),

                _buildDetailRow('ID', item.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Kategori', item.name),
                const SizedBox(height: 12),
                _buildDetailRow('Deskripsi', item.description ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Icon', item.iconName ?? '-'),
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
}