// lib/insights/profiles/views/submenu1_ringkasan.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_summary_provider.dart';
import '../providers/profile_attendance_provider.dart';
// import '../widgets/shared/kpi_card.dart';
import '../widgets/shared/donut_chart.dart';
import '../widgets/shared/bar_chart.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../models/profile_summary_model.dart';
import '../services/profile_attendance_service.dart';

class Submenu1Ringkasan extends ConsumerWidget {
  const Submenu1Ringkasan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(profileSummaryStreamProvider);
    final workingAsync = ref.watch(workingEmployeesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF052D9C), // Biru tua seperti submenu3
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileSummaryProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              summaryAsync.when(
                data: (summary) => _buildContent(context, ref, summary, workingAsync),
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
          'RINGKASAN PEGAWAI',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color.fromARGB(255, 233, 236, 253),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Statistik dan distribusi seluruh pegawai rumah sakit',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6A98DF),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 3, width: 40, color: Colors.white),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ProfileSummaryModel summary,
    AsyncValue<WorkingEmployeesResult> workingAsync,
  ) {
    final totalEmployees = summary.totalEmployees;
    final activeCount = summary.employeesBySituation['ACTIVE'] ?? 0;
    final maleCount = summary.employeesByGender['L'] ?? 0;
    final femaleCount = summary.employeesByGender['P'] ?? 0;
    final leaveCount = summary.employeesBySituation['LEAVE'] ?? 0;
    final offCount = summary.employeesBySituation['OFF'] ?? 0;

    final malePercentage = totalEmployees > 0 
        ? (maleCount / totalEmployees) * 100 
        : 0.0;
    final femalePercentage = totalEmployees > 0 
        ? (femaleCount / totalEmployees) * 100 
        : 0.0;

    return Column(
      children: [
        // KPI CARDS (4 kolom)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.5,
          children: [
            _buildKpiCard('Total Pegawai', totalEmployees.toString(), Icons.people_alt, const Color.fromARGB(255, 32, 38, 121), 'Seluruh pegawai aktif'),
            _buildWorkingKpiCard(workingAsync, totalEmployees),
            _buildKpiCard('Laki-laki', maleCount.toString(), Icons.male, const Color.fromARGB(255, 75, 164, 238), '${malePercentage.toStringAsFixed(1)}% dari total'),
            _buildKpiCard('Perempuan', femaleCount.toString(), Icons.female, const Color.fromARGB(255, 243, 131, 39), '${femalePercentage.toStringAsFixed(1)}% dari total'),
          ],
        ),

        const SizedBox(height: 20),

        // DONUT CHARTS
        Row(
          children: [
            Expanded(
              child: _buildDonutCard(
                title: 'SITUASI PEGAWAI',
                subtitle: 'Status kepegawaian saat ini',
                child: DonutChart(
                  title: '',
                  data: summary.employeesBySituation,
                  total: totalEmployees.toDouble(),
                ),
                insight: '${activeCount} aktif, ${leaveCount} cuti, ${offCount} tidak aktif',
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDonutCard(
                title: 'DISTRIBUSI GENDER',
                subtitle: 'Perbandingan jumlah berdasarkan gender',
                child: DonutChart(
                  title: '',
                  data: summary.employeesByGender,
                  total: totalEmployees.toDouble(),
                ),
                insight: '${malePercentage.toStringAsFixed(1)}% laki-laki, ${femalePercentage.toStringAsFixed(1)}% perempuan',
                color: const Color(0xFF0288D1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // BAR CHARTS
        Row(
          children: [
            Expanded(
              child: _buildBarCard(
                title: 'PEGAWAI PER UNIT',
                subtitle: 'Distribusi terbanyak per unit kerja',
                child: BarChartWidget(
                  title: '',
                  data: summary.employeesByUnit.map((k, v) => MapEntry(k, v.toDouble())),
                  barColor: const Color(0xFF00838F),
                  maxItems: 5,
                ),
                insight: 'Unit dengan pegawai terbanyak',
                color: const Color(0xFF00838F),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBarCard(
                title: 'PEGAWAI PER POSISI',
                subtitle: 'Distribusi terbanyak per posisi/jabatan',
                child: BarChartWidget(
                  title: '',
                  data: summary.employeesByPosition.map((k, v) => MapEntry(k, v.toDouble())),
                  barColor: const Color(0xFF5E35B1),
                  maxItems: 5,
                ),
                insight: 'Posisi dengan jumlah terbanyak',
                color: const Color(0xFF5E35B1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // JOIN YEAR TREND
        _buildJoinYearCard(
          title: 'TAHUN BERGABUNG',
          subtitle: 'Tren rekrutmen pegawai per tahun',
          data: summary.employeesByJoinYear,
          totalEmployees: totalEmployees,
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String subtitle) {
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
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 26, 26, 26))),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkingKpiCard(AsyncValue<WorkingEmployeesResult> workingAsync, int totalEmployees) {
    return workingAsync.when(
      data: (working) {
        final workingCount = working.total;
        final percentage = totalEmployees > 0 ? (workingCount / totalEmployees) * 100 : 0;
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
            border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
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
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline, color: Color(0xFF2E7D32), size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Sedang Bertugas', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text(workingCount.toString(), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${working.normal} normal, ${working.overshift} overshift', style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 2, 23, 83))),
              ),
            ],
          ),
        );
      },
      loading: () => _buildKpiCard('Sedang Bertugas', '...', Icons.work_outline, const Color(0xFF2E7D32), 'Memuat data...'),
      error: (error, _) => _buildKpiCard('Sedang Bertugas', '0', Icons.work_outline, const Color(0xFF2E7D32), 'Gagal memuat'),
    );
  }

  Widget _buildDonutCard({
    required String title,
    required String subtitle,
    required Widget child,
    required String insight,
    required Color color,
  }) {
    return Container(
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
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          child,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 12, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(insight, style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard({
    required String title,
    required String subtitle,
    required Widget child,
    required String insight,
    required Color color,
  }) {
    return Container(
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
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 63, 1, 1))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: child,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 12, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(insight, style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinYearCard({
    required String title,
    required String subtitle,
    required Map<String, int> data,
    required int totalEmployees,
  }) {
    return Container(
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
        border: Border.all(color: const Color(0xFF01579B).withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01579B).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF01579B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF01579B)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF01579B))),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 63, 1, 1))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              children: data.entries.map((entry) {
                final year = entry.key;
                final count = entry.value;
                final percentage = totalEmployees > 0 ? (count / totalEmployees) * 100 : 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF01579B).withValues(alpha: 0.1),
                        const Color(0xFF01579B).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF01579B).withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(year, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF01579B))),
                      const SizedBox(height: 4),
                      Text('$count pegawai', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700)),
                      Text('(${percentage.toStringAsFixed(1)}%)', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF01579B).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 12, color: Color(0xFF01579B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Total ${data.length} tahun berbeda sejak berdiri',
                    style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.5,
          children: List.generate(4, (_) => _buildShimmerCard()),
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
        height: 140,
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
          Text('Gagal memuat data', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}