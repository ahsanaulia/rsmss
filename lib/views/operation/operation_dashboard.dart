import 'dart:ui';
import 'package:rsmss/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rsmss/core/di/service_locator.dart';
import 'package:rsmss/core/services/auth_service.dart';
import '../../widgets/pending_approval_overlay.dart';
import 'task_list_view.dart';
import 'attendance_view.dart';
import '../profile_view.dart';
import 'task_history_view.dart';
import 'report_history_view.dart';
import 'attendance_history_view.dart';
import '../../services/announcement_service.dart';
import '../../services/sound_notification_service.dart';
import '../../features/asset_initial/views/op_initial_asset.dart';
import '../../features/asset_inspection/views/asset_inspection_view.dart';
import '../../features/stock/views/stock_initial_view.dart';
import '../../features/stock/views/stock_write_off_list_page.dart';
import '../../features/stock/views/stock_bin_opname_view.dart';
import '../../features/stock/views/stock_write_off_approval_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/roster/providers/roster_provider.dart';
import '../../features/roster/widgets/roster_reminder_card.dart';
import '../../features/duty/views/duty_note_bottom_sheet.dart';
import '../../features/incident/views/incident_report_bottom_sheet.dart';
import '../../features/dashboard/services/dashboard_stats_service.dart';
import '../../features/dashboard/widgets/employee_stats_card.dart';
import '../../features/reports/views/my_reports_view.dart';
import '../../features/asset_assignment/views/employee/employee_asset_request_page.dart';
import '../../features/asset_assignment/views/employee/employee_asset_return_page.dart';
import '../../features/stock_in/presentations/stock_in_form_mobile.dart';
import '../../features/stock_in_bins/presentations/pending_put_away_list.dart';
import '../../features/stock_request/presentations/stock_request_list_page.dart';
import '../../features/stock_request/presentations/stock_request_approval_page.dart';
import '../../features/stock_request/presentations/stock_request_fulfillment_page.dart';
import '../../crud/buildings/views/building_mobile.dart';
import '../../crud/stock_bins/views/stock_bin_mobile.dart';
import '../../features/bed_assignments/views/bed_assignment_screen.dart';
import '../../features/bed_unassignment/views/bed_unassignment_screen.dart';
import '../../features/people/views/people_input_screen.dart';
import '../../features/people_checkout/views/people_checkout_screen.dart';
import '../../crud/todos/views/todo_mobile_stream.dart';
import 'package:rsmss/l10n/app_localizations.dart';

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

class _OperationDashboardState extends ConsumerState<OperationDashboard> {
  late final AuthService _authService;

  Set<String> _previousAnnouncementIds = {};
  final SoundNotificationService _soundService = SoundNotificationService();

  int _currentNavbarIndex = 0;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _hospitalData;

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
    _loadStaticData();
    _loadTaskStats();
    _loadEmployeeStats();
  }

  Future<void> _loadStaticData() async {
    try {
      final currentSession = _authService.currentSession;
      final userId = _authService.currentUserId;

      if (userId == null) return;

      final hospital = await Supabase.instance.client
          .from('hospital_profile')
          .select()
          .maybeSingle();

      Map<String, dynamic>? profile;

      if (currentSession != null && currentSession.rawData != null) {
        profile = currentSession.rawData;
      } else {
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
        if ((priority == 'urgent' || priority == 'emergency') && status != 'done') {
          u++;
        }
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
    final isApproved = _authService.isApproved;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF01579B)),
        ),
      );
    }

    if (!isApproved) {
      return PendingApprovalOverlay(
        child: _buildFullDashboard(context),
        onLogout: widget.onLogout,
      );
    }

    return _buildFullDashboard(context);
  }

  Widget _buildFullDashboard(BuildContext context) {
    final double topSpacing = MediaQuery.of(context).size.height * 0.12;

    final List<Widget> pages = [
      _buildHomeContent(topSpacing),
      const AttendanceView(),
      const TaskListView(),
      const ProfileView(),
      const StockRequestListPage(),
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
    final localizations = AppLocalizations.of(context);
    
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () async {
        await _loadStaticData();
        await _loadTaskStats();
        await _loadEmployeeStats();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: topSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.operationHospitalPlatform ?? "Hospital Operational Intelligence Platform",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _hospitalData?['name']?.toUpperCase() ??
                      (localizations?.operationHospitalPlatform ?? "Hospital Operational Intelligence Platform"),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF01579B),
                    height: 1.1,
                  ),
                ),
                Text(
                  _hospitalData?['address'] ?? "Indonesia",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildRealtimeUserCard(),
          const SizedBox(height: 20),
          _buildControlRoomSection(),
          const SizedBox(height: 20),
          _buildMenuCategory(
            localizations?.operationOperational ?? "Operational",
            [
              // ✅ Menu Report Incident - SELALU TAMPIL
              _menuItemSmall(
                localizations?.opMenuReportIncident ?? "Lapor Insiden",
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
              // ✅ Conditional menus menggunakan kolom can_
              if (_profileData?['can_register_people'] == true)
                _menuItemSmall(
                  localizations?.opMenuRegisterPeopleRfid ?? "Registrasi Orang & RFID",
                  Icons.person_add_alt_1,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PeopleInputScreen(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_bed_assignment'] == true)
                _menuItemSmall(
                  localizations?.opMenuBedAssignment ?? "Penentuan Tempat Tidur",
                  Icons.bed,
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BedAssignmentScreen(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_bed_unassignment'] == true)
                _menuItemSmall(
                  localizations?.opMenuBedUnassignment ?? "Tempat Tidur Dikosongkan",
                  Icons.bed_rounded,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BedUnassignmentScreen(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_checkout_people'] == true)
                _menuItemSmall(
                  localizations?.opMenuCheckOutPeople ?? "Check Out People",
                  Icons.exit_to_app,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PeopleCheckoutScreen(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_asset_initial'] == true)
                _menuItemSmall(
                  localizations?.opMenuInitialAsset ?? "Inisialisasi Awal Asset",
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
              if (_profileData?['can_asset_inspection'] == true)
                _menuItemSmall(
                  localizations?.opMenuRoutineAssetInspection ?? "Inspeksi Rutin Asset",
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
              if (_profileData?['can_stock_initial'] == true)
                _menuItemSmall(
                  localizations?.opMenuInitialStock ?? "Inisialisasi Awal Stock",
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
              if (_profileData?['can_asset_request'] == true)
                _menuItemSmall(
                  localizations?.opMenuAssetRequest ?? "Permintaan Aset",
                  Icons.inventory_2_outlined,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeAssetRequestPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_return_asset'] == true)
                _menuItemSmall(
                  localizations?.opMenuReturnAsset ?? "Kembalikan Aset",
                  Icons.assignment_return_outlined,
                  Colors.deepOrange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeAssetReturnPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_stock_opname'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockOpname ?? "Stock Opname",
                  Icons.playlist_add_check_circle_outlined,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockBinOpnameView(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_stock_in'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockIn ?? "Stok Masuk",
                  Icons.input_rounded,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockInFormMobile(),
                      ),
                    ).then((_) {
                      _loadTaskStats();
                    });
                  },
                ),
              if (_profileData?['can_stock_placement'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockPlacement ?? "Penempatan Stok Pada Bin",
                  Icons.shelves,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingPutAwayList(),
                      ),
                    ).then((_) {
                      _loadTaskStats();
                    });
                  },
                ),
              if (_profileData?['can_stock_request'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockRequest ?? "Permintaan Stok",
                  Icons.request_page,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockRequestListPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_stock_request_approval'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockRequestApproval ?? "Persetujuan Permintaan Stok",
                  Icons.approval_rounded,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockRequestApprovalPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_stock_fulfillment'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockFulfillment ?? "Pengeluaran Stok Atas Permintaan",
                  Icons.approval_rounded,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockRequestFulfillmentPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_stock_write_off'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockWriteOff ?? "Pengeluaran Stok Atas Kadaluarsa/Rusak",
                  Icons.broken_image_outlined,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockWriteOffListPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_stock_write_off_approval'] == true)
                _menuItemSmall(
                  localizations?.opMenuStockWriteOffApproval ?? "Persetujuan Pengeluaran Stok Atas Kadaluarsa/Rusak",
                  Icons.approval_rounded,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockWriteOffApprovalPage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_building_reference'] == true)
                _menuItemSmall(
                  localizations?.opMenuBuildingReference ?? "Tabel Referensi Bangunan",
                  Icons.warehouse_outlined,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuildingMobilePage(),
                      ),
                    );
                  },
                ),
              if (_profileData?['can_bins_reference'] == true)
                _menuItemSmall(
                  localizations?.opMenuBinsReference ?? "Tabel Referensi Bins",
                  Icons.outbox,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockBinMobilePage(),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuCategory(
            localizations?.operationReports ?? "Reports",
            [
              _menuItemSmall(
                localizations?.opMenuWorkHistory ?? "Riwayat Pekerjaan",
                Icons.receipt_long_rounded,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReportsView(),
                    ),
                  );
                },
              ),
              _menuItemSmall(
                localizations?.opMenuTaskHistory ?? "Riwayat Tugas",
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
                localizations?.opMenuTaskReportHistory ?? "Riwayat Laporan Tugas",
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
                localizations?.opMenuAttendanceHistory ?? "Riwayat Absensi",
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
            ],
          ),
          const SizedBox(height: 16),
          _buildRosterReminderCard(),
          const SizedBox(height: 10),
          TodoMobileStreamView(
            profileId: _authService.currentUserId!,
            date: DateTime.now(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EmployeeStatsCard(
              totalPoints: _employeePoints,
              categoryScores: _categoryScores,
              fatigueScore: _fatigueScore,
              fatigueRiskLevel: _fatigueRiskLevel,
              period: _pointsPeriod,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildRosterReminderCard() {
    final rosterState = ref.watch(rosterStateProvider);

    if (rosterState.isLoading) {
      return const SizedBox.shrink();
    }

    if (!rosterState.hasRoster && !rosterState.isFlexibleRoster) {
      return const SizedBox.shrink();
    }

    return RosterReminderCard(state: rosterState);
  }

  Widget _buildRealtimeUserCard() {
    final userId = _authService.currentUserId;
    final localizations = AppLocalizations.of(context);

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
                              color: const Color(0xFF01579B).withValues(alpha: 0.15),
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
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _profileData?['full_name'] ?? widget.userName,
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
                                              color: isPresent ? Colors.green : Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isPresent
                                                  ? (localizations?.operationOnDuty ?? "BERTUGAS")
                                                  : (localizations?.operationOffDuty ?? "TIDAK BERTUGAS"),
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
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _languageToggle(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _miniStat("New", _newTasksCount, Colors.blue),
                                  const SizedBox(width: 22),
                                  _miniStat("On", _onGoingTasksCount, Colors.indigo),
                                  const SizedBox(width: 22),
                                  _miniStat("Urg", _urgentTasksCount, Colors.red),
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

  Widget _languageToggle() {
    final currentLocale = ref.watch(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _changeLocale(const Locale('en')),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEnglish ? const Color(0xFF01579B) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'EN',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnglish ? Colors.white : const Color(0xFF01579B),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _changeLocale(const Locale('id')),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: !isEnglish ? const Color(0xFF01579B) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: !isEnglish ? Colors.white : const Color(0xFF01579B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLocale(Locale locale) {
    ref.read(localeProvider.notifier).setLocale(locale);
  }

  Widget _miniStat(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$value",
          style: GoogleFonts.poppins(
            fontSize: 36,
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
          childAspectRatio: 0.9,
          children: items,
        ),
      ],
    );
  }

  Widget _menuItemSmall(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlRoomSection() {
    final userId = _authService.currentUserId;
    final localizations = AppLocalizations.of(context);
    
    if (userId == null || _profileData == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 25, 8),
          child: Text(
            localizations?.operationLatestAnnouncements ?? "LATEST ANNOUNCEMENTS",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: AnnouncementService().getFilteredAnnouncements(
              userId,
              _profileData?['position_id'],
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SizedBox();

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildAnnouncementBox(
                  title: localizations?.operationInfo ?? "INFO",
                  content: localizations?.operationNoAnnouncements ?? "Belum ada pesan baru dari pusat kontrol.",
                  priority: "normal",
                );
              }

              final announcements = snapshot.data!;
              final currentIds = announcements.map((a) => a['id'].toString()).toSet();
              final newAnnouncements = currentIds.difference(_previousAnnouncementIds);

              for (final newId in newAnnouncements) {
                final newAnn = announcements.firstWhere(
                  (a) => a['id'].toString() == newId,
                );
                final priority = newAnn['priority'] ?? 'normal';
                if (priority == 'urgent' || priority == 'emergency') {
                  _soundService.playNotificationSound(newId);
                }
              }

              _previousAnnouncementIds = currentIds;

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: announcements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ann = announcements[index];
                  return _buildAnnouncementBox(
                    title: ann['title'] ?? (localizations?.operationInfo ?? "INFO"),
                    content: ann['content'] ?? "",
                    priority: ann['priority'] ?? "normal",
                    time: _formatTime(ann['created_at']),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementBox({
    required String title,
    required String content,
    required String priority,
    String time = "Baru saja",
  }) {
    final localizations = AppLocalizations.of(context);
    bool isUrgent = priority == 'urgent' || priority == 'emergency';
    bool isInfo = priority == 'info' || priority == 'normal';

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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                isUrgent ? Icons.warning_amber_rounded : Icons.announcement_rounded,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    localizations?.operationUrgent ?? "URGENT",
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
    final localizations = AppLocalizations.of(context);
    
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
          _navIcon(Icons.home_filled, localizations?.operationBottomNavHome ?? "Home", 0),
          _navIcon(Icons.calendar_month, localizations?.operationBottomNavAttendance ?? "Absensi", 1),
          const SizedBox(width: 45),
          _navIcon(Icons.assignment, localizations?.operationBottomNavTasks ?? "Tasks", 2),
          _navIcon(Icons.person, localizations?.operationBottomNavProfile ?? "Profile", 3),
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
    final localizations = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Material(
        elevation: 6.0,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              enableDrag: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (context) => const DutyNoteBottomSheet(),
            );
          },
          child: Container(
            width: 65,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFF01579B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF01579B).withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  localizations?.operationNotes ?? "Notes",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    final localizations = AppLocalizations.of(context);
    
    if (timestamp == null) return localizations?.operationJustNow ?? "Baru saja";

    DateTime date;
    if (timestamp is DateTime) {
      date = timestamp;
    } else if (timestamp is String) {
      date = DateTime.parse(timestamp);
    } else {
      return localizations?.operationJustNow ?? "Baru saja";
    }

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return localizations?.operationJustNow ?? "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} ${localizations?.operationMinutesAgo ?? "menit lalu"}";
    if (diff.inHours < 24) {
      if (diff.inHours == 1) {
        return "1 ${localizations?.operationHourAgo ?? "jam lalu"}";
      }
      return "${diff.inHours} ${localizations?.operationHoursAgo ?? "jam lalu"}";
    }
    if (diff.inDays == 1) return localizations?.operationYesterday ?? "Kemarin";
    if (diff.inDays < 7) return "${diff.inDays} ${localizations?.operationDaysAgo ?? "hari lalu"}";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} ${localizations?.operationWeeksAgo ?? "minggu lalu"}";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} ${localizations?.operationMonthsAgo ?? "bulan lalu"}";
    return "${(diff.inDays / 365).floor()} ${localizations?.operationYearsAgo ?? "tahun lalu"}";
  }
}