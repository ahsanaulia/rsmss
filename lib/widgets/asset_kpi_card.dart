import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_glass_card.dart';

class AssetKpiCard extends StatelessWidget {
  final String title;
  final String value;

  final String? subtitle;

  final IconData icon;

  final Color color;

  final double height;

  final bool compact;

  const AssetKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.height = 150,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final screenWidth = media.size.width;

    // 🔥 penting untuk Android TV / TCL TV
    final textScale =
        media.textScaler.scale(1.0);

    final bool isTV =
        screenWidth >= 1400;

    final bool isUltraWide =
        screenWidth >= 1800;

    final double valueSize =
        compact
            ? (isTV ? 24 : 20)
            : (isUltraWide ? 34 : 28);

    final double titleSize =
        isTV ? 12 : 11;

    final double subtitleSize =
        isTV ? 10 : 9;

    final double iconSize =
        compact
            ? (isTV ? 24 : 20)
            : (isUltraWide ? 34 : 28);

    return DashboardGlassCard(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =====================================
                // HEADER
                // =====================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            color.withOpacity(0.18),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: iconSize,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // =====================================
                // VALUE
                // =====================================

                Align(
                  alignment:
                      Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        Alignment.centerRight,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      overflow:
                          TextOverflow.fade,
                      textAlign:
                          TextAlign.right,
                      style:
                          GoogleFonts.plusJakartaSans(
                        fontSize:
                            valueSize /
                            textScale,
                        fontWeight:
                            FontWeight.w700,
                        color: Colors.blue,
                        letterSpacing:
                            -0.5,
                        height: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // =====================================
                // TITLE
                // =====================================

                SizedBox(
                  height: 30,
                  child: Align(
                    alignment:
                        Alignment.centerRight,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      textAlign:
                          TextAlign.right,
                      style:
                          GoogleFonts.plusJakartaSans(
                        fontSize:
                            titleSize /
                            textScale,
                        color: Colors.blue
                            .withOpacity(0.82),
                        fontWeight:
                            FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),

                // =====================================
                // SUBTITLE
                // =====================================

                if (subtitle != null)
                  SizedBox(
                    height: 16,
                    child: Align(
                      alignment:
                          Alignment.centerRight,
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        textAlign:
                            TextAlign.right,
                        style:
                            GoogleFonts.plusJakartaSans(
                          fontSize:
                              subtitleSize /
                              textScale,
                          color: Colors.blue
                              .withOpacity(
                            0.50,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}