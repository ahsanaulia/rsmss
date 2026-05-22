// lib/features/stock_request/presentations/stock_request_fulfillment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_request_providers.dart';
import 'stock_request_fulfill_form.dart';

class StockRequestFulfillmentPage extends ConsumerStatefulWidget {
  const StockRequestFulfillmentPage({super.key});

  @override
  ConsumerState<StockRequestFulfillmentPage> createState() =>
      _StockRequestFulfillmentPageState();
}

class _StockRequestFulfillmentPageState
    extends ConsumerState<StockRequestFulfillmentPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(approvedRequestsProvider);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
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
      case 'APPROVED':
        return 'Menunggu Diambil';
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
    final approvedRequestsAsync = ref.watch(approvedRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengambilan Stok'),
        elevation: 2,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF01579B), Color(0xFF0288D1)],
              ),
            ),
          ),
        ),
        actions: [
          // Search
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search, color: Colors.black87, size: 18),
            ),
            onPressed: () => _showSearchDialog(),
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(approvedRequestsProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(approvedRequestsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: approvedRequestsAsync.when(
          data: (requests) {
            // Filter berdasarkan search
            var filteredRequests = requests.where((r) {
              if (_searchQuery.isNotEmpty) {
                return r.requestNumber.toLowerCase().contains(_searchQuery) ||
                    r.requestedStockName.toLowerCase().contains(_searchQuery) ||
                    r.requesterName.toLowerCase().contains(_searchQuery);
              }
              return true;
            }).toList();

            if (filteredRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: Colors.green.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada permintaan yang perlu diambil',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semua request sudah selesai diambil',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                final approvedQty = request.approvedQuantity ?? request.requestedQuantity;
                final remaining = approvedQty - request.fulfilledQuantity;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor:
                          _getStatusColor(request.status).withOpacity(0.2),
                      radius: 20,
                      child: Icon(
                        request.status == 'APPROVED'
                            ? Icons.pending_actions
                            : Icons.incomplete_circle,
                        size: 20,
                        color: _getStatusColor(request.status),
                      ),
                    ),
                    title: Text(
                      '${request.requestNumber} - ${request.requesterName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requestedStockName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Disetujui: ${approvedQty.toInt()} ${request.requestedUnit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sisa: ${remaining.toInt()} ${request.requestedUnit}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: remaining > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(request.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.inventory_2, color: Colors.blue),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Peminta', request.requesterName),
                          _infoRow('Ruangan', request.roomName ?? '-'),
                          _infoRow('Tujuan', request.purpose ?? '-'),
                          _infoRow('Batch', request.requestedBatch ?? '-'),
                          _infoRow(
                              'Tanggal Request', _formatDate(request.requestDate)),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StockRequestFulfillForm(
                                          requestId: request.id!,
                                          requestNumber: request.requestNumber,
                                          stockId: request.requestedStockId,
                                          stockName: request.requestedStockName,
                                          approvedQuantity: approvedQty,
                                          fulfilledQuantity:
                                              request.fulfilledQuantity,
                                          unit: request.requestedUnit,
                                          remaining: remaining,
                                        ),
                                      ),
                                    ).then((_) {
                                      ref.invalidate(approvedRequestsProvider);
                                    });
                                  },
                                  icon: const Icon(Icons.inventory, size: 18),
                                  label: const Text('AMBIL STOK'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  onPressed: () {
                    ref.invalidate(approvedRequestsProvider);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    String tempQuery = _searchQuery;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Permintaan'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cari nomor request, produk, atau peminta...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            tempQuery = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = tempQuery.toLowerCase();
              });
              Navigator.pop(context);
            },
            child: const Text('Cari'),
          ),
        ],
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
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
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