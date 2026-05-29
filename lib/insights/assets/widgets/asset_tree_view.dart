// lib/insights/assets/widgets/asset_tree_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset_tree_model.dart';
import '../providers/asset_tree_provider.dart';

class AssetTreeView extends ConsumerStatefulWidget {
  final Function(AssetTypeNode) onTypeTap;
  final String? selectedTypeId;

  const AssetTreeView({
    super.key,
    required this.onTypeTap,
    this.selectedTypeId,
  });

  @override
  ConsumerState<AssetTreeView> createState() => _AssetTreeViewState();
}

class _AssetTreeViewState extends ConsumerState<AssetTreeView> {
  final Set<String> _expandedCategories = {};
  final Set<String> _expandedSubCategories = {};

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(assetTreeProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: categoriesAsync.when(
            data: (categories) => _buildTree(categories),
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat data: ${e.toString()}',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTree(List<AssetCategoryNode> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data asset',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isExpanded = _expandedCategories.contains(category.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryItem(category, isExpanded),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: category.subCategories.map((subCategory) {
                    return _buildSubCategoryItem(subCategory);
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(AssetCategoryNode category, bool isExpanded) {
    final color = const Color(0xFF10B981);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCategories.remove(category.id);
          } else {
            _expandedCategories.add(category.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Icon(Icons.category, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${category.assetCount}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryItem(AssetSubCategoryNode subCategory) {
    final isExpanded = _expandedSubCategories.contains(subCategory.id);
    final color = const Color(0xFF06B6D4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedSubCategories.remove(subCategory.id);
              } else {
                _expandedSubCategories.add(subCategory.id);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Icon(Icons.subdirectory_arrow_right, size: 16, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subCategory.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${subCategory.assetCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: subCategory.types.map((type) {
                return _buildTypeItem(type);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeItem(AssetTypeNode type) {
    final isSelected = widget.selectedTypeId == type.id;
    final color = const Color(0xFF8B5CF6);

    return GestureDetector(
      onTap: () => widget.onTypeTap(type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.devices, size: 16, color: isSelected ? color : Colors.white54),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                type.name,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${type.assetCount}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}