// File: lib/insights/profiles/views/submenu3_lokasi_kehadiran.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shift_attendance_provider.dart';
import '../widgets/shared/donut_chart.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../models/shift_attendance_model.dart';

class Submenu3LokasiKehadiran extends ConsumerWidget {
  const Submenu3LokasiKehadiran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(shiftAttendanceOverviewStreamProvider);

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
            ref.invalidate(shiftAttendanceOverviewProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                overviewAsync.when(
                  data: (overview) => _buildContent(overview),
                  loading: () => _buildLoadingShimmer(),
                  error: (error, _) => _buildErrorState(error.toString()),
                ),
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
          'LOKASI & KEHADIRAN',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Monitoring kehadiran pegawai per shift',
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

  Widget _buildContent(AttendanceOverview overview) {
    final Map<String, List<RecentCheckIn>> checkInsByShift = {};
    for (final checkIn in overview.recentCheckIns) {
      final shiftName = checkIn.shiftName ?? 'Lainnya';
      if (!checkInsByShift.containsKey(shiftName)) {
        checkInsByShift[shiftName] = [];
      }
      checkInsByShift[shiftName]!.add(checkIn);
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: overview.shifts.asMap().entries.map((entry) {
            final index = entry.key;
            final shift = entry.value;
            final shiftCheckIns = checkInsByShift[shift.shiftName] ?? [];
            return Expanded(child: _buildShiftColumn(shift, shiftCheckIns, index));
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildStatusCard(overview.employeesBySituation),
      ],
    );
  }

  Widget _buildShiftColumn(ShiftAttendanceSummary shift, List<RecentCheckIn> shiftCheckIns, int colorIndex) {
    final total = shift.hadir + shift.tidakHadir + shift.cuti;
    final kehadiranPersen = total > 0 ? (shift.hadir / total) * 100 : 0;

    final List<Color> accentColors = [
      const Color(0xFF3B82F6),  // Biru
      const Color(0xFFF59E0B),  // Oranye
      const Color(0xFF10B981),  // Hijau
    ];
    
    final accentColor = accentColors[colorIndex % accentColors.length];

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shift.shiftIcon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            shift.shiftName,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            '${shift.shiftStart.substring(0, 5)} - ${shift.shiftEnd.substring(0, 5)}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          
          const SizedBox(height: 14),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'Kehadiran',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${kehadiranPersen.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStat(shift.hadir, 'Hadir', const Color(0xFF10B981)),
              const SizedBox(width: 6),
              _buildStat(shift.tidakHadir, 'Tdk', const Color(0xFFEF4444)),
              const SizedBox(width: 6),
              _buildStat(shift.cuti, 'Cuti', const Color(0xFFF59E0B)),
            ],
          ),
          
          const SizedBox(height: 10),
          
          if (shift.terlambat > 0 || shift.overshiftEmployees.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (shift.terlambat > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚠️ ${shift.terlambat} terlambat',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                if (shift.overshiftEmployees.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🔄 ${shift.overshiftEmployees.length} overshift',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
              ],
            ),
          
          const Divider(height: 18, color: Colors.white24),
          
          Text(
            'RECENT CHECK-IN',
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          
          if (shiftCheckIns.isEmpty)
            Center(
              child: Text(
                'Belum ada check-in',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: shiftCheckIns.length,
                itemBuilder: (context, index) {
                  final checkIn = shiftCheckIns[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            checkIn.fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(checkIn.checkIn),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.5),
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

  Widget _buildStat(int value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, int> employeesBySituation) {
    final total = employeesBySituation.values.fold(0, (sum, val) => sum + val);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(const Color(0xFF3B82F6)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DonutChart(
              title: '',
              data: employeesBySituation,
              total: total.toDouble(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: employeesBySituation.entries.map((entry) {
                final percentage = total > 0 ? (entry.value / total) * 100 : 0;
                final color = _getColor(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String situation) {
    switch (situation) {
      case 'ACTIVE': return const Color(0xFF10B981);
      case 'LEAVE': return const Color(0xFFF59E0B);
      case 'OFF': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}d';
  }

  Widget _buildLoadingShimmer() {
    return Row(
      children: List.generate(3, (_) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          height: 420,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ShimmerLoading(isLoading: true, child: Container()),
        ),
      )),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
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