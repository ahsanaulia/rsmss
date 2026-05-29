// File: lib/insights/stocks/views/stock_opname_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/stock_opname_providers.dart';
import '../models/stock_opname_model.dart';
import '../models/stock_opname_summary_model.dart';
import '../models/stock_opname_anomaly_model.dart';
import '../models/stock_opname_trend_model.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class StockOpnameScreen extends ConsumerStatefulWidget {
  const StockOpnameScreen({super.key});

  @override
  ConsumerState<StockOpnameScreen> createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends ConsumerState<StockOpnameScreen> {
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

    // Watch realtime state
    final state = ref.watch(stockOpnameRealtimeStateProvider);
    final summary = state.summary;
    final distribution = state.distribution;
    final topItems = state.topItems;
    final trend = state.trend;
    final unusualDiscrepancy = state.unusualDiscrepancy;
    final frequentDiscrepancy = state.frequentDiscrepancy;
    final patternByPerson = state.patternByPerson;
    final anomalyPerBin = state.anomalyPerBin;
    final recentOpnames = state.recentOpnames;
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

                if (isLoading && summary.totalOpnames == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalOpnames == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  // ROW 1: KPI CARDS
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  // ROW 2: DONUT CHART (MATCH/SURPLUS/SHORTAGE)
                  _buildDonutChart(distribution, summary.totalOpnames),
                  const SizedBox(height: 20),

                  // ROW 3: TOP ITEMS SELISIH TERBESAR (Bar Chart)
                  if (topItems.isNotEmpty)
                    _buildTopItemsChart(topItems),
                  const SizedBox(height: 20),

                  // ROW 4: TREND SELISIH PER BULAN (Line Chart)
                  if (trend.isNotEmpty)
                    _buildTrendChart(trend),
                  const SizedBox(height: 20),

                  // ROW 5: ANOMALY CARDS (5 card)
                  _buildAnomalySection(unusualDiscrepancy, frequentDiscrepancy, patternByPerson),
                  const SizedBox(height: 20),

                  // ROW 6: ANOMALY PER BIN
                  if (anomalyPerBin.isNotEmpty)
                    _buildAnomalyPerBin(anomalyPerBin),
                  const SizedBox(height: 20),

                  // ROW 7: RIWAYAT OPNAME TERBARU
                  if (recentOpnames.isNotEmpty)
                    _buildRecentOpnamesTable(recentOpnames),
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
          child: const Icon(Icons.inventory, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STOCK OPNAME & ANOMALY DETECTION',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'Pengecekan berkala & deteksi kejanggalan stok (Realtime)',
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
  Widget _buildKPICards(StockOpnameSummaryModel summary, bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _kpiCard('Total Opname', summary.totalOpnames.toString(), Icons.receipt_long, const Color(0xFF3B82F6)),
        _kpiCard('Total Selisih', NumberFormat('#,##0').format(summary.totalAbsAdjustment), Icons.compare_arrows, const Color(0xFFF59E0B)),
        _kpiCard('Rata-rata Selisih', NumberFormat('#,##0.00').format(summary.avgAdjustment), Icons.trending_up, const Color(0xFF10B981)),
        _kpiCard('Items Bermasalah', summary.problematicItems.toString(), Icons.warning_amber, const Color(0xFFEF4444)),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
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
  // DONUT CHART (Opname Result Distribution)
  // ============================================================
  Widget _buildDonutChart(Map<String, int> distribution, int total) {
    if (distribution.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data opname',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: _glassDecoration(),
      padding: const EdgeInsets.all(12),
      child: DonutChart(
        data: distribution,
        title: 'Opname Result Distribution',
        total: total.toDouble(),
      ),
    );
  }

  // ============================================================
  // TOP ITEMS SELISIH TERBESAR (Bar Chart)
  // ============================================================
  Widget _buildTopItemsChart(List<StockOpnameAnomalyItemModel> items) {
    final displayItems = items.take(5).toList();
    final maxDiscrepancy = displayItems.fold<double>(0, (max, item) => 
      item.discrepancy.abs() > max ? item.discrepancy.abs() : max);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Items Selisih Terbesar',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: displayItems.map((item) {
              final percent = maxDiscrepancy > 0 
                  ? (item.discrepancy.abs() / maxDiscrepancy) * 100 
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.stockName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item.discrepancy > 0 ? 'SURPLUS' : 'SHORTAGE',
                          style: GoogleFonts.poppins(
                            color: item.discrepancy > 0 
                                ? const Color(0xFF10B981) 
                                : const Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.discrepancy.abs().toStringAsFixed(0)} ${item.unit}',
                          style: GoogleFonts.poppins(
                            color: item.discrepancy > 0 
                                ? const Color(0xFF10B981) 
                                : const Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        color: item.discrepancy > 0 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFFEF4444),
                        minHeight: 6,
                      ),
                    ),
                    Text(
                      '${item.discrepancyPercent.toStringAsFixed(1)}% dari stok sistem',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
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
  // TREND SELISIH PER BULAN (Line Chart - menggunakan bar untuk sederhana)
  // ============================================================
  Widget _buildTrendChart(List<StockOpnameTrendModel> trend) {
    final maxDiscrepancy = trend.fold<double>(0, (max, t) => 
      t.totalDiscrepancy.abs() > max ? t.totalDiscrepancy.abs() : max);
    
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
                'Trend Selisih per Bulan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trend.length,
              itemBuilder: (context, index) {
                final data = trend[index];
                final barHeight = maxDiscrepancy > 0 
                    ? (data.totalDiscrepancy.abs() / maxDiscrepancy) * 150 
                    : 0.0;
                
                return SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: data.totalDiscrepancy > 0 
                              ? const Color(0xFFEF4444).withValues(alpha: 0.7)
                              : data.totalDiscrepancy < 0
                                  ? const Color(0xFF10B981).withValues(alpha: 0.7)
                                  : const Color(0xFF3B82F6).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM').format(data.month),
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
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
  // ANOMALY SECTION (3 Card)
  // ============================================================
  Widget _buildAnomalySection(
    List<StockOpnameAnomalyItemModel> unusual,
    List<StockOpnameAnomalyItemModel> frequent,
    List<StockOpnameAnomalyPersonModel> persons,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️ ANOMALY DETECTION',
          style: GoogleFonts.poppins(
            color: const Color(0xFFEF4444),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        
        // Card 1: Unusual Discrepancy (>20%)
        if (unusual.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFEF4444).withValues(alpha: 0.15), const Color(0xFFEF4444).withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: const Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '⚠️ Unusual Discrepancy (>20%) - ${unusual.length} item',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...unusual.take(5).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text('• ', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Expanded(
                        child: Text(
                          '${item.stockName} - ${item.discrepancyPercent.toStringAsFixed(1)}% ${item.discrepancyType}',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      if (item.binName != null)
                        Text(
                          'Bin: ${item.binName}',
                          style: GoogleFonts.poppins(color: const Color(0xFFF59E0B), fontSize: 10),
                        ),
                    ],
                  ),
                )),
                if (unusual.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '📋 +${unusual.length - 5} item lainnya',
                      style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        
        // Card 2: Frequent Discrepancy Items (3+ kali dalam 3 bulan)
        if (frequent.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFF59E0B).withValues(alpha: 0.15), const Color(0xFFF59E0B).withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.repeat, color: const Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '🔄 Frequent Discrepancy (3+ kali/3 bulan) - ${frequent.length} item',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFF59E0B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...frequent.take(5).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text('• ', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Expanded(
                        child: Text(
                          '${item.stockName} - ${item.frequency}x discrepancy',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )),
                if (frequent.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '📋 +${frequent.length - 5} item lainnya',
                      style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
        
        // Card 3: Pattern by Person
        if (persons.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF8B5CF6).withValues(alpha: 0.15), const Color(0xFF8B5CF6).withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: const Color(0xFF8B5CF6), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '👤 Pattern by Person',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...persons.take(5).map((person) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text('• ', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Expanded(
                        child: Text(
                          '${person.personName} - ${person.pattern} ${person.percentage.toStringAsFixed(0)}% (${person.totalOpnames} opname)',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ANOMALY PER BIN
  // ============================================================
  Widget _buildAnomalyPerBin(List<StockOpnameAnomalyBinModel> bins) {
    final displayBins = bins.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                '📍 Anomaly per BIN (Kebocoran Stok)',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: displayBins.map((bin) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '📍 ${bin.binName}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF59E0B),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '⚠️ ${bin.avgPercentage.toStringAsFixed(0)}% anomaly',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bin.locationHierarchy,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total selisih: ${bin.totalDiscrepancy.toStringAsFixed(0)} item dari ${bin.count} opname',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    if (bin.topItems.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Top bermasalah:',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                      ...bin.topItems.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text(
                          '• ${item.stockName}: ${item.discrepancyPercent.toStringAsFixed(0)}% ${item.discrepancyType}',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          if (bins.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${bins.length - 5} bin lainnya',
                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // RIWAYAT OPNAME TERBARU (Table)
  // ============================================================
  Widget _buildRecentOpnamesTable(List<StockOpnameModel> opnames) {
    final displayOpnames = opnames.take(10).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Riwayat Opname Terbaru (${opnames.length})',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
                  dataRowColor: WidgetStateProperty.all(Colors.transparent),
                  dividerThickness: 0,
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Tanggal', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Item', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('System', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Fisik', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Selisih', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Petugas', style: TextStyle(color: Colors.white70, fontSize: 11))),
                  ],
                  rows: displayOpnames.map((opname) {
                    return DataRow(
                      cells: [
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(opname.opnameAt), style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(opname.stockName, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        DataCell(Text(opname.stockBefore.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(opname.physicalStock.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(
                          Text(
                            '${opname.adjustmentStock > 0 ? "+" : ""}${opname.adjustmentStock.toInt()}',
                            style: TextStyle(
                              color: opname.adjustmentStock > 0 
                                  ? const Color(0xFF10B981) 
                                  : opname.adjustmentStock < 0
                                      ? const Color(0xFFEF4444)
                                      : Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DataCell(Text(opname.opnameByName ?? '-', style: const TextStyle(color: Colors.white, fontSize: 11))),
                      ],
                    );
                  }).toList(),
                ),
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
              ref.invalidate(stockOpnameRealtimeStateProvider);
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