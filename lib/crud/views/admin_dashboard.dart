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
import '../../features/asset_assignment/views/admin/admin_asset_verification_page.dart';
import '../../features/asset_report/views/asset_report_page.dart';
import '../../features/stock/views/stock_write_off_approval_page.dart';
// import '../../features/stock_in/presentations/stock_in_form_admin.dart';
import '../../features/stock_in/presentations/stock_in_list_screen.dart';
import '../../features/stock_in_bins/presentations/pending_put_away_admin_list.dart';


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

  final List<MenuGroup> _menuGroups = [
    MenuGroup(
      title: "MASTER DATA",
      icon: Icons.storage,
      menus: [
        MenuItem("Data Pegawai", Icons.people, EmployeeTable()),
        // ← Tambahkan menu Data Asset di sini
        // MenuItem("Data Asset", Icons.inventory_2, const AssetPage()),
      ],
    ),
    MenuGroup(
      title: "MANAJEMEN ASSET",  // ← Group baru untuk Asset Management
      icon: Icons.inventory,
      menus: [
        MenuItem("Daftar Asset", Icons.inventory_2, const AssetListPage()),
         MenuItem("Persetujuan Pemakaian Aset", Icons.verified, const AdminAssetVerificationPage()),
         MenuItem("Laporan Aset", Icons.receipt_long, const AssetReportPage()), // ← TAMBAHKAN
        // MenuItem("Kategori Asset", Icons.category, null), // Placeholder untuk nanti
        // MenuItem("Inspeksi Asset", Icons.assignment_turned_in, null), // Placeholder untuk nanti
        // MenuItem("Laporan Asset", Icons.assessment, null), // Placeholder untuk nanti
      ],
    ),
    MenuGroup(
      title: "MANAJEMEN STOK/INVENTORI",  // ← Group baru untuk Asset Management
      icon: Icons.inventory,
      menus: [
        MenuItem("Daftar Stok", Icons.inventory_2, const StockListPage()),
        MenuItem("Stok Masuk", Icons.input, const StockInListScreen()),
        MenuItem("Stok Yang Belum DItempatkan", Icons.pending, const PendingPutAwayAdminList()),
        MenuItem("Persetujuan Penghapusan Stok", Icons.check_circle, const StockWriteOffApprovalPage()),
        // MenuItem("Inspeksi Stok", Icons.assignment_turned_in, null), // Placeholder untuk nanti
        // MenuItem("Laporan Asset", Icons.assessment, null), // Placeholder untuk nanti
      ],
    ),
    MenuGroup(
      title: "OPERASIONAL",
      icon: Icons.work,
      menus: [
        MenuItem("Penjadwalan", Icons.calendar_today, const RosterPage()),
        MenuItem("Pengumuman", Icons.assignment, AnnouncementsTable()),
        MenuItem("Penugasan", Icons.assignment, TasksTable()),
      ],
    ),
    MenuGroup(
      title: "SYSTEM",
      icon: Icons.settings,
      menus: [
        MenuItem("Logout", Icons.logout, null, true),
      ],
    ),
  ];

  final Set<String> _expandedGroups = {"MASTER DATA", "OPERASIONAL", "MANAJEMEN ASSET"}; // ← Tambahkan group baru

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
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          // ========== SIDEBAR ==========
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarVisible ? 260 : 0,
            child: _isSidebarVisible ? _buildSidebar() : const SizedBox.shrink(),
          ),

          // ========== MAIN CONTENT ==========
          Expanded(
            child: _buildMainCanvas(),
          ),
        ],
      ),
    );
  }

  // ======================
  // SIDEBAR
  // ======================
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
              color: isExpanded ? deepBlue.withOpacity(0.08) : Colors.transparent,
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
        if (isExpanded)
          Column(
            children: group.menus.map((menu) => _buildMenuItem(menu)).toList(),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem menu) {
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
        margin: const EdgeInsets.only(left: 30, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? deepBlue.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(menu.icon, size: 16, color: isLogout ? Colors.red : (isSelected ? deepBlue : Colors.grey.shade600)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                menu.title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isLogout ? Colors.red : (isSelected ? deepBlue : Colors.grey.shade800),
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
            child: _hospitalProfile?.logoUrl != null && _hospitalProfile!.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _hospitalProfile!.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.local_hospital, color: deepBlue, size: 32);
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
            style: GoogleFonts.poppins(fontSize: 7, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            "Distributed By: PT. REKAMITRA",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 7, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            "2026 - Indonesia",
            style: GoogleFonts.poppins(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ======================
  // MAIN CANVAS
  // ======================
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
          // Konten Utama
          Padding(
            padding: const EdgeInsets.all(16),
            child: _getBody(),
          ),
          
          // Tombol Toggle Sidebar (hanya muncul saat sidebar tertutup)
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
    for (var group in _menuGroups) {
      for (var menu in group.menus) {
        if (menu.title == _selectedMenu && menu.widget != null) {
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: menu.widget!,
            ),
          );
        }
      }
    }
    return const Center(child: Text("Pilih menu dari sidebar"));
  }
}

class MenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;
  MenuGroup({required this.title, required this.icon, required this.menus});
}

class MenuItem {
  final String title;
  final IconData icon;
  final Widget? widget;
  final bool isLogout;
  MenuItem(this.title, this.icon, this.widget, [this.isLogout = false]);
}