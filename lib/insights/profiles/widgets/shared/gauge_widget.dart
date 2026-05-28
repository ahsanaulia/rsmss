// lib/insights/profiles/widgets/shared/gauge_widget.dart

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
    this.lowColor = Colors.green,
    this.mediumColor = Colors.orange,
    this.highColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value - minValue) / (maxValue - minValue);
    final gaugeColor = _getColor(percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
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
                fontSize: 20,
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
    
    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, bgPaint);

    // Colored arc
    final valueAngle = sweepAngle * percentage;
    final valuePaint = Paint()
      ..color = gaugeColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, valueAngle, false, valuePaint);

    // Needle
    final needleAngle = startAngle + valueAngle;
    final needleEnd = Offset(
      center.dx + (radius - 15) * (needleAngle < 0 ? -1 : 1),
      center.dy + (radius - 15) * (needleAngle.abs() / 180),
    );
    canvas.drawLine(center, needleEnd, Paint()..color = Colors.grey.shade800..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
