// ============================================================
// PAGE: Stock Detail Page
// ============================================================
// TANGGUNG JAWAB:
// 1. Menampilkan detail lengkap stok
// 2. Header dengan foto stok dan informasi utama
// 3. Informasi detail dalam card-grid (3 kolom)
// 4. Aksi: Edit (buka dialog), Delete (konfirmasi), Back
// 5. Refresh data saat kembali dari edit
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../providers/stock_providers.dart';
import '../../providers/stock_state.dart';
import '../../models/stock_model.dart';
import '../../services/stock_service.dart';
import '../dialogs/stock_form_dialog.dart';

class StockDetailPage extends ConsumerStatefulWidget {
  final String stockId;
  final VoidCallback onStockUpdated;

  const StockDetailPage({
    super.key,
    required this.stockId,
    required this.onStockUpdated,
  });

  @override
  ConsumerState<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends ConsumerState<StockDetailPage> {
  late final AuthService _authService;
  late final StockService _stockService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _stockService = StockService();
  }

  String? get _currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  Future<void> _refreshDetail() async {
    final notifier = ref.read(stockDetailProvider(widget.stockId).notifier);
    await notifier.loadStock(widget.stockId);
  }

  void _showEditDialog(Stock stock) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StockFormDialog(
          isEditing: true,
          existingStock: stock,
          stockService: _stockService,
          currentUserId: _currentUserId,
          onSuccess: () {
            Navigator.pop(dialogContext);
            _refreshDetail();
            widget.onStockUpdated();
          },
        );
      },
    );
  }

  void _confirmDelete(Stock stock) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus stok "${stock.stockName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              if (_currentUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session expired, silakan login ulang'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              try {
                await _stockService.deleteStock(stock.id, _currentUserId!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stok berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  widget.onStockUpdated();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus stok: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockDetailProvider(widget.stockId));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Detail Stok'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF01579B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (state.stock != null && !state.isLoading)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(state.stock!);
                } else if (value == 'delete') {
                  _confirmDelete(state.stock!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Color(0xFF01579B)),
                      SizedBox(width: 8),
                      Text('Edit Stok'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Stok'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF01579B)),
            )
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat detail stok',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01579B),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : state.stock == null
                  ? const Center(
                      child: Text('Stok tidak ditemukan'),
                    )
                  : _buildDetailContent(state.stock!),
    );
  }

  Widget _buildDetailContent(Stock stock) {
    final stockStatus = StockStatus.fromStock(stock);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // HEADER CARD: Foto & Informasi Utama
          // ==================================================
          _buildHeaderCard(stock, stockStatus),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Informasi Identitas
          // ==================================================
          _buildSectionTitle('Informasi Identitas'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem('Nama Stok', stock.stockName, Icons.inventory_2),
            InfoItem('Kode Stok', stock.stockCode ?? '-', Icons.code),
            InfoItem('Satuan', stock.unit, Icons.scale),
            InfoItem('Tipe Stok', stock.stockTypeName ?? '-', Icons.category),
            InfoItem('Lokasi Gudang', stock.storageLocationName ?? '-', Icons.warehouse),
            InfoItem('Batch Number', stock.batchNumber ?? '-', Icons.production_quantity_limits),
          ]),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Stok & Kondisi
          // ==================================================
          _buildSectionTitle('Stok & Kondisi'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem(
              'Status Stok',
              stockStatus.label,
              Icons.inventory,
              color: stockStatus.color,
            ),
            InfoItem(
              'Stok Saat Ini',
              '${stock.currentStock} ${stock.unit}',
              Icons.inventory_2,
            ),
            InfoItem(
              'Minimum Stok',
              '${stock.minimumStock} ${stock.unit}',
              Icons.warning_amber,
              color: stock.isLowStock ? Colors.orange : null,
            ),
            InfoItem(
              'Kondisi Stok',
              stock.stockCondition == 'GOOD' ? 'Baik' : 'Stok Rendah',
              Icons.check_circle,
              color: stock.stockCondition == 'GOOD' ? Colors.green : Colors.orange,
            ),
            InfoItem(
              'Tanggal Kadaluarsa',
              stock.expiryDate != null 
                  ? _formatDate(stock.expiryDate!) 
                  : '-',
              Icons.event_busy,
              color: _getExpiryDateColor(stock.expiryDate),
            ),
            InfoItem(
              'Status Aktif',
              stock.isActive ? 'Aktif' : 'Tidak Aktif',
              Icons.power_settings_new,
              color: stock.isActive ? Colors.green : Colors.red,
            ),
          ]),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Riwayat Terakhir
          // ==================================================
          _buildSectionTitle('Riwayat Terakhir'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem('Stok Opname Terakhir', _formatDate(stock.lastOpnameAt), Icons.assignment),
            InfoItem('Stok Opname Oleh', stock.lastOpnameByName ?? '-', Icons.person),
            InfoItem('Stok Opname Catatan', stock.lastOpnameNote ?? '-', Icons.note),
            InfoItem('Stok Opname Hasil', '${stock.lastOpnameStock ?? '-'} ${stock.unit}', Icons.numbers),
          ]),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Pembelian Terakhir
          // ==================================================
          if (stock.lastPurchaseAt != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Pembelian Terakhir'),
                const SizedBox(height: 8),
                _buildInfoGrid([
                  InfoItem('Tanggal', _formatDate(stock.lastPurchaseAt!), Icons.calendar_today),
                  InfoItem('Oleh', stock.lastPurchaseByName ?? '-', Icons.person),
                  InfoItem('Jumlah', '${stock.lastPurchaseQty ?? '-'} ${stock.unit}', Icons.shopping_cart),
                  InfoItem('Harga', _formatCurrency(stock.lastPurchasePrice), Icons.attach_money),
                ]),
                const SizedBox(height: 16),
              ],
            ),

          // ==================================================
          // SECTION: Penggunaan Terakhir
          // ==================================================
          if (stock.lastUsageAt != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Penggunaan Terakhir'),
                const SizedBox(height: 8),
                _buildInfoGrid([
                  InfoItem('Tanggal', _formatDate(stock.lastUsageAt!), Icons.calendar_today),
                  InfoItem('Oleh', stock.lastUsageByName ?? '-', Icons.person),
                  InfoItem('Jumlah', '${stock.lastUsageQty ?? '-'} ${stock.unit}', Icons.production_quantity_limits),
                ]),
                const SizedBox(height: 16),
              ],
            ),

          // ==================================================
          // SECTION: Deskripsi
          // ==================================================
          if (stock.description != null && stock.description!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Deskripsi'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    stock.description!,
                    style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // ==================================================
          // SECTION: Metadata (dibuat, diupdate)
          // ==================================================
          _buildSectionTitle('Informasi Sistem'),
          const SizedBox(height: 8),
          _buildInfoGrid([
            InfoItem('Dibuat Oleh', stock.createdByName ?? '-', Icons.person_add),
            InfoItem('Tanggal Dibuat', _formatDate(stock.createdAt), Icons.create),
            InfoItem('Terakhir Update', _formatDate(stock.updatedAt), Icons.update),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF01579B),
      ),
    );
  }

  Widget _buildHeaderCard(Stock stock, StockStatus stockStatus) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF01579B),
            const Color(0xFF0288D1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01579B).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Foto Stok - SQUARE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 80,
                height: 80,
                child: stock.photoUrl != null && stock.photoUrl!.isNotEmpty
                    ? Image.network(
                        stock.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(stock.stockName);
                        },
                      )
                    : _buildDefaultAvatar(stock.stockName),
              ),
            ),
            const SizedBox(width: 16),
            // Informasi Ringkas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: stockStatus.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stockStatus == StockStatus.empty ? Icons.inventory : 
                          (stockStatus == StockStatus.low ? Icons.warning : Icons.check_circle),
                          size: 12,
                          color: stockStatus.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stockStatus.label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: stockStatus.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stock.stockName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stok: ${stock.currentStock} ${stock.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (stock.stockCode != null && stock.stockCode!.isNotEmpty)
                        Text(
                          'Kode: ${stock.stockCode}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String stockName) {
    final initial = stockName.isNotEmpty ? stockName[0].toUpperCase() : 'S';
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<InfoItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
        childAspectRatio: 4.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (item.color ?? const Color(0xFF01579B)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 16,
                  color: item.color ?? const Color(0xFF01579B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.value,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: item.color ?? Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getExpiryDateColor(DateTime? expiryDate) {
    if (expiryDate == null) return Colors.grey;
    final now = DateTime.now();
    final daysLeft = expiryDate.difference(now).inDays;
    if (daysLeft < 0) return Colors.red;
    if (daysLeft < 30) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(num? value) {
    if (value == null) return '-';
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}

class InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  InfoItem(this.label, this.value, this.icon, {this.color});
}