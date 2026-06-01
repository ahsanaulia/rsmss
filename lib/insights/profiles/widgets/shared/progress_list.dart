// File: lib/insights/profiles/widgets/shared/progress_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressItem {
  final String id;
  final String title;
  final String? subtitle;
  final double value;
  final double maxValue;
  final Color? color;
  final String? avatarUrl;
  final String? initial;

  ProgressItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.value,
    required this.maxValue,
    this.color,
    this.avatarUrl,
    this.initial,
  });

  double get percentage => maxValue > 0 ? (value / maxValue) * 100 : 0;
}

class ProgressList extends StatelessWidget {
  final List<ProgressItem> items;
  final String title;
  final bool showAvatar;
  final int maxItems;

  const ProgressList({
    super.key,
    required this.items,
    required this.title,
    this.showAvatar = true,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(maxItems).toList();
    final accentColor = const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
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
          const SizedBox(height: 14),
          ...displayItems.map((item) => _buildProgressItem(item)),
          if (items.length > maxItems)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'dan ${items.length - maxItems} lainnya...',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(ProgressItem item) {
    final itemColor = item.color ?? const Color(0xFF3B82F6);
    final percentage = item.percentage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (showAvatar)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: itemColor.withValues(alpha: 0.1),
                border: Border.all(color: itemColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Center(
                child: item.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          item.avatarUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            size: 16,
                            color: itemColor,
                          ),
                        ),
                      )
                    : Text(
                        item.initial ?? item.title.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: itemColor,
                        ),
                      ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.value.toInt()}/${item.maxValue.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: itemColor,
                      ),
                    ),
                  ],
                ),
                if (item.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: itemColor.withValues(alpha: 0.15),
                    color: _getProgressColor(percentage, itemColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage, Color defaultColor) {
    if (percentage < 30) return const Color(0xFFEF4444);
    if (percentage < 70) return const Color(0xFFF59E0B);
    return defaultColor;
  }
}