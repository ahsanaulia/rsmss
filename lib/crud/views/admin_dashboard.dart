import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../models/hospital_profile_model.dart';
import 'tables/employee_table.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  HospitalProfileModel? _hospitalProfile;
  bool _isSidebarVisible = true;
  final Color deepBlue = const Color(0xFF01579B);

  String _selectedMenu = "Data Pegawai";

  final List<Map<String, dynamic>> _menus = [
    {'title': 'Data Pegawai', 'icon': Icons.people, 'widget': const EmployeeTable()},
    // Tambahkan menu lain di sini nanti
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Navigator.pop(context);
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
          // Sidebar - tidak menimpa main canvas
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _isSidebarVisible ? 260 : 0,
            child: _isSidebarVisible ? _buildSidebar() : const SizedBox.shrink(),
          ),
          
          // Main Content - selalu di kanan sidebar
          Expanded(
            child: Stack(
              children: [
                // Main Canvas
                Positioned.fill(child: _buildMainCanvas()),
                
                // Toggle Button (di dalam main canvas, pojok kiri atas)
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
                      _sectionTitle("MASTER DATA"),
                      ..._menus.map((menu) => _menu(menu['title'], menu['icon'])),
                      const SizedBox(height: 24),
                      _sectionTitle("SYSTEM"),
                      _menu("Logout", Icons.logout, isLogout: true),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10, top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: const Color.fromARGB(255, 3, 37, 150).withValues(alpha: 0.7),
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
          color: active ? Colors.white.withValues(alpha: 0.28) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active ? Border.all(color: Colors.white.withValues(alpha: 0.35)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isLogout ? Colors.red : (active ? deepBlue : Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: isLogout ? Colors.red : (active ? deepBlue : Colors.black87),
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
    final selectedWidget = _menus.firstWhere(
      (menu) => menu['title'] == _selectedMenu,
      orElse: () => _menus[0],
    )['widget'];

    return selectedWidget;
  }
}