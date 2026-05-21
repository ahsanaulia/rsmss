// ============================================================
// PAGE: Employee Asset Request (PEGAWAI - HP)
// ============================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../models/asset_assignment_pending.dart';
import '../../services/asset_assignment_service.dart';
import '../../models/asset_request_model.dart';

class EmployeeAssetRequestPage extends StatefulWidget {
  const EmployeeAssetRequestPage({super.key});

  @override
  State<EmployeeAssetRequestPage> createState() => _EmployeeAssetRequestPageState();
}

class _EmployeeAssetRequestPageState extends State<EmployeeAssetRequestPage> {
  late final AuthService _authService;
  final _assetAssignmentService = AssetAssignmentService();
  
  List<Map<String, dynamic>> _availableAssets = [];
  List<Map<String, dynamic>> _filteredAssets = [];
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingAssets = true;
  bool _isLoadingRequests = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _requestsError;
  
  List<AssetAssignmentPending> _myRequests = [];
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String? get _currentUserId => _authService.currentUserId;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadInitialData();
    _loadMyRequests();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterAssets();
      });
    });
  }

  void _filterAssets() {
    if (_searchQuery.isEmpty) {
      _filteredAssets = List.from(_availableAssets);
    } else {
      _filteredAssets = _availableAssets.where((asset) {
        final assetName = (asset['asset_name'] ?? '').toLowerCase();
        final typeName = (asset['type_name'] ?? '').toLowerCase();
        return assetName.contains(_searchQuery) || typeName.contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingAssets = true;
      _errorMessage = null;
    });

    try {
      final assets = await _assetAssignmentService.fetchAvailableAssets();
      final rooms = await _assetAssignmentService.fetchRooms();
      
      setState(() {
        _availableAssets = assets;
        _filteredAssets = List.from(assets);
        _rooms = rooms;
        _isLoadingAssets = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAssets = false;
      });
    }
  }

  Future<void> _loadMyRequests() async {
    if (_currentUserId == null) return;
    
    setState(() {
      _isLoadingRequests = true;
      _requestsError = null;
    });

    try {
      final requests = await _assetAssignmentService.fetchMyRequests(_currentUserId!);
      setState(() {
        _myRequests = requests;
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() {
        _requestsError = e.toString();
        _isLoadingRequests = false;
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadInitialData(),
      _loadMyRequests(),
    ]);
  }

  Future<void> _cancelRequest(String requestId, String assetName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Batalkan Permintaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan permintaan aset "$assetName"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Tidak', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Ya, Batalkan', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await _assetAssignmentService.cancelRequest(requestId);
      
      if (mounted) {
        _showSnackbar('Permintaan aset dibatalkan', Colors.orange);
        await _loadMyRequests();
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal membatalkan: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showRequestForm(Map<String, dynamic> asset) {
    String? selectedRoomId;
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset['asset_name'] ?? 'Unknown Asset',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF01579B),
                                ),
                              ),
                              Text(
                                asset['type_name'] ?? 'No Type',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String?>(
                      value: selectedRoomId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Lokasi Serah Terima *',
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
                      validator: (value) => value == null ? 'Pilih lokasi serah terima' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey),
                        hintText: 'Contoh: Untuk keperluan operasi pasien',
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
                            onPressed: () => Navigator.pop(context),
                            child: Text('Batal', style: GoogleFonts.poppins()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      await _submitRequest(
                                        assetId: asset['id'],
                                        assetName: asset['asset_name'],
                                        handoverLocationId: selectedRoomId,
                                        notes: notesController.text.trim(),
                                      );
                                      if (mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF01579B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Ajukan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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

  Future<void> _submitRequest({
    required String assetId,
    required String assetName,
    required String? handoverLocationId,
    required String notes,
  }) async {
    if (_currentUserId == null) {
      _showSnackbar('Session expired, silakan login ulang', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final request = AssetRequest.newRequest(
        assetId: assetId,
        profileId: _currentUserId!,
        notes: notes.isEmpty ? null : notes,
        handoverLocationId: handoverLocationId,
      );
      
      await _assetAssignmentService.submitRequest(request);
      
      if (mounted) {
        _showSnackbar('Permintaan aset "$assetName" berhasil diajukan', Colors.green);
        await _refreshAll();
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal mengajukan permintaan: $e', Colors.red);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;
    
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        title: Text(
          'Ajukan Aset',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau tipe aset...',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF01579B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
            ),
          ),
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
          onRefresh: _refreshAll,
          color: const Color(0xFF01579B),
          child: Column(
            children: [
              // ==================================================
              // BAGIAN ATAS: DAFTAR ASET TERSEDIA
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Aset Tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildAvailableAssetsList(isSmall),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.5),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // ==================================================
              // BAGIAN BAWAH: RIWAYAT PERMINTAAN
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Riwayat Permintaan Saya',
                        style: GoogleFonts.poppins(
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01579B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildMyRequestsList(isSmall),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableAssetsList(bool isSmall) {
    if (_isLoadingAssets) {
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
              onPressed: _loadInitialData,
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
    
    if (_filteredAssets.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty 
            ? 'Tidak ada aset yang tersedia saat ini'
            : 'Tidak ditemukan aset dengan kata "$_searchQuery"',
          style: GoogleFonts.poppins(),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredAssets.length,
      itemBuilder: (context, index) => _buildAssetCard(_filteredAssets[index], isSmall),
    );
  }

  Widget _buildMyRequestsList(bool isSmall) {
    if (_isLoadingRequests) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF01579B)),
      );
    }
    
    if (_requestsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_requestsError!, style: GoogleFonts.poppins(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMyRequests,
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
    
    if (_myRequests.isEmpty) {
      return Center(
        child: Text(
          'Belum ada permintaan yang diajukan',
          style: GoogleFonts.poppins(),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _myRequests.length,
      itemBuilder: (context, index) => _buildRequestCard(_myRequests[index], isSmall),
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
                Text(
                  asset['type_name'] ?? 'No Type',
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 10 : 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (asset['last_room_name'] != null)
                  Text(
                    'Lokasi: ${asset['last_room_name']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9 : 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                if (asset['handling_instruction'] != null)
                  Text(
                    '⚠️ ${asset['handling_instruction']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9 : 10,
                      color: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showRequestForm(asset),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF01579B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: isSmall ? 6 : 8),
            ),
            child: Text(
              'Ajukan',
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

  Widget _buildRequestCard(AssetAssignmentPending request, bool isSmall) {
    Color statusColor;
    String statusLabel;
    
    switch (request.assignmentStatus.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusLabel = 'Menunggu';
        break;
      case 'active':
        statusColor = Colors.green;
        statusLabel = 'Disetujui';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusLabel = 'Ditolak';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = request.assignmentStatus;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 45 : 50,
            height: isSmall ? 45 : 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: request.fotoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      request.fotoUrl!,
                      width: isSmall ? 45 : 50,
                      height: isSmall ? 45 : 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2),
                    ),
                  )
                : const Icon(Icons.inventory_2, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.assetName,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: isSmall ? 8 : 9,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(request.requestedAt),
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 8 : 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (request.handoverLocationName != null)
                  Text(
                    'Serah terima: ${request.handoverLocationName}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9 : 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (request.assignedByName != null && request.assignedByName!.isNotEmpty && request.assignmentStatus == 'active')
                  Text(
                    'Disetujui oleh: ${request.assignedByName}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 9 : 10,
                      color: Colors.green.shade700,
                    ),
                  ),
              ],
            ),
          ),
          if (request.assignmentStatus.toLowerCase() == 'pending')
            IconButton(
              onPressed: _isSubmitting ? null : () => _cancelRequest(request.id, request.assetName),
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              tooltip: 'Batalkan Permintaan',
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}