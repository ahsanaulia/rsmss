// lib/features/stock_request/presentations/stock_request_approval_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_request_providers.dart';
import 'stock_request_admin_form_page.dart';

class StockRequestApprovalPage extends ConsumerStatefulWidget {
  const StockRequestApprovalPage({super.key});

  @override
  ConsumerState<StockRequestApprovalPage> createState() =>
      _StockRequestApprovalPageState();
}

class _StockRequestApprovalPageState
    extends ConsumerState<StockRequestApprovalPage> {
  String _filterStatus = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(allRequestsProvider);
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

  String _getFilterLabel(String status) {
    switch (status) {
      case 'ALL':
        return 'Semua';
      case 'PENDING':
        return 'Menunggu';
      case 'APPROVED':
        return 'Disetujui';
      case 'COMPLETED':
        return 'Selesai';
      case 'REJECTED_BY_ADMIN':
        return 'Ditolak';
      default:
        return 'Filter';
    }
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

  @override
  Widget build(BuildContext context) {
    final allRequestsAsync = ref.watch(allRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Permintaan Stok'),
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
          // Filter dropdown - PopupMenuButton hemat tempat
          PopupMenuButton<String>(
            initialValue: _filterStatus,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getFilterLabel(_filterStatus),
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 18),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('Semua Status')),
              const PopupMenuItem(value: 'PENDING', child: Text('Menunggu')),
              const PopupMenuItem(value: 'APPROVED', child: Text('Disetujui')),
              const PopupMenuItem(value: 'COMPLETED', child: Text('Selesai')),
              const PopupMenuItem(value: 'REJECTED_BY_ADMIN', child: Text('Ditolak')),
            ],
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
          ),
          
          // Search - IconButton membuka dialog
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
          
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(allRequestsProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allRequestsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: allRequestsAsync.when(
          data: (requests) {
            var filteredRequests = requests.where((r) {
              if (_filterStatus != 'ALL' && r.status != _filterStatus)
                return false;
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
                    Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada permintaan',
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
                final remaining = request.approvedQuantity != null
                    ? request.approvedQuantity! - request.fulfilledQuantity
                    : request.requestedQuantity - request.fulfilledQuantity;

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
                        request.status == 'PENDING'
                            ? Icons.pending
                            : (request.status == 'APPROVED'
                                ? Icons.check_circle
                                : (request.status == 'COMPLETED'
                                    ? Icons.done_all
                                    : Icons.cancel)),
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
                          'Diminta: ${request.requestedQuantity.toInt()} ${request.requestedUnit}',
                          style: const TextStyle(fontSize: 11),
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
                    trailing: request.status == 'PENDING'
                        ? const Icon(Icons.pending, color: Colors.orange)
                        : null,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Ruangan', request.roomName ?? '-'),
                          _infoRow('Tujuan', request.purpose ?? '-'),
                          _infoRow(
                            'Tanggal Request',
                            _formatDate(request.requestDate),
                          ),
                          if (request.notes != null && request.notes!.isNotEmpty)
                            _infoRow('Catatan', request.notes!),
                          if (request.approvedQuantity != null)
                            _infoRow(
                              'Disetujui',
                              '${request.approvedQuantity!.toInt()} ${request.requestedUnit}',
                            ),
                          if (request.fulfilledQuantity > 0)
                            _infoRow(
                              'Sudah Diambil',
                              '${request.fulfilledQuantity.toInt()} ${request.requestedUnit}',
                            ),
                          if (request.approvalNotes != null &&
                              request.approvalNotes!.isNotEmpty)
                            _infoRow('Catatan Approval', request.approvalNotes!),
                          const Divider(),
                          if (request.status == 'PENDING')
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _openApproveDialog(request),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('SETUJUI'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _openRejectDialog(request),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('TOLAK'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (request.status == 'APPROVED' &&
                              request.fulfilledQuantity <
                                  (request.approvedQuantity ??
                                      request.requestedQuantity))
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Menunggu pengambilan oleh logistik. Sisa: ${remaining.toInt()} ${request.requestedUnit}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    ref.invalidate(allRequestsProvider);
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
              builder: (context) => const StockRequestAdminFormPage(),
            ),
          );
          if (result == true) {
            ref.invalidate(allRequestsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Request untuk Pegawai'),
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

  void _openApproveDialog(dynamic request) {
    final _formKey = GlobalKey<FormState>();

    String? _editedStockId = request.requestedStockId;
    String? _editedStockName = request.requestedStockName;
    String? _editedStockUnit = request.requestedUnit;
    double _editedQuantity = request.requestedQuantity.toDouble();
    String _approvalNotes = '';

    final _quantityController =
        TextEditingController(text: request.requestedQuantity.toString());

    bool _isProductChanged = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Setujui Permintaan'),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informasi Peminta
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peminta: ${request.requesterName}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ruangan: ${request.roomName ?? '-'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Tujuan: ${request.purpose ?? '-'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        'EDIT PERMINTAAN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Produk Diminta: ${request.requestedStockName}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      // Dropdown Ganti Produk
                      Consumer(
                        builder: (context, ref, child) {
                          final stocksAsync =
                              ref.watch(stockRequestStocksProvider);
                          return stocksAsync.when(
                            data: (stocks) {
                              return DropdownButtonFormField<String?>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Ganti Produk (opsional)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                value: _editedStockId,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('-- Tetap produk asli --'),
                                  ),
                                  ...stocks.map((stock) {
                                    return DropdownMenuItem<String?>(
                                      value: stock['id'].toString(),
                                      child: Text(
                                        '${stock['stock_name']} (Stok: ${stock['current_stock']} ${stock['unit']})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setDialogState(() {
                                    _editedStockId = value;
                                    _isProductChanged = true;
                                    if (value == null) {
                                      _editedStockName =
                                          request.requestedStockName;
                                      _editedStockUnit = request.requestedUnit;
                                    } else {
                                      final selected = stocks.firstWhere(
                                        (s) => s['id'].toString() == value,
                                        orElse: () => {},
                                      );
                                      _editedStockName = selected['stock_name']
                                          as String?;
                                      _editedStockUnit =
                                          selected['unit'] as String?;
                                    }
                                  });
                                },
                              );
                            },
                            loading: () =>
                                const LinearProgressIndicator(minHeight: 40),
                            error: (error, stack) =>
                                Text('Error: $error', style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Disetujui *',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          suffixText: _editedStockUnit ?? request.requestedUnit,
                          helperText:
                              'Bisa diubah dari ${request.requestedQuantity.toInt()} ${request.requestedUnit}',
                          helperMaxLines: 2,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _editedQuantity = double.tryParse(value) ?? 0;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah harus diisi';
                          }
                          final qty = double.tryParse(value);
                          if (qty == null) {
                            return 'Jumlah harus angka';
                          }
                          if (qty <= 0) {
                            return 'Jumlah harus lebih dari 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_isProductChanged ||
                          _editedQuantity != request.requestedQuantity)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Perubahan yang akan disimpan:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              if (_editedQuantity != request.requestedQuantity)
                                Text(
                                  '• Jumlah: ${request.requestedQuantity.toInt()} → ${_editedQuantity.toInt()} ${_editedStockUnit ?? request.requestedUnit}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              if (_isProductChanged && _editedStockId != null)
                                Text(
                                  '• Produk: ${request.requestedStockName} → $_editedStockName',
                                  style: const TextStyle(fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Divider(),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Catatan Approval (opsional)',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        maxLines: 2,
                        onChanged: (value) => _approvalNotes = value,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final approvedQuantity =
                      double.parse(_quantityController.text);

                  final controller = ref.read(stockRequestControllerProvider);
                  await controller.approveRequest(
                    request.id!,
                    approvedQuantity,
                    _editedStockId,
                    _editedStockName,
                    _editedStockUnit,
                    _approvalNotes.isEmpty ? null : _approvalNotes,
                  );

                  if (mounted) {
                    ref.invalidate(allRequestsProvider);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Request ${_isProductChanged ? "diedit dan " : ""}disetujui!',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('SETUJUI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openRejectDialog(dynamic request) {
    final _formKey = GlobalKey<FormState>();
    String _rejectionReason = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        content: Form(
          key: _formKey,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Alasan Penolakan *',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) =>
                value == null || value.isEmpty ? 'Alasan harus diisi' : null,
            onChanged: (value) => _rejectionReason = value,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final controller = ref.read(stockRequestControllerProvider);
              await controller.rejectRequest(
                request.id!,
                _rejectionReason,
                'ADMIN',
              );

              if (mounted) {
                ref.invalidate(allRequestsProvider);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request ditolak'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.close, size: 18),
            label: const Text('TOLAK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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