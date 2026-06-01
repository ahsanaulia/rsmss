// File: lib/insights/profiles/widgets/shared/alert_card.dart

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
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: colors['border']!.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors['iconBg']!.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors['icon'], size: 18),
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
                      color: Colors.white.withValues(alpha: 0.7),
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
                          color: Colors.white.withValues(alpha: 0.5),
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
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.4),
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
          'border': const Color(0xFFEF4444),
          'iconBg': const Color(0xFFEF4444),
          'icon': const Color(0xFFEF4444),
          'text': const Color(0xFFEF4444),
        };
      case AlertType.warning:
        return {
          'border': const Color(0xFFF59E0B),
          'iconBg': const Color(0xFFF59E0B),
          'icon': const Color(0xFFF59E0B),
          'text': const Color(0xFFF59E0B),
        };
      case AlertType.info:
        return {
          'border': const Color(0xFF3B82F6),
          'iconBg': const Color(0xFF3B82F6),
          'icon': const Color(0xFF3B82F6),
          'text': const Color(0xFF3B82F6),
        };
      case AlertType.success:
        return {
          'border': const Color(0xFF10B981),
          'iconBg': const Color(0xFF10B981),
          'icon': const Color(0xFF10B981),
          'text': const Color(0xFF10B981),
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