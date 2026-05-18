// lib/features/roster/presentation/widgets/roster_legend.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/enums/attendance_status.dart';
import '../../domain/enums/approval_status.dart';

class RosterLegend extends StatelessWidget {
  const RosterLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEGENDA',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.green, 'Hadir'),
              _buildLegendItem(Colors.red, 'Absen'),
              _buildLegendItem(Colors.orange, 'Terlambat'),
              _buildLegendItem(Colors.blue, 'Cuti'),
              _buildLegendItem(Colors.purple, 'Sakit'),
              _buildLegendItem(Colors.grey, 'Terjadwal'),
              _buildLegendItem(Colors.blue, 'Libur'),
              _buildLegendItem(Colors.orange, 'Menunggu'),
              _buildLegendItem(Colors.green, 'Disetujui'),
              _buildLegendItem(Colors.red, 'Ditolak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10),
        ),
      ],
    );
  }
}