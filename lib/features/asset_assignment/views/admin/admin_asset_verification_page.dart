// ============================================================
// PAGE: Admin Asset Verification (ADMIN - WEB)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../models/asset_assignment_pending.dart';
import '../../services/asset_assignment_service.dart';

class AdminAssetVerificationPage extends ConsumerStatefulWidget {
  const AdminAssetVerificationPage({super.key});

  @override
  ConsumerState<AdminAssetVerificationPage> createState() => _AdminAssetVerificationPageState();
}

class _AdminAssetVerificationPageState extends ConsumerState<AdminAssetVerificationPage> {
  late final AuthService _authService;
  final _assetAssignmentService = AssetAssignmentService();
  
  List<AssetAssignmentPending> _pendingRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isProcessing = false;

  String? get _currentAdminId => _authService.currentUserId;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _assetAssignmentService.fetchPendingRequests();
      setState(() {
        _pendingRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveRequest(AssetAssignmentPending request) async {
    if (_currentAdminId == null) {
      _showSnackbar('Session expired, silakan login ulang', Colors.red);
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Setujui Permintaan',
      content: 'Anda akan menyetujui permintaan aset "${request.assetName}" dari ${request.requesterName}?',
      confirmText: 'Setujui',
      confirmColor: Colors.green,
    );
    
    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await _assetAssignmentService.approveRequest(request.id, _currentAdminId!);
      
      if (mounted) {
        _showSnackbar('Permintaan aset "${request.assetName}" telah disetujui', Colors.green);
        await _loadPendingRequests();
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal menyetujui: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectRequest(AssetAssignmentPending request) async {
    if (_currentAdminId == null) {
      _showSnackbar('Session expired, silakan login ulang', Colors.red);
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Tolak Permintaan',
      content: 'Anda akan menolak permintaan aset "${request.assetName}" dari ${request.requesterName}?',
      confirmText: 'Tolak',
      confirmColor: Colors.red,
    );
    
    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await _assetAssignmentService.rejectRequest(request.id, _currentAdminId!);
      
      if (mounted) {
        _showSnackbar('Permintaan aset "${request.assetName}" telah ditolak', Colors.orange);
        await _loadPendingRequests();
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Gagal menolak: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF01579B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF01579B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Verifikasi Permintaan Aset',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF01579B),
                  ),
                ),
                const Spacer(),
                if (!_isLoading)
                  IconButton(
                    onPressed: _loadPendingRequests,
                    icon: const Icon(Icons.refresh, color: Color(0xFF01579B)),
                    tooltip: 'Refresh',
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPendingRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01579B),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Tidak ada permintaan aset yang menunggu verifikasi',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      color: const Color(0xFF01579B),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) => _buildRequestCard(_pendingRequests[index]),
      ),
    );
  }

  Widget _buildRequestCard(AssetAssignmentPending request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Aset
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: request.fotoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      request.fotoUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, color: Colors.grey),
                    ),
                  )
                : const Icon(Icons.inventory_2, color: Colors.grey, size: 40),
          ),
          const SizedBox(width: 16),

          // Informasi Permintaan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.assetName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      request.requesterName,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (request.requesterEmployeeId != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.badge_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        request.requesterEmployeeId!,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (request.notes != null && request.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Catatan: ${request.notes}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(request.requestedAt),
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    if (request.handoverLocationName != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        request.handoverLocationName!,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _approveRequest(request),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Setujui'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isProcessing ? null : () => _rejectRequest(request),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Tolak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}