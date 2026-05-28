import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../models/hospital_profile_model.dart';
import 'tables/employee_table.dart';
import 'tables/tasks_table.dart';
import 'tables/announcements_table.dart';
import '../../crud/roster/presentation/pages/roster_page.dart';
import '../../crud/assets/presentation/pages/asset_list_page.dart';
import '../../crud/stocks/presentation/pages/stock_list_page.dart';
import '../../crud/ref_asset_categories/views/ref_asset_category_list.dart';
import '../../crud/ref_asset_sub_categories/views/ref_asset_sub_category_list.dart';
import '../../crud/ref_asset_types/views/ref_asset_type_list.dart';
import '../../crud/ref_stock_categories/views/ref_stock_category_list.dart';
import '../../crud/ref_stock_sub_categories/views/ref_stock_sub_category_list.dart';
import '../../crud/ref_stock_types/views/ref_stock_type_list.dart';
import '../../crud/ref_building_functions/views/ref_building_function_list.dart';
import '../../crud/buildings/views/building_list.dart';
import '../../crud/floors/views/floor_list.dart';
import '../../crud/rooms/views/room_list.dart';
import '../../crud/ref_room_categories/views/ref_room_category_list.dart';
import '../../features/asset_assignment/views/admin/admin_asset_verification_page.dart';
import '../../features/asset_report/views/asset_report_page.dart';
import '../../features/stock/views/stock_write_off_approval_page.dart';
import '../../features/stock/views/stock_mutation_view.dart';
import '../../features/stock_in/presentations/stock_in_list_screen.dart';
import '../../features/stock_in_bins/presentations/pending_put_away_admin_list.dart';

import '../../crud/stock_warehouses/views/stock_warehouse_list.dart';
import '../../crud/stock_zones/views/stock_zone_list.dart';
import '../../crud/stock_racks/views/stock_rack_list.dart';
import '../../crud/stock_shelves/views/stock_shelf_list.dart';
import '../../crud/stock_bins/views/stock_bin_list.dart';

import '../../crud/employee_qualifications/views/employee_qualification_list.dart';
import '../../crud/scoring_categories/views/scoring_category_list.dart';
import '../../crud/leave_types/views/leave_type_list.dart';
import '../../crud/ref_incident_categories/views/ref_incident_category_list.dart';
import '../../crud/employee_units/views/employee_unit_list.dart';
import '../../crud/ref_people_categories/views/ref_people_category_list.dart';
import '../../crud/ref_positions/views/ref_position_list.dart';
import '../../crud/ref_reports_category/views/ref_reports_category_list.dart';
// import '../../crud/admin_accidents/views/accident_list.dart';
import '../../crud/ref_shifts/views/ref_shift_list.dart';
// import '../../crud/admin_incidents/views/incident_list_admin.dart';
import '../../crud/todos/views/todo_list.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const AdminDashboard({super.key, required this.onLogout});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  HospitalProfileModel? _hospitalProfile;
  bool _isSidebarVisible = true;
  final Color deepBlue = const Color(0xFF01579B);

  String _selectedMenu = "Data Pegawai";

  // Track expanded state untuk sub-menu
  final Set<String> _expandedSubMenus = {};

  final List<MenuGroup> _menuGroups = [
    MenuGroup(
      title: "MASTER DATA",
      icon: Icons.storage,
      menus: [
        MenuItem("Data Pegawai", Icons.people, EmployeeTable()),
        MenuItem(
          "Daftar Kualifikasi Pegawai",
          Icons.badge,
          const EmployeeQualificationListPage(),
        ),
        MenuItem(
          "Kategori Penilaian (Scoring)",
          Icons.score,
          const ScoringCategoryListPage(),
        ),
        MenuItem(
          "Jenis-jenis Cuti",
          Icons.calendar_today,
          const LeaveTypeListPage(),
        ),
        MenuItem(
          "Kategori Insiden",
          Icons.warning,
          const RefIncidentCategoryListPage(),
        ),
        MenuItem(
          "Klasifikasi Orang/People Dalam Sistem",
          Icons.people,
          const RefPeopleCategoryListPage(),
        ),
        MenuItem("Posisi/Jabatan", Icons.work, const RefPositionListPage()),
        MenuItem(
          "Kategori Laporan Pegawai",
          Icons.description,
          const RefReportsCategoryListPage(),
        ),
        MenuItem(
          "Daftar Shift Kerja",
          Icons.schedule,
          const RefShiftListPage(),
        ),
      ],
    ),
    MenuGroup(
      title: "MANAJEMEN ASSET",
      icon: Icons.inventory,
      menus: [
        MenuItem("Daftar Asset", Icons.inventory_2, const AssetListPage()),
        MenuItem(
          "Persetujuan Pemakaian Aset",
          Icons.verified,
          const AdminAssetVerificationPage(),
        ),
        MenuItem("Laporan Aset", Icons.receipt_long, const AssetReportPage()),
      ],
    ),
    MenuGroup(
      title: "MANAJEMEN STOK/INVENTORI",
      icon: Icons.inventory,
      menus: [
        MenuItem("Daftar Stok", Icons.inventory_2, const StockListPage()),
        MenuItem("Stok Masuk", Icons.input, const StockInListScreen()),
        MenuItem(
          "Stok Yang Belum DItempatkan",
          Icons.pending,
          const PendingPutAwayAdminList(),
        ),
        MenuItem(
          "Persetujuan Penghapusan Stok",
          Icons.check_circle,
          const StockWriteOffApprovalPage(),
        ),
        MenuItem(
          "Mutasi Stok",
          Icons.assignment_turned_in,
          const StockMutationView(),
        ),
      ],
    ),
    MenuGroup(
      title: "OPERASIONAL",
      icon: Icons.work,
      menus: [
        MenuItem("Penjadwalan", Icons.calendar_today, const RosterPage()),
        MenuItem("Pengumuman", Icons.assignment, AnnouncementsTable()),
        MenuItem("Penugasan", Icons.assignment, TasksTable()),
        MenuItem("To Do", Icons.checklist, const TodoListPage()),
        // MenuItem("Penanganan Atas Laporan ", Icons.assignment, IncidentListAdmin()),
        // MenuItem("Daftar Penanganan Laporan ", Icons.assignment, AccidentList()),
      ],
    ),
    MenuGroup(
      title: "TABEL REFERENSI",
      icon: Icons.table_chart,
      subMenus: [
        SubMenuGroup(
          title: "ASSET REF",
          icon: Icons.category,
          menus: [
            MenuItem(
              "Kategori Aset",
              Icons.category,
              const RefAssetCategoryListPage(),
            ),
            MenuItem(
              "Sub-Kategori Aset",
              Icons.subdirectory_arrow_right,
              const RefAssetSubCategoryListPage(),
            ),
            MenuItem("Tipe Aset", Icons.devices, const RefAssetTypeListPage()),
          ],
        ),
        SubMenuGroup(
          title: "STOK REF",
          icon: Icons.inventory_2,
          menus: [
            MenuItem(
              "Kategori Stok",
              Icons.inventory_2,
              const RefStockCategoryListPage(),
            ),
            MenuItem(
              "Sub-Kategori Stok",
              Icons.subdirectory_arrow_right,
              const RefStockSubCategoryListPage(),
            ),
            MenuItem("Tipe Stok", Icons.label, const RefStockTypeListPage()),
            // MenuItem("Sub-Kategori Stok", Icons.subdirectory_arrow_right, null),
            // MenuItem("Tipe Stok", Icons.devices, null),
          ],
        ),
        SubMenuGroup(
          title: "HIRARKI LOKASI",
          icon: Icons.broadcast_on_personal_sharp,
          menus: [
            MenuItem(
              "Fungsi Khusus Gedung",
              Icons.functions_rounded,
              const RefBuildingFunctionListPage(),
            ),
            MenuItem(
              "Kategori Ruangan/Kamar",
              Icons.room_preferences,
              const RefRoomCategoryListPage(),
            ),
            MenuItem(
              "Gedung / Bangunan",
              Icons.business,
              const BuildingListPage(),
            ),
            MenuItem(
              "Lantai",
              Icons.format_list_numbered_rounded,
              const FloorListPage(),
            ),
            MenuItem("Ruangan", Icons.room, const RoomListPage()),
            // MenuItem("Sub-Kategori Stok", Icons.subdirectory_arrow_right, null),
            // MenuItem("Tipe Stok", Icons.devices, null),
          ],
        ),
        SubMenuGroup(
          title: "HiIRARKI GUDANG PENYIMPANAN",
          icon: Icons.broadcast_on_personal_sharp,
          menus: [
            MenuItem("Gudang", Icons.warehouse, const StockWarehouseListPage()),
            MenuItem(
              "Zona Penyimpanan",
              Icons.zoom_out_map_rounded,
              const StockZoneListPage(),
            ),
            MenuItem("Ruangan", Icons.room, const RoomListPage()),
            MenuItem(
              "Lemari Rak",
              Icons.archive_outlined,
              const StockRackListPage(),
            ),
            MenuItem(
              "Shelf / Rak Level",
              Icons.border_top_sharp,
              const StockShelfListPage(),
            ),
            MenuItem("Bin / Box", Icons.inbox, const StockBinListPage()),
          ],
        ),
        // Nanti bisa ditambah:
        SubMenuGroup(
          title: "REFERENSI KEPEGAWAIAN DAN UMUM",
          icon: Icons.location_on,
          menus: [
            MenuItem(
              "Unit / Departemen",
              Icons.business_center,
              const EmployeeUnitListPage(),
            ),
            MenuItem(
              "Daftar Kualifikasi Pegawai",
              Icons.badge,
              const EmployeeQualificationListPage(),
            ),
            MenuItem(
              "Kategori Penilaian (Scoring)",
              Icons.score,
              const ScoringCategoryListPage(),
            ),
            MenuItem(
              "Jenis-jenis Cuti",
              Icons.calendar_today,
              const LeaveTypeListPage(),
            ),
            MenuItem(
              "Kategori Insiden",
              Icons.warning,
              const RefIncidentCategoryListPage(),
            ),
            MenuItem(
              "Klasifikasi Orang/People Dalam Sistem",
              Icons.people,
              const RefPeopleCategoryListPage(),
            ),
            MenuItem("Posisi/Jabatan", Icons.work, const RefPositionListPage()),
            MenuItem(
              "Kategori Laporan Pegawai",
              Icons.description,
              const RefReportsCategoryListPage(),
            ),
            MenuItem(
              "Daftar Shift Kerja",
              Icons.schedule,
              const RefShiftListPage(),
            ),
          ],
        ),
        // SubMenuGroup(
        //   title: "SUPPLIER REF",
        //   icon: Icons.local_shipping,
        //   menus: [
        //     MenuItem("Vendor", Icons.store, null),
        //   ],
        // ),
      ],
    ),
    MenuGroup(
      title: "SYSTEM",
      icon: Icons.settings,
      menus: [MenuItem("Logout", Icons.logout, null, true)],
    ),
  ];

  final Set<String> _expandedGroups = {
    "MASTER DATA",
    "OPERASIONAL",
    "MANAJEMEN ASSET",
    "TABEL REFERENSI", // ← tambahkan agar terbuka default
  };

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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              widget.onLogout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _toggleGroup(String groupTitle) {
    setState(() {
      if (_expandedGroups.contains(groupTitle)) {
        _expandedGroups.remove(groupTitle);
      } else {
        _expandedGroups.add(groupTitle);
      }
    });
  }

  void _toggleSubMenu(String subMenuTitle) {
    setState(() {
      if (_expandedSubMenus.contains(subMenuTitle)) {
        _expandedSubMenus.remove(subMenuTitle);
      } else {
        _expandedSubMenus.add(subMenuTitle);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarVisible ? 260 : 0,
            child: _isSidebarVisible
                ? _buildSidebar()
                : const SizedBox.shrink(),
          ),
          Expanded(child: _buildMainCanvas()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: deepBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSidebarHeader(),
              _buildHospitalBrand(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._menuGroups.map((group) => _buildMenuGroup(group)),
                      const SizedBox(height: 32),
                      _buildFooter(),
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

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.menu, size: 18, color: deepBlue),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSidebarVisible = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_left, size: 24, color: deepBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(MenuGroup group) {
    final isExpanded = _expandedGroups.contains(group.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleGroup(group.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isExpanded
                  ? deepBlue.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(group.icon, size: 18, color: deepBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    group.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: deepBlue,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: deepBlue,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          // Untuk group dengan subMenus (nested)
          if (group.subMenus.isNotEmpty)
            ...group.subMenus.map((subMenu) => _buildSubMenuGroup(subMenu)),
          // Untuk group dengan menus biasa
          if (group.menus.isNotEmpty)
            ...group.menus.map((menu) => _buildMenuItem(menu)),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubMenuGroup(SubMenuGroup subMenu) {
    final isExpanded = _expandedSubMenus.contains(subMenu.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleSubMenu(subMenu.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: isExpanded
                  ? deepBlue.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(subMenu.icon, size: 16, color: deepBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subMenu.title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: deepBlue,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: deepBlue,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Column(
            children: subMenu.menus
                .map((menu) => _buildMenuItem(menu, indent: 48))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem menu, {double indent = 30}) {
    final isSelected = _selectedMenu == menu.title;
    final isLogout = menu.isLogout;

    return GestureDetector(
      onTap: () {
        if (isLogout) {
          _handleLogout();
        } else {
          setState(() {
            _selectedMenu = menu.title;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: indent, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? deepBlue.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              menu.icon,
              size: 16,
              color: isLogout
                  ? Colors.red
                  : (isSelected ? deepBlue : Colors.grey.shade600),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                menu.title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isLogout
                      ? Colors.red
                      : (isSelected ? deepBlue : Colors.grey.shade800),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                _hospitalProfile?.logoUrl != null &&
                    _hospitalProfile!.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _hospitalProfile!.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_hospital,
                          color: deepBlue,
                          size: 32,
                        );
                      },
                    ),
                  )
                : Icon(Icons.local_hospital, color: deepBlue, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            _hospitalProfile?.name ?? 'HOSPITAL SYSTEM',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: deepBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            "Developed By: PLATFORM PELAYANAN TERBAIK",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 7,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Distributed By: PT. REKAMITRA",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 7,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "2026 - Indonesia",
            style: GoogleFonts.poppins(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMainCanvas() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
        ),
      ),
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: _getBody()),
          if (!_isSidebarVisible)
            Positioned(
              top: 20,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSidebarVisible = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: deepBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getBody() {
    // Cari menu yang dipilih dari semua group dan subMenu
    for (var group in _menuGroups) {
      // Cek di menus biasa
      for (var menu in group.menus) {
        if (menu.title == _selectedMenu && menu.widget != null) {
          return _buildContentContainer(menu.widget!);
        }
      }
      // Cek di subMenus
      for (var subMenu in group.subMenus) {
        for (var menu in subMenu.menus) {
          if (menu.title == _selectedMenu && menu.widget != null) {
            return _buildContentContainer(menu.widget!);
          }
        }
      }
    }
    return const Center(child: Text("Pilih menu dari sidebar"));
  }

  Widget _buildContentContainer(Widget widget) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: widget),
    );
  }
}

// ======================
// MODEL CLASSES
// ======================

class MenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;
  final List<SubMenuGroup> subMenus;

  MenuGroup({
    required this.title,
    required this.icon,
    this.menus = const [],
    this.subMenus = const [],
  });
}

class SubMenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;

  SubMenuGroup({required this.title, required this.icon, required this.menus});
}

class MenuItem {
  final String title;
  final IconData icon;
  final Widget? widget;
  final bool isLogout;

  MenuItem(this.title, this.icon, this.widget, [this.isLogout = false]);
}
