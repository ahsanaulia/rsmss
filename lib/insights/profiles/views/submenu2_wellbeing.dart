// lib/insights/profiles/views/submenu2_wellbeing.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_wellbeing_provider.dart';
// import '../widgets/shared/kpi_card.dart';
import '../widgets/shared/gauge_widget.dart';
import '../widgets/shared/line_chart.dart';
// import '../widgets/shared/alert_card.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../models/profile_wellbeing_model.dart';

class Submenu2Wellbeing extends ConsumerWidget {
  const Submenu2Wellbeing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wellbeingAsync = ref.watch(wellbeingSummaryStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF052D9C), // Biru tua seperti submenu1 & 3
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wellbeingSummaryProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              wellbeingAsync.when(
                data: (summary) => _buildContent(context, summary),
                loading: () => _buildLoadingShimmer(),
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
          '        WELLBEING & KINERJA',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Monitoring kesehatan mental, fatigue, dan skor kinerja pegawai',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6A98DF),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 3, width: 40, color: Color(0xFF052D9C)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WellbeingSummary summary) {
    return Column(
      children: [
        // KPI Cards Row - 3 kolom
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Rata-rata Fatigue',
                value: summary.averageFatigueScore.toStringAsFixed(1),
                icon: Icons.battery_alert_outlined,
                color: _getFatigueColor(summary.averageFatigueScore),
                percentage: (summary.averageFatigueScore / 100) * 100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKpiCard(
                title: 'Rata-rata Stress',
                value: summary.averageStressScore.toStringAsFixed(1),
                icon: Icons.psychology_outlined,
                color: _getStressColor(summary.averageStressScore),
                percentage: (summary.averageStressScore / 100) * 100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKpiCard(
                title: 'Rata-rata Mood',
                value: summary.averageMoodScore.toStringAsFixed(1),
                icon: Icons.sentiment_satisfied_outlined,
                color: _getMoodColor(summary.averageMoodScore),
                percentage: summary.averageMoodScore,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Gauge and High Risk Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildGaugeCard(
                title: 'TINGKAT FATIGUE GLOBAL',
                value: summary.averageFatigueScore,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHighRiskCard(
                title: 'PERINGATAN FATIGUE TINGGI',
                employees: summary.highRiskEmployees,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Wellbeing Trend Line Chart
        if (summary.last7Days.isNotEmpty)
          _buildLineChartCard(
            title: 'TREND WELLBEING (7 HARI TERAKHIR)',
            data: summary.last7Days.map((log) => log.fatigueScore ?? 0).toList(),
            labels: summary.last7Days.map((log) => _formatDate(log.logDate)).toList(),
          ),
        const SizedBox(height: 20),

        // Requires Attention Alerts
        if (summary.requiresAttentionToday.isNotEmpty)
          _buildAttentionCard(
            title: 'BUTUH PERHATIAN HARI INI',
            employees: summary.requiresAttentionToday,
          ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required double value,
  }) {
    final color = _getFatigueColor(value);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GaugeWidget(
              title: '',
              value: value,
              minValue: 0,
              maxValue: 100,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${value.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighRiskCard({
    required String title,
    required List<HighRiskEmployee> employees,
  }) {
    final color = const Color.fromARGB(255, 233, 1, 1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          if (employees.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tidak ada pegawai dengan fatigue tinggi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            )
          else
            ...employees.take(3).map((emp) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 16, 0),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      emp.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 32, 32, 32),
                      ),
                    ),
                  ),
                  Text(
                    '${emp.fatigueScore.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 233, 1, 1),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildLineChartCard({
    required String title,
    required List<double> data,
    required List<String> labels,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 16),
          LineChartWidget(
            title: '',
            data: data,
            xAxisLabels: labels,
            lineColor: const Color(0xFF0288D1),
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionCard({
    required String title,
    required List<AttentionRequiredEmployee> employees,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 65, 12, 12).withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 87, 29, 29).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 82, 26, 26),
            ),
          ),
          const SizedBox(height: 16),
          ...employees.map((emp) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 77, 29, 29).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromARGB(255, 87, 27, 27).withValues(alpha: 0.2), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 77, 27, 27),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      emp.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 70, 22, 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    emp.aiRecommendation ?? 'Fatigue: ${emp.fatigueScore.toStringAsFixed(0)}%, Stress: ${emp.stressScore.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Color _getFatigueColor(double score) {
    if (score >= 70) return const Color(0xFFD32F2F);
    if (score >= 50) return const Color(0xFFED6C02);
    return const Color(0xFF2E7D32);
  }

  Color _getStressColor(double score) {
    if (score >= 70) return const Color.fromARGB(255, 0, 52, 194);
    if (score >= 50) return const Color.fromARGB(255, 237, 2, 61);
    return const Color(0xFF2E7D32);
  }

  Color _getMoodColor(double score) {
    if (score >= 70) return Color.fromARGB(255, 0, 52, 194);
    if (score >= 50) return  Color.fromARGB(255, 237, 2, 61);
    return const Color.fromARGB(255, 5, 46, 136);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
        const SizedBox(height: 16),
        _buildShimmerCard(),
        const SizedBox(height: 16),
        _buildShimmerCard(),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data wellbeing',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}