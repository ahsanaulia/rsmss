// File: lib/insights/stocks/views/stock_overview_screen.dart
// COPY PASTE SELURUH FILE INI - REPLACE YANG LAMA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/stock_overview_providers.dart';
import '../models/stock_summary_model.dart';
import '../models/stock_trend_model.dart';
import '../models/stock_prediction_model.dart';
import '../models/stock_velocity_model.dart';
import '../models/stock_expiry_model.dart';
import '../models/stock_slow_moving_model.dart';
import '../models/stock_category_value_model.dart';
import '../models/stock_storage_model.dart';
import '../models/stock_discrepancy_model.dart';

class StockOverviewScreen extends ConsumerStatefulWidget {
  const StockOverviewScreen({super.key});

  @override
  ConsumerState<StockOverviewScreen> createState() => _StockOverviewScreenState();
}

class _StockOverviewScreenState extends ConsumerState<StockOverviewScreen> {
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

    // Watch semua stream
    final summaryAsync = ref.watch(realtimeSummaryProvider);
    final categoryDistAsync = ref.watch(realtimeCategoryDistributionProvider);
    final trendAsync = ref.watch(realtimeTrendProvider);
    final predictionsAsync = ref.watch(realtimePredictionProvider);
    final topVelocityAsync = ref.watch(realtimeTopVelocityProvider);
    final expiryAsync = ref.watch(realtimeExpiryProvider);
    final slowMovingAsync = ref.watch(realtimeSlowMovingProvider);
    final categoryValueAsync = ref.watch(realtimeCategoryValueProvider);
    final storageAsync = ref.watch(realtimeStorageDistributionProvider);
    final discrepancyAsync = ref.watch(realtimeTopDiscrepancyProvider);
    final lowStockAsync = ref.watch(realtimeLowStockProvider);
    final emptyStockAsync = ref.watch(realtimeEmptyStockProvider);

    // AMBIL VALUE
    final summary = summaryAsync.hasValue 
        ? (summaryAsync.value as StockSummaryModel) 
        : StockSummaryModel.empty();
    
    final categoryDistribution = categoryDistAsync.hasValue 
        ? (categoryDistAsync.value as Map<String, int>) 
        : <String, int>{};
    
    final trend = trendAsync.hasValue 
        ? (trendAsync.value as List<StockTrendModel>) 
        : <StockTrendModel>[];
    
    final predictions = predictionsAsync.hasValue 
        ? (predictionsAsync.value as List<StockPredictionModel>) 
        : <StockPredictionModel>[];
    
    final topVelocity = topVelocityAsync.hasValue 
        ? (topVelocityAsync.value as List<StockVelocityModel>) 
        : <StockVelocityModel>[];
    
    final expiryAlert = expiryAsync.hasValue 
        ? (expiryAsync.value as List<StockExpiryModel>) 
        : <StockExpiryModel>[];
    
    final slowMoving = slowMovingAsync.hasValue 
        ? (slowMovingAsync.value as List<StockSlowMovingModel>) 
        : <StockSlowMovingModel>[];
    
    final categoryValues = categoryValueAsync.hasValue 
        ? (categoryValueAsync.value as List<StockCategoryValueModel>) 
        : <StockCategoryValueModel>[];
    
    final storageDistribution = storageAsync.hasValue 
        ? (storageAsync.value as List<StockStorageModel>) 
        : <StockStorageModel>[];
    
    final topDiscrepancy = discrepancyAsync.hasValue 
        ? (discrepancyAsync.value as List<StockDiscrepancyModel>) 
        : <StockDiscrepancyModel>[];

    // Data untuk low stock dan empty stock dari stream
    final lowStockItems = lowStockAsync.valueOrNull ?? [];
    final emptyStockItems = emptyStockAsync.valueOrNull ?? [];
    final isLoadingLowStock = lowStockAsync.isLoading;
    final isLoadingEmptyStock = emptyStockAsync.isLoading;

    // Cek loading utama
    final isLoading = 
        summaryAsync.isLoading ||
        categoryDistAsync.isLoading ||
        trendAsync.isLoading ||
        predictionsAsync.isLoading ||
        topVelocityAsync.isLoading ||
        expiryAsync.isLoading ||
        slowMovingAsync.isLoading ||
        categoryValueAsync.isLoading ||
        storageAsync.isLoading ||
        discrepancyAsync.isLoading;

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

                if (isLoading && summary.totalItems == 0)
                  _buildLoadingShimmer()
                else ...[
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  // LOW STOCK & EMPTY STOCK
                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLowStockList(lowStockItems, isLoadingLowStock)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEmptyStockList(emptyStockItems, isLoadingEmptyStock)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildLowStockList(lowStockItems, isLoadingLowStock),
                        const SizedBox(height: 16),
                        _buildEmptyStockList(emptyStockItems, isLoadingEmptyStock),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // DONUT CHART + GAUGE
                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDonutChart(categoryDistribution)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildGauge(summary.healthPercentage)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildDonutChart(categoryDistribution),
                        const SizedBox(height: 16),
                        _buildGauge(summary.healthPercentage),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (expiryAlert.isNotEmpty) _buildExpiryAlert(expiryAlert),
                  const SizedBox(height: 20),

                  if (trend.isNotEmpty) _buildTrendChart(trend),
                  const SizedBox(height: 20),

                  if (predictions.isNotEmpty) _buildStockOutPrediction(predictions),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (topVelocity.isNotEmpty) Expanded(child: _buildTopVelocity(topVelocity)),
                        if (slowMoving.isNotEmpty) const SizedBox(width: 16),
                        if (slowMoving.isNotEmpty) Expanded(child: _buildSlowMoving(slowMoving)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        if (topVelocity.isNotEmpty) _buildTopVelocity(topVelocity),
                        if (slowMoving.isNotEmpty) const SizedBox(height: 16),
                        if (slowMoving.isNotEmpty) _buildSlowMoving(slowMoving),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoryValues.isNotEmpty) Expanded(child: _buildCategoryValueChart(categoryValues)),
                        if (storageDistribution.isNotEmpty) const SizedBox(width: 16),
                        if (storageDistribution.isNotEmpty) Expanded(child: _buildStorageDistribution(storageDistribution)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        if (categoryValues.isNotEmpty) _buildCategoryValueChart(categoryValues),
                        if (storageDistribution.isNotEmpty) const SizedBox(height: 16),
                        if (storageDistribution.isNotEmpty) _buildStorageDistribution(storageDistribution),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (topDiscrepancy.isNotEmpty) _buildTopDiscrepancy(topDiscrepancy),
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
          child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STOCK OVERVIEW', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
              Text('Kesehatan Stok & Insight Penting (Realtime)', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // KPI CARDS
  // ============================================================
  Widget _buildKPICards(StockSummaryModel summary, bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 5);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _kpiCard('Total Item', summary.totalItems.toString(), Icons.inventory_2, const Color(0xFF3B82F6)),
        _kpiCard('Total Qty', NumberFormat('#,##0').format(summary.totalQuantity), Icons.scale, const Color(0xFF10B981)),
        _kpiCard('Low Stock', summary.lowStock.toString(), Icons.warning_amber, const Color(0xFFF59E0B)),
        _kpiCard('Empty Stock', summary.emptyStock.toString(), Icons.error_outline, const Color(0xFFEF4444)),
        _kpiCard('Stock Value', 'Rp ${NumberFormat('#,##0').format(summary.stockValue)}', Icons.attach_money, const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w500)),
                Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOW STOCK LIST
  // ============================================================
  Widget _buildLowStockList(List<Map<String, dynamic>> lowStockItems, bool isLoading) {
  if (isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
  if (lowStockItems.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tidak ada stok yang mendekati minimum',
              style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  final displayItems = lowStockItems.take(5).toList();
  final hasMore = lowStockItems.length > 5;
  
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
              '⚠️ Low Stock (${lowStockItems.length})',
              style: GoogleFonts.poppins(color: const Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((item) {
            final current = (item['current_stock'] as num?)?.toDouble() ?? 0;
            final minimum = (item['minimum_stock'] as num?)?.toDouble() ?? 0;
            final percent = minimum > 0 ? (current / minimum) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['stock_name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${current.toStringAsFixed(0)} / ${minimum.toStringAsFixed(0)} ${item['unit'] ?? ''}',
                          style: GoogleFonts.poppins(color: const Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: const Color(0xFFF59E0B),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${lowStockItems.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}
  // ============================================================
  // EMPTY STOCK LIST
  // ============================================================
  Widget _buildEmptyStockList(List<Map<String, dynamic>> emptyStockItems, bool isLoading) {
  if (isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
  if (emptyStockItems.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tidak ada stok kosong',
              style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  final displayItems = emptyStockItems.take(5).toList();
  final hasMore = emptyStockItems.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: const Color(0xFFEF4444), size: 20),
            const SizedBox(width: 8),
            Text(
              '❌ Empty Stock (${emptyStockItems.length})',
              style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['stock_name'] ?? 'Unknown',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Minimum: ${item['minimum_stock'] ?? 0} ${item['unit'] ?? ''}',
                            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HABIS',
                        style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${emptyStockItems.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}
  // ============================================================
  // DONUT CHART
  // ============================================================
Widget _buildDonutChart(Map<String, int> distribution) {
  if (distribution.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Center(
        child: Text(
          'Tidak ada data distribusi',
          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
      ),
    );
  }

  final entries = distribution.entries.toList();
  entries.sort((a, b) => b.value.compareTo(a.value));
  
  final total = entries.fold(0, (sum, entry) => sum + entry.value);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    // TINGGI MINIMAL SAMA DENGAN STOCK HEALTH
    constraints: const BoxConstraints(minHeight: 180),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart, color: const Color(0xFF3B82F6), size: 20),
            const SizedBox(width: 8),
            Text(
              'Distribusi per Tipe Stok',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // PAKAI ConstrainedBox, BUKAN Expanded
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 180 - 60, // 180 total - (header + padding)
          ),
          child: SingleChildScrollView(
            child: Column(
              children: entries.map((entry) {
                final percent = total > 0 ? (entry.value / total) * 100 : 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(entries.indexOf(entry)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value} item',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 45,
                        child: Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.right,
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
  // GAUGE
  // ============================================================
  Widget _buildGauge(double healthPercentage) {
    final color = healthPercentage >= 70 ? const Color(0xFF10B981) : (healthPercentage >= 40 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      constraints: const BoxConstraints(minHeight: 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock Health', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text('${healthPercentage.toStringAsFixed(1)}%', style: GoogleFonts.poppins(color: color, fontSize: 36, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: healthPercentage / 100, backgroundColor: Colors.white.withValues(alpha: 0.2), color: color, minHeight: 8)),
                const SizedBox(height: 8),
                Text(healthPercentage >= 70 ? 'Sehat' : (healthPercentage >= 40 ? 'Perhatian' : 'Kritis'), style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPIRY ALERT
  // ============================================================
  Widget _buildExpiryAlert(List<StockExpiryModel> expiries) {
  final displayItems = expiries.take(5).toList();
  final hasMore = expiries.length > 5;
  
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
              '⚠️ Expiry Alert (${expiries.length})',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((expiry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: expiry.statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(expiry.stockName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))),
                  Text('${expiry.daysUntilExpiry} hari lagi', style: GoogleFonts.poppins(color: expiry.statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${expiries.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}

  // ============================================================
  // TREND CHART
  // ============================================================
  Widget _buildTrendChart(List<StockTrendModel> trend) {
    final maxOut = trend.fold<double>(0, (max, d) => d.outQuantity > max ? d.outQuantity : max);
    final maxIn = trend.fold<double>(0, (max, d) => d.inQuantity > max ? d.inQuantity : max);
    final maxTotal = maxIn > maxOut ? maxIn : maxOut;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trend Stok 30 Hari (IN Hijau / OUT Merah)', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trend.length,
              itemBuilder: (context, index) {
                final data = trend[index];
                final barHeightIn = maxTotal > 0 ? (data.inQuantity / maxTotal) * 140 : 0.0;
                final barHeightOut = maxTotal > 0 ? (data.outQuantity / maxTotal) * 140 : 0.0;
                return SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (data.outQuantity > 0) Container(width: 18, height: barHeightOut, decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(3))),
                      if (data.inQuantity > 0) Container(width: 18, height: barHeightIn, decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(height: 6),
                      Text(DateFormat('dd').format(data.date), style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 9)),
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
  // STOCK OUT PREDICTION
  // ============================================================
  Widget _buildStockOutPrediction(List<StockPredictionModel> predictions) {
  final displayItems = predictions.take(5).toList();
  final hasMore = predictions.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: const Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            Text(
              '📊 Stock Out Prediction (${predictions.length})',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((pred) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: pred.priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: pred.priorityColor.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: pred.priorityColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(pred.priority, style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pred.stockName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('Habis dalam ${pred.daysUntilEmpty.toStringAsFixed(1)} hari • Rekomendasi beli ${pred.recommendedQty.toInt()} ${pred.unit}', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${predictions.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}

  // ============================================================
  // TOP VELOCITY
  // ============================================================
  Widget _buildTopVelocity(List<StockVelocityModel> velocities) {
  if (velocities.isEmpty) return const SizedBox.shrink();
  
  final maxVel = velocities.first.totalOut30Days;
  final displayItems = velocities.take(5).toList();
  final hasMore = velocities.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🚀 Konsumsi Tercepat (30 hari)', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((vel) {
            final percent = maxVel > 0 ? (vel.totalOut30Days / maxVel) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vel.stockName,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${vel.totalOut30Days.toInt()} ${vel.unit}', style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: const Color(0xFF10B981),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${velocities.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}
  // ============================================================
  // SLOW MOVING STOCK
  // ============================================================
  Widget _buildSlowMoving(List<StockSlowMovingModel> slowMoving) {
  if (slowMoving.isEmpty) return const SizedBox.shrink();
  
  final displayItems = slowMoving.take(5).toList();
  final hasMore = slowMoving.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🐢 Slow Moving Stock (>30 hari tidak terpakai)', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.stockName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))),
                  Text(item.daysInactive >= 999 ? 'Tidak pernah' : '${item.daysInactive} hari', style: GoogleFonts.poppins(color: const Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${slowMoving.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}

  // ============================================================
  // CATEGORY VALUE CHART
  // ============================================================
  Widget _buildCategoryValueChart(List<StockCategoryValueModel> values) {
  if (values.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Center(
        child: Text('Tidak ada data nilai stok', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ),
    );
  }
  
  final maxValue = values.first.totalValue;
  final displayItems = values.take(5).toList();
  final hasMore = values.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('💰 Nilai Stok per Kategori', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((cat) {
            final percent = maxValue > 0 ? (cat.totalValue / maxValue) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cat.categoryName,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('Rp ${NumberFormat('#,##0').format(cat.totalValue)}', style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6), fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: const Color(0xFF8B5CF6),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${values.length - 5} kategori lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}

  // ============================================================
  // STORAGE DISTRIBUTION
  // ============================================================
  Widget _buildStorageDistribution(List<StockStorageModel> storages) {
  if (storages.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Center(
        child: Text('Tidak ada data lokasi penyimpanan', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ),
    );
  }
  
  final displayItems = storages.take(5).toList();
  final hasMore = storages.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🏭 Distribusi Stok per Gudang', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((storage) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(storage.storageName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text('${storage.totalQuantity.toInt()}', style: GoogleFonts.poppins(color: const Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${storages.length - 5} lokasi lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
    ),
  );
}

  // ============================================================
  // TOP DISCREPANCY
  // ============================================================
  Widget _buildTopDiscrepancy(List<StockDiscrepancyModel> discrepancies) {
  final displayItems = discrepancies.take(5).toList();
  final hasMore = discrepancies.length > 5;
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _glassDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: const Color(0xFFEF4444), size: 20),
            const SizedBox(width: 8),
            Text(
              '⚠️ Selisih Opname Terbesar (${discrepancies.length})',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: displayItems.map((disc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: disc.discrepancy > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(disc.discrepancyType, style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(disc.stockName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('Selisih ${disc.discrepancy > 0 ? '+' : ''}${disc.discrepancy.toInt()} (${disc.discrepancyPercent.toStringAsFixed(1)}%)', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '📋 +${discrepancies.length - 5} item lainnya',
                style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
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
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(),
          child: Column(
            children: [
              Container(width: double.infinity, height: 20, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8))),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // HELPER
  // ============================================================
  Color _getColorForIndex(int index) {
    const colors = [Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFFEF4444)];
    return colors[index % colors.length];
  }

  Decoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
    );
  }
}