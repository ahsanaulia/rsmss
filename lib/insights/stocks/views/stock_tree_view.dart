// File: lib/insights/stocks/views/stock_tree_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/stock_tree_providers.dart';
import '../models/stock_tree_node_model.dart';

class StockTreeView extends ConsumerStatefulWidget {
  const StockTreeView({super.key});

  @override
  ConsumerState<StockTreeView> createState() => _StockTreeViewState();
}

class _StockTreeViewState extends ConsumerState<StockTreeView> {
  // Selected type untuk panel kanan
  StockTypeNode? _selectedType;
  
  // Expanded state untuk tree
  final Map<String, bool> _expandedCategories = {};
  final Map<String, bool> _expandedSubCategories = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockTreeProvider.notifier).loadTree();
    });
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    });
  }

  void _toggleSubCategory(String subCategoryId) {
    setState(() {
      _expandedSubCategories[subCategoryId] = !(_expandedSubCategories[subCategoryId] ?? false);
    });
  }

  bool _isCategoryExpanded(String categoryId) {
    return _expandedCategories[categoryId] ?? false;
  }

  bool _isSubCategoryExpanded(String subCategoryId) {
    return _expandedSubCategories[subCategoryId] ?? false;
  }

  void _onTypeSelected(StockTypeNode type) {
    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final horizontalMargin = isMobile ? 12.0 : 24.0;

    final treeState = ref.watch(stockTreeProvider);
    final isLoading = treeState.isLoading;
    final errorMessage = treeState.errorMessage;
    final categories = treeState.categories;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF052D9C),
            Color(0xFF1E3A8A),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                
                if (isLoading)
                  Expanded(child: _buildLoadingShimmer())
                else if (errorMessage != null)
                  Expanded(child: _buildErrorWidget(errorMessage))
                else if (categories.isEmpty)
                  Expanded(child: _buildEmptyWidget())
                else
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PANEL KIRI - TREE (Category, SubCategory, Type)
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: _glassDecoration(),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: categories.map((category) {
                                  return _buildCategoryNode(category);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // PANEL KANAN - DETAIL STOCKS (dari Type yang dipilih)
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: _glassDecoration(),
                            child: _buildDetailPanel(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.account_tree, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STOCK TREE VIEW',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              Text(
                'Klik Type untuk melihat daftar stock',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryNode(StockCategoryNode category) {
    final isExpanded = _isCategoryExpanded(category.category.id);
    final hasChildren = category.subCategories.isNotEmpty;
    final totalStock = category.totalItems;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CATEGORY HEADER
        GestureDetector(
          onTap: () {
            if (hasChildren) {
              _toggleCategory(category.category.id);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.6),
                  )
                else
                  const SizedBox(width: 18),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: category.category.markerColorValue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.category.icon,
                    size: 16,
                    color: category.category.markerColorValue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.category.categoryName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: totalStock > 0
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalStock.toString(),
                    style: GoogleFonts.poppins(
                      color: totalStock > 0
                          ? const Color(0xFF10B981)
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // SUB CATEGORIES (if expanded)
        if (isExpanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: category.subCategories.map((subCategory) {
                return _buildSubCategoryNode(subCategory);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubCategoryNode(StockSubCategoryNode subCategory) {
    final isExpanded = _isSubCategoryExpanded(subCategory.subCategory.id);
    final hasChildren = subCategory.types.isNotEmpty;
    final totalStock = subCategory.totalItems;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SUB CATEGORY HEADER
        GestureDetector(
          onTap: () {
            if (hasChildren) {
              _toggleSubCategory(subCategory.subCategory.id);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.5),
                  )
                else
                  const SizedBox(width: 16),
                Icon(
                  subCategory.subCategory.icon,
                  size: 14,
                  color: subCategory.subCategory.markerColorValue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subCategory.subCategory.subCategoryName,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: totalStock > 0
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    totalStock.toString(),
                    style: GoogleFonts.poppins(
                      color: totalStock > 0
                          ? const Color(0xFF10B981)
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // TYPES (if expanded)
        if (isExpanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subCategory.types.map((type) {
                return _buildTypeNode(type);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeNode(StockTypeNode type) {
    final isSelected = _selectedType == type;
    final totalStock = type.totalItems;
    
    return GestureDetector(
      onTap: () => _onTypeSelected(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              type.type.icon,
              size: 14,
              color: type.type.markerColorValue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                type.type.typeName,
                style: GoogleFonts.poppins(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: totalStock > 0
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                totalStock.toString(),
                style: GoogleFonts.poppins(
                  color: totalStock > 0
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    if (_selectedType == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Klik Type untuk melihat daftar stock',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final items = _selectedType!.items;
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada stock untuk type ${_selectedType!.type.typeName}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header panel kanan
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _selectedType!.type.icon,
                size: 28,
                color: _selectedType!.type.markerColorValue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedType!.type.typeName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${items.length} items',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // List stock items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildStockItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockItemCard(StockTreeItem item) {
    return GestureDetector(
      onTap: () => _showStockDetailDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isLowStock
              ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
              : (item.isEmpty
                  ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
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
            
            // Stock info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Min: ${item.minimumStock.toInt()} ${item.unit ?? ''}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            
            // Current stock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: item.statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item.currentStock.toInt()} ${item.unit ?? ''}',
                style: GoogleFonts.poppins(
                  color: item.statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            // Status badge
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.statusText,
                style: GoogleFonts.poppins(
                  color: item.statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            // Icon indicator clickable
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStockDetailDialog(StockTreeItem item) async {
    // Ambil detail lengkap dari database
    final detail = await _fetchStockDetail(item.id);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF052D9C), Color(0xFF1E3A8A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: item.statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (detail != null)
                          Text(
                            detail['stock_code'] ?? '-',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Stock Information
                      _buildDetailSection('INFORMASI STOK', [
                        _detailRow('Kode Stock', detail?['stock_code'] ?? '-'),
                        _detailRow('Nama Stock', detail?['stock_name'] ?? item.name),
                        _detailRow('Unit', detail?['unit'] ?? item.unit ?? '-'),
                        _detailRow('Kondisi', detail?['stock_condition'] ?? item.condition),
                        _detailRow('Status', item.statusText, color: item.statusColor),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Section: Quantity Information
                      _buildDetailSection('KUANTITAS', [
                        _detailRow('Current Stock', '${item.currentStock.toInt()} ${item.unit ?? ''}'),
                        _detailRow('Minimum Stock', '${item.minimumStock.toInt()} ${item.unit ?? ''}'),
                        _detailRow('Last Opname Stock', _getValueString(detail, 'last_opname_stock', item.unit)),
                        _detailRow('Stock In Qty', _getValueString(detail, 'stock_in_qty', item.unit)),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Section: Last Purchase
                      if (detail != null && detail['last_purchase_at'] != null)
                        _buildDetailSection('PEMBELIAN TERAKHIR', [
                          _detailRow('Tanggal', _formatDate(detail['last_purchase_at'])),
                          _detailRow('Quantity', _getValueString(detail, 'last_purchase_qty', item.unit)),
                          _detailRow('Harga', detail['last_purchase_price'] != null ? 'Rp ${NumberFormat('#,##0').format(detail['last_purchase_price'])}' : '-'),
                          _detailRow('Oleh', detail['last_purchase_by_name'] ?? detail['last_purchase_by'] ?? '-'),
                        ]),
                      
                      const SizedBox(height: 16),
                      
                      // Section: Last Opname
                      if (detail != null && detail['last_opname_at'] != null)
                        _buildDetailSection('OPNAME TERAKHIR', [
                          _detailRow('Tanggal', _formatDate(detail['last_opname_at'])),
                          _detailRow('Catatan', detail['last_opname_note'] ?? '-'),
                          _detailRow('Oleh', detail['last_opname_by_name'] ?? detail['last_opname_by'] ?? '-'),
                        ]),
                      
                      const SizedBox(height: 16),
                      
                      // Section: Last Usage
                      if (detail != null && detail['last_usage_at'] != null)
                        _buildDetailSection('PENGGUNAAN TERAKHIR', [
                          _detailRow('Tanggal', _formatDate(detail['last_usage_at'])),
                          _detailRow('Quantity', _getValueString(detail, 'last_usage_qty', item.unit)),
                          _detailRow('Oleh', detail['last_usage_by_name'] ?? detail['last_usage_by'] ?? '-'),
                        ]),
                      
                      const SizedBox(height: 16),
                      
                      // Section: Batch & Expiry
                      if (detail != null && (detail['batch_number'] != null || detail['expiry_date'] != null))
                        _buildDetailSection('BATCH & EXPIRY', [
                          _detailRow('Batch Number', detail['batch_number'] ?? '-'),
                          _detailRow('Expiry Date', detail['expiry_date'] != null ? _formatDate(detail['expiry_date']) : '-'),
                        ]),
                      
                      const SizedBox(height: 16),
                      
                      // Section: Description
                      if (detail != null && detail['description'] != null && detail['description'].toString().isNotEmpty)
                        _buildDetailSection('DESKRIPSI', [
                          _detailRow('', detail['description'], isLongText: true),
                        ]),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function untuk mengambil nilai dengan aman
  String _getValueString(Map<String, dynamic>? detail, String key, String? unit) {
    if (detail == null) return '-';
    final value = detail[key];
    if (value == null) return '-';
    return '$value ${unit ?? ''}';
  }

  Widget _buildDetailSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF10B981),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, {Color? color, bool isLongText = false}) {
    if (label.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: color ?? Colors.white,
                fontSize: 12,
                fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchStockDetail(String stockId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('stocks')
          .select('''
            *,
            last_opname_by:last_opname_by (full_name),
            last_purchase_by:last_purchase_by (full_name),
            last_usage_by:last_usage_by (full_name),
            created_by:created_by (full_name)
          ''')
          .eq('id', stockId)
          .single();
      
      // Map names safely
      if (response != null) {
        final lastOpnameBy = response['last_opname_by'];
        if (lastOpnameBy != null) {
          response['last_opname_by_name'] = lastOpnameBy['full_name'];
        }
        final lastPurchaseBy = response['last_purchase_by'];
        if (lastPurchaseBy != null) {
          response['last_purchase_by_name'] = lastPurchaseBy['full_name'];
        }
        final lastUsageBy = response['last_usage_by'];
        if (lastUsageBy != null) {
          response['last_usage_by_name'] = lastUsageBy['full_name'];
        }
      }
      
      return response;
    } catch (e) {
      debugPrint('Error fetching stock detail: $e');
      return null;
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '-';
    try {
      final date = DateTime.parse(dateValue.toString());
      return DateFormat('dd MMM yyyy HH:mm').format(date.toLocal());
    } catch (e) {
      return dateValue.toString();
    }
  }

  Widget _buildLoadingShimmer() {
    return Container(
      decoration: _glassDecoration(),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      decoration: _glassDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: const Color(0xFFEF4444).withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(stockTreeProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      decoration: _glassDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada data kategori',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan tambahkan kategori, sub kategori, dan tipe stok terlebih dahulu',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Decoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 0.5,
      ),
    );
  }
}