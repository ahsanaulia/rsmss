// lib/insights/assets/views/asset_utilization_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/asset_utilization_provider.dart';
import '../models/asset_utilization_model.dart';
import '../widgets/asset_kpi_card.dart';

// Import shared widgets dari profiles (reuse)
import '../../profiles/widgets/shared/donut_chart.dart';
import '../../profiles/widgets/shared/bar_chart.dart';
import '../../profiles/widgets/shared/shimmer_loading.dart';

class AssetUtilizationScreen extends ConsumerWidget {
  const AssetUtilizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(assetUtilizationProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding
    final horizontalPadding = screenWidth * 0.04;
    final kpiCrossAxisCount = screenWidth < 1000 ? 2 : 4;

    return Scaffold(
      backgroundColor: const Color(0xFF052D9C),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assetUtilizationProvider);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              summaryAsync.when(
                data: (summary) => _buildContent(context, summary, kpiCrossAxisCount),
                loading: () => _buildLoadingShimmer(kpiCrossAxisCount),
                error: (error, _) => _buildErrorState(error.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PENGGUNAAN DAN KONDISI ASSET',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitoring ketersediaan, penggunaan, dan kondisi aset rumah sakit',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6A98DF),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AssetUtilizationSummary summary, int kpiCrossAxisCount) {
    final kpi = summary.kpi;
    final inspection = summary.inspectionSummary;
    final alert = summary.alertSummary;

    return Column(
      children: [
        // KPI CARDS
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: kpiCrossAxisCount,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.6,
          children: [
            AssetKpiCard(
              title: 'Total Aset',
              value: '${kpi.totalAssets}',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFF3B82F6),
              subtitle: 'Seluruh aset terdaftar',
            ),
            AssetKpiCard(
              title: 'Aset Siap Pakai',
              value: '${kpi.assetsAvailable}',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF10B981),
              subtitle: '${kpi.readyRate}% dari total',
            ),
            AssetKpiCard(
              title: 'Aset Digunakan',
              value: '${kpi.assetsInUse}',
              icon: Icons.play_circle_outline,
              color: const Color(0xFFF59E0B),
              subtitle: '${kpi.utilizationRate}% utilization',
            ),
            AssetKpiCard(
              title: 'Aset Berbahaya',
              value: '${kpi.dangerousAssets}',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFEF4444),
              subtitle: 'Perlu penanganan khusus',
            ),
          ],
        ),

        const SizedBox(height: 32),

        // DONUT CHARTS (2 kolom)
        _buildGlassSection(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDonutCard(
                  title: 'KONDISI ASET',
                  subtitle: 'Distribusi berdasarkan status kondisi',
                  data: {
                    'Good': kpi.goodAssets,
                    'Maintenance': kpi.maintenanceAssets,
                    'Damaged': kpi.damagedAssets,
                    'Critical': kpi.criticalAssets,
                  },
                  total: kpi.totalAssets,
                  insight:
                      '${kpi.maintenanceAssets + kpi.damagedAssets + kpi.criticalAssets} aset memerlukan perhatian',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDonutCard(
                  title: 'KATEGORI ASET',
                  subtitle: 'Moving, Moveable, Installed',
                  data: summary.categories.fold<Map<String, int>>({}, (map, c) {
                    map[c.categoryName] = c.totalAssets;
                    return map;
                  }),
                  total: kpi.totalAssets,
                  insight: 'Aset yang dapat dipindahkan dalam lingkungan RS',
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // BAR CHARTS (2 kolom)
        _buildGlassSection(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBarCard(
                  title: 'ASET PER KATEGORI',
                  subtitle: 'Distribusi terbanyak per kategori aset',
                  data: summary.categories.fold<Map<String, int>>({}, (map, c) {
                    map[c.categoryName] = c.totalAssets;
                    return map;
                  }),
                  barColor: const Color(0xFF8B5CF6),
                  insight: 'Kategori dengan aset terbanyak',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildBarCard(
                  title: 'ASET PER TIPE (TOP 5)',
                  subtitle: '5 tipe aset dengan jumlah terbanyak',
                  data: summary.topTypes.fold<Map<String, int>>({}, (map, t) {
                    map[t.typeName] = t.total;
                    return map;
                  }),
                  barColor: const Color(0xFFEC4899),
                  insight: summary.topTypes.isNotEmpty
                      ? '${summary.topTypes.first.typeName} adalah tipe aset paling banyak'
                      : 'Tidak ada data tipe aset',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // INSPECTION PANEL & ALERT PANEL (2 kolom)
        _buildGlassSection(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInspectionPanel(inspection),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildAlertPanel(alert),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassSection({required Widget child}) {
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildDonutCard({
    required String title,
    required String subtitle,
    required Map<String, int> data,
    required int total,
    required String insight,
    required Color color,
  }) {
    final filteredData = Map.fromEntries(data.entries.where((e) => e.value > 0));

    if (filteredData.isEmpty || total == 0) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Tidak ada data',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        ),
        const SizedBox(height: 20),
        DonutChart(title: '', data: filteredData, total: total.toDouble()),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 14, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(insight, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarCard({
    required String title,
    required String subtitle,
    required Map<String, int> data,
    required Color barColor,
    required String insight,
  }) {
    final filteredData = Map.fromEntries(data.entries.where((e) => e.value > 0));

    if (filteredData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text('Tidak ada data', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: barColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(minHeight: 280),
          child: BarChartWidget(
            title: '',
            data: filteredData.map((key, value) => MapEntry(key, value.toDouble())),
            barColor: barColor,
            maxItems: 5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 14, color: barColor),
              const SizedBox(width: 8),
              Expanded(child: Text(insight, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionPanel(inspection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF06B6D4), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('RINGKASAN INSPEKSI', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Jadwal pemeliharaan dan inspeksi', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 20),
        _buildInfoRow('Inspeksi Terlambat', '${inspection?.overdueInspectionAssets ?? 0}', const Color(0xFFEF4444)),
        _buildInfoRow('Inspeksi Hari Ini', '${inspection?.inspectionDueToday ?? 0}', const Color(0xFFF97316)),
        _buildInfoRow('Inspeksi Minggu Ini', '${inspection?.inspectionDueThisWeek ?? 0}', const Color(0xFFF59E0B)),
        _buildInfoRow('Belum Pernah Diinspeksi', '${inspection?.neverInspectedAssets ?? 0}', const Color(0xFF64748B)),
      ],
    );
  }

  Widget _buildAlertPanel(alert) {
    final hasAlert = (alert?.dangerousAssets ?? 0) > 0 ||
        (alert?.criticalConditionAssets ?? 0) > 0 ||
        (alert?.criticalContaminationAssets ?? 0) > 0 ||
        (alert?.damagedAssets ?? 0) > 0;

    if (!hasAlert) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('ALERT & REKOMENDASI', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Alert operasional real-time', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Semua aset dalam kondisi normal. Tidak ada alert kritis.',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('ALERT & REKOMENDASI', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Alert operasional real-time', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 20),
        _buildAlertRow('Aset Berbahaya', '${alert?.dangerousAssets ?? 0}', const Color(0xFFEF4444)),
        _buildAlertRow('Kontaminasi Kritis', '${alert?.criticalContaminationAssets ?? 0}', const Color(0xFFF97316)),
        _buildAlertRow('Kondisi Kritis', '${alert?.criticalConditionAssets ?? 0}', const Color(0xFFEF4444)),
        _buildAlertRow('Aset Rusak', '${alert?.damagedAssets ?? 0}', const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70))),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildAlertRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70))),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(int kpiCrossAxisCount) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: kpiCrossAxisCount,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.6,
          children: List.generate(4, (_) => ShimmerLoading(isLoading: true, child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ))),
        ),
        const SizedBox(height: 32),
        ShimmerLoading(isLoading: true, child: Container(height: 400, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
        const SizedBox(height: 32),
        ShimmerLoading(isLoading: true, child: Container(height: 400, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Gagal memuat data aset', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(error, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}