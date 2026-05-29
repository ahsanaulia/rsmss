// File: lib/insights/profiles/widgets/shared/donut_chart.dart

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
      const Color(0xFFF59E0B), // PENDING - Orange/Warning
      const Color(0xFF10B981), // APPROVED - Hijau/Success
      const Color(0xFFEF4444), // REJECTED - Merah/Danger
      const Color(0xFF8B5CF6), // COMPLETED - Ungu/Purple
      const Color(0xFF3B82F6), // Cadangan - Biru
      const Color(0xFF06B6D4), // Cadangan - Cyan
      const Color(0xFFF9A825), // Cadangan - Kuning
    ];

    if (entries.isEmpty || total == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Tidak ada data',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
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
          radius: 45, // DIPERKECIL DARI 55
          titleStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          showTitle: percentage > 5,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8), // DIPERKECIL DARI 12
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              // Tinggi responsif berdasarkan lebar
              final chartHeight = constraints.maxWidth * 0.35;
              return SizedBox(
                height: chartHeight.clamp(130.0, 160.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 25, // DIPERKECIL DARI 35
                          startDegreeOffset: -90,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    Expanded(flex: 1, child: _buildLegend(entries, colors)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<MapEntry<String, int>> entries, List<Color> colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: entries.map((entry) {
        final index = entries.indexOf(entry);
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6), // DIPERKECIL DARI 12
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
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
