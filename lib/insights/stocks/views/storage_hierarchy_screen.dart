// File: lib/insights/stocks/views/storage_hierarchy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/storage_hierarchy_providers.dart';
import '../models/bin_stock_detail_model.dart';
import '../models/storage_hierarchy_model.dart'; // TAMBAHKAN IMPORT INI
import '../widgets/storage_hierarchy_tree.dart';

class StorageHierarchyScreen extends ConsumerStatefulWidget {
  const StorageHierarchyScreen({super.key});

  @override
  ConsumerState<StorageHierarchyScreen> createState() => _StorageHierarchyScreenState();
}

class _StorageHierarchyScreenState extends ConsumerState<StorageHierarchyScreen> {
  String? _selectedBinId;

  void _onBinTap(StorageBinNodeModel bin, String binId) {
    setState(() {
      _selectedBinId = binId;
    });
    // Fetch detail stock
    ref.invalidate(binStockDetailsProvider(binId));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    final hierarchyAsync = ref.watch(realtimeStorageHierarchyProvider);

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
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(realtimeStorageHierarchyProvider);
              if (_selectedBinId != null) {
                ref.invalidate(binStockDetailsProvider(_selectedBinId!));
              }
              return Future.value();
            },
            child: Row(
              children: [
                // LEFT PANEL - Hierarchy Tree (40%)
                Expanded(
                  flex: isMobile ? 5 : 4,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: hierarchyAsync.when(
                      data: (warehouses) => StorageHierarchyTree(
                        warehouses: warehouses,
                        onBinTap: _onBinTap,
                        selectedBinId: _selectedBinId,
                      ),
                      loading: () => _buildLoadingTree(),
                      error: (error, stack) => _buildErrorWidget(error.toString()),
                    ),
                  ),
                ),
                // RIGHT PANEL - Stock Details (60%)
                Expanded(
                  flex: isMobile ? 5 : 6,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: _selectedBinId == null
                        ? _buildEmptyState()
                        : _buildStockDetailsPanel(_selectedBinId!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingTree() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Storage Hierarchy',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: const Color(0xFF8B5CF6),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Stock Details',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tap_and_play, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Bin dari panel kiri',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockDetailsPanel(String binId) {
    final detailsAsync = ref.watch(binStockDetailsProvider(binId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Stock Details',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Expanded(
            child: detailsAsync.when(
              data: (details) => _buildStockList(details),
              loading: () => _buildLoadingDetails(),
              error: (error, stack) => _buildErrorWidget(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(List<BinStockDetailModel> details) {
    if (details.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 48, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Tidak ada stok di bin ini',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final totalQuantity = details.fold(0.0, (sum, d) => sum + d.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Text(
                'Total Stok: ${totalQuantity.toStringAsFixed(0)} item',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${details.length} batch',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: details.length,
            itemBuilder: (context, index) => _buildStockCard(details[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(BinStockDetailModel stock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stock.stockName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stock.statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  stock.statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: stock.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Batch: ${stock.batchNumber}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
                ),
              ),
              Text(
                '${stock.quantity.toStringAsFixed(0)} ${stock.unit}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.date_range, size: 12, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                'Exp: ${DateFormat('dd/MM/yyyy').format(stock.expiryDate)}',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
              ),
              const SizedBox(width: 16),
              if (stock.barcode != null)
                Row(
                  children: [
                    Icon(Icons.qr_code, size: 12, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      stock.barcode!,
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
            ],
          ),
          if (stock.putAwayByName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  'Put Away By: ${stock.putAwayByName}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
                ),
                if (stock.putAwayAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 12, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(stock.putAwayAt!),
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingDetails() {
    return Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          color: const Color(0xFF10B981),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: const Color(0xFFEF4444).withValues(alpha: 0.8)),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
          ),
        ],
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