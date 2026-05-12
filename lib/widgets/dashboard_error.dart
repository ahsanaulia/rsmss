import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_glass_card.dart';

class DashboardError extends StatelessWidget {
  final String title;

  final String? message;

  final VoidCallback? onRetry;

  const DashboardError({
    super.key,
    this.title = 'Failed to Load Dashboard',
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen =
        MediaQuery.of(context).size.width >= 1600;

    return Center(
      child: SizedBox(
        width: isLargeScreen ? 520 : 420,
        child: DashboardGlassCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 36, 22).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color.fromARGB(255, 248, 18, 18),
                  size: 42,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize:
                      isLargeScreen ? 24 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),

              if (message != null) ...[
                const SizedBox(height: 10),

                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.plusJakartaSans(
                    fontSize:
                        isLargeScreen ? 14 : 12,
                    color: Colors.blue
                        .withOpacity(0.65),
                    height: 1.6,
                  ),
                ),
              ],

              if (onRetry != null) ...[
                const SizedBox(height: 24),

                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Retry',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
