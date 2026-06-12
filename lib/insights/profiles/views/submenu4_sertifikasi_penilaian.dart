// File: lib/insights/profiles/views/submenu4_sertifikasi_penilaian.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_scoring_provider.dart';
import '../providers/profile_qualification_provider.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../models/profile_scoring_model.dart';
import '../models/profile_qualification_model.dart';

class Submenu4SertifikasiPenilaian extends ConsumerWidget {
  const Submenu4SertifikasiPenilaian({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print('🔥🔥🔥 [SUB-MENU 4] BUILD DIPANGGIL 🔥🔥🔥');
    
    final scoreSummaryAsync = ref.watch(scoreSummaryListStreamProvider);
    final topPerformersAsync = ref.watch(topPerformersStreamProvider);
    final categoriesAsync = ref.watch(scoringCategoriesStreamProvider);
    final allQualificationsAsync = ref.watch(allOwnedQualificationsProvider);
    
    allQualificationsAsync.when(
      data: (list) => print('✅ [SUB-MENU 4] Data sertifikasi: ${list.length} items'),
      loading: () => print('⏳ [SUB-MENU 4] Loading sertifikasi...'),
      error: (e, _) => print('❌ [SUB-MENU 4] Error sertifikasi: $e'),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: RefreshIndicator(
          onRefresh: () async {
            // print('🔄 [SUB-MENU 4] Refresh dipanggil');
            ref.invalidate(scoreSummaryListProvider);
            ref.invalidate(topPerformersProvider);
            ref.invalidate(allOwnedQualificationsProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                _buildKpiRow(scoreSummaryAsync, allQualificationsAsync),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTopPerformersCard(topPerformersAsync)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBottomPerformersCard(scoreSummaryAsync)),
                  ],
                ),
                const SizedBox(height: 20),

                _buildScoreByCategoryCard(categoriesAsync, scoreSummaryAsync),
                const SizedBox(height: 20),

                _buildQualificationsCard(allQualificationsAsync),
              ],
            ),
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
          '       SERTIFIKASI & PENILAIAN',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Skor kinerja pegawai dan status sertifikasi',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 3, width: 40, color: Colors.white.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _buildKpiRow(
    AsyncValue<List<ScoreSummary>> scoreAsync,
    AsyncValue<List<QualificationWithAssignment>> qualificationsAsync,
  ) {
    return scoreAsync.when(
      data: (scores) {
        final totalEmployees = scores.length;
        final avgScore = totalEmployees > 0
            ? scores.map((s) => s.totalPercentage).reduce((a, b) => a + b) / totalEmployees
            : 0;

        return qualificationsAsync.when(
          data: (qualifications) {
            final totalCertifications = qualifications.length;
            print('📊 [KPI ROW] Total sertifikasi: $totalCertifications');
            
            return Row(
              children: [
                Expanded(child: _buildKpiCard(
                  title: 'PEGAWAI DINILAI',
                  value: totalEmployees.toString(),
                  icon: Icons.people_alt,
                  color: const Color(0xFF3B82F6),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard(
                  title: 'RATA-RATA SKOR',
                  value: '${avgScore.toStringAsFixed(1)}%',
                  icon: Icons.assessment_outlined,
                  color: avgScore >= 70 ? const Color(0xFF10B981) : (avgScore >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard(
                  title: 'TOTAL SERTIFIKASI',
                  value: totalCertifications.toString(),
                  icon: Icons.verified_outlined,
                  color: const Color(0xFF8B5CF6),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard(
                  title: 'RATA-RATA SKOR',
                  value: '${avgScore.toStringAsFixed(1)}%',
                  icon: Icons.assessment_outlined,
                  color: avgScore >= 70 ? const Color(0xFF10B981) : (avgScore >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                )),
              ],
            );
          },
          loading: () => Row(
            children: List.generate(4, (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ShimmerLoading(
                  isLoading: true,
                  child: Container(height: 120, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16))),
                ),
              ),
            )),
          ),
          error: (e, _) => Row(
            children: List.generate(4, (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildKpiCard(title: 'Error', value: '0', icon: Icons.error, color: Colors.grey),
              ),
            )),
          ),
        );
      },
      loading: () => Row(
        children: List.generate(4, (_) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ShimmerLoading(
              isLoading: true,
              child: Container(height: 120, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16))),
            ),
          ),
        )),
      ),
      error: (e, _) => Row(
        children: List.generate(4, (_) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildKpiCard(title: 'Error', value: '0', icon: Icons.error, color: Colors.grey),
          ),
        )),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersCard(AsyncValue<List<ScoreSummary>> performers) {
    const color = Color(0xFF10B981);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 TOP PERFORMERS',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          performers.when(
            data: (list) => list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Belum ada data penilaian',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: list.take(5).toList().asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final score = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$index',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    score.fullName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (score.unitCode != null && score.unitCode!.isNotEmpty)
                                    Text(
                                      score.unitCode!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${score.totalPercentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat data',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPerformersCard(AsyncValue<List<ScoreSummary>> summaries) {
    const color = Color(0xFFEF4444);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📉 BOTTOM PERFORMERS',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          summaries.when(
            data: (list) => list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Belum ada data penilaian',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: list.reversed.take(5).toList().asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final score = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$index',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    score.fullName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (score.unitCode != null && score.unitCode!.isNotEmpty)
                                    Text(
                                      score.unitCode!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${score.totalPercentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFEF4444))),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat data',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreByCategoryCard(
    AsyncValue<List<ScoringCategoryModel>> categoriesAsync,
    AsyncValue<List<ScoreSummary>> scoresAsync,
  ) {
    const color = Color(0xFF8B5CF6);
    
    return categoriesAsync.when(
      data: (categories) {
        return scoresAsync.when(
          data: (scores) {
            final Map<String, double> avgScores = {};
            
            for (final category in categories) {
              avgScores[category.categoryName] = 0;
            }
            
            for (final score in scores) {
              for (final categoryScore in score.categoryScores) {
                final categoryName = categories.firstWhere(
                  (c) => c.id == categoryScore.categoryId,
                  orElse: () => ScoringCategoryModel(
                    id: '',
                    categoryCode: '',
                    categoryName: 'Unknown',
                    weight: 1,
                    isActive: true,
                  ),
                ).categoryName;
                
                if (avgScores.containsKey(categoryName)) {
                  final currentAvg = avgScores[categoryName]!;
                  final count = scores.length;
                  avgScores[categoryName] = (currentAvg * (count - 1) + categoryScore.percentage) / count;
                }
              }
            }

            if (avgScores.isEmpty) {
              return _buildPlaceholderCard('SKOR PER KATEGORI', color);
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: _glassDecoration(color),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKOR PER KATEGORI',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...avgScores.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              '${entry.value.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(entry.value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            color: _getScoreColor(entry.value),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          },
          loading: () => _buildPlaceholderCard('SKOR PER KATEGORI', color),
          error: (e, _) => _buildPlaceholderCard('SKOR PER KATEGORI', color),
        );
      },
      loading: () => _buildPlaceholderCard('SKOR PER KATEGORI', color),
      error: (e, _) => _buildPlaceholderCard('SKOR PER KATEGORI', color),
    );
  }

  Widget _buildQualificationsCard(AsyncValue<List<QualificationWithAssignment>> qualifications) {
    const color = Color(0xFF8B5CF6);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📜 SERTIFIKASI PEGAWAI',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          qualifications.when(
            data: (list) => list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Belum ada data sertifikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 350),
                    child: SingleChildScrollView(
                      child: Column(
                        children: list.take(10).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    item.displayName.isNotEmpty ? item.displayName[0].toUpperCase() : '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.displayName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.qualification.qualificationName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.unitCode != null && item.unitCode!.isNotEmpty)
                                      Text(
                                        item.unitCode!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: Colors.white.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    if (item.expiryDate != null)
                                      Text(
                                        'Berlaku s/d: ${_formatDate(item.expiryDate!)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: _getExpiryColor(item.expiryDate!),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
            error: (e, _) => Center(
              child: Text(
                'Gagal memuat data: ${e.toString()}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(color),
      child: ShimmerLoading(
        isLoading: true,
        child: Container(height: 200, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16))),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return const Color(0xFFEF4444);
    if (daysLeft <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================================
  // GLASSMORPHISM DECORATION
  // ============================================================
  Decoration _glassDecoration(Color accentColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.08),
      border: Border.all(
        color: accentColor.withValues(alpha: 0.2),
        width: 0.5,
      ),
    );
  }
}