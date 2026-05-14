import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rsmss/core/di/service_locator.dart';
import 'package:rsmss/core/services/auth_service.dart';
import 'task_list_view.dart';
import 'attendance_view.dart';
import '../profile_view.dart';
import 'task_history_view.dart';
import 'report_history_view.dart';
import 'attendance_history_view.dart';
import '../../services/announcement_service.dart';
// import 'op_initial_asset.dart';
import '../../features/asset_initial/views/op_initial_asset.dart';
import '../../features/asset_inspection/views/asset_inspection_view.dart';
import '../../features/stock/views/stock_initial_view.dart';
import '../../features/stock/views/stock_opname_view.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/roster/providers/roster_provider.dart';
import '../../features/roster/widgets/roster_reminder_card.dart';

import '../../features/duty/views/duty_note_bottom_sheet.dart';
import '../../features/incident/views/incident_report_bottom_sheet.dart';

import '../../features/dashboard/services/dashboard_stats_service.dart';
import '../../features/dashboard/widgets/employee_stats_card.dart';

class OperationDashboard extends ConsumerStatefulWidget {
  final String userName;
  final VoidCallback onLogout;

  const OperationDashboard({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  ConsumerState<OperationDashboard> createState() => _OperationDashboardState();
}

// class _OperationDashboardState extends State<OperationDashboard> {
class _OperationDashboardState extends ConsumerState<OperationDashboard> {
  // HAPUS: final supabase = Supabase.instance.client;
  late final AuthService _authService;

  int _currentNavbarIndex = 0;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _hospitalData;

  // Stats tetap pake variabel karena butuh logic perhitungan kompleks (looping)
  int _newTasksCount = 0;
  int _onGoingTasksCount = 0;
  int _urgentTasksCount = 0;
  bool _isLoading = true;
  double _employeePoints = 0;
  Map<String, double> _categoryScores = {};
  double _fatigueScore = 0;
  String _fatigueRiskLevel = 'normal';
  String _pointsPeriod = '';

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadStaticData(); // Load data yang jarang berubah (Hospital & Profile)
    _loadTaskStats(); // Load statistik task
    _loadEmployeeStats();
  }

  /// AMBIL DATA STATIS (Hospital & Profile)
  /// OPTIMASI: Profile data sekarang pakai dari AuthService jika tersedia
  Future<void> _loadStaticData() async {
    try {
      final currentSession = _authService.currentSession;
      final userId = _authService.currentUserId;

      if (userId == null) return;

      // Ambil hospital profile
      final hospital = await Supabase.instance.client
          .from('hospital_profile')
          .select()
          .maybeSingle();

      // OPTIMASI: Cek apakah profile sudah ada di cache AuthService
      Map<String, dynamic>? profile;

      if (currentSession != null && currentSession.rawData != null) {
        // Pakai data dari cache AuthService untuk mengurangi query
        profile = currentSession.rawData;
      } else {
        // Fallback: query langsung ke database
        profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
      }

      if (mounted) {
        setState(() {
          _hospitalData = hospital;
          _profileData = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Static Data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEmployeeStats() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final service = DashboardStatsService();

    try {
      final pointsData = await service.getEmployeePoints(userId);
      final fatigueData = await service.getTodayFatigue(userId);

      if (mounted) {
        setState(() {
          _employeePoints = pointsData['totalScore'] ?? 0;
          _categoryScores = pointsData['categoryScores'] ?? {};
          _pointsPeriod = pointsData['period'] ?? '';
          _fatigueScore = fatigueData['fatigueScore'] ?? 0;
          _fatigueRiskLevel = fatigueData['riskLevel'] ?? 'normal';
        });
      }
    } catch (e) {
      debugPrint("Error loading employee stats: $e");
    }
  }

  /// AMBIL STATISTIK TASK (Manual Refresh/Initial)
  Future<void> _loadTaskStats() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;

      final List<dynamic> tasksResponse = await Supabase.instance.client
          .from('tasks')
          .select()
          .eq('assignee_id', userId);

      int n = 0, o = 0, u = 0;
      for (var t in tasksResponse) {
        final String? status = t['status']?.toString();
        final String? priority = t['priority']?.toString();
        if (status == 'pending') n++;
        if (status == 'accepted') o++;
        if ((priority == 'urgent' || priority == 'emergency') &&
            status != 'done')
          u++;
      }

      if (mounted) {
        setState(() {
          _newTasksCount = n;
          _onGoingTasksCount = o;
          _urgentTasksCount = u;
        });
      }
    } catch (e) {
      debugPrint("Error Task Stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topSpacing = MediaQuery.of(context).size.height * 0.12;

    final List<Widget> pages = [
      _buildHomeContent(topSpacing),
      const AttendanceView(),
      const TaskListView(),
      const ProfileView(),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: IndexedStack(index: _currentNavbarIndex, children: pages),
        ),
      ),
      bottomNavigationBar: _buildBottomNavbar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHomeContent(double topSpacing) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () async {
        await _loadStaticData();
        await _loadTaskStats();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: topSpacing),
          _buildHospitalInfo(),
          const SizedBox(height: 20),
          EmployeeStatsCard(
            totalPoints: _employeePoints,
            categoryScores: _categoryScores,
            fatigueScore: _fatigueScore,
            fatigueRiskLevel: _fatigueRiskLevel,
            period: _pointsPeriod,
            onTap: () {
              // Optional: Navigate to detail stats page
            },
          ),
          // --- INTEGRASI STREAMBUILDER DI SINI ---
          _buildRealtimeUserCard(),

          const SizedBox(height: 10),
          _buildMenuCategory("REPORTS", [
            _menuItemSmall(
              "Riwayat Tugas",
              Icons.history_rounded,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskHistoryView(),
                  ),
                );
              },
            ),
            _menuItemSmall(
              "Riwayat Laporan",
              Icons.assignment_late_outlined,
              Colors.teal,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportHistoryView(),
                  ),
                );
              },
            ),
            _menuItemSmall(
              "Riwayat Absensi",
              Icons.pending_actions_rounded,
              Colors.indigo,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryView(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 10),

          // =====================================================
          // WORK OPERATIONS
          // =====================================================
          _buildMenuCategory("OPERASIONAL KERJA", [
            // =================================================
            // INCIDENT REPORT (TAMBAHKAN INI)
            // =================================================
            _menuItemSmall(
              "Lapor Insiden",
              Icons.warning_amber_rounded,
              Colors.red,
              () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  builder: (context) => const IncidentReportBottomSheet(),
                );
              },
            ),

            // =================================================
            // ASSET INITIAL
            // =================================================
            if (_profileData?['is_asset_initial'] == true)
              _menuItemSmall(
                "Inisialisasi Awal Asset",
                Icons.inventory_2_outlined,
                Colors.blue,
                () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OpInitialAsset(),
                    ),
                  );

                  if (result == true) {
                    await _loadTaskStats();
                  }
                },
              ),

            // =================================================
            // ASSET INSPECTION
            // =================================================
            if (_profileData?['is_asset_inspection'] == true)
              _menuItemSmall(
                "Inspeksi Rutin Asset",
                Icons.fact_check_outlined,
                Colors.teal,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssetInspectionView(),
                    ),
                  );
                },
              ),

            // =================================================
            // STOCK INITIAL
            // =================================================
            if (_profileData?['is_stock_initial'] == true)
              _menuItemSmall(
                "Inisialisasi Awal Stock",
                Icons.warehouse_outlined,
                Colors.indigo,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StockInitialView(),
                    ),
                  );
                },
              ),

            // =================================================
            // STOCK OPNAME
            // =================================================
            if (_profileData?['is_stock_opname'] == true)
              _menuItemSmall(
                "Stock Opname",
                Icons.playlist_add_check_circle_outlined,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StockOpnameView(),
                    ),
                  );
                },
              ),
          ]),

          const SizedBox(height: 10),
          _buildControlRoomSection(),
          const SizedBox(height: 16),

          // =====================================================
          // ROSTER REMINDER CARD
          // =====================================================
          _buildRosterReminderCard(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildRosterReminderCard() {
    final rosterState = ref.watch(rosterStateProvider);

    // Hanya tampilkan jika ada roster atau sedang loading
    if (rosterState.isLoading) {
      return const SizedBox.shrink();
    }

    // Jika tidak ada roster dan bukan flexible roster, tidak usah ditampilkan
    if (!rosterState.hasRoster && !rosterState.isFlexibleRoster) {
      return const SizedBox.shrink();
    }

    return RosterReminderCard(state: rosterState);
  }

  /// WIDGET CARD DENGAN STREAMBUILDER (REAL-TIME STATUS)
  Widget _buildRealtimeUserCard() {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return const SizedBox();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('attendance')
          .stream(primaryKey: ['id'])
          .eq('profile_id', userId)
          .order('check_in', ascending: false)
          .limit(1),
      builder: (context, snapshot) {
        bool isPresent = false;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          isPresent = snapshot.data!.first['check_out'] == null;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================
                    // AVATAR
                    // ==================================
                    Transform.translate(
                      offset: const Offset(-10, -10),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.95),
                              Colors.white.withValues(alpha: 0.75),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF01579B,
                              ).withValues(alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(-2, -2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileData?['avatar_url'] != null
                              ? NetworkImage(_profileData!['avatar_url'])
                              : null,
                          child: _profileData?['avatar_url'] == null
                              ? Icon(
                                  Icons.person,
                                  size: 38,
                                  color: Colors.blueGrey.shade400,
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ==================================
                    // CONTENT
                    // ==================================
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==========================
                            // TOP ROW
                            // ==========================
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _profileData?['full_name'] ??
                                              widget.userName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF01579B),
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: isPresent
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isPresent
                                                  ? "ON DUTY"
                                                  : "OFF DUTY",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.4,
                                                color: isPresent
                                                    ? Colors.green.shade800
                                                    : Colors.red.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ======================
                                // LOGOUT
                                // ======================
                                Transform.translate(
                                  offset: const Offset(8, -6),
                                  child: IconButton(
                                    onPressed: widget.onLogout,
                                    splashRadius: 22,
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      color: Color(0xFF01579B),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ==========================
                            // TASK TELEMETRY
                            // ==========================
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _miniStat("New", _newTasksCount, Colors.blue),
                                  const SizedBox(width: 22),
                                  _miniStat(
                                    "On",
                                    _onGoingTasksCount,
                                    Colors.indigo,
                                  ),
                                  const SizedBox(width: 22),
                                  _miniStat(
                                    "Urg",
                                    _urgentTasksCount,
                                    Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$value",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Management Support System IOT",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _hospitalData?['name']?.toUpperCase() ?? "RUMAH SAKIT",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF01579B),
              height: 1.1,
            ),
          ),
          Text(
            _hospitalData?['address'] ?? "Alamat belum tersedia",
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem("New", _newTasksCount, Colors.blue),
            _statItem("Ongoing", _onGoingTasksCount, Colors.indigo),
            _statItem("Urgent", _urgentTasksCount, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, int val, Color color) {
    return Column(
      children: [
        Text(
          "$val",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildMenuCategory(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 25, 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF01579B),
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.4,
          children: items,
        ),
      ],
    );
  }

  Widget _menuItemSmall(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRoomSection() {
    final userId = _authService.currentUserId;
    if (userId == null || _profileData == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 25, 8),
          child: Text(
            "LATEST ANNOUNCEMENTS",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: AnnouncementService().getFilteredAnnouncements(
            userId,
            _profileData?['position_id'],
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const SizedBox();

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildAnnouncementBox(
                title: "INFO",
                content: "Belum ada pesan baru dari pusat kontrol.",
                priority: "normal",
              );
            }

            final announcements = snapshot.data!;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // ← PENTING
              padding: EdgeInsets.zero, // ← Padding sudah di dalam box
              itemCount: announcements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ann = announcements[index];
                return _buildAnnouncementBox(
                  title: ann['title'] ?? "INFO",
                  content: ann['content'] ?? "",
                  priority: ann['priority'] ?? "normal",
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementBox({
    required String title,
    required String content,
    required String priority,
    String time = "Just now",
  }) {
    bool isUrgent = priority == 'urgent' || priority == 'emergency';
    bool isInfo = priority == 'info' || priority == 'normal';

    // Warna berdasarkan priority
    Color borderColor;
    Color bgColor;
    Color titleColor;
    Color contentColor;

    if (isUrgent) {
      borderColor = Colors.red.shade400;
      bgColor = Colors.red.shade50.withValues(alpha: 0.9);
      titleColor = Colors.red.shade800;
      contentColor = Colors.red.shade900;
    } else if (isInfo) {
      borderColor = Colors.blue.shade300;
      bgColor = Colors.blue.shade50.withValues(alpha: 0.85);
      titleColor = Colors.blue.shade800;
      contentColor = Colors.blue.shade900;
    } else {
      borderColor = Colors.grey.shade300;
      bgColor = Colors.white.withValues(alpha: 0.85);
      titleColor = Colors.grey.shade800;
      contentColor = Colors.grey.shade800;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ), // ← SAMA DENGAN ROSTER
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.6),
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUrgent
                    ? Icons.warning_amber_rounded
                    : Icons.announcement_rounded,
                color: titleColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "URGENT",
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: contentColor,
              fontWeight: FontWeight.normal,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: isUrgent ? Colors.red.shade400 : Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 50),
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF01579B),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home_filled, "Home", 0),
          _navIcon(Icons.calendar_month, "Absensi", 1),
          const SizedBox(width: 45),
          _navIcon(Icons.assignment, "Tasks", 2),
          _navIcon(Icons.person, "Profile", 3),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, int index) {
    bool isSelected = _currentNavbarIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentNavbarIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01579B).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // ✅ WAJIB (Anda sudah punya)
            isDismissible: true,
            enableDrag: true,
            useRootNavigator: true, // ← TAMBAHKAN INI
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            builder: (context) => const DutyNoteBottomSheet(),
          );
        },
        backgroundColor: const Color(0xFF01579B),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
