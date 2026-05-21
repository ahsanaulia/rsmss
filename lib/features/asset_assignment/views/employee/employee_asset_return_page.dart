// ============================================================
// PAGE: Employee Asset Return (PEGAWAI - HP)
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan daftar aset yang sedang dipakai (status 'active')
// 2. Form pengembalian aset (pilih lokasi return, catatan)
// 3. Submit -> update released_at, return_location_id, status = 'released'
// ============================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../services/asset_assignment_service.dart';

class EmployeeAssetReturnPage extends StatefulWidget {
  const EmployeeAssetReturnPage({super.key});

  @override
  State<EmployeeAssetReturnPage> createState() => _EmployeeAssetReturnPageState();
}

class _EmployeeAssetReturnPageState extends State<EmployeeAssetReturnPage> {
  late final AuthService _authService;
  final _assetAssignmentService = AssetAssignmentService();
  
  List<Map<String, dynamic>> _activeAssets = [];
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  String? get _currentUserId => _authService.currentUserId;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ambil aset aktif milik pegawai
      final assets = await _assetAssignmentService.fetchMyActiveAssets(_currentUserId!);
      // Ambil daftar ruangan untuk dropdown return location
      final rooms = await _assetAssignmentService.fetchRooms();
      
      setState(() {
        _activeAssets = assets;
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _returnAsset(Map<String, dynamic> asset) async {
    String? selectedRoomId;
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Asset
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF01579B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: asset['foto_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    asset['foto_url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2),
                                  ),
                                )
                              : const Icon(Icons.inventory_2, color: Color(0xFF01579B), size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            asset['asset_name'] ?? 'Unknown Asset',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Lokasi Pengembalian
                    DropdownButtonFormField<String?>(
                      value: selectedRoomId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Lokasi Pengembalian *',
                        labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Pilih Ruangan')),
                        ..._rooms.map((room) => DropdownMenuItem(
                          value: room['id'].toString(),
                          child: Text(room['room_name'] ?? '-', style: GoogleFonts.poppins()),
                        )),
                      ],
                      onChanged: (value) => setSheetState(() => selectedRoomId = value),
                      validator: (value) => value == null ? 'Pilih lokasi pengembalian' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // Catatan Pengembalian
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Catatan Pengembalian (Opsional)',
                        labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey),
                        hintText: 'Contoh: Aset dalam kondisi baik',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Batal', style: GoogleFonts.poppins()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context, true);
                                await _submitReturn(
                                  assignmentId: asset['id'],
                                  assetName: asset['asset_name'],
                                  returnLocationId: selectedRoomId,
                                  notes: notesController.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text('Kembalikan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitReturn({
    required String assignmentId,
    required String assetName,
    required String? returnLocationId,
    required String notes,
  }) async {
    setState(() => _isSubmitting = true);

    try {
      await _assetAssignmentService.returnAsset(
        assignmentId: assignmentId,
        returnLocationId: returnLocationId,
        notes: notes.isEmpty ? null : notes,
      );
      
      if (mounted) {
        _showSnackbar('Aset "$assetName" berhasil dikembalikan', Colors.green);
        await _loadData(); // Refresh daftar
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal mengembalikan aset: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: Text(
          'Kembalikan Aset',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: isSmall ? 18 : 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF01579B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF01579B),
          child: _buildBody(isSmall),
        ),
      ),
    );
  }

  Widget _buildBody(bool isSmall) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF01579B)),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: GoogleFonts.poppins(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01579B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text('Coba Lagi', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }
    
    if (_activeAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada aset yang sedang dipakai',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeAssets.length,
      itemBuilder: (context, index) => _buildAssetCard(_activeAssets[index], isSmall),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset, bool isSmall) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Foto
          Container(
            width: isSmall ? 50 : 60,
            height: isSmall ? 50 : 60,
            decoration: BoxDecoration(
              color: const Color(0xFF01579B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: asset['foto_url'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      asset['foto_url'],
                      width: isSmall ? 50 : 60,
                      height: isSmall ? 50 : 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, color: Color(0xFF01579B)),
                    ),
                  )
                : const Icon(Icons.inventory_2, color: Color(0xFF01579B), size: 30),
          ),
          const SizedBox(width: 12),
          
          // Informasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset['asset_name'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(DateTime.parse(asset['assigned_at'])),
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 9 : 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (asset['handover_location_name'] != null)
                  Text(
                    'Ambil di: ${asset['handover_location_name']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9 : 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Tombol Kembalikan
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _returnAsset(asset),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: isSmall ? 6 : 8),
            ),
            child: Text(
              'Kembalikan',
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}