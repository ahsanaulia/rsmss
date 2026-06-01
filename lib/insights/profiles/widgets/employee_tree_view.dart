// File: lib/insights/profiles/widgets/employee_tree_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_list_provider.dart';

class EmployeeTreeView extends ConsumerStatefulWidget {
  final Function(int level) onLevelTap;
  final int? selectedLevel;

  const EmployeeTreeView({
    super.key,
    required this.onLevelTap,
    this.selectedLevel,
  });

  @override
  ConsumerState<EmployeeTreeView> createState() => _EmployeeTreeViewState();
}

class _EmployeeTreeViewState extends ConsumerState<EmployeeTreeView> {
  @override
  Widget build(BuildContext context) {
    final levelsAsync = ref.watch(allLevelsProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: levelsAsync.when(
          data: (levels) => _buildTree(levels),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => Center(
            child: Text(
              'Gagal memuat data level: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTree(List<LevelItem> levels) {
    if (levels.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data level',
          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isSelected = widget.selectedLevel == level.level;

        return _buildLevelItem(level, isSelected);
      },
    );
  }

  Widget _buildLevelItem(LevelItem level, bool isSelected) {
    final levelColor = _getColorFromHex(level.color);

    return GestureDetector(
      onTap: () => widget.onLevelTap(level.level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? levelColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? levelColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconFromName(level.iconName),
                color: levelColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${level.level}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          level.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${level.employeeCount} Orang',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.chevron_right,
                color: levelColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse('0xFF${hexColor.replaceAll('#', '')}'));
    } catch (e) {
      return const Color(0xFF8B5CF6);
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'business_center':
        return Icons.business_center;
      case 'manage_accounts':
        return Icons.manage_accounts;
      case 'account_balance':
        return Icons.account_balance;
      case 'medical_services':
        return Icons.medical_services;
      case 'meeting_room':
        return Icons.meeting_room;
      case 'supervisor_account':
        return Icons.supervisor_account;
      case 'healing':
        return Icons.healing;
      case 'favorite':
        return Icons.favorite;
      case 'science':
        return Icons.science;
      case 'assignment_ind':
        return Icons.assignment_ind;
      case 'group':
        return Icons.group;
      default:
        return Icons.person;
    }
  }
}