// File: lib/insights/hospital/views/human_ratio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/human_ratio_providers.dart';
import '../models/human_ratio_summary.dart';
import '../models/human_ratio_distribution.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class HumanRatioScreen extends ConsumerStatefulWidget {
  const HumanRatioScreen({super.key});

  @override
  ConsumerState<HumanRatioScreen> createState() => _HumanRatioScreenState();
}

class _HumanRatioScreenState extends ConsumerState<HumanRatioScreen> {
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

    final state = ref.watch(humanRatioStateProvider);
    final summary = state.summary;
    final peopleCategories = state.peopleCategories;
    final positions = state.positions;
    final employeePerUnit = state.employeePerUnit;
    final techInsight = state.techInsight;
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

                if (isLoading && summary.totalPeople == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalPeople == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  // ROW 1: KPI CARDS (DINAMIS)
                  _buildKPICards(summary, peopleCategories, isMobile, isTablet),
                  const SizedBox(height: 20),

                  // ROW 2: RATIO CARDS
                  _buildRatioCards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  // ROW 3: DISTRIBUSI PEOPLE + POSISI
                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPeopleCategoryChart(peopleCategories)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPositionChart(positions)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildPeopleCategoryChart(peopleCategories),
                        const SizedBox(height: 16),
                        _buildPositionChart(positions),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // ROW 4: PEGAWAI PER UNIT
                  if (employeePerUnit.isNotEmpty)
                    _buildEmployeePerUnitChart(employeePerUnit),
                  const SizedBox(height: 20),

                  // ROW 5: TECH INSIGHT CARD
                  _buildTechInsightCard(techInsight),
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
          child: const Icon(Icons.people, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HUMAN RATIO & ANALYTICS',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'Perbandingan Pegawai vs Non-Pegawai | Beban Kerja | Rasio',
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
  // KPI CARDS (DINAMIS - Berdasarkan Kategori dari Database)
  // ============================================================
Widget _buildKPICards(HumanRatioSummary summary, List<PeopleCategoryDistribution> categories, bool isMobile, bool isTablet) {
  final List<Widget> kpiCards = [];
  
  // Card 1: Total Pegawai (selalu ada)
  kpiCards.add(_kpiCard('Total Pegawai', summary.totalEmployees.toString(), Icons.badge, const Color(0xFF3B82F6)));
  
  // Card 2: Total People (selalu ada)
  kpiCards.add(_kpiCard('Total People', summary.totalPeople.toString(), Icons.people, const Color(0xFF10B981)));
  
  // Tambahkan KPI dari setiap kategori people (dinamis, max 8)
  final colors = [
    const Color(0xFFF59E0B), const Color(0xFF8B5CF6), 
    const Color(0xFF06B6D4), const Color(0xFFEF4444),
    const Color(0xFFEC4899), const Color(0xFF14B8A6),
    const Color(0xFF6366F1), const Color(0xFFF97316),
  ];
  
  for (int i = 0; i < categories.length && i < 8; i++) {
    final cat = categories[i];
    kpiCards.add(
      _kpiCard(cat.categoryName, cat.totalCount.toString(), Icons.person, colors[i % colors.length]),
    );
  }
  
  // Gunakan LayoutBuilder untuk menghitung jumlah kolom berdasarkan lebar layar
  return LayoutBuilder(
    builder: (context, constraints) {
      // Tentukan jumlah kolom berdasarkan lebar
      int columns = 2; // default mobile
      if (constraints.maxWidth >= 1200) {
        columns = 6; // desktop besar
      } else if (constraints.maxWidth >= 900) {
        columns = 3; // desktop kecil / tablet landscape
      } else if (constraints.maxWidth >= 600) {
        columns = 3; // tablet
      } else {
        columns = 2; // mobile
      }
      
      // Batasi kolom tidak lebih dari jumlah card
      if (kpiCards.length < columns) {
        columns = kpiCards.length;
      }
      
      // Hitung lebar card (berdasarkan lebar container - spacing)
      final cardWidth = (constraints.maxWidth - (12 * (columns - 1))) / columns;
      
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: kpiCards.map((card) {
          return SizedBox(
            width: cardWidth,
            child: card,
          );
        }).toList(),
      );
    },
  );
}

Widget _kpiCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: _glassDecoration(),
    child: Row(
      children: [
        // KOLOM KIRI: ICON
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
        // KOLOM KANAN: ANGKA + TEKS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
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
  // RATIO CARDS
  // ============================================================
  Widget _buildRatioCards(HumanRatioSummary summary, bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    
    // Siapkan data rasio (semua dinamis)
    final List<Map<String, dynamic>> ratioData = [];
    
    // Pegawai vs Pasien (jika ada pasien)
    if (summary.totalPatients > 0) {
      ratioData.add({
        'title': 'Pegawai vs Pasien',
        'ratio': '1 : ${summary.employeeVsPatientRatio.toStringAsFixed(1)}',
        'description': 'Setiap 1 pegawai melayani ${summary.employeeVsPatientRatio.toStringAsFixed(1)} pasien',
        'color': const Color(0xFF10B981),
      });
    }
    
    // Perawat vs Pasien (jika ada perawat)
    if (summary.nurseVsPatientRatio > 0) {
      ratioData.add({
        'title': 'Perawat vs Pasien',
        'ratio': '1 : ${summary.nurseVsPatientRatio.toStringAsFixed(1)}',
        'description': 'Setiap 1 perawat menangani ${summary.nurseVsPatientRatio.toStringAsFixed(1)} pasien',
        'color': const Color(0xFF3B82F6),
      });
    }
    
    // Pegawai vs Non-Pegawai
    if (summary.employeeVsNonEmployee > 0) {
      ratioData.add({
        'title': 'Pegawai vs Non-Pegawai',
        'ratio': '1 : ${summary.employeeVsNonEmployee.toStringAsFixed(1)}',
        'description': 'Perbandingan pegawai dengan non-pegawai',
        'color': const Color(0xFF8B5CF6),
      });
    }
    
    if (ratioData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: ratioData.map((data) {
        return _ratioCard(
          data['title'] as String,
          data['ratio'] as String,
          data['description'] as String,
          data['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _ratioCard(String title, String ratio, String description, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Icon(Icons.calculate, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ratio,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                  ),
                  maxLines: 2,
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
  // PEOPLE CATEGORY CHART (Donut)
  // ============================================================
  Widget _buildPeopleCategoryChart(List<PeopleCategoryDistribution> categories) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data kategori people',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final Map<String, int> chartData = {};
    for (final cat in categories) {
      chartData[cat.categoryName] = cat.totalCount;
    }

    final total = categories.fold(0, (sum, cat) => sum + cat.totalCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      constraints: const BoxConstraints(minHeight: 280),
      child: SingleChildScrollView(
        child: DonutChart(
          data: chartData,
          title: 'Distribusi People per Kategori',
          total: total.toDouble(),
        ),
      ),
    );
  }

  // ============================================================
  // POSITION CHART (Donut - Pegawai per Posisi)
  // ============================================================
  Widget _buildPositionChart(List<PositionDistribution> positions) {
    if (positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data posisi pegawai',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final Map<String, int> chartData = {};
    for (final pos in positions) {
      chartData[pos.positionName] = pos.employeeCount;
    }

    final total = positions.fold(0, (sum, pos) => sum + pos.employeeCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      constraints: const BoxConstraints(minHeight: 280),
      child: SingleChildScrollView(
        child: DonutChart(
          data: chartData,
          title: 'Distribusi Pegawai per Posisi',
          total: total.toDouble(),
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE PER UNIT CHART (Bar Chart dengan List)
  // ============================================================
  Widget _buildEmployeePerUnitChart(List<EmployeePerUnit> employees) {
    if (employees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data pegawai per unit',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final displayItems = employees.take(5).toList();
    final maxCount = displayItems.first.employeeCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Pegawai per Unit',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: displayItems.map((item) {
                  final percent = maxCount > 0 ? (item.employeeCount / maxCount) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.unitName,
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
                              '${item.employeeCount} org',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF10B981),
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
                            color: const Color(0xFF10B981),
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
          if (employees.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${employees.length - 5} unit lainnya',
                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TECH INSIGHT CARD
  // ============================================================
  Widget _buildTechInsightCard(Map<String, dynamic> insight) {
    final techCount = insight['techCount'] ?? 0;
    final techName = insight['techName'] ?? 'IT';
    final totalPeople = insight['totalPeople'] ?? 0;
    final ratio = insight['ratio'] ?? 0.0;
    
    String message;
    Color cardColor;
    
    if (techCount == 0) {
      message = 'Tidak ada data teknisi $techName di sistem';
      cardColor = const Color(0xFFF59E0B);
    } else if (ratio > 100) {
      message = '⚠️ KRITIS: 1 teknisi $techName melayani ${ratio.toStringAsFixed(0)} orang! Beban kerja sangat tinggi. Perhatikan kesejahteraan mental tim IT.';
      cardColor = const Color(0xFFEF4444);
    } else if (ratio > 50) {
      message = '⚠️ PERHATIAN: 1 teknisi $techName melayani ${ratio.toStringAsFixed(0)} orang. Beban kerja cukup tinggi.';
      cardColor = const Color(0xFFF59E0B);
    } else {
      message = '✅ IDEAL: 1 teknisi $techName melayani ${ratio.toStringAsFixed(1)} orang. Beban kerja terkendali.';
      cardColor = const Color(0xFF10B981);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withValues(alpha: 0.15), cardColor.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.computer, color: cardColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 INSIGHT: Beban Mental Teknisi $techName',
                  style: GoogleFonts.poppins(
                    color: cardColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                if (techCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '📊 $techCount teknisi untuk $totalPeople orang',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
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
              ref.invalidate(humanRatioStateProvider);
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