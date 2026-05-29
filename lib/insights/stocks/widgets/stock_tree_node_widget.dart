// File: lib/insights/stocks/widgets/stock_tree_node_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stock_tree_node_model.dart';

/// Widget untuk menampilkan node tree (Category, SubCategory, Type)
class StockTreeNodeWidget extends ConsumerStatefulWidget {
  final StockCategoryNode? category;
  final StockSubCategoryNode? subCategory;
  final StockTypeNode? type;
  final int level;
  final bool isExpanded;
  final VoidCallback onToggle;

  const StockTreeNodeWidget({
    super.key,
    this.category,
    this.subCategory,
    this.type,
    this.level = 0,
    this.isExpanded = false,
    required this.onToggle,
  }) : assert(
         (category != null) ||
             (subCategory != null) ||
             (type != null),
         'Must provide either category, subCategory, or type',
       );

  @override
  ConsumerState<StockTreeNodeWidget> createState() => _StockTreeNodeWidgetState();
}

class _StockTreeNodeWidgetState extends ConsumerState<StockTreeNodeWidget> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final indent = widget.level * (isMobile ? 12.0 : 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NODE HEADER
        _buildNodeHeader(indent),
        
        // CHILDREN (if expanded)
        if (widget.isExpanded) ...[
          if (widget.category != null)
            ..._buildCategoryChildren(),
          if (widget.subCategory != null)
            ..._buildSubCategoryChildren(),
          if (widget.type != null)
            ..._buildTypeChildren(),
        ],
      ],
    );
  }

  Widget _buildNodeHeader(double indent) {
    final hasChildren = _hasChildren();
    final isCategory = widget.category != null;
    final isSubCategory = widget.subCategory != null;
    // isType dihapus karena tidak digunakan (warning resolved)

    Color nodeColor;
    IconData nodeIcon;
    String nodeName;
    int itemCount;
    int totalQuantity;

    if (isCategory) {
      nodeColor = widget.category!.category.markerColorValue;
      nodeIcon = widget.category!.category.icon;
      nodeName = widget.category!.category.categoryName;
      itemCount = widget.category!.totalItems;
      totalQuantity = widget.category!.totalQuantity;
    } else if (isSubCategory) {
      nodeColor = widget.subCategory!.subCategory.markerColorValue;
      nodeIcon = widget.subCategory!.subCategory.icon;
      nodeName = widget.subCategory!.subCategory.subCategoryName;
      itemCount = widget.subCategory!.totalItems;
      totalQuantity = widget.subCategory!.totalQuantity;
    } else {
      // Type node
      nodeColor = widget.type!.type.markerColorValue;
      nodeIcon = widget.type!.type.icon;
      nodeName = widget.type!.type.typeName;
      itemCount = widget.type!.totalItems;
      totalQuantity = widget.type!.totalQuantity;
    }

    return GestureDetector(
      onTap: hasChildren ? widget.onToggle : null,
      child: Container(
        margin: EdgeInsets.only(left: indent, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon with color
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: nodeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                nodeIcon,
                size: 18,
                color: nodeColor,
              ),
            ),
            const SizedBox(width: 12),
            
            // Node name and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nodeName,
                    style: GoogleFonts.poppins(
                      fontSize: widget.level == 0 ? 14 : 13,
                      fontWeight: widget.level == 0 ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$itemCount items • $totalQuantity qty',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                totalQuantity.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            
            // Expand/Collapse icon
            if (hasChildren) ...[
              const SizedBox(width: 8),
              Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryChildren() {
    final children = <Widget>[];
    for (final subCategory in widget.category!.subCategories) {
      children.add(
        StockTreeNodeWidget(
          subCategory: subCategory,
          level: widget.level + 1,
          isExpanded: false,
          onToggle: () {},
        ),
      );
    }
    return children;
  }

  List<Widget> _buildSubCategoryChildren() {
    final children = <Widget>[];
    for (final type in widget.subCategory!.types) {
      children.add(
        StockTreeNodeWidget(
          type: type,
          level: widget.level + 1,
          isExpanded: false,
          onToggle: () {},
        ),
      );
    }
    return children;
  }

  List<Widget> _buildTypeChildren() {
    final children = <Widget>[];
    for (final item in widget.type!.items) {
      children.add(_buildStockItemWidget(item, widget.level + 1));
    }
    return children;
  }

  Widget _buildStockItemWidget(StockTreeItem item, int level) {
    final indent = level * 16.0;

    return Container(
      margin: EdgeInsets.only(left: indent, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.isLowStock
            ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
            : (item.isEmpty
                ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.statusColor,
            ),
          ),
          const SizedBox(width: 12),
          
          // Stock name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Min: ${item.minimumStock.toInt()} ${item.unit ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Current stock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.statusColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.currentStock.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: item.statusColor,
                  ),
                ),
                Text(
                  ' ${item.unit ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: item.statusColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Status badge
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.statusText,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: item.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasChildren() {
    if (widget.category != null) {
      return widget.category!.subCategories.isNotEmpty;
    }
    if (widget.subCategory != null) {
      return widget.subCategory!.types.isNotEmpty;
    }
    return false;
  }
}

/// Widget untuk menampilkan search result item (compact)
class StockSearchResultItemWidget extends StatelessWidget {
  final StockTreeItem item;
  final VoidCallback? onTap;

  const StockSearchResultItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 20,
                color: item.statusColor,
              ),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock: ${item.currentStock.toInt()} ${item.unit ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: item.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}