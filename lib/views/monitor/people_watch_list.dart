// File: lib/views/monitor/people_watch_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../../models/watch_list_people_model.dart';

class PeopleWatchList extends StatefulWidget {
  const PeopleWatchList({super.key});

  @override
  State<PeopleWatchList> createState() => _PeopleWatchListState();
}

class _PeopleWatchListState extends State<PeopleWatchList> {
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _searchController = TextEditingController();
  
  List<WatchListPeopleModel> _allData = [];
  List<WatchListPeopleModel> _filteredData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final movementRes = await _supabase.from('personil_last_position').select('''
          *,
          peoples:rfid_tag_id (*)
        ''');

      final refs = await Future.wait([
        _supabase.from('ref_people_categories').select('*'),
        _supabase.from('buildings').select('*'),
        _supabase.from('floors').select('*'),
        _supabase.from('rooms').select('*'),
        _supabase.from('detectors').select('*'),
      ]);

      final catMap = {for (var x in refs[0]) x['id']?.toString() ?? '': x};
      final bldMap = {for (var x in refs[1]) x['id']?.toString() ?? '': x};
      final flrMap = {for (var x in refs[2]) x['id']?.toString() ?? '': x};
      final romMap = {for (var x in refs[3]) x['id']?.toString() ?? '': x};
      final detMap = {for (var x in refs[4]) x['id']?.toString() ?? '': x};

      List<WatchListPeopleModel> mappedList = (movementRes as List).map((m) {
        final p = m['peoples'] ?? {};
        final dId = m['detector_id']?.toString() ?? '';

        final det = detMap[dId];
        final rom = romMap[det?['room_id']?.toString() ?? ''];
        final flr = flrMap[rom?['floor_id']?.toString() ?? ''];
        final bld = bldMap[flr?['building_id']?.toString() ?? ''];
        final cat = catMap[p['category_id']?.toString() ?? ''];

        return WatchListPeopleModel.fromManualJoin(
          movement: m,
          people: p,
          category: cat,
          detector: det,
          room: rom,
          floor: flr,
          building: bld,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allData = mappedList;
          _filteredData = mappedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("FATAL ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _allData.where((item) {
        final searchString =
            "${item.fullName} ${item.rfidTagId} ${item.locationFullPath} ${item.categoryName}"
                .toLowerCase();
        return searchString.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _filteredData.isEmpty
                        ? _buildEmptyState()
                        : _buildDataTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PEOPLE WATCH LIST',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Monitoring pergerakan personil realtime',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari Nama, RFID, Gedung atau Ruangan...",
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.white.withValues(alpha: 0.5)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: Colors.white.withValues(alpha: 0.5)),
                        onPressed: () {
                          _searchController.clear();
                          _filterData("");
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${_filteredData.length} Orang",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text(
                  "Real-time Active",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 40.0, bottom: 20.0, left: 16, top: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 45,
                dataRowMinHeight: 55,
                dataRowMaxHeight: 65,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                ),
                columns: [
                  _headerCell("PERSONIL"),
                  _headerCell("KATEGORI"),
                  _headerCell("LOKASI (G > L > R)"),
                  _headerCell("KOORDINAT (X, Y)"),
                  _headerCell("STATUS"),
                  _headerCell("WAKTU"),
                ],
                rows: _filteredData.map((item) {
                  return DataRow(cells: [
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.fullName ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item.rfidTagId,
                          style: const TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    )),
                    DataCell(_buildCategoryBadge(item)),
                    DataCell(
                      Text(
                        item.locationFullPath,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.coordinateLabel,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.movementStatus == "IN"
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.movementStatus,
                          style: TextStyle(
                            color: item.movementStatus == "IN"
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.formattedTime,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _headerCell(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(WatchListPeopleModel item) {
    final colorStr = item.markerColor?.replaceAll('#', '0xFF') ?? '0xFF8B5CF6';
    final color = Color(int.parse(colorStr));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        item.categoryName ?? "-",
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Data tidak ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}