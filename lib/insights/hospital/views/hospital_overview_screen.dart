// File: lib/insights/hospital/views/hospital_overview_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import '../providers/hospital_overview_providers.dart';
import '../models/hospital_overview_summary.dart';
import '../models/hospital_profile_model.dart';
import '../models/hospital_organization_model.dart';
import '../../profiles/widgets/shared/donut_chart.dart';

class HospitalOverviewScreen extends ConsumerStatefulWidget {
  const HospitalOverviewScreen({super.key});

  @override
  ConsumerState<HospitalOverviewScreen> createState() => _HospitalOverviewScreenState();
}

class _HospitalOverviewScreenState extends ConsumerState<HospitalOverviewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final horizontalMargin = isMobile ? 12.0 : (isTablet ? 20.0 : 32.0);
    final useTwoColumns = screenWidth >= 900;


    final state = ref.watch(hospitalOverviewStateProvider);
    final profile = state.profile;
    final summary = state.summary;
    final roomCategories = state.roomCategories;
    final employeePerUnit = state.employeePerUnit;
    final employeeHierarchy = state.employeeHierarchy;
    final buildingHierarchy = state.buildingHierarchy;
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

     debugPrint('🏥 SCREEN STATE: isLoading=${state.isLoading}, error=${state.errorMessage}');
  debugPrint('🏥 SCREEN SUMMARY: buildings=${state.summary.totalBuildings}, employees=${state.summary.totalEmployees}');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF052D9C),
            Color(0xFF1E3A8A),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(profile),
                const SizedBox(height: 20),

                if (isLoading && summary.totalBuildings == 0)
                  _buildLoadingShimmer()
                else if (errorMessage != null && summary.totalBuildings == 0)
                  _buildErrorWidget(errorMessage)
                else ...[
                  _buildKPICards(summary, isMobile, isTablet),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRoomCategoryChart(roomCategories)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEmployeePerUnitChart(employeePerUnit)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildRoomCategoryChart(roomCategories),
                        const SizedBox(height: 16),
                        _buildEmployeePerUnitChart(employeePerUnit),
                      ],
                    ),
                  const SizedBox(height: 20),

                  if (useTwoColumns)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildEmployeeHierarchyTree(employeeHierarchy)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBuildingHierarchyTree(buildingHierarchy)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildEmployeeHierarchyTree(employeeHierarchy),
                        const SizedBox(height: 16),
                        _buildBuildingHierarchyTree(buildingHierarchy),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(HospitalProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: profile.logoUrl != null && profile.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      profile.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.local_hospital,
                        size: 32,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  )
                : Icon(Icons.local_hospital, size: 32, color: const Color(0xFF10B981)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (profile.address != null)
                  Text(
                    profile.address!,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                if (profile.contactCenter != null)
                  Text(
                    '☎️ ${profile.contactCenter}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KPI CARDS
  // ============================================================
  Widget _buildKPICards(HospitalOverviewSummary summary, bool isMobile, bool isTablet) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.3,
      children: [
        _kpiCard('Gedung', summary.totalBuildings.toString(), Icons.business, const Color(0xFF3B82F6)),
        _kpiCard('Lantai', summary.totalFloors.toString(), Icons.square, const Color(0xFF10B981)),
        _kpiCard('Kamar', summary.totalRooms.toString(), Icons.meeting_room, const Color(0xFF8B5CF6)),
        _kpiCard('Pegawai', summary.totalEmployees.toString(), Icons.people, const Color(0xFFF59E0B)),
        _kpiCard('Unit', summary.totalUnits.toString(), Icons.account_tree, const Color(0xFF06B6D4)),
        _kpiCard('Hadir Hari Ini', summary.presentToday.toString(), Icons.check_circle, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: _glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROOM CATEGORY CHART
  // ============================================================
  Widget _buildRoomCategoryChart(List<RoomCategoryDistribution> categories) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data kategori kamar',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final Map<String, int> chartData = {};
    for (final cat in categories) {
      chartData[cat.categoryName] = cat.totalRooms;
    }

    final total = categories.fold(0, (sum, cat) => sum + cat.totalRooms);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: DonutChart(
        data: chartData,
        title: 'Distribusi Kamar per Kategori',
        total: total.toDouble(),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE PER UNIT CHART
  // ============================================================
  Widget _buildEmployeePerUnitChart(List<EmployeePerUnit> employees) {
    if (employees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data pegawai per unit',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    final displayItems = employees.take(5).toList();
    final maxCount = displayItems.first.employeeCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pegawai per Unit',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: displayItems.map((item) {
                  final percent = maxCount > 0 ? (item.employeeCount / maxCount) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.unitName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${item.employeeCount} org',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: const Color(0xFF10B981),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (employees.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '📋 +${employees.length - 5} unit lainnya',
                  style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPLOYEE HIERARCHY TREE
  // ============================================================
  Widget _buildEmployeeHierarchyTree(List<EmployeeUnitNode> roots) {
    if (roots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data struktur organisasi',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Struktur Organisasi',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: roots.map((root) => _buildEmployeeNode(root)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeNode(EmployeeUnitNode node) {
    return ExpansionTile(
      leading: Icon(
        node.children.isEmpty ? Icons.business_center : Icons.account_tree,
        color: const Color(0xFF3B82F6),
        size: 18,
      ),
      title: Text(
        '🏛️ ${node.unitName} (${node.employeeCount} org)',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      subtitle: node.headOfUnitName != null
          ? Text(
              'Kepala: ${node.headOfUnitName}',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
            )
          : null,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: node.children.map((child) => _buildEmployeeNode(child)).toList(),
    );
  }

  // ============================================================
  // BUILDING HIERARCHY TREE
  // ============================================================
  Widget _buildBuildingHierarchyTree(List<BuildingNode> buildings) {
    if (buildings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Center(
          child: Text(
            'Tidak ada data gedung',
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Struktur Gedung',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: buildings.map((building) => _buildBuildingNode(building)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingNode(BuildingNode building) {
    return ExpansionTile(
      leading: const Icon(Icons.business, color: Color(0xFF10B981), size: 18),
      title: Text(
        '🏢 ${building.buildingName} (${building.totalRooms} kamar)',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: building.floors.map((floor) => _buildFloorNode(floor)).toList(),
    );
  }

  Widget _buildFloorNode(FloorNode floor) {
    return ExpansionTile(
      leading: const Icon(Icons.square, color: Color(0xFFF59E0B), size: 16),
      title: Text(
        '📐 Lantai ${floor.floorNumber}${floor.floorAlias != null ? ' - ${floor.floorAlias}' : ''} (${floor.totalRooms} kamar)',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: floor.rooms.map((room) => _buildRoomNode(room)).toList(),
    );
  }

  Widget _buildRoomNode(RoomNode room) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _parseColor(room.categoryColor, const Color(0xFF8B5CF6)),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🚪 ${room.roomName}${room.categoryName != null ? ' (${room.categoryName})' : ''}',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING SHIMMER
  // ============================================================
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glassDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(hospitalOverviewStateProvider);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER
  // ============================================================
  Color _parseColor(String? colorHex, Color defaultColor) {
    if (colorHex == null || colorHex.isEmpty) return defaultColor;
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return defaultColor;
    } catch (_) {
      return defaultColor;
    }
  }

  Decoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 0.5,
      ),
    );
  }
}