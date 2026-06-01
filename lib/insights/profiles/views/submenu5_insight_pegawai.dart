// File: lib/insights/profiles/views/submenu5_insight_pegawai.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/employee_tree_view.dart';
import '../widgets/employee_insight_popup.dart';
import '../providers/profile_list_provider.dart';
import '../models/profile_summary_model.dart';

class Submenu5InsightPegawai extends ConsumerStatefulWidget {
  const Submenu5InsightPegawai({super.key});

  @override
  ConsumerState<Submenu5InsightPegawai> createState() => _Submenu5InsightPegawaiState();
}

class _Submenu5InsightPegawaiState extends ConsumerState<Submenu5InsightPegawai> {
  int? _selectedLevel = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (_selectedLevel == 1) {
        _onLevelTap(1);
      }
    });
  }

  void _onLevelTap(int level) {
    setState(() {
      _selectedLevel = level;
      _searchQuery = '';
    });
  }

  void _showEmployeePopup(String profileId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => EmployeeInsightPopup(
        profileId: profileId,
        onClose: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesGroupedAsync = _selectedLevel != null
        ? ref.watch(employeesGroupedByUnitProvider(_selectedLevel!))
        : const AsyncValue.data(<UnitItem>[]);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: Row(
          children: [
            // LEFT PANEL - Tree View (30% width)
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.02),
                      child: EmployeeTreeView(
                        onLevelTap: _onLevelTap,
                        selectedLevel: _selectedLevel,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // RIGHT PANEL - Employees List Grouped by Unit (70% width)
            Expanded(
              flex: 7,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.02),
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          Expanded(
                            child: employeesGroupedAsync.when(
                              data: (groupedUnits) => _buildGroupedEmployeeList(groupedUnits),
                              loading: () => _buildLoading(),
                              error: (e, _) => _buildError(e.toString()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
        ),
        child: TextField(
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari unit atau nama pegawai...',
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: Icon(Icons.search, size: 18, color: Colors.white.withValues(alpha: 0.6)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  List<UnitItem> _filterUnits(List<UnitItem> units) {
    if (_searchQuery.isEmpty) return units;

    return units.where((unit) {
      final unitMatches = unit.unitName.toLowerCase().contains(_searchQuery);
      final employeeMatches = unit.employees.any((employee) {
        return employee.fullName.toLowerCase().contains(_searchQuery) ||
            (employee.positionName?.toLowerCase().contains(_searchQuery) ?? false);
      });
      return unitMatches || employeeMatches;
    }).toList();
  }

  List<ProfileListItem> _filterEmployees(List<ProfileListItem> employees) {
    if (_searchQuery.isEmpty) return employees;
    
    return employees.where((employee) {
      return employee.fullName.toLowerCase().contains(_searchQuery) ||
          (employee.positionName?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Widget _buildGroupedEmployeeList(List<UnitItem> groupedUnits) {
    final filteredUnits = _filterUnits(groupedUnits);
    
    if (filteredUnits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unit atau pegawai dengan kata "$_searchQuery" tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredUnits.length,
      itemBuilder: (context, index) {
        final unit = filteredUnits[index];
        final filteredEmployees = _filterEmployees(unit.employees);
        
        if (filteredEmployees.isEmpty && _searchQuery.isNotEmpty) {
          return const SizedBox.shrink();
        }
        
        return _buildUnitGroup(unit, filteredEmployees);
      },
    );
  }

  Widget _buildUnitGroup(UnitItem unit, List<ProfileListItem> employees) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  unit.id == 'tanpa_unit' ? Icons.people_outline : Icons.business_outlined,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    unit.unitName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${employees.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: employees.map((employee) => _buildEmployeeCard(employee)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(ProfileListItem employee) {
    final levelColor = _getColorFromHex(employee.positionColor ?? '#8B5CF6');

    return GestureDetector(
      onTap: () => _showEmployeePopup(employee.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: levelColor.withValues(alpha: 0.15),
                border: Border.all(color: levelColor.withValues(alpha: 0.4), width: 1),
              ),
              child: ClipOval(
                child: employee.avatarUrl != null
                    ? Image.network(
                        employee.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 20,
                          color: levelColor,
                        ),
                      )
                    : Icon(Icons.person, size: 20, color: levelColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.positionName ?? 'Tidak Ada Posisi',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.white.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse('0xFF${hexColor.replaceAll('#', '')}'));
    } catch (e) {
      return const Color(0xFF8B5CF6);
    }
  }
}