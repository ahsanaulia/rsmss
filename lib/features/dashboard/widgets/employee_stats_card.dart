import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeStatsCard extends StatelessWidget {
  final double totalPoints;
  final Map<String, double> categoryScores;
  final double fatigueScore;
  final String fatigueRiskLevel;
  final String period;
  final VoidCallback? onTap;

  const EmployeeStatsCard({
    super.key,
    required this.totalPoints,
    this.categoryScores = const {},
    required this.fatigueScore,
    required this.fatigueRiskLevel,
    required this.period,
    this.onTap,
  });

  Color get _fatigueColor {
    if (fatigueScore <= 3) return Colors.green;
    if (fatigueScore <= 6) return Colors.orange;
    if (fatigueScore <= 8) return Colors.deepOrange;
    return Colors.red;
  }

  String get _fatigueLabel {
    if (fatigueScore <= 3) return 'Rendah';
    if (fatigueScore <= 6) return 'Sedang';
    if (fatigueScore <= 8) return 'Tinggi';
    return 'Kritis';
  }

  String get _fatigueIcon {
    if (fatigueScore <= 3) return '😊';
    if (fatigueScore <= 6) return '😐';
    if (fatigueScore <= 8) return '😓';
    return '😫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF01579B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              size: 20,
                              color: Color(0xFF01579B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Kinerja Bulan Ini",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF01579B),
                              ),
                            ),
                          ),
                          Text(
                            period,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Total Points
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            totalPoints.toInt().toString(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                          Text(
                            " poin",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          // Fatigue Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _fatigueColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _fatigueColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _fatigueIcon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Fatigue: $_fatigueLabel",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _fatigueColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      _buildProgressBar(),
                      const SizedBox(height: 12),

                      // Category Scores
                      if (categoryScores.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: categoryScores.entries.map((entry) {
                            return _buildCategoryChip(entry.key, entry.value);
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    // Target 100 points per bulan
    final target = 100.0;
    final progress = (totalPoints / target).clamp(0.0, 1.0);
    final remaining = target - totalPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF01579B),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${(progress * 100).toInt()}%",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: const Color(0xFF01579B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          remaining > 0 
              ? "Butuh ${remaining.toInt()} poin lagi untuk mencapai target"
              : "Target tercapai! 🎉",
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: remaining > 0 ? Colors.grey.shade500 : Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, double score) {
    final Map<String, dynamic> categoryConfig = _getCategoryConfig(category);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryConfig['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryConfig['icon'],
            size: 12,
            color: categoryConfig['color'],
          ),
          const SizedBox(width: 4),
          Text(
            "${categoryConfig['label']}: ${score.toInt()}",
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: categoryConfig['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryConfig(String code) {
    switch (code.toUpperCase()) {
      case 'ATTENDANCE':
        return {'label': 'Absensi', 'icon': Icons.check_circle, 'color': Colors.green};
      case 'TASK':
        return {'label': 'Tugas', 'icon': Icons.assignment, 'color': Colors.blue};
      case 'INCIDENT':
        return {'label': 'Insiden', 'icon': Icons.warning, 'color': Colors.red};
      case 'INSPECTION':
        return {'label': 'Inspeksi', 'icon': Icons.fact_check, 'color': Colors.teal};
      case 'OPNAME':
        return {'label': 'Opname', 'icon': Icons.inventory, 'color': Colors.orange};
      case 'WELLBEING':
        return {'label': 'Wellbeing', 'icon': Icons.favorite, 'color': Colors.pink};
      case 'duty_note':
        return {'label': 'Catatan', 'icon': Icons.note, 'color': Colors.purple};
      default:
        return {'label': code, 'icon': Icons.star, 'color': Colors.grey};
    }
  }
}