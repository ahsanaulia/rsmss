// File: lib/insights/profiles/widgets/shared/line_chart.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> data;
  final String title;
  final String? yAxisLabel;
  final List<String>? xAxisLabels;
  final Color lineColor;
  final Color fillColor;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.yAxisLabel,
    this.xAxisLabels,
    this.lineColor = const Color(0xFF3B82F6),
    this.fillColor = const Color(0xFF3B82F6),
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _buildDecoration(),
        child: Center(
          child: Text(
            'Belum ada data',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final chartHeight = 120.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildDecoration(),
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
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: data,
                maxValue: maxValue,
                minValue: minValue,
                chartHeight: chartHeight,
                lineColor: lineColor,
                fillColor: fillColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          if (xAxisLabels != null && xAxisLabels!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: xAxisLabels!.map((label) {
                  return Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.08),
      border: Border.all(
        color: lineColor.withValues(alpha: 0.2),
        width: 0.5,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double minValue;
  final double chartHeight;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.chartHeight,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final range = maxValue - minValue;
    final stepX = width / (data.length - 1);
    
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final y = range > 0 
          ? chartHeight - ((data[i] - minValue) / range) * chartHeight
          : chartHeight / 2;
      points.add(Offset(i * stepX, y));
    }

    // Draw fill area
    final fillPath = Path()
      ..addPolygon([Offset(0, chartHeight), ...points, Offset(width, chartHeight)], true);
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
      canvas.drawCircle(point, 1.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}