// File: lib/insights/profiles/widgets/shared/gauge_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GaugeWidget extends StatelessWidget {
  final double value;
  final String title;
  final double minValue;
  final double maxValue;
  final Color lowColor;
  final Color mediumColor;
  final Color highColor;

  const GaugeWidget({
    super.key,
    required this.value,
    required this.title,
    this.minValue = 0,
    this.maxValue = 100,
    this.lowColor = const Color(0xFF10B981),
    this.mediumColor = const Color(0xFFF59E0B),
    this.highColor = const Color(0xFFEF4444),
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value - minValue) / (maxValue - minValue);
    final gaugeColor = _getColor(percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: gaugeColor.withValues(alpha: 0.2),
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
          Center(
            child: SizedBox(
              width: 120,
              height: 70,
              child: CustomPaint(
                painter: _GaugePainter(
                  percentage: percentage,
                  gaugeColor: gaugeColor,
                  lowColor: lowColor,
                  mediumColor: mediumColor,
                  highColor: highColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${value.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(double percentage) {
    if (percentage < 0.5) return lowColor;
    if (percentage < 0.8) return mediumColor;
    return highColor;
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color gaugeColor;
  final Color lowColor;
  final Color mediumColor;
  final Color highColor;

  _GaugePainter({
    required this.percentage,
    required this.gaugeColor,
    required this.lowColor,
    required this.mediumColor,
    required this.highColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final startAngle = -180 * (3.14159 / 180);
    final sweepAngle = 180 * (3.14159 / 180);
    
    // Background arc - glassmorphism style
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, bgPaint);

    // Colored arc
    final valueAngle = sweepAngle * percentage;
    final valuePaint = Paint()
      ..color = gaugeColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, valueAngle, false, valuePaint);

    // Needle
    final needleAngle = startAngle + valueAngle;
    final needleEnd = Offset(
      center.dx + (radius - 12) * (needleAngle < 0 ? -1 : 1),
      center.dy + (radius - 12) * (needleAngle.abs() / 180),
    );
    canvas.drawLine(center, needleEnd, Paint()..color = Colors.white..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}