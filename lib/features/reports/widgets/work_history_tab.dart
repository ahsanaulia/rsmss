import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';

class WorkHistoryTab extends StatefulWidget {
  final String userId;
  const WorkHistoryTab({super.key, required this.userId});

  @override
  State<WorkHistoryTab> createState() => _WorkHistoryTabState();
}

class _WorkHistoryTabState extends State<WorkHistoryTab>
    with SingleTickerProviderStateMixin {
  final ReportService _service = ReportService();
  late TabController _subTabController;
  
  List<Map<String, dynamic>> _stockInitials = [];
  List<Map<String, dynamic>> _assetInitials = [];
  List<Map<String, dynamic>> _stockOpnames = [];
  List<Map<String, dynamic>> _assetInspections = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getStockInitialHistory(widget.userId),
        _service.getAssetInitialHistory(widget.userId),
        _service.getStockOpnameHistory(widget.userId),
        _service.getAssetInspectionHistory(widget.userId),
      ]);
      
      setState(() {
        _stockInitials = results[0];
        _assetInitials = results[1];
        _stockOpnames = results[2];
        _assetInspections = results[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Sub Tab Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _subTabController,
            isScrollable: true,
            indicatorColor: const Color(0xFF01579B),
            labelColor: const Color(0xFF01579B),
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "📦 Stock Awal"),
              Tab(text: "🏗️ Asset Awal"),
              Tab(text: "📊 Stock Opname"),
              Tab(text: "🔍 Inspeksi Asset"),
            ],
          ),
        ),
        // Sub Tab View
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildStockInitialList(),
              _buildAssetInitialList(),
              _buildStockOpnameList(),
              _buildAssetInspectionList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockInitialList() {
    if (_stockInitials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text("Belum ada stock awal", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stockInitials.length,
      itemBuilder: (context, index) {
        final stock = _stockInitials[index];
        final storage = stock['storage_locations'] as Map<String, dynamic>?;
        final type = stock['ref_stock_types'] as Map<String, dynamic>?;
        final createdAt = stock['created_at'] != null
            ? DateTime.parse(stock['created_at'])
            : null;

        return _buildCard(
          icon: Icons.warehouse,
          title: stock['stock_name'] ?? '-',
          subtitle: "Kode: ${stock['stock_code'] ?? '-'}",
          details: [
            "Type: ${type?['type_name'] ?? '-'}",
            "Stock: ${stock['current_stock']} ${stock['unit'] ?? ''}",
            "Min: ${stock['minimum_stock']} ${stock['unit'] ?? ''}",
            "Lokasi: ${storage?['location_name'] ?? '-'}",
            "Kondisi: ${stock['stock_condition'] ?? '-'}",
          ],
          date: _formatDateTime(createdAt),
          status: stock['stock_condition'] ?? 'GOOD',
        );
      },
    );
  }

  Widget _buildAssetInitialList() {
    if (_assetInitials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text("Belum ada asset awal", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assetInitials.length,
      itemBuilder: (context, index) {
        final asset = _assetInitials[index];
        final type = asset['ref_asset_types'] as Map<String, dynamic>?;
        final room = asset['rooms'] as Map<String, dynamic>?;
        final createdAt = asset['created_at'] != null
            ? DateTime.parse(asset['created_at'])
            : null;

        return _buildCard(
          icon: Icons.inventory_2,
          title: asset['asset_name'] ?? '-',
          subtitle: "RFID: ${asset['rfid_tag_id'] ?? '-'}",
          details: [
            "Type: ${type?['type_name'] ?? '-'}",
            "Lokasi: ${room?['room_name'] ?? '-'}",
            "Kondisi: ${asset['status_condition'] ?? '-'}",
            asset['is_dangerous'] == true ? "⚠️ Berbahaya" : "",
          ],
          date: _formatDateTime(createdAt),
          status: asset['status_condition'] ?? 'Good',
          statusColor: asset['status_condition'] == 'Good' ? Colors.green : Colors.orange,
          hasImage: asset['foto_url'] != null,
          imageUrl: asset['foto_url'],
        );
      },
    );
  }

  Widget _buildStockOpnameList() {
    if (_stockOpnames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.playlist_add_check, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text("Belum ada stock opname", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stockOpnames.length,
      itemBuilder: (context, index) {
        final opname = _stockOpnames[index];
        final stock = opname['stocks'] as Map<String, dynamic>?;
        final opnameAt = opname['opname_at'] != null
            ? DateTime.parse(opname['opname_at'])
            : null;
        final adjustment = (opname['adjustment_stock'] as num?)?.toDouble() ?? 0;

        return _buildCard(
          icon: Icons.playlist_add_check,
          title: stock?['stock_name'] ?? '-',
          subtitle: "Kode: ${stock?['stock_code'] ?? '-'}",
          details: [
            "Stock Sebelum: ${opname['stock_before']} ${stock?['unit'] ?? ''}",
            "Stock Fisik: ${opname['physical_stock']} ${stock?['unit'] ?? ''}",
            "Adjustment: ${adjustment >= 0 ? '+' : ''}$adjustment",
            "Catatan: ${opname['opname_note'] ?? '-'}",
          ],
          date: _formatDateTime(opnameAt),
          status: adjustment == 0 ? "Tidak Berubah" : (adjustment > 0 ? "Bertambah" : "Berkurang"),
          statusColor: adjustment > 0 ? Colors.green : (adjustment < 0 ? Colors.red : Colors.grey),
        );
      },
    );
  }

  Widget _buildAssetInspectionList() {
    if (_assetInspections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fact_check, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text("Belum ada inspeksi asset", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assetInspections.length,
      itemBuilder: (context, index) {
        final inspection = _assetInspections[index];
        final asset = inspection['assets'] as Map<String, dynamic>?;
        final inspectedAt = inspection['inspected_at'] != null
            ? DateTime.parse(inspection['inspected_at'])
            : null;

        return _buildCard(
          icon: Icons.fact_check,
          title: asset?['asset_name'] ?? '-',
          subtitle: "RFID: ${asset?['rfid_tag_id'] ?? '-'}",
          details: [
            "Hasil: ${inspection['inspection_result'] ?? '-'}",
            "Kondisi: ${inspection['condition_status'] ?? '-'}",
            "Kontaminasi: Level ${inspection['contamination_level'] ?? 0}",
            "Tindakan: ${inspection['action_taken'] ?? '-'}",
          ],
          date: _formatDateTime(inspectedAt),
          status: inspection['inspection_result'] ?? 'Pass',
          statusColor: inspection['inspection_result'] == 'Pass' ? Colors.green : Colors.red,
          hasImage: inspection['photo_url'] != null,
          imageUrl: inspection['photo_url'],
        );
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> details,
    required String date,
    required String status,
    Color statusColor = Colors.blue,
    bool hasImage = false,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF01579B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...details.where((d) => d.isNotEmpty).map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                detail,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
              ),
            )),
            const SizedBox(height: 8),
            Text(
              date,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}