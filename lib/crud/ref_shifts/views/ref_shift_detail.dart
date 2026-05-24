import 'package:flutter/material.dart';
import 'package:rsmss/crud/ref_shifts/models/ref_shift_model.dart';

class RefShiftDetailPage extends StatelessWidget {
  final RefShiftModel item;

  const RefShiftDetailPage({
    super.key,
    required this.item,
  });

  String _formatTime(String time) {
    if (time.length >= 5) {
      return time.substring(0, 5);
    }
    return time;
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;
    final color = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$color', radix: 16));
  }

  String _getRiskLevelLabel(String? level) {
    switch (level) {
      case 'normal': return 'Normal';
      case 'low': return 'Rendah';
      case 'medium': return 'Sedang';
      case 'high': return 'Tinggi';
      case 'critical': return 'Kritis';
      default: return 'Normal';
    }
  }

  Color _getRiskLevelColor(String? level) {
    switch (level) {
      case 'normal': return Colors.green;
      case 'low': return Colors.blue;
      case 'medium': return Colors.orange;
      case 'high': return Colors.deepOrange;
      case 'critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive ?? true;
    final color = _getColorFromHex(item.colorHex);
    final riskLevelColor = _getRiskLevelColor(item.riskLevel);
    final riskLevelLabel = _getRiskLevelLabel(item.riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${item.shiftName}'),
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
                // Header
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
                        child: Icon(Icons.schedule, size: 48, color: color),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.shiftName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}'),
                        avatar: const Icon(Icons.access_time, size: 16),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (item.isCrossDay == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Lintas Hari',
                                style: TextStyle(color: Colors.purple.shade800),
                              ),
                            ),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),

                // Basic Info
                _buildSectionTitle('Informasi Dasar'),
                _buildDetailRow('ID', item.id ?? '-'),
                _buildDetailRow('Nama Shift', item.shiftName),
                if (item.shiftCode != null) _buildDetailRow('Kode Shift', item.shiftCode!),
                _buildDetailRow('Jam Mulai', _formatTime(item.startTime)),
                _buildDetailRow('Jam Selesai', _formatTime(item.endTime)),
                if (item.description != null) _buildDetailRow('Deskripsi', item.description!),
                // if (item.appName != null) _buildDetailRow('Aplikasi', item.appName!),
                const SizedBox(height: 16),

                // Time & Tolerance
                _buildSectionTitle('Waktu & Toleransi'),
                _buildDetailRow('Durasi Istirahat', '${item.breakDurationMinutes ?? 60} menit'),
                _buildDetailRow('Toleransi Terlambat', '${item.toleranceLateMinutes ?? 15} menit'),
                _buildDetailRow('Toleransi Pulang Cepat', '${item.toleranceEarlyLeaveMinutes ?? 15} menit'),
                _buildDetailRow('Minimal Kerja', '${item.minimumWorkMinutes ?? 480} menit'),
                _buildDetailRow('Maksimal Lembur', '${item.maximumOvertimeMinutes ?? 240} menit'),
                const SizedBox(height: 16),

                // Risk & Weight
                _buildSectionTitle('Risiko & Bobot'),
                _buildDetailRow('Bobot Kelelahan', (item.fatigueWeight ?? 1.0).toStringAsFixed(2)),
                _buildDetailRow('Bobot Prioritas AI', (item.aiPriorityWeight ?? 1.0).toStringAsFixed(2)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 120, child: Text('Tingkat Risiko', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskLevelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(riskLevelLabel, style: TextStyle(color: riskLevelColor)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Requirements
                _buildSectionTitle('Persyaratan'),
                _buildDetailRow('Perlu Keterangan Medis', item.requiresMedicalFit == true ? 'Ya' : 'Tidak'),
                _buildDetailRow('Perlu Persetujuan Supervisor', item.requiresSupervisor == true ? 'Ya' : 'Tidak'),
                _buildDetailRow('Perlu Foto Check-in', item.requiresCheckinPhoto == true ? 'Ya' : 'Tidak'),
                _buildDetailRow('Perlu Validasi Lokasi', item.requiresLocationValidation == true ? 'Ya' : 'Tidak'),
                const SizedBox(height: 16),

                // Features
                _buildSectionTitle('Fitur'),
                _buildDetailRow('Monitoring Kesejahteraan', item.wellbeingMonitoringEnabled == true ? 'Ya' : 'Tidak'),
                _buildDetailRow('Penjadwalan Otomatis', item.autoAssignAllowed == true ? 'Ya' : 'Tidak'),
                const SizedBox(height: 16),

                // Style
                _buildSectionTitle('Tampilan'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 120, child: Text('Warna', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(item.colorHex ?? '#2196F3'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.iconName != null) _buildDetailRow('Icon', item.iconName!),
                const SizedBox(height: 16),

                // Timestamps
                _buildSectionTitle('Informasi Waktu'),
                _buildDetailRow('Dibuat Pada', item.createdAt != null ? _formatDateTime(item.createdAt!) : '-'),
                _buildDetailRow('Terakhir Diupdate', item.updatedAt != null ? _formatDateTime(item.updatedAt!) : '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}