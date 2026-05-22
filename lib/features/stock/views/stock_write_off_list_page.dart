// lib/features/stock/views/stock_write_off_list_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_write_off_provider.dart';
import 'stock_write_off_form_page.dart';

class StockWriteOffListPage extends ConsumerStatefulWidget {
  const StockWriteOffListPage({super.key});

  @override
  ConsumerState<StockWriteOffListPage> createState() =>
      _StockWriteOffListPageState();
}

class _StockWriteOffListPageState extends ConsumerState<StockWriteOffListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(stockWriteOffHistoryProvider);
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT':
        return 'Menunggu Verifikasi';
      case 'VERIFIED':
        return 'Terverifikasi';
      case 'COMPLETED':
        return 'Selesai';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.orange;
      case 'VERIFIED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'EXPIRED':
        return 'Kadaluarsa';
      case 'DAMAGED':
        return 'Rusak';
      case 'CONTAMINATED':
        return 'Terkontaminasi';
      case 'RECALL':
        return 'Recall Produk';
      default:
        return reason;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(stockWriteOffHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        title: Text(
          "Penghapusan Stok",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockWriteOffHistoryProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: historyState.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada pengajuan penghapusan stok',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StockWriteOffFormPage(),
                          ),
                        ).then((_) {
                          ref.invalidate(stockWriteOffHistoryProvider);
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Pengajuan Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01579B),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(
                        item.status,
                      ).withOpacity(0.2),
                      child: Icon(
                        item.status == 'COMPLETED'
                            ? Icons.check
                            : Icons.pending,
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
                        Text('${item.stockName ?? item.stockId}'),
                        Text(
                          '${item.quantity.toStringAsFixed(0)} ${item.unit} - ${_getReasonText(item.reason)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(item.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      _formatDate(item.requestedAt),
                      style: const TextStyle(fontSize: 11),
                    ),
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
                  onPressed: () {
                    ref.invalidate(stockWriteOffHistoryProvider);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StockWriteOffFormPage(),
            ),
          ).then((_) {
            // Refresh list setelah form ditutup
            ref.invalidate(stockWriteOffHistoryProvider);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Pengajuan Baru'),
      ),
    );
  }
}
