import 'dart:ui';

import 'package:flutter/material.dart';

class DashboardGlassCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final double borderRadius;

  final double blurSigma;

  final double opacity;

  final double borderOpacity;

  final double elevationOpacity;

  final double? width;
  final double? height;

  final Color? tintColor;

  const DashboardGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 24,
    this.blurSigma = 18,
    this.opacity = 0.10,
    this.borderOpacity = 0.18,
    this.elevationOpacity = 0.08,
    this.width,
    this.height,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        tintColor ?? const Color.fromARGB(255, 65, 126, 218);

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(opacity + 0.08),
                    color.withOpacity(opacity),
                  ],
                ),
                border: Border.all(
                  color: const Color.fromARGB(255, 35, 45, 88).withOpacity(
                    borderOpacity,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 185, 184, 184).withOpacity(
                      elevationOpacity,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}