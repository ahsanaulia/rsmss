// lib/insights/profiles/widgets/employee_insight_popup.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/employee_detail_provider.dart';
import '../models/employee_detail_model.dart';

class EmployeeInsightPopup extends ConsumerStatefulWidget {
  final String profileId;
  final VoidCallback onClose;

  const EmployeeInsightPopup({
    super.key,
    required this.profileId,
    required this.onClose,
  });

  @override
  ConsumerState<EmployeeInsightPopup> createState() => _EmployeeInsightPopupState();
}

class _EmployeeInsightPopupState extends ConsumerState<EmployeeInsightPopup> {
  @override
  void initState() {
    super.initState();
    // Set selected profile ID
    Future.microtask(() {
      if (mounted) {
        ref.read(selectedEmployeeIdProvider.notifier).state = widget.profileId;
      }
    });
  }

  @override
  void dispose() {
    // Reset selected profile ID
    ref.read(selectedEmployeeIdProvider.notifier).state = null;
    super.dispose();
  }

  void _closeDialog() {
    // Reset state sebelum tutup
    ref.read(selectedEmployeeIdProvider.notifier).state = null;
    if (mounted) {
      Navigator.of(context).pop();
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Gunakan employeeDetailProvider (sudah ada di provider file)
    final detailAsync = ref.watch(employeeDetailProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A2A4A).withValues(alpha: 0.95),
                const Color(0xFF0F1A2E).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: detailAsync.when(
                data: (detail) {
                  if (!mounted) return const SizedBox.shrink();
                  return _buildContent(context, detail);
                },
                loading: () {
                  if (!mounted) return const SizedBox.shrink();
                  return _buildLoading();
                },
                error: (e, st) {
                  if (!mounted) return const SizedBox.shrink();
                  return _buildError(e.toString());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // SEMUA METHOD _buildContent, _buildHeader, dll SAMA SEPERTI SEBELUMNYA
  // ============================================
  
  Widget _buildContent(BuildContext context, EmployeeDetail? detail) {
    if (detail == null) {
      return _buildError('Data tidak ditemukan');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(detail.profile),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiRow(detail.kpi),
                const SizedBox(height: 20),
                _buildWellbeingSection(detail.wellbeing),
                const SizedBox(height: 20),
                _buildScoreSection(detail.score),
                const SizedBox(height: 20),
                _buildQualificationSection(detail.qualifications),
                const SizedBox(height: 20),
                _buildActivitySection(detail.activities),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(EmployeeProfileData profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: profile.avatarUrl != null
                  ? Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.positionName ?? 'Tidak Ada Posisi',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                if (profile.unitCode != null)
                  Text(
                    profile.unitCode!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _closeDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(EmployeeKpiData kpi) {
    return Row(
      children: [
        _buildKpiCard(
          title: 'Fatigue',
          value: '${kpi.fatigueScore.toStringAsFixed(0)}%',
          icon: Icons.battery_alert_outlined,
          color: _getFatigueColor(kpi.fatigueScore),
        ),
        const SizedBox(width: 12),
        _buildKpiCard(
          title: 'Kehadiran',
          value: '${kpi.attendanceRate.toStringAsFixed(0)}%',
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildKpiCard(
          title: 'Task',
          value: '${kpi.tasksCompleted}/${kpi.tasksTotal}',
          icon: Icons.task_alt,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _buildKpiCard(
          title: 'Skor',
          value: '${kpi.scorePercentage.toStringAsFixed(0)}%',
          icon: Icons.star,
          color: Colors.orange,
          subtitle: kpi.scoreLabel,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingSection(EmployeeWellbeingData wellbeing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_outline, color: Colors.pink.shade300, size: 18),
              const SizedBox(width: 8),
              Text(
                'WELLBEING TREND (7 HARI)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: wellbeing.history.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data wellbeing',
                      style: GoogleFonts.poppins(color: Colors.white54),
                    ),
                  )
                : _buildWellbeingChart(wellbeing.history),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWellbeingStat('Fatigue', wellbeing.averageFatigue, Colors.red),
              _buildWellbeingStat('Stress', wellbeing.averageStress, Colors.orange),
              _buildWellbeingStat('Mood', wellbeing.averageMood, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingChart(List<WellbeingHistoryItem> history) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: history.map((item) {
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 4,
                      height: (item.fatigue ?? 0) / 100 * 80,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.date.day}',
                style: GoogleFonts.poppins(fontSize: 9, color: Colors.white54),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWellbeingStat(String label, double value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(EmployeeScoreData score) {
    if (score.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment_outlined, color: Colors.purple.shade300, size: 18),
              const SizedBox(width: 8),
              Text(
                'SKOR PER KATEGORI',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...score.categories.map((cat) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${cat.percentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(cat.percentage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cat.percentage / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    color: _getScoreColor(cat.percentage),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQualificationSection(EmployeeQualificationData qualifications) {
    if (qualifications.qualifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: Colors.teal.shade300, size: 18),
              const SizedBox(width: 8),
              Text(
                'SERTIFIKASI',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...qualifications.qualifications.take(3).map((q) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: q.isExpired ? Colors.red : (q.isExpiringSoon ? Colors.orange : Colors.green),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (q.expiryDate != null)
                  Text(
                    _formatDate(q.expiryDate!),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: q.isExpired ? Colors.red : (q.isExpiringSoon ? Colors.orange : Colors.white54),
                    ),
                  ),
              ],
            ),
          )),
          if (qualifications.qualifications.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${qualifications.qualifications.length - 3} lainnya',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white38,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(EmployeeActivityData activities) {
    final allActivities = <ActivityItem>[
      ...activities.recentTasks,
      ...activities.recentDutyNotes,
      ...activities.recentIncidents,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (allActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_outlined, color: Colors.blue.shade300, size: 18),
              const SizedBox(width: 8),
              Text(
                'AKTIVITAS TERBARU',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...allActivities.take(5).map((activity) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getActivityIcon(activity.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(activity.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusText(activity.status),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: _getStatusColor(activity.status),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  Widget _getActivityIcon(String type) {
    switch (type) {
      case 'task':
        return Icon(Icons.task_alt, size: 16, color: Colors.green);
      case 'duty_note':
        return Icon(Icons.edit_note, size: 16, color: Colors.blue);
      case 'incident':
        return Icon(Icons.warning_amber_outlined, size: 16, color: Colors.red);
      default:
        return Icon(Icons.circle, size: 16, color: Colors.grey);
    }
  }

  Color _getFatigueColor(double score) {
    if (score >= 70) return Colors.red;
    if (score >= 50) return Colors.orange;
    return Colors.green;
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'done':
      case 'completed':
      case 'resolved':
        return Colors.green;
      case 'in_progress':
      case 'accepted':
        return Colors.blue;
      case 'pending':
      case 'reported':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'completed':
        return 'Selesai';
      case 'resolved':
        return 'Terselesaikan';
      case 'in_progress':
        return 'Proses';
      case 'accepted':
        return 'Diterima';
      case 'pending':
        return 'Menunggu';
      case 'reported':
        return 'Dilaporkan';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Memuat data pegawai...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _closeDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF052D9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}