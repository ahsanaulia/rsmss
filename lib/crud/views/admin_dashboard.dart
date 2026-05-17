import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../models/hospital_profile_model.dart';
import 'tables/employee_table.dart';
import 'tables/tasks_table.dart';  // ← TAMBAHKAN IMPORT
import 'tables/announcements_table.dart';  // ← TAMBAHKAN IMPORT
class AdminDashboard extends ConsumerStatefulWidget {

  final VoidCallback onLogout;  // ← Tambahkan ini
  
  const AdminDashboard({super.key,required this.onLogout,});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  HospitalProfileModel? _hospitalProfile;
  bool _isSidebarVisible = true;
  final Color deepBlue = const Color(0xFF01579B);

  String _selectedMenu = "Data Pegawai";

  // Menu groups dengan struktur expandable
  final List<MenuGroup> _menuGroups = [
    MenuGroup(
      title: "MASTER DATA",
      icon: Icons.storage,
      menus: [
        MenuItem("Data Pegawai", Icons.people, EmployeeTable()),
      ],
    ),
    MenuGroup(
      title: "OPERASIONAL",
      icon: Icons.work,
      menus: [
        MenuItem("Pengumuman", Icons.assignment, AnnouncementsTable()),
        MenuItem("Penugasan", Icons.assignment, TasksTable()),  // ← TAMBAHKAN
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

  // Expanded groups state
  final Set<String> _expandedGroups = {"MASTER DATA", "OPERASIONAL"};

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
            Navigator.pop(ctx); // Tutup dialog
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            widget.onLogout(); // ← Panggil callback ke login screen
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
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _isSidebarVisible ? 260 : 0,
            child: _isSidebarVisible ? _buildSidebar() : const SizedBox.shrink(),
          ),
          
          // Main Content
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _buildMainCanvas()),
                Positioned(
                  top: 20,
                  left: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSidebarVisible = !_isSidebarVisible;
                      });
                    },
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
        topRight: Radius.circular(40),
        bottomRight: Radius.circular(40),
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
                Colors.white.withValues(alpha: 0.20),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 36, 86, 194).withValues(alpha: 0.15),
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

  Widget _buildMenuGroup(MenuGroup group) {
    final isExpanded = _expandedGroups.contains(group.title);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Header
        GestureDetector(
          onTap: () => _toggleGroup(group.title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isExpanded ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(group.icon, size: 18, color: Colors.black54),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.black54,
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
    final isSelected = _selectedMenu == menu.title;

    return GestureDetector(
      onTap: () {
        if (menu.isLogout) {
          _handleLogout();
        } else {
          setState(() {
            _selectedMenu = menu.title;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 32, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.transparent,
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
            width: 74,
            height: 74,
            child: _hospitalProfile?.logoUrl != null && _hospitalProfile!.logoUrl!.isNotEmpty
                ? Image.network(
                    _hospitalProfile!.logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.local_hospital, color: deepBlue, size: 42);
                    },
                  )
                : Icon(Icons.local_hospital, color: deepBlue, size: 42),
          ),
          const SizedBox(height: 14),
          Text(
            _hospitalProfile?.name ?? 'HOSPITAL HUMAN ASSET TRACKING SYSTEM',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              height: 1.35,
              letterSpacing: 0.2,
              color: deepBlue,
            ),
          ),
          if (_hospitalProfile?.address != null && _hospitalProfile!.address!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _hospitalProfile!.address!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            "Developed By : PLATFORM PELAYANAN TERBAIK",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Distributed By : PT. REKAMITRA",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "2026 - Indonesia",
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
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
      child: _getBody(),
    );
  }

  Widget _getBody() {
    // Cari menu yang dipilih
    for (var group in _menuGroups) {
      for (var menu in group.menus) {
        if (menu.title == _selectedMenu && menu.widget != null) {
          return menu.widget!;
        }
      }
    }
    return const Center(child: Text("Pilih menu dari sidebar"));
  }
}

// Models untuk menu
class MenuGroup {
  final String title;
  final IconData icon;
  final List<MenuItem> menus;

  MenuGroup({
    required this.title,
    required this.icon,
    required this.menus,
  });
}

class MenuItem {
  final String title;
  final IconData icon;
  final Widget? widget;
  final bool isLogout;

  MenuItem(this.title, this.icon, this.widget, [this.isLogout = false]);
}