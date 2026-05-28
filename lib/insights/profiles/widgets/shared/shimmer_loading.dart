// lib/insights/profiles/widgets/shared/shimmer_loading.dart

import 'package:flutter/material.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer(
      linearGradient: const LinearGradient(
        colors: [
          Color(0xFFEBEBF4),
          Color(0xFFF5F5FA),
          Color(0xFFEBEBF4),
        ],
        stops: [0.1, 0.3, 0.4],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
      ),
      child: child,
    );
  }
}

class Shimmer extends StatefulWidget {
  final LinearGradient linearGradient;
  final Widget child;
  final Duration period;

  const Shimmer({
    super.key,
    required this.linearGradient,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: widget.period);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return widget.linearGradient.createShader(
              Rect.fromLTWH(
                -bounds.width + (bounds.width * 2 * _controller.value),
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}