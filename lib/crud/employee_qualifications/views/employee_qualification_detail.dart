import 'package:flutter/material.dart';
import 'package:rsmss/crud/employee_qualifications/models/employee_qualification_model.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class EmployeeQualificationDetailPage extends StatelessWidget {
  final EmployeeQualificationModel item;

  const EmployeeQualificationDetailPage({
    super.key,
    required this.item,
  });

  String _getCategoryLabel(String? category) {
    switch (category) {
      case 'medical':
        return 'Medis';
      case 'nursing':
        return 'Keperawatan';
      case 'administrative':
        return 'Administrasi';
      case 'technical':
        return 'Teknis';
      default:
        return category ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isActive = item.isActive ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations?.crud_eq_detail_title ?? 'Detail'}: ${item.qualificationName}'),
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
                          color: isActive ? Colors.green.shade50 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.verified,
                          size: 48,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.qualificationName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(item.qualificationCode),
                        avatar: const Icon(Icons.code, size: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isActive 
                                  ? (localizations?.crud_eq_status_active ?? 'Aktif')
                                  : (localizations?.crud_eq_status_inactive ?? 'Nonaktif'),
                              style: TextStyle(
                                color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.requiresRenewal == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                localizations?.crud_eq_requires_renewal ?? 'Perlu Perpanjangan',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                _buildDetailRow(context, localizations?.crud_eq_detail_id ?? 'ID', item.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow(context, localizations?.crud_eq_detail_code ?? 'Kode Kualifikasi', item.qualificationCode),
                const SizedBox(height: 12),
                _buildDetailRow(context, localizations?.crud_eq_detail_name ?? 'Nama Kualifikasi', item.qualificationName),
                const SizedBox(height: 12),
                _buildDetailRow(context, localizations?.crud_eq_detail_category ?? 'Kategori', _getCategoryLabel(item.category)),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  localizations?.crud_eq_detail_validity ?? 'Masa Berlaku',
                  item.validityPeriodMonths != null
                      ? '${item.validityPeriodMonths} ${localizations?.crud_eq_months_suffix ?? 'bulan'}'
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  localizations?.crud_eq_detail_requires_renewal ?? 'Perlu Perpanjangan',
                  item.requiresRenewal == true 
                      ? (localizations?.crud_eq_yes ?? 'Ya')
                      : (localizations?.crud_eq_no ?? 'Tidak'),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(context, localizations?.crud_eq_detail_description ?? 'Deskripsi', item.description ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  localizations?.crud_eq_detail_created_at ?? 'Dibuat Pada',
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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