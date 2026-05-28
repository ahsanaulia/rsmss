// lib/insights/profiles/widgets/shared/donut_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DonutChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final double total;

  const DonutChart({
    super.key,
    required this.data,
    required this.title,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final colors = [
      const Color(0xFF01579B),
      const Color(0xFF00838F),
      const Color(0xFF2E7D32),
      const Color(0xFFED6C02),
      const Color(0xFFD32F2F),
      const Color(0xFF5E35B1),
      const Color(0xFFF9A825),
    ];

    if (entries.isEmpty || total == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Center(
          child: Text(
            'Tidak ada data',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );
    }

    // Konversi data ke PieChartSectionData
    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final percentage = (entry.value / total) * 100;
      sections.add(
        PieChartSectionData(
          value: percentage,
          title: '${percentage.toStringAsFixed(0)}%',
          color: colors[i % colors.length],
          radius: 55,
          titleStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          showTitle: percentage > 5,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180, // 🔥 DIPERBESAR untuk accommodate legend multi-baris
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildLegend(entries, colors),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<MapEntry<String, int>> entries, List<Color> colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.take(5).map((entry) {
        final index = entries.indexOf(entry);
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), // 🔥 DIPERBESAR jarak antar item
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // 🔥 Ubah agar teks multi-baris sejajar atas
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 2), // 🔥 sejajarkan dengan teks baris pertama
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 TEKS BISA 2-3 BARIS
                    Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                      softWrap: true, // 🔥 BAWAAN - biarkan wrap
                      overflow: TextOverflow.visible, // 🔥 JANGAN dipotong
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors[index % colors.length],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}