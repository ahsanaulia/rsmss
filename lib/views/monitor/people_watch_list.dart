import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/watch_list_people_model.dart';

class PeopleWatchList extends StatefulWidget {
  const PeopleWatchList({super.key});

  @override
  State<PeopleWatchList> createState() => _PeopleWatchListState();
}

class _PeopleWatchListState extends State<PeopleWatchList> {
  final _supabase = Supabase.instance.client;
  
  // Menggunakan Controller untuk SearchBar
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
    // Penting: Hapus controller saat widget dihancurkan
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Mengambil data dari VIEW personil_last_position
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
      // Logic pencarian menggunakan parameter query
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
      // Mencegah error garis kuning hitam saat keyboard muncul
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Monitoring Personil",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
              onPressed: _loadInitialData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                    ? const Center(child: Text("Data tidak ditemukan"))
                    : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey[50],
      child: Column(
        children: [
          TextField(
            controller: _searchController, // Menggunakan controller
            onChanged: _filterData,
            decoration: InputDecoration(
              hintText: "Cari Nama, RFID, Gedung atau Ruangan...",
              prefixIcon: const Icon(Icons.search),
              // Tombol silang untuk mereset pencarian
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterData("");
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: ${_filteredData.length} Orang",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Real-time Active",
                    style: GoogleFonts.poppins(
                        color: Colors.green[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          )
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
          // Memberi ruang di kanan agar tabel tidak menempel saat di-scroll
          padding: const EdgeInsets.only(right: 40.0, bottom: 20.0),
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 45,
            dataRowMinHeight: 50,
            dataRowMaxHeight: 60,
            headingRowColor: WidgetStateProperty.all(Colors.blueGrey[900]),
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
                    Text(item.fullName ?? "-",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(item.rfidTagId,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )),
                DataCell(_buildCategoryBadge(item)),
                DataCell(Text(item.locationFullPath,
                    style: const TextStyle(fontSize: 11))),
                DataCell(Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(item.coordinateLabel,
                      style: GoogleFonts.sourceCodePro(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800])),
                )),
                DataCell(Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: item.movementStatus == "IN"
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(item.movementStatus,
                      style: TextStyle(
                          color: item.movementStatus == "IN"
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                )),
                DataCell(Text(item.formattedTime,
                    style: const TextStyle(fontSize: 11))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _headerCell(String label) {
    return DataColumn(
        label: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)));
  }

  Widget _buildCategoryBadge(WatchListPeopleModel item) {
    final colorStr = item.markerColor?.replaceAll('#', '0xFF') ?? '0xFF9E9E9E';
    final color = Color(int.parse(colorStr));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.5))),
      child: Text(item.categoryName ?? "-",
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}