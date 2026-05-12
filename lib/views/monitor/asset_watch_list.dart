import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/watch_list_asset_model.dart';

class AssetWatchList extends StatefulWidget {
  const AssetWatchList({super.key});

  @override
  State<AssetWatchList> createState() => _AssetWatchListState();
}

class _AssetWatchListState extends State<AssetWatchList> {
  final _supabase = Supabase.instance.client;

  // Menggunakan Controller untuk menangani input pencarian secara efisien
  final TextEditingController _searchController = TextEditingController();

  List<WatchListAssetModel> _allData = [];
  List<WatchListAssetModel> _filteredData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssetData();
  }

  @override
  void dispose() {
    // Perbaikan Memory Leak: Pastikan controller dihapus dari memori
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssetData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Ambil dari VIEW agar cepat
      final res = await _supabase.from('asset_last_position').select('''
          *,
          assets:rfid_tag_id (*)
        ''');

      final refs = await Future.wait([
        _supabase.from('ref_asset_types').select('*'),
        _supabase.from('buildings').select('*'),
        _supabase.from('floors').select('*'),
        _supabase.from('rooms').select('*'),
        _supabase.from('detectors').select('*'),
      ]);

      final typeMap = {for (var x in refs[0]) x['id'].toString(): x};
      final bldMap = {for (var x in refs[1]) x['id'].toString(): x};
      final flrMap = {for (var x in refs[2]) x['id'].toString(): x};
      final romMap = {for (var x in refs[3]) x['id'].toString(): x};
      final detMap = {for (var x in refs[4]) x['id'].toString(): x};

      List<WatchListAssetModel> mappedList = (res as List).map((m) {
        final a = m['assets'] ?? {};
        final dId = m['detector_id']?.toString() ?? '';
        final det = detMap[dId];
        final rom = romMap[det?['room_id']?.toString() ?? ''];
        final flr = flrMap[rom?['floor_id']?.toString() ?? ''];
        final bld = bldMap[flr?['building_id']?.toString() ?? ''];
        final type = typeMap[a['type_id']?.toString() ?? ''];

        return WatchListAssetModel.fromManualJoin(
          movement: m,
          asset: a,
          type: type,
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
      debugPrint("Asset Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterData(String query) {
    setState(() {
      // Perbaikan search_query warning: Menggunakan parameter 'query' langsung
      _filteredData = _allData.where((item) {
        final searchString =
            "${item.assetName} ${item.rfidTagId} ${item.locationFullPath} ${item.typeName}"
                .toLowerCase();
        return searchString.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Perbaikan Overflow: Mencegah error layout saat keyboard muncul
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Monitoring Aset",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: _loadAssetData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                    ? const Center(child: Text("Aset tidak ditemukan"))
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
      child: TextField(
        controller: _searchController, // Hubungkan controller
        onChanged: _filterData,
        decoration: InputDecoration(
          hintText: "Cari Nama Aset, RFID, atau Lokasi...",
          prefixIcon: const Icon(Icons.inventory_2),
          // Tombol pembersih teks pencarian
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
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          // Tambah batas kanan (Padding) agar scroll tabel tidak mepet ke pinggir layar
          padding: const EdgeInsets.only(right: 60.0, bottom: 20.0),
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: WidgetStateProperty.all(Colors.blueGrey[900]),
            columns: [
              _headerCell("ASET"),
              _headerCell("TIPE"),
              _headerCell("KONDISI"),
              _headerCell("LOKASI"),
              _headerCell("KOORDINAT"),
              _headerCell("WAKTU"),
            ],
            rows: _filteredData.map((item) => DataRow(cells: [
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.assetName ?? "-",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(item.rfidTagId,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  )),
                  DataCell(Text(item.typeName ?? "-",
                      style: const TextStyle(fontSize: 11))),
                  DataCell(_buildStatusBadge(item)),
                  DataCell(Text(item.locationFullPath,
                      style: const TextStyle(fontSize: 11))),
                  DataCell(Text(item.coordinateLabel,
                      style: GoogleFonts.sourceCodePro(
                          fontSize: 10, fontWeight: FontWeight.bold))),
                  DataCell(Text(item.formattedTime,
                      style: const TextStyle(fontSize: 11))),
                ])).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _headerCell(String label) => DataColumn(
          label: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)));

  Widget _buildStatusBadge(WatchListAssetModel item) {
    bool isDangerous = item.isDangerous ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDangerous ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDangerous ? "DANGEROUS" : (item.statusCondition ?? "Unknown"),
        style: TextStyle(
            color: isDangerous ? Colors.red[900] : Colors.green[900],
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}