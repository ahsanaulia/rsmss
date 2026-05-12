import 'package:flutter/material.dart';

import 'dashboard_glass_card.dart';

class DashboardLoading extends StatelessWidget {
  final int itemCount;

  final double itemHeight;

  const DashboardLoading({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 240,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (_, __) {
        return DashboardGlassCard(
          height: itemHeight,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 51, 73, 133)
                      .withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),

              const Spacer(),

              Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 25, 68, 109)
                      .withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 61, 114)
                      .withOpacity(0.05),
                  borderRadius:
                      BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}