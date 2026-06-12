// File: lib/insights/hospital/views/incident_response_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/incident_providers.dart';
import '../models/incident_summary_model.dart';
import '../models/incident_response_model.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class IncidentResponseScreen extends ConsumerStatefulWidget {
  const IncidentResponseScreen({super.key});

  @override
  ConsumerState<IncidentResponseScreen> createState() => _IncidentResponseScreenState();
}

class _IncidentResponseScreenState extends ConsumerState<IncidentResponseScreen> {
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

    final state = ref.watch(incidentStateProvider);
    final summary = state.summary;
    final categoryDistribution = state.categoryDistribution;
    final severityDistribution = state.severityDistribution;
    final responseStats = state.responseStats;
    final topReporters = state.topReporters;
    final recentIncidents = state.recentIncidents;
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

                if (isLoading && summary.totalIncidents == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalIncidents == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  // ROW 1: KPI CARDS
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  // ROW 2: KATEGORI KPI CARDS (DINAMIS)
                  // _buildCategoryKPICards(categoryDistribution, isMobile, isTablet),
                  // const SizedBox(height: 20),

                  // ROW 3: DONUT CHARTS (KATEGORI + SEVERITY + RESPONSE)
                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCategoryDonut(categoryDistribution)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSeverityDonut(severityDistribution)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildCategoryDonut(categoryDistribution),
                        const SizedBox(height: 16),
                        _buildSeverityDonut(severityDistribution),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // ROW 4: RESPONSE RATE + TOP REPORTERS
                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildResponseRateCard(responseStats)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTopReportersChart(topReporters)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildResponseRateCard(responseStats),
                        const SizedBox(height: 16),
                        _buildTopReportersChart(topReporters),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // ROW 5: RECENT INCIDENTS TABLE
                  if (recentIncidents.isNotEmpty)
                    _buildRecentIncidentsTable(recentIncidents),
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
          child: const Icon(Icons.warning_amber, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INCIDENT & RESPONSE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'Monitoring Insiden | Response Time | Penanganan',
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
  // KPI CARDS (MAIN)
  // ============================================================
  Widget _buildKPICards(IncidentSummaryModel summary, bool isMobile, bool isTablet) {
    final kpiCards = [
      _kpiCard('Total Insiden', summary.totalIncidents.toString(), Icons.warning_amber, const Color(0xFFEF4444)),
      _kpiCard('Open', summary.openIncidents.toString(), Icons.pending, const Color(0xFFF59E0B)),
      _kpiCard('Resolved', summary.resolvedIncidents.toString(), Icons.check_circle, const Color(0xFF10B981)),
      _kpiCard('Avg Response', '${summary.avgResponseTimeMinutes.toStringAsFixed(0)}m', Icons.speed, const Color(0xFF3B82F6)),
    ];

    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 8);
    // if (kpiCards.length < crossAxisCount) {
    //   crossAxisCount = kpiCards.length;
    // }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: kpiCards,
    );
  }

  // ============================================================
  // KATEGORI KPI CARDS (DINAMIS - MINI)
  // ============================================================
  Widget _buildCategoryKPICards(List<IncidentCategoryDistribution> categories, bool isMobile, bool isTablet) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = [
      const Color(0xFF8B5CF6), const Color(0xFF06B6D4),
      const Color(0xFFEC4899), const Color(0xFF14B8A6),
      const Color(0xFF6366F1), const Color(0xFFF97316),
    ];

    final List<Widget> categoryCards = [];
    for (int i = 0; i < categories.length && i < 8; i++) {
      final cat = categories[i];
      categoryCards.add(
        _miniCard(cat.categoryName, cat.totalIncidents.toString(), colors[i % colors.length]),
      );
    }

    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 8);
    if (categoryCards.length < crossAxisCount) {
      crossAxisCount = categoryCards.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insiden per Kategori',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: categoryCards,
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY DONUT CHART
  // ============================================================
  Widget _buildCategoryDonut(List<IncidentCategoryDistribution> categories) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data kategori',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final Map<String, int> chartData = {};
    for (final cat in categories) {
      chartData[cat.categoryName] = cat.totalIncidents;
    }

    final total = categories.fold(0, (sum, cat) => sum + cat.totalIncidents);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      constraints: const BoxConstraints(minHeight: 280),
      child: SingleChildScrollView(
        child: DonutChart(
          data: chartData,
          title: 'Insiden per Kategori',
          total: total.toDouble(),
        ),
      ),
    );
  }

  // ============================================================
  // SEVERITY DONUT CHART
  // ============================================================
  Widget _buildSeverityDonut(List<IncidentSeverityDistribution> severities) {
    if (severities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data severity',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final Map<String, int> chartData = {};
    for (final sev in severities) {
      chartData[sev.severity] = sev.count;
    }

    final total = severities.fold(0, (sum, sev) => sum + sev.count);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      constraints: const BoxConstraints(minHeight: 280),
      child: SingleChildScrollView(
        child: DonutChart(
          data: chartData,
          title: 'Insiden per Severity',
          total: total.toDouble(),
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSE RATE CARD
  // ============================================================
  Widget _buildResponseRateCard(IncidentResponseStats stats) {
    final respondedPercent = stats.responseRate;
    final notRespondedPercent = 100 - respondedPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Response Rate',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: stats.responseRate / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    color: const Color(0xFF10B981),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${stats.responseRate.toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF10B981),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Responded',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stats.responded.toString(),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF10B981),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Respon',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stats.notResponded.toString(),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFEF4444),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Belum',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP REPORTERS CHART
  // ============================================================
  Widget _buildTopReportersChart(List<IncidentReporterStats> reporters) {
    if (reporters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data reporter',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final maxReports = reporters.first.totalReports;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Reporter',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: SingleChildScrollView(
              child: Column(
                children: reporters.map((reporter) {
                  final percent = maxReports > 0 ? (reporter.totalReports / maxReports) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reporter.fullName,
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
                              '${reporter.totalReports} laporan',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF8B5CF6),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
                        if (reporter.unitName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              reporter.unitName!,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 9,
                              ),
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
  // RECENT INCIDENTS TABLE
  // ============================================================
  Widget _buildRecentIncidentsTable(List<IncidentRecentModel> incidents) {
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
                'Riwayat Insiden Terbaru (${incidents.length})',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
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
                    DataColumn(label: Text('Tgl', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Insiden', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Kategori', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Severity', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Status', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Pelapor', style: TextStyle(color: Colors.white70, fontSize: 11))),
                  ],
                  rows: incidents.map((incident) {
                    return DataRow(
                      cells: [
                        DataCell(Text(DateFormat('dd/MM HH:mm').format(incident.occurredAt), style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(incident.title, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        DataCell(Text(incident.categoryName ?? '-', style: const TextStyle(color: Colors.white70, fontSize: 11))),
                        DataCell(_severityChip(incident.severity)),
                        DataCell(_statusChip(incident.status)),
                        DataCell(Text(incident.reporterName, style: const TextStyle(color: Colors.white70, fontSize: 11))),
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

  Widget _severityChip(String severity) {
    Color color;
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        color = const Color(0xFFEF4444);
        break;
      case 'HIGH':
        color = const Color(0xFFF97316);
        break;
      case 'MEDIUM':
        color = const Color(0xFFF59E0B);
        break;
      default:
        color = const Color(0xFF10B981);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        severity,
        style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'reported':
        color = const Color(0xFFEF4444);
        break;
      case 'in_progress':
        color = const Color(0xFFF59E0B);
        break;
      case 'resolved':
        color = const Color(0xFF10B981);
        break;
      default:
        color = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(color: color, fontSize: 10, fontWeight: FontWeight.w600),
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
              ref.invalidate(incidentStateProvider);
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