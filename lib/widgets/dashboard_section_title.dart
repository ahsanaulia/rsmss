import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSectionTitle extends StatelessWidget {
  final String title;

  final String? subtitle;

  final IconData? icon;

  final EdgeInsetsGeometry padding;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.padding =
        const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen =
        MediaQuery.of(context).size.width >= 1600;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: const Color.fromARGB(255, 9, 27, 85),
              size: isLargeScreen ? 22 : 18,
            ),

            const SizedBox(width: 10),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize:
                        isLargeScreen ? 24 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color.fromARGB(255, 13, 24, 83),
                    letterSpacing: -0.4,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 4),

                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        GoogleFonts.plusJakartaSans(
                      fontSize:
                          isLargeScreen ? 13 : 11,
                      color: const Color.fromARGB(255, 16, 29, 85)
                          .withOpacity(0.60),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}