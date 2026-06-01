// File: lib/insights/profiles/widgets/shared/bar_chart.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color barColor;
  final int maxItems;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.barColor = const Color(0xFF3B82F6),
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    final displayEntries = entries.take(maxItems).toList();
    
    final maxValue = displayEntries.isNotEmpty 
        ? displayEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: barColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          ...displayEntries.map((entry) => _buildBar(entry.key, entry.value, maxValue)),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, double maxValue) {
    final percentage = maxValue > 0 ? (value / maxValue) * 100 : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.toInt().toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: barColor.withValues(alpha: 0.15),
              color: barColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}