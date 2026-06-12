// File: lib/views/monitor/monitor_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'people_watch_list.dart';
import 'asset_overview_screen.dart';
import 'general_people_map.dart';
import 'general_asset_map.dart';
import 'asset_intelligence_screen.dart';
import 'asset_report_screen.dart';
import 'stocks_intelligence_screen.dart';
import 'stock_report_screen.dart';
import '../../models/hospital_profile_model.dart';
import '../../../insights/hospital/views/hospital_overview_screen.dart';
import '../../../insights/hospital/views/human_ratio_screen.dart';

// IMPORT SUB-MENU PROFILES INSIGHTS
import '../../../insights/profiles/views/submenu1_ringkasan.dart';
import '../../../insights/profiles/views/submenu2_wellbeing.dart';
import '../../../insights/profiles/views/submenu3_lokasi_kehadiran.dart';
import '../../../insights/profiles/views/submenu4_sertifikasi_penilaian.dart';
import '../../../insights/profiles/views/submenu5_insight_pegawai.dart';
import '../../../insights/assets/views/asset_utilization_screen.dart';
import '../../../insights/assets/views/asset_tree_screen.dart';
import '../../../insights/stocks/views/stock_tree_view.dart';
import '../../../insights/stocks/views/stock_overview_screen.dart';
import '../../../insights/stocks/views/stock_requests_screen.dart';
import '../../../insights/stocks/views/stock_opname_screen.dart';
import '../../../insights/stocks/views/storage_distribution_screen.dart';
import '../../insights/stocks/views/storage_hierarchy_screen.dart';
import '../../../insights/hospital/views/incident_response_screen.dart';
import '../../../insights/hospital/views/occupancy_dashboard_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class MonitorDashboard extends ConsumerStatefulWidget {
  final String userName;
  final VoidCallback onLogout;

  const MonitorDashboard({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  ConsumerState<MonitorDashboard> createState() => _MonitorDashboardState();
}

class _MonitorDashboardState extends ConsumerState<MonitorDashboard> {
  final _supabase = Supabase.instance.client;

  String _selectedMenu = "Organization Overview";
  HospitalProfileModel? _hospitalProfile;

  bool _isSidebarVisible = true;

  final Color deepBlue = const Color(0xFF01579B);

  // CACHE MAP (tidak pernah rebuild)
  late final Widget _peopleMapView = const GeneralPeopleMap();
  late final Widget _assetMapView = const GeneralAssetMap();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _fetchHospitalProfile();
  }

  Future<void> _fetchHospitalProfile() async {
    try {
      final data = await _supabase
          .from('hospital_profile')
          .select()
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _hospitalProfile = HospitalProfileModel.fromJson(data);
        });
      }
    } catch (_) {}
  }

  void _handleLogout() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
      _,
    ) {
      widget.onLogout();
    });
  }

  void _changeLocale(Locale locale) {
    ref.read(localeProvider.notifier).setLocale(locale);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ======================
          // MAP FULLSCREEN (TIDAK PERNAH BERUBAH)
          // ======================
          Positioned.fill(child: _buildMainCanvas()),

          // ======================
          // SIDEBAR OVERLAY
          // ======================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: _isSidebarVisible ? 0 : -260,
            top: 0,
            bottom: 0,
            child: _buildSidebar(),
          ),

          // ======================
          // TOGGLE BUTTON
          // ======================
          Positioned(
            top: 20,
            left: _isSidebarVisible ? 10 : 10,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarVisible = !_isSidebarVisible;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isSidebarVisible ? Icons.arrow_back : Icons.menu,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================
  // SIDEBAR
  // ======================
  Widget _buildSidebar() {
    final localizations = AppLocalizations.of(context);
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.20),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF052D9C).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHospitalBrand(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(localizations?.monitor_section_organization_insights ?? "ORGANIZATION INSIGHTS"),
                      _menu(localizations?.monitor_menu_organization_overview ?? "Organization Overview", Icons.business_outlined),
                      _menu(localizations?.monitor_menu_human_ratio ?? "Human Ratio & Analytics", Icons.people_outline),
                      // Di dalam _sectionTitle "ORGANIZATION INSIGHTS" atau "HOSPITAL OPERATIONS"
                      _menu(localizations?.monitor_menu_bed_occupancy ?? "Bed Occupancy", Icons.bed),
                      _menu(localizations?.monitor_menu_incident_response ?? "Incident & Response", Icons.warning_amber),
                      const SizedBox(height: 24),
                      _sectionTitle(localizations?.monitor_section_people_insights ?? "PEOPLE INSIGHTS"),
                      _menu(localizations?.monitor_menu_employee_summary ?? "Ringkasan Pegawai", Icons.people_alt),
                      _menu(localizations?.monitor_menu_wellbeing_performance ?? "Wellbeing & Kinerja", Icons.favorite_outline),
                      _menu(localizations?.monitor_menu_location_attendance ?? "Lokasi & Kehadiran", Icons.location_on_outlined),
                      _menu(localizations?.monitor_menu_certification_assessment ?? "Sertifikasi & Penilaian", Icons.verified_outlined),
                      _menu(localizations?.monitor_menu_employee_insight ?? "Insight Pegawai", Icons.people_outline_outlined),
                      const SizedBox(height: 24),

                      _sectionTitle(localizations?.monitor_section_asset ?? "ASSET"),
                      _menu(localizations?.monitor_menu_asset_utilization ?? "Asset Utilization", Icons.speed),
                      _menu(localizations?.monitor_menu_live_asset_tracking ?? "Live Asset Tracking", Icons.inventory),
                      _menu(localizations?.monitor_menu_asset_by_taxonomy ?? "Asset by Taxonomy", Icons.account_tree),
                      _menu(localizations?.monitor_menu_asset_intelligence ?? "Asset Intelligence", Icons.bar_chart),
                      _menu(localizations?.monitor_menu_asset_report ?? "Asset Report", Icons.description),
                      const SizedBox(height: 24),

                      _sectionTitle(localizations?.monitor_section_stock_inventory ?? "STOCK & INVENTORY"),
                      _menu(localizations?.monitor_menu_stock_overview ?? "Stock Overview", Icons.inventory),
                      _menu(localizations?.monitor_menu_stock_tree_view ?? "Stock Tree View", Icons.account_tree),
                      _menu(localizations?.monitor_menu_stock_requests ?? "Stock Requests", Icons.request_page),
                      _menu(localizations?.monitor_menu_stock_opname ?? "Stock Opname", Icons.medical_information_outlined),
                      _menu(localizations?.monitor_menu_storage_distribution ?? "Storage Distribution", Icons.inventory_2_outlined),
                      _menu(localizations?.monitor_menu_storage_tree_view ?? "Storage Tree View", Icons.account_tree_outlined),
                      _menu(localizations?.monitor_menu_stock_intelligence ?? "Stock Intelligence", Icons.watch_later),
                      _menu(localizations?.monitor_menu_stock_report ?? "Stock Report", Icons.description),
                      const SizedBox(height: 24),

                      _sectionTitle(localizations?.monitor_section_people_tracking ?? "PEOPLE TRACKING"),
                      _menu(localizations?.monitor_menu_live_people_tracking ?? "Live People Tracking", Icons.language),
                      _menu(localizations?.monitor_menu_people_watch_list ?? "People Watch List", Icons.person),
                      const SizedBox(height: 24),

                      _sectionTitle(localizations?.monitor_section_system ?? "SYSTEM"),
                      _menu(localizations?.monitor_menu_logout ?? "Logout", Icons.logout, isLogout: true),

                      const SizedBox(height: 16),
                      
                      // LANGUAGE TOGGLE
                      _buildLanguageToggle(),
                      
                      const SizedBox(height: 16),
                      
                      Center(
                        child: Column(
                          children: [
                            Text(
                              localizations?.monitor_footer_developed_by ?? "Developed By : PLATFORM PELAYANAN TERBAIK",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizations?.monitor_footer_distributed_by ?? "Distributed By : PT. REKAMITRA",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localizations?.monitor_footer_year_country ?? "2026 - Indonesia",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 20),
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
    );
  }

  Widget _buildLanguageToggle() {
    final currentLocale = ref.watch(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';
    final localizations = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangButton(
            langCode: 'en',
            label: 'EN',
            isActive: isEnglish,
            onTap: () => _changeLocale(const Locale('en')),
          ),
          const SizedBox(width: 4),
          _buildLangButton(
            langCode: 'id',
            label: 'ID',
            isActive: !isEnglish,
            onTap: () => _changeLocale(const Locale('id')),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton({
    required String langCode,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10, top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _menu(String title, IconData icon, {bool isLogout = false}) {
    final active = _selectedMenu == title;

    return GestureDetector(
      onTap: () {
        if (isLogout) {
          _handleLogout();
        } else {
          setState(() {
            _selectedMenu = title;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active
              ? Border.all(color: Colors.white.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isLogout
                  ? const Color(0xFFEF4444)
                  : (active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: isLogout
                      ? const Color(0xFFEF4444)
                      : (active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7)),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalBrand() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child:
                _hospitalProfile?.logoUrl != null &&
                    _hospitalProfile!.logoUrl!.isNotEmpty
                ? Image.network(
                    _hospitalProfile!.logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 42,
                      );
                    },
                  )
                : Icon(Icons.local_hospital, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 14),
          Text(
            _hospitalProfile?.name ?? 'HOSPITAL HUMAN ASSET TRACKING SYSTEM',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              height: 1.35,
              letterSpacing: 0.2,
              color: Colors.white,
            ),
          ),
          if (_hospitalProfile?.address != null &&
              _hospitalProfile!.address!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _hospitalProfile!.address!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ======================
  // MAIN CANVAS
  // ======================
  Widget _buildMainCanvas() {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [Color(0xFF052D9C), Color(0xFF1E3A8A)],
              ),
            ),
            child: _getBody(),
          ),
        ),
      ),
    );
  }

  // ======================
  // GET BODY BASED ON SELECTED MENU
  // ======================
  Widget _getBody() {
    final localizations = AppLocalizations.of(context);
    
    if (_selectedMenu == (localizations?.monitor_menu_organization_overview ?? "Organization Overview")) {
      return const HospitalOverviewScreen();
    }
    if (_selectedMenu == (localizations?.monitor_menu_bed_occupancy ?? "Bed Occupancy")) {
      return const OccupancyDashboardScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_incident_response ?? "Incident & Response")) {
      return const IncidentResponseScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_employee_summary ?? "Ringkasan Pegawai")) {
      return const Submenu1Ringkasan();
    }

    if (_selectedMenu == (localizations?.monitor_menu_human_ratio ?? "Human Ratio & Analytics")) {
      return const HumanRatioScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_wellbeing_performance ?? "Wellbeing & Kinerja")) {
      return const Submenu2Wellbeing();
    }

    if (_selectedMenu == (localizations?.monitor_menu_location_attendance ?? "Lokasi & Kehadiran")) {
      return const Submenu3LokasiKehadiran();
    }

    if (_selectedMenu == (localizations?.monitor_menu_certification_assessment ?? "Sertifikasi & Penilaian")) {
      return const Submenu4SertifikasiPenilaian();
    }

    if (_selectedMenu == (localizations?.monitor_menu_employee_insight ?? "Insight Pegawai")) {
      return const Submenu5InsightPegawai();
    }

    if (_selectedMenu == (localizations?.monitor_menu_live_people_tracking ?? "Live People Tracking")) {
      return _peopleMapView;
    }

    if (_selectedMenu == (localizations?.monitor_menu_live_asset_tracking ?? "Live Asset Tracking")) {
      return _assetMapView;
    }

    if (_selectedMenu == (localizations?.monitor_menu_people_watch_list ?? "People Watch List")) {
      return const PeopleWatchList();
    }

    if (_selectedMenu == "Asset Overview") {
      return const AssetOverviewScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_asset_by_taxonomy ?? "Asset by Taxonomy")) {
      return const AssetTreeScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_asset_intelligence ?? "Asset Intelligence")) {
      return const AssetIntelligenceScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_asset_utilization ?? "Asset Utilization")) {
      return const AssetUtilizationScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_asset_report ?? "Asset Report")) {
      return const AssetReportScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_stock_overview ?? "Stock Overview")) {
      return const StockOverviewScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_stock_tree_view ?? "Stock Tree View")) {
      return const StockTreeView();
    }

    if (_selectedMenu == (localizations?.monitor_menu_stock_opname ?? "Stock Opname")) {
      return const StockOpnameScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_storage_distribution ?? "Storage Distribution")) {
      return const StorageDistributionScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_storage_tree_view ?? "Storage Tree View")) {
      return const StorageHierarchyScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_stock_requests ?? "Stock Requests")) {
      return const StockRequestsScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_stock_intelligence ?? "Stock Intelligence")) {
      return const StocksIntelligenceScreen();
    }

    if (_selectedMenu == (localizations?.monitor_menu_stock_report ?? "Stock Report")) {
      return const StockReportScreen();
    }

    // DEFAULT
    return Center(
      child: Text(
        localizations?.monitor_empty_state ?? "EMPTY",
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      ),
    );
  }
}