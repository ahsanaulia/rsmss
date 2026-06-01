// File: lib/crud/beds/views/bed_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bed_model.dart';
import 'bed_form_page.dart';

class BedListPage extends ConsumerStatefulWidget {
  const BedListPage({super.key});

  @override
  ConsumerState<BedListPage> createState() => _BedListPageState();
}

class _BedListPageState extends ConsumerState<BedListPage> {
  final _supabase = Supabase.instance.client;
  List<BedModel> _beds = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadBeds();
  }

  Future<void> _loadBeds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // HAPUS JOIN KE PEOPLE UNTUK HINDARI ERROR RELATIONSHIP
      final response = await _supabase
          .from('beds')
          .select('''
            *,
            rooms!beds_room_id_fkey(
              id,
              room_name,
              floor_id,
              floors!rooms_floor_id_fkey(
                floor_number,
                building_id,
                buildings!floors_building_id_fkey(
                  building_name
                )
              )
            ),
            assets!beds_asset_id_fkey(
              id,
              asset_name
            )
          ''')
          .order('created_at', ascending: false);

      final List<BedModel> beds = [];
      for (final item in response as List) {
        beds.add(BedModel.fromJson(item));
      }

      // Ambil nama pasien terpisah (opsional, jika ada patient_id)
      final patientIds = beds.where((b) => b.patientId != null).map((b) => b.patientId!).toList();
      if (patientIds.isNotEmpty) {
        final peopleRes = await _supabase
            .from('people')
            .select('id, full_name')
            .inFilter('id', patientIds);
        
        final Map<String, String> patientNames = {};
        for (final p in peopleRes as List) {
          patientNames[p['id'].toString()] = p['full_name']?.toString() ?? 'Unknown';
        }
        
        // Update patientName di setiap bed
        for (int i = 0; i < beds.length; i++) {
          final bed = beds[i];
          if (bed.patientId != null && patientNames.containsKey(bed.patientId)) {
            beds[i] = BedModel(
              id: bed.id,
              roomId: bed.roomId,
              roomName: bed.roomName,
              bedNumber: bed.bedNumber,
              assetId: bed.assetId,
              assetName: bed.assetName,
              status: bed.status,
              patientId: bed.patientId,
              patientName: patientNames[bed.patientId],
              admittedAt: bed.admittedAt,
              notes: bed.notes,
              createdAt: bed.createdAt,
              updatedAt: bed.updatedAt,
            );
          }
        }
      }

      setState(() {
        _beds = beds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBed(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Bed'),
        content: const Text('Apakah Anda yakin ingin menghapus bed ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _supabase.from('beds').delete().eq('id', id);
      _loadBeds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bed berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  List<BedModel> get _filteredBeds {
    var filtered = _beds;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bed) {
        return bed.bedNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bed.roomName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bed.assetName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (bed.patientName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    if (_selectedStatus != 'all') {
      filtered = filtered.where((bed) => bed.status == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredBeds = _filteredBeds;
    final occupiedCount = _beds.where((b) => b.isOccupied).length;
    final emptyCount = _beds.where((b) => b.isEmpty).length;
    final maintenanceCount = _beds.where((b) => b.isMaintenance).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bed, color: Color(0xFF01579B), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manajemen Tempat Tidur (Beds)',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                      Text(
                        'Kelola data bed, okupansi, dan perawatan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BedFormPage(),
                      ),
                    );
                    if (result == true) {
                      _loadBeds();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Bed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Stat Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard('Total Bed', _beds.length, Icons.bed, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Terisi', occupiedCount, Icons.person, Colors.red),
                const SizedBox(width: 12),
                _buildStatCard('Kosong', emptyCount, Icons.bed, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('Perawatan', maintenanceCount, Icons.build, Colors.orange),
              ],
            ),
          ),

          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Cari bed, ruangan, aset...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                      DropdownMenuItem(value: 'OCCUPIED', child: Text('Terisi')),
                      DropdownMenuItem(value: 'EMPTY', child: Text('Kosong')),
                      DropdownMenuItem(value: 'MAINTENANCE', child: Text('Perawatan')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : filteredBeds.isEmpty
                        ? const Center(child: Text('Tidak ada data bed'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                                columns: const [
                                  DataColumn(label: Text('No. Bed')),
                                  DataColumn(label: Text('Ruangan')),
                                  DataColumn(label: Text('Aset')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Pasien')),
                                  DataColumn(label: Text('Masuk')),
                                  DataColumn(label: Text('Aksi')),
                                ],
                                rows: filteredBeds.map((bed) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(bed.bedNumber)),
                                      DataCell(Text(bed.roomName)),
                                      DataCell(Text(bed.assetName)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: bed.statusColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            bed.statusLabel,
                                            style: TextStyle(color: bed.statusColor, fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(bed.patientName ?? '-')),
                                      DataCell(Text(
                                        bed.admittedAt != null
                                            ? '${bed.admittedAt!.day}/${bed.admittedAt!.month}/${bed.admittedAt!.year}'
                                            : '-',
                                      )),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 18),
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BedFormPage(bed: bed),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _loadBeds();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                              onPressed: () => _deleteBed(bed.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  value.toString(),
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}