import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/incident_history_tab.dart';
import '../widgets/duty_notes_tab.dart';
import '../widgets/work_history_tab.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';

class MyReportsView extends ConsumerStatefulWidget {
  const MyReportsView({super.key});

  @override
  ConsumerState<MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends ConsumerState<MyReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // ← 3 TAB
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;
    final authService = getIt<AuthService>();
    final userId = authService.currentUserId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        centerTitle: true,
        title: Text(
          "Laporan Saya",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: isSmall ? 18 : 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF01579B),
          labelColor: const Color(0xFF01579B),
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.warning_amber_rounded), text: "Insiden"),
            Tab(icon: Icon(Icons.note_alt), text: "Catatan Dinas"),
            Tab(icon: Icon(Icons.work), text: "Pekerjaan"),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC), Color(0xFF81D4FA)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            IncidentHistoryTab(userId: userId),
            DutyNotesTab(userId: userId),
            WorkHistoryTab(userId: userId),
          ],
        ),
      ),
    );
  }
}