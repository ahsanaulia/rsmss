// File: lib/insights/stocks/views/storage_distribution_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/storage_distribution_providers.dart';
import '../models/storage_summary_model.dart';
import '../models/storage_bin_model.dart';
import '../models/storage_hierarchy_model.dart';
import '../models/storage_trend_model.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class StorageDistributionScreen extends ConsumerStatefulWidget {
  const StorageDistributionScreen({super.key});

  @override
  ConsumerState<StorageDistributionScreen> createState() => _StorageDistributionScreenState();
}

class _StorageDistributionScreenState extends ConsumerState<StorageDistributionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final horizontalMargin = isMobile ? 12.0 : (isTablet ? 20.0 : 32.0);
    final useTwoColumns = screenWidth >= 900;

    final state = ref.watch(storageDistributionRealtimeStateProvider);
    final summary = state.summary;
    final distribution = state.distribution;
    final topBinsByQty = state.topBinsByQty;
    final topUtilizedBins = state.topUtilizedBins;
    final mostFulfilledBins = state.mostFulfilledBins;
    final expiringStock = state.expiringStock;
    final stockInSource = state.stockInSource;
    final stockInTrend = state.stockInTrend;
    final storageHierarchy = state.storageHierarchy;
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

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
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                if (isLoading && summary.totalBins == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalBins == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  if (distribution.isNotEmpty)
                    _buildDonutChart(distribution),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTopBinsByQty(topBinsByQty)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTopUtilizedBins(topUtilizedBins)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildTopBinsByQty(topBinsByQty),
                        const SizedBox(height: 16),
                        _buildTopUtilizedBins(topUtilizedBins),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (mostFulfilledBins.isNotEmpty)
                    _buildMostFulfilledBins(mostFulfilledBins),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStockInSource(stockInSource)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStockInTrend(stockInTrend)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildStockInSource(stockInSource),
                        const SizedBox(height: 16),
                        _buildStockInTrend(stockInTrend),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (expiringStock.isNotEmpty)
                    _buildExpiringStock(expiringStock),
                  const SizedBox(height: 20),

                  if (storageHierarchy.isNotEmpty)
                    _buildStorageHierarchy(storageHierarchy),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
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
          child: const Icon(Icons.warehouse, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STORAGE & DISTRIBUTION',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'Monitoring kapasitas & pergerakan stok per lokasi (Realtime)',
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

  // ============================================================
  // KPI CARDS
  // ============================================================
  Widget _buildKPICards(StorageSummaryModel summary, bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 5);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _kpiCard('Total Warehouse', summary.totalWarehouses.toString(), Icons.warehouse, const Color(0xFF3B82F6)),
        _kpiCard('Total Zone', summary.totalZones.toString(), Icons.grid_view, const Color(0xFF10B981)),
        _kpiCard('Total Rack', summary.totalRacks.toString(), Icons.view_list, const Color(0xFF8B5CF6)),
        _kpiCard('Total Shelf', summary.totalShelves.toString(), Icons.shelves, const Color(0xFFF59E0B)),
        _kpiCard('Total Bin', summary.totalBins.toString(), Icons.inventory, const Color(0xFF06B6D4)),
        _kpiCard('Utilisasi', '${summary.avgUtilization.toStringAsFixed(0)}%', Icons.percent, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DONUT CHART DISTRIBUSI PER WAREHOUSE
  // ============================================================
  Widget _buildDonutChart(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (sum, val) => sum + val);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(),
      child: DonutChart(
        data: distribution,
        title: 'Distribusi Bin per Warehouse',
        total: total.toDouble(),
      ),
    );
  }

  // ============================================================
  // TOP BINS BY STOCK QTY (SCROLLABLE - SEMUA BIN)
  // ============================================================
  Widget _buildTopBinsByQty(List<StorageTopBinModel> bins) {
    if (bins.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data bin',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final allBins = bins;
    final maxQty = allBins.isEmpty ? 0 : allBins.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Bin by Stock Qty (${allBins.length} bins)',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Column(
                children: allBins.map((item) {
                  final percent = maxQty > 0 ? ((item.value / maxQty) * 100).toDouble() : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.bin.binCode,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${item.value.toStringAsFixed(0)} item',
                              style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.bin.locationHierarchy.split('→').take(2).join(' →'),
                          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: const Color(0xFF3B82F6),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP UTILIZED BINS (SCROLLABLE - SEMUA BIN)
  // ============================================================
  Widget _buildTopUtilizedBins(List<StorageTopBinModel> bins) {
    if (bins.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data utilisasi bin',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final allBins = bins;
    final maxUtil = allBins.isEmpty ? 0 : allBins.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.percent, color: const Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Text(
                'Bin Utilization (Paling Penuh) - ${allBins.length} bins',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Column(
                children: allBins.map((item) {
                  final percent = maxUtil > 0 ? (item.value / maxUtil) * 100 : 0;
                  final color = item.bin.utilization >= 80 
                      ? const Color(0xFFEF4444)
                      : item.bin.utilization >= 60 
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.bin.binCode,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${item.value.toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.bin.currentQuantity.toStringAsFixed(0)} / ${item.bin.maxQuantity?.toStringAsFixed(0) ?? '?'} item',
                          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: color,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOST FULFILLED BINS (SCROLLABLE - SEMUA BIN)
  // ============================================================
  Widget _buildMostFulfilledBins(List<StorageTopBinModel> bins) {
    final allBins = bins;
    final maxCount = allBins.isEmpty ? 0 : allBins.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Bin Paling Sering Diambil (${allBins.length} bins)',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Column(
                children: allBins.map((item) {
                  final percent = maxCount > 0 ? (item.value / maxCount) * 100 : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.bin.binCode,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${item.value.toStringAsFixed(0)}x diambil',
                              style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.bin.locationHierarchy.split('→').take(2).join(' →'),
                          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: const Color(0xFF8B5CF6),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STOCK IN SOURCE DISTRIBUTION
  // ============================================================
  Widget _buildStockInSource(List<StockInSourceModel> sources) {
    if (sources.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data stock in',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final total = sources.fold(0.0, (sum, s) => sum + s.totalQuantity);
    final displaySources = sources.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.input, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                'Stock In Source Distribution',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: displaySources.map((source) {
              final percent = total > 0 ? (source.totalQuantity / total) * 100 : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            source.sourceType == 'PURCHASE' ? 'Pembelian' : 'Return',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        color: const Color(0xFF10B981),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STOCK IN TREND
  // ============================================================
  Widget _buildStockInTrend(List<StorageTrendModel> trend) {
    if (trend.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data trend',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final maxQty = trend.fold<double>(0, (max, t) => t.totalStockInQuantity > max ? t.totalStockInQuantity : max);
    final displayTrend = trend.take(12).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Trend Stock In per Bulan',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayTrend.length,
              itemBuilder: (context, index) {
                final data = displayTrend[index];
                final barHeight = maxQty > 0 ? ((data.totalStockInQuantity / maxQty) * 120).toDouble() : 0.0;
                
                return SizedBox(
                  width: 55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM').format(data.month),
                        style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPIRING STOCK (SCROLLABLE)
  // ============================================================
  Widget _buildExpiringStock(List<StockExpiryModel> expiries) {
    final displayExpiries = expiries.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: const Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Text(
                '⚠️ Stock Mendekati Expired (${expiries.length})',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Column(
                children: displayExpiries.map((expiry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: expiry.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: expiry.statusColor.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expiry.stockName,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Batch: ${expiry.batchNumber} | Bin: ${expiry.binCode} | ${expiry.warehouseName}',
                                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${expiry.daysUntilExpiry} hari',
                            style: GoogleFonts.poppins(color: expiry.statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (expiries.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${expiries.length - 10} item lainnya',
                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // STORAGE HIERARCHY VIEWER (SCROLLABLE)
  // ============================================================
  Widget _buildStorageHierarchy(List<StorageWarehouseModel> warehouses) {
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
                'Storage Hierarchy (Warehouse → Zone → Rack → Shelf → Bin)',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: warehouses.map((warehouse) => _buildWarehouseTile(warehouse)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseTile(StorageWarehouseModel warehouse) {
    return ExpansionTile(
      leading: const Icon(Icons.warehouse, color: Color(0xFF3B82F6), size: 20),
      title: Text(
        '🏭 ${warehouse.name} (${warehouse.totalBins} bins, ${warehouse.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: warehouse.zones.map((zone) => _buildZoneTile(zone)).toList(),
    );
  }

  Widget _buildZoneTile(StorageZoneModel zone) {
    return ExpansionTile(
      leading: const Icon(Icons.grid_view, color: Color(0xFF10B981), size: 18),
      title: Text(
        '📦 ${zone.name} (${zone.totalBins} bins, ${zone.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: zone.racks.map((rack) => _buildRackTile(rack)).toList(),
    );
  }

  Widget _buildRackTile(StorageRackModel rack) {
    return ExpansionTile(
      leading: const Icon(Icons.view_list, color: Color(0xFFF59E0B), size: 16),
      title: Text(
        '🗄️ ${rack.name} (${rack.totalBins} bins, ${rack.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w400),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: rack.shelves.map((shelf) => _buildShelfTile(shelf)).toList(),
    );
  }

  Widget _buildShelfTile(StorageShelfModel shelf) {
    return ExpansionTile(
      leading: const Icon(Icons.shelves, color: Color(0xFF8B5CF6), size: 14),
      title: Text(
        '📚 ${shelf.name} (${shelf.totalBins} bins, ${shelf.totalStock.toStringAsFixed(0)} item)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w400),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: shelf.bins.map((bin) => _buildBinTile(bin)).toList(),
    );
  }

  Widget _buildBinTile(StorageBinNodeModel bin) {
    final color = bin.utilization >= 80 
        ? const Color(0xFFEF4444)
        : bin.utilization >= 60 
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '📦 ${bin.code} - ${bin.currentQuantity.toStringAsFixed(0)} item',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
            ),
          ),
          if (bin.maxQuantity != null)
            Text(
              '${bin.utilization.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING SHIMMER
  // ============================================================
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glassDecoration(),
      child: Column(
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
              ref.invalidate(storageDistributionRealtimeStateProvider);
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
    );
  }

  // ============================================================
  // HELPER
  // ============================================================
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