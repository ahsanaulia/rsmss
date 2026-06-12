// File: lib/insights/hospital/views/occupancy_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/occupancy_providers.dart';
import '../models/occupancy_summary.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class OccupancyDashboardScreen extends ConsumerStatefulWidget {
  const OccupancyDashboardScreen({super.key});

  @override
  ConsumerState<OccupancyDashboardScreen> createState() => _OccupancyDashboardScreenState();
}

class _OccupancyDashboardScreenState extends ConsumerState<OccupancyDashboardScreen> {
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

    final state = ref.watch(occupancyStateProvider);
    final summary = state.summary;
    final perRoom = state.perRoom;
    final categoryDistribution = state.categoryDistribution;
    final activePatients = state.activePatients;
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

                if (isLoading && summary.totalBeds == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalBeds == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  // ROW 1: KPI CARDS
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  // ROW 2: GAUGE + DISTRIBUSI KATEGORI
                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildGaugeCard(summary.occupancyRate)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCategoryDonut(categoryDistribution)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildGaugeCard(summary.occupancyRate),
                        const SizedBox(height: 16),
                        _buildCategoryDonut(categoryDistribution),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // ROW 3: OKUPANSI PER KAMAR
                  if (perRoom.isNotEmpty)
                    _buildOccupancyPerRoomChart(perRoom),
                  const SizedBox(height: 20),

                  // ROW 4: PASIEN AKTIF
                  if (activePatients.isNotEmpty)
                    _buildActivePatientsTable(activePatients),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          child: const Icon(Icons.bed, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BED OCCUPANCY DASHBOARD',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'Monitoring okupansi tempat tidur rumah sakit',
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

  Widget _buildKPICards(OccupancySummary summary, bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 8);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _kpiCard('Total Bed', summary.totalBeds.toString(), Icons.bed, const Color(0xFF3B82F6)),
        _kpiCard('Terisi', summary.occupiedBeds.toString(), Icons.person, const Color(0xFFEF4444)),
        _kpiCard('Kosong', summary.emptyBeds.toString(), Icons.bed, const Color(0xFF10B981)),
        _kpiCard('Perawatan', summary.maintenanceBeds.toString(), Icons.build, const Color(0xFFF59E0B)),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard(double occupancyRate) {
    final color = occupancyRate >= 80 
        ? const Color(0xFFEF4444)
        : occupancyRate >= 60 
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'OKUPANSI',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: occupancyRate / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${occupancyRate.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Terisi',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            occupancyRate >= 80 
                ? '⚠️ Kapasitas Hampir Penuh'
                : occupancyRate >= 60 
                    ? '⚠️ Okupansi Cukup Tinggi'
                    : '✅ Okupansi Terkendali',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDonut(List<BedCategoryDistribution> categories) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data kategori kamar',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final Map<String, int> chartData = {};
    for (final cat in categories) {
      chartData[cat.categoryName] = cat.totalBeds;
    }

    final total = categories.fold(0, (sum, cat) => sum + cat.totalBeds);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: DonutChart(
        data: chartData,
        title: 'Distribusi Bed per Kategori Kamar',
        total: total.toDouble(),
      ),
    );
  }

  Widget _buildOccupancyPerRoomChart(List<OccupancyPerRoom> rooms) {
    final displayRooms = rooms.take(10).toList();
    final maxRate = displayRooms.first.occupancyRate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Okupansi per Kamar (Top 10)',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Column(
                children: displayRooms.map((room) {
                  final percent = maxRate > 0 ? (room.occupancyRate / maxRate) * 100 : 0.0;
                  final color = room.occupancyRate >= 80 
                      ? const Color(0xFFEF4444)
                      : room.occupancyRate >= 60 
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
                                room.roomName,
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
                              '${room.occupiedBeds}/${room.totalBeds}',
                              style: GoogleFonts.poppins(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: color,
                            minHeight: 6,
                          ),
                        ),
                        Text(
                          '${room.occupancyRate.toStringAsFixed(0)}% terisi',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
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

  Widget _buildActivePatientsTable(List<ActivePatient> patients) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: const Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Pasien Aktif (${patients.length})',
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
                    DataColumn(label: Text('Bed', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Ruangan', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Pasien', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Masuk', style: TextStyle(color: Colors.white70, fontSize: 11))),
                    DataColumn(label: Text('Prediksi', style: TextStyle(color: Colors.white70, fontSize: 11))),
                  ],
                  rows: patients.map((patient) {
                    return DataRow(
                      cells: [
                        DataCell(Text(patient.bedNumber, style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(patient.roomName, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                        DataCell(Text(patient.patientName, style: const TextStyle(color: Colors.white, fontSize: 11))),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(patient.assignedAt), style: const TextStyle(color: Colors.white70, fontSize: 11))),
                        DataCell(Text(
                          patient.predictedUntil != null
                              ? DateFormat('dd/MM/yyyy').format(patient.predictedUntil!)
                              : '-',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        )),
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

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(4, (index) {
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
              ref.invalidate(occupancyStateProvider);
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