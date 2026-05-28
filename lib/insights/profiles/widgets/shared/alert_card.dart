// lib/insights/profiles/widgets/shared/alert_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AlertType {
  critical,
  warning,
  info,
  success,
}

class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final String? time;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.time,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final icon = _getIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors['bg']!.withValues(alpha: 0.95),
              colors['bg']!.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors['border']!.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: colors['shadow']!.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors['iconBg']!.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors['icon'], size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors['text'],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: colors['text']?.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (time != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        time!,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: colors['text']?.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colors['text']?.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case AlertType.critical:
        return {
          'bg': Colors.red.shade50,
          'border': Colors.red.shade300,
          'shadow': Colors.red,
          'iconBg': Colors.red,
          'icon': Colors.red.shade700,
          'text': Colors.red.shade900,
        };
      case AlertType.warning:
        return {
          'bg': Colors.orange.shade50,
          'border': Colors.orange.shade300,
          'shadow': Colors.orange,
          'iconBg': Colors.orange,
          'icon': Colors.orange.shade700,
          'text': Colors.orange.shade900,
        };
      case AlertType.info:
        return {
          'bg': Colors.blue.shade50,
          'border': Colors.blue.shade300,
          'shadow': Colors.blue,
          'iconBg': Colors.blue,
          'icon': Colors.blue.shade700,
          'text': Colors.blue.shade900,
        };
      case AlertType.success:
        return {
          'bg': Colors.green.shade50,
          'border': Colors.green.shade300,
          'shadow': Colors.green,
          'iconBg': Colors.green,
          'icon': Colors.green.shade700,
          'text': Colors.green.shade900,
        };
    }
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.critical:
        return Icons.error_outline;
      case AlertType.warning:
        return Icons.warning_amber_outlined;
      case AlertType.info:
        return Icons.info_outline;
      case AlertType.success:
        return Icons.check_circle_outline;
    }
  }
}