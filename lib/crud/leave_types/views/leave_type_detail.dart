import 'package:flutter/material.dart';
import 'package:rsmss/crud/leave_types/models/leave_type_model.dart';

class LeaveTypeDetailPage extends StatelessWidget {
  final LeaveTypeModel item;

  const LeaveTypeDetailPage({
    super.key,
    required this.item,
  });

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.orange;
    final color = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$color', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive ?? true;
    final color = _getColorFromHex(item.color);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${item.leaveName}'),
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
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.beach_access,
                          size: 48,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.leaveName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(item.leaveCode),
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
                _buildDetailRow('Kode Cuti', item.leaveCode),
                const SizedBox(height: 12),
                _buildDetailRow('Nama Cuti', item.leaveName),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Maksimal Hari per Tahun',
                  item.maxDaysPerYear != null ? '${item.maxDaysPerYear} hari' : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Cuti Berbayar', item.paidLeave == true ? 'Ya' : 'Tidak'),
                const SizedBox(height: 12),
                _buildDetailRow('Perlu Dokumen', item.requiresDocument == true ? 'Ya' : 'Tidak'),
                const SizedBox(height: 12),
                _buildDetailRow('Perlu Surat Dokter', item.requiresMedicalCertificate == true ? 'Ya' : 'Tidak'),
                const SizedBox(height: 12),
                _buildDetailRow('Warna', item.color ?? '#FF9800'),
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