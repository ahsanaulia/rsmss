// lib/features/stock/views/stock_write_off_approval_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_write_off_provider.dart';

class StockWriteOffApprovalPage extends ConsumerStatefulWidget {
  const StockWriteOffApprovalPage({super.key});

  @override
  ConsumerState<StockWriteOffApprovalPage> createState() => _StockWriteOffApprovalPageState();
}

class _StockWriteOffApprovalPageState extends ConsumerState<StockWriteOffApprovalPage> {
  String _filterStatus = 'ALL';
  String _searchQuery = '';
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(allWriteOffsProvider);
    });
  }

  void _log(String msg) {
    print('🔴 [APPROVAL_PAGE] $msg');
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT': return 'Menunggu Persetujuan';
      case 'APPROVED': return 'Disetujui (Stok Berkurang)';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT': return Colors.orange;
      case 'APPROVED': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'EXPIRED': return 'Kadaluarsa';
      case 'DAMAGED': return 'Rusak';
      case 'CONTAMINATED': return 'Terkontaminasi';
      case 'RECALL': return 'Recall Produk';
      default: return reason;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approveWriteOff(String id) async {
    _log('🔴🔴🔴 TOMBOL DIKLIK! ID: $id 🔴🔴🔴');
    
    final notifier = ref.read(stockWriteOffStateProvider.notifier);
    final success = await notifier.approveWriteOff(id);
    
    _log('approveWriteOff success: $success');
    
    if (success && mounted) {
      ref.invalidate(allWriteOffsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write-off disetujui, stok berkurang'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _log('approveWriteOff GAGAL!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal approve write-off'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allWriteOffsAsync = ref.watch(allWriteOffsProvider);
    _log('build dipanggil');

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        title: Text(
          "Approval Penghapusan Stok",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 40,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: _filterStatus,
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('Semua Status')),
                DropdownMenuItem(value: 'DRAFT', child: Text('Menunggu')),
                DropdownMenuItem(value: 'APPROVED', child: Text('Disetujui')),
              ],
              onChanged: (value) => setState(() => _filterStatus = value!),
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          Container(
            width: 200,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari...',
                prefixIcon: Icon(Icons.search, size: 18),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(allWriteOffsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allWriteOffsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: allWriteOffsAsync.when(
          data: (items) {
            _log('data received, items count: ${items.length}');
            
            var filteredItems = items.where((item) {
              if (_filterStatus != 'ALL' && item.status != _filterStatus) return false;
              if (_searchQuery.isNotEmpty) {
                return item.writeOffNumber.toLowerCase().contains(_searchQuery) ||
                    (item.stockName ?? '').toLowerCase().contains(_searchQuery);
              }
              return true;
            }).toList();

            if (filteredItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Tidak ada pengajuan penghapusan stok'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isExpanded = _expandedIds.contains(item.id);
                final isDraft = item.status == 'DRAFT';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedIds.remove(item.id);
                            } else {
                              _expandedIds.add(item.id!);
                            }
                          });
                        },
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(item.status).withOpacity(0.2),
                          child: Icon(
                            item.status == 'APPROVED' ? Icons.check_circle : Icons.pending,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                        title: Text(
                          item.writeOffNumber,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.stockName ?? '-'),
                            Text(
                              '${item.quantity.toStringAsFixed(0)} ${item.unit} - ${_getReasonText(item.reason)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(item.status),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Nomor', item.writeOffNumber),
                              _infoRow('Produk', item.stockName ?? '-'),
                              _infoRow('Batch', item.batchNumber),
                              _infoRow('Expiry', _formatDate(item.expiryDate)),
                              _infoRow('Jumlah', '${item.quantity.toStringAsFixed(0)} ${item.unit}'),
                              _infoRow('Alasan', _getReasonText(item.reason)),
                              if (item.reasonNote != null) _infoRow('Catatan Alasan', item.reasonNote!),
                              if (item.notes != null) _infoRow('Catatan', item.notes!),
                              _infoRow('Pengaju', item.requestedBy ?? '-'),
                              _infoRow('Tanggal', _formatDate(item.requestedAt)),
                              const Divider(),
                              if (isDraft)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _approveWriteOff(item.id!),
                                    icon: const Icon(Icons.check_circle, size: 18),
                                    label: const Text('SETUJUI & HAPUS STOK'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              if (item.status == 'APPROVED')
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Stok sudah dikurangi',
                                          style: GoogleFonts.poppins(color: Colors.green.shade800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allWriteOffsProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}