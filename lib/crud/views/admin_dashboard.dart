// lib/crud/views/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../../models/hospital_profile_model.dart';
import '../configs/table_configs.dart';
import '../widgets/dynamic_pluto_grid.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  String _selectedTable = "employee_shift_rosters";
  HospitalProfileModel? _hospitalProfile;
  bool _isSidebarVisible = true;
  final Color deepBlue = const Color(0xFF01579B);
  
  // Expanded menu groups
  final Set<String> _expandedGroups = {};

  // Menu Group Definition
  final List<MenuGroup> _menuGroups = [
    MenuGroup(
      title: "📁 OPERATIONAL DATA",
      icon: Icons.work,
      menus: [
        MenuItem("Jadwal Kerja", Icons.calendar_month, "employee_shift_rosters"),
        MenuItem("Penugasan", Icons.assignment, "tasks"),
        MenuItem("Laporan Tugas", Icons.receipt, "tasks_reports"),
        MenuItem("Pemberitahuan", Icons.announcement, "announcements"),
        MenuItem("Catatan Dinas", Icons.note, "duty_notes"),
        MenuItem("Insiden", Icons.warning_amber, "incidents"),
      ],
    ),
    MenuGroup(
      title: "📁 HRD DATA",
      icon: Icons.people,
      menus: [
        MenuItem("Data Pegawai", Icons.person, "profiles"),
        MenuItem("Unit Kerja", Icons.business, "employee_units"),
        MenuItem("Posisi/Jabatan", Icons.work_history, "ref_positions"),
        MenuItem("Kualifikasi Pegawai", Icons.school, "employee_qualifications"),
        MenuItem("Assignment Kualifikasi", Icons.assignment_ind, "employee_qualification_assignments"),
        MenuItem("Pengajuan Cuti", Icons.beach_access, "employee_leave_requests"),
        MenuItem("Tipe Cuti", Icons.category, "leave_types"),
        MenuItem("Scoring Pegawai", Icons.star, "employee_scoring"),
        MenuItem("Kategori Scoring", Icons.star_border, "scoring_categories"),
        MenuItem("Wellbeing Log", Icons.favorite, "employee_wellbeing_logs"),
      ],
    ),
    MenuGroup(
      title: "📁 LOGISTIC DATA",
      icon: Icons.inventory,
      menus: [
        MenuItem("Asset", Icons.inventory_2, "assets"),
        MenuItem("Tipe Asset", Icons.category, "ref_asset_types"),
        MenuItem("Kategori Asset", Icons.folder, "ref_asset_categories"),
        MenuItem("Sub Kategori Asset", Icons.subdirectory_arrow_right, "ref_asset_sub_categories"),
        MenuItem("Inspeksi Asset", Icons.fact_check, "asset_inspections"),
        MenuItem("Assignment Asset", Icons.assignment, "asset_assignments"),
        MenuItem("Pergerakan Asset", Icons.timeline, "asset_movements"),
        MenuItem("Stock", Icons.warehouse, "stocks"),
        MenuItem("Tipe Stock", Icons.label, "ref_stock_types"),
        MenuItem("Opname Stock", Icons.playlist_add_check, "stocks_opnames"),
        MenuItem("Pembelian Stock", Icons.shopping_cart, "stock_purchases"),
        MenuItem("Transaksi Stock", Icons.swap_horiz, "stock_transactions"),
        MenuItem("Penggunaan Stock", Icons.remove_shopping_cart, "stock_usages"),
        MenuItem("Lokasi Penyimpanan", Icons.location_on, "storage_locations"),
        // Warehousing
        MenuItem("Zona Gudang", Icons.map, "warehouse_zones"),
        MenuItem("Rak Penyimpanan", Icons.shelves, "storage_racks"),
        MenuItem("Level Rak", Icons.view_agenda, "rack_levels"),
        MenuItem("Bin/Slot", Icons.grid_view, "storage_bins"),
        MenuItem("Pergerakan Bin", Icons.move_to_inbox, "stock_bin_movements"),
      ],
    ),
    MenuGroup(
      title: "📁 HOSPITAL INITIAL",
      icon: Icons.local_hospital,
      menus: [
        MenuItem("Gedung", Icons.business, "buildings"),
        MenuItem("Lantai", Icons.layers, "floors"),
        MenuItem("Ruangan", Icons.door_front_door, "rooms"),
        MenuItem("Kategori Ruangan", Icons.category, "ref_room_categories"),
        MenuItem("Fungsi Gedung", Icons.apartment, "ref_building_functions"),
        MenuItem("Detektor", Icons.sensors, "detectors"),
        MenuItem("Lokasi Tracking", Icons.gps_fixed, "employee_location_tracking"),
        MenuItem("Pergerakan People", Icons.directions_walk, "people_movements"),
      ],
    ),
    MenuGroup(
      title: "📁 REFERENSI DATA",
      icon: Icons.dataset,
      menus: [
        MenuItem("Shift Kerja", Icons.schedule, "ref_shifts"),
        MenuItem("Tipe Tugas", Icons.task, "ref_task_types"),
        MenuItem("Kategori Insiden", Icons.warning, "ref_incident_categories"),
        MenuItem("Kategori People", Icons.group, "ref_people_categories"),
        MenuItem("Kategori Laporan", Icons.report, "ref_reports_category"),
        MenuItem("People", Icons.people_outline, "people"),
        MenuItem("Spatial Ref", Icons.map, "spatial_ref_sys"),
      ],
    ),
    MenuGroup(
      title: "🔒 SYSTEM (Super Admin Only)",
      icon: Icons.settings,
      isDisabled: true,
      menus: [
        MenuItem("App Config", Icons.app_settings_alt, "apps_config"),
        MenuItem("Hospital Profile", Icons.local_hospital_outlined, "hospital_profile"),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _fetchHospitalProfile();
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
      Navigator.pop(context);
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(child: _buildMainCanvas()),
          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: _isSidebarVisible ? 0 : -280,
            top: 0,
            bottom: 0,
            child: _buildSidebar(),
          ),
          // Toggle Button
          Positioned(
            top: 20,
            left: _isSidebarVisible ? 10 : 10,
            child: GestureDetector(
              onTap: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 93, 160, 177),
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

  Widget _buildSidebar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.20),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 36, 86, 194).withOpacity(0.15),
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._menuGroups.map((group) => _buildMenuGroup(group)),
                      const SizedBox(height: 30),
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

  Widget _buildMenuGroup(MenuGroup group) {
    final isExpanded = _expandedGroups.contains(group.title);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        GestureDetector(
          onTap: group.isDisabled ? null : () => _toggleGroup(group.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isExpanded ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  group.icon,
                  size: 18,
                  color: group.isDisabled ? Colors.grey : Colors.black54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: group.isDisabled ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: group.isDisabled ? Colors.grey : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        // Menu Items (if expanded)
        if (isExpanded)
          Column(
            children: group.menus.map((menu) => _buildMenuItem(menu)).toList(),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem menu) {
    final isSelected = _selectedTable == menu.tableName;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTable = menu.tableName;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 32, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(menu.icon, size: 16, color: isSelected ? deepBlue : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                menu.title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? deepBlue : Colors.black54,
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
            width: 60,
            height: 60,
            child: _hospitalProfile?.logoUrl != null && _hospitalProfile!.logoUrl!.isNotEmpty
                ? Image.network(_hospitalProfile!.logoUrl!, fit: BoxFit.contain)
                : Icon(Icons.local_hospital, color: deepBlue, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            _hospitalProfile?.name ?? 'HOSPITAL HUMAN ASSET TRACKING SYSTEM',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 11, color: deepBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text("Developed By : PLATFORM PELAYANAN TERBAIK", style: GoogleFonts.poppins(fontSize: 7)),
          Text("Distributed By : PT. REKAMITRA", style: GoogleFonts.poppins(fontSize: 7)),
          Text("2026 - Indonesia", style: GoogleFonts.poppins(fontSize: 7, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMainCanvas() {
  final config = tableConfigs[_selectedTable];
  
  if (config == null) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
        ),
      ),
      child: Center(
        child: Text(
          "Konfigurasi tabel '$_selectedTable' tidak ditemukan",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
  
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
      ),
    ),
    child: DynamicPlutoGrid(
      tableName: _selectedTable,
      config: config,
    ),
  );
}
}

// Models
class MenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;
  final bool isDisabled;
  
  MenuGroup({required this.title, required this.icon, required this.menus, this.isDisabled = false});
}

class MenuItem {
  final String title;
  final IconData icon;
  final String tableName;
  
  MenuItem(this.title, this.icon, this.tableName);
}