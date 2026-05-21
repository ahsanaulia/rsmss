// lib/features/stock_request/presentations/stock_request_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_request_providers.dart';
import 'stock_request_form_page.dart';

class StockRequestListPage extends ConsumerStatefulWidget {
  const StockRequestListPage({super.key});

  @override
  ConsumerState<StockRequestListPage> createState() => _StockRequestListPageState();
}

class _StockRequestListPageState extends ConsumerState<StockRequestListPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data saat halaman dibuka
    Future.microtask(() {
      ref.invalidate(myRequestsProvider);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED_BY_ADMIN':
      case 'REJECTED_BY_LOGISTIC':
        return Colors.red;
      case 'PARTIALLY_FULFILLED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu Approval';
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED_BY_ADMIN':
        return 'Ditolak Admin';
      case 'REJECTED_BY_LOGISTIC':
        return 'Ditolak Logistik';
      case 'PARTIALLY_FULFILLED':
        return 'Sebagian Diambil';
      case 'COMPLETED':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myRequestsAsync = ref.watch(myRequestsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Stok Saya'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(myRequestsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myRequestsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: myRequestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada permintaan stok',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekan tombol + di bawah untuk membuat request',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final remaining = request.approvedQuantity != null
                    ? request.approvedQuantity! - request.fulfilledQuantity
                    : request.requestedQuantity - request.fulfilledQuantity;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                      child: Icon(
                        request.status == 'PENDING'
                            ? Icons.pending
                            : (request.status == 'APPROVED'
                                ? Icons.check_circle
                                : (request.status == 'COMPLETED'
                                    ? Icons.done_all
                                    : Icons.cancel)),
                        color: _getStatusColor(request.status),
                      ),
                    ),
                    title: Text(
                      request.requestNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${request.requestedStockName}'),
                        Text(
                          'Jumlah: ${request.requestedQuantity.toInt()} ${request.requestedUnit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (request.approvedQuantity != null && request.approvedQuantity != request.requestedQuantity)
                          Text(
                            'Disetujui: ${request.approvedQuantity!.toInt()} ${request.requestedUnit}',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        if (request.fulfilledQuantity > 0)
                          Text(
                            'Sudah diambil: ${request.fulfilledQuantity.toInt()} ${request.requestedUnit}',
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        if (remaining > 0 && request.status == 'APPROVED')
                          Text(
                            'Sisa: ${remaining.toInt()} ${request.requestedUnit}',
                            style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(request.status),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(request.requestDate),
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: request.status == 'PENDING'
                        ? const Icon(Icons.pending, color: Colors.orange)
                        : (request.status == 'APPROVED'
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null),
                    onTap: () {
                      // Bisa tampilkan detail request
                      _showDetailDialog(context, request);
                    },
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
                    ref.invalidate(myRequestsProvider);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StockRequestFormPage(),
            ),
          );
          if (result == true) {
            // Refresh list setelah membuat request
            ref.invalidate(myRequestsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Request Baru'),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.requestNumber),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Produk', request.requestedStockName),
              _detailRow('Jumlah Diminta', '${request.requestedQuantity.toInt()} ${request.requestedUnit}'),
              if (request.approvedQuantity != null)
                _detailRow('Disetujui', '${request.approvedQuantity!.toInt()} ${request.requestedUnit}'),
              _detailRow('Status', _getStatusText(request.status)),
              _detailRow('Tanggal', _formatDate(request.requestDate)),
              if (request.notes != null) _detailRow('Catatan', request.notes),
              if (request.approvalNotes != null) _detailRow('Catatan Approval', request.approvalNotes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}