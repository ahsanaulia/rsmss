// lib/features/stock_request/presentations/stock_request_fulfill_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_request_model.dart';
import '../providers/stock_request_providers.dart';

class StockRequestFulfillForm extends ConsumerStatefulWidget {
  final String requestId;
  final String requestNumber;
  final String stockId;
  final String stockName;
  final double approvedQuantity;
  final double fulfilledQuantity;
  final String unit;
  final double remaining;

  const StockRequestFulfillForm({
    super.key,
    required this.requestId,
    required this.requestNumber,
    required this.stockId,
    required this.stockName,
    required this.approvedQuantity,
    required this.fulfilledQuantity,
    required this.unit,
    required this.remaining,
  });

  @override
  ConsumerState<StockRequestFulfillForm> createState() =>
      _StockRequestFulfillFormState();
}

class _StockRequestFulfillFormState
    extends ConsumerState<StockRequestFulfillForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();

  String? _selectedBinId;
  String? _selectedBinName;
  String? _selectedStockInBinsId;
  double _availableStockInBin = 0;
  bool _isLoading = false;
  bool _isScanning = false;

  // List untuk multiple fulfillment dalam 1 session
  List<Map<String, dynamic>> _selectedItems = [];
  double _totalToTake = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBin() async {
  if (_barcodeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masukkan barcode bin terlebih dahulu')),
    );
    return;
  }

  setState(() => _isScanning = true);

  final controller = ref.read(stockRequestControllerProvider);
  final result = await controller.getAvailableStockInBins(
    widget.stockId,
    _barcodeController.text,
  );

  setState(() => _isScanning = false);

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Barcode tidak ditemukan atau stok tidak tersedia!')),
    );
    return;
  }

  setState(() {
    _selectedBinId = result['bin_id']?.toString();
    _selectedBinName = result['full_location_name']?.toString() ?? 
                       result['bin_code']?.toString() ?? 
                       'Bin';
    _selectedStockInBinsId = result['stock_in_bins_id']?.toString();
    _availableStockInBin = (result['quantity'] as num?)?.toDouble() ?? 0;
    _barcodeController.text = '';
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text('Bin terpilih: ${_selectedBinName ?? _selectedBinId}')),
  );
}

  Future<void> _selectBin() async {
  try {
    final bins = await ref.read(availableStockInBinsProvider(widget.stockId).future);

    if (!mounted) return;

    if (bins.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada stok yang tersedia di bin')),
      );
      return;
    }

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bin'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: bins.length,
            itemBuilder: (context, index) {
              final bin = bins[index];
              
              // ✅ AMAN: gunakan null check
              final location = bin['full_location_name'] != null 
                  ? bin['full_location_name'].toString() 
                  : (bin['bin_code']?.toString() ?? 'Bin tidak dikenal');
              
              final available = (bin['quantity'] as num?)?.toDouble() ?? 0;
              
              return ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(
                  location,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                subtitle: Text('Tersedia: ${available.toInt()} ${widget.unit}'),
                onTap: () => Navigator.pop(context, bin),
              );
            },
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

    if (selected != null) {
      setState(() {
        _selectedBinId = selected['bin_id']?.toString();
        _selectedBinName = selected['full_location_name']?.toString() ?? 
                           selected['bin_code']?.toString() ?? 
                           'Bin';
        _selectedStockInBinsId = selected['stock_in_bins_id']?.toString();
        _availableStockInBin = (selected['quantity'] as num?)?.toDouble() ?? 0;
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bins: $e')),
      );
    }
  }
}

  Future<void> _addToCart() async {
    if (_selectedBinId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bin terlebih dahulu')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    final remaining = widget.remaining - _totalToTake;
    if (quantity > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Jumlah melebihi sisa permintaan (${remaining.toInt()} ${widget.unit})')),
      );
      return;
    }

    if (quantity > _availableStockInBin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Stok di bin tidak mencukupi (${_availableStockInBin.toInt()} ${widget.unit})')),
      );
      return;
    }

    setState(() {
      _selectedItems.add({
        'stock_in_bins_id': _selectedStockInBinsId,
        'bin_id': _selectedBinId,
        'bin_name': _selectedBinName,
        'quantity': quantity,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      });
      _totalToTake += quantity;
      _quantityController.clear();
      _notesController.clear();
      _selectedBinId = null;
      _selectedBinName = null;
      _selectedStockInBinsId = null;
      _availableStockInBin = 0;
    });
  }

  Future<void> _submitFulfillment() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada item yang ditambahkan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(stockRequestControllerProvider);
      
      for (var item in _selectedItems) {
        final fulfillment = StockRequestFulfillmentModel(
          stockRequestId: widget.requestId,
          stockInBinsId: item['stock_in_bins_id'],
          binId: item['bin_id'],
          stockId: widget.stockId,
          batchNumber: '', // Akan diisi dari service
          expiryDate: DateTime.now(), // Akan diisi dari service
          quantity: item['quantity'],
          notes: item['notes'],
        );
        await controller.createFulfillment(fulfillment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Berhasil mengambil ${_totalToTake.toInt()} ${widget.unit} dari ${widget.requestNumber}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeItem(int index) {
    setState(() {
      _totalToTake -= _selectedItems[index]['quantity'];
      _selectedItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.remaining - _totalToTake;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ambil Stok: ${widget.requestNumber}'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Request
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.requestNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Produk: ${widget.stockName}'),
                    Text('Unit: ${widget.unit}'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Disetujui:'),
                        Text('${widget.approvedQuantity.toInt()} ${widget.unit}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sudah Diambil:'),
                        Text('${widget.fulfilledQuantity.toInt()} ${widget.unit}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SISA:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${remaining.toInt()} ${widget.unit}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: remaining > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pilih Bin
            const Text(
              'Pilih Bin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Barcode Scanner
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      hintText: 'Scan Barcode Bin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_scanner),
                    ),
                    onSubmitted: (_) => _scanBin(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scanBin,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _selectBin,
                icon: const Icon(Icons.list),
                label: const Text('Atau Pilih dari Daftar Bin'),
              ),
            ),

            if (_selectedBinName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedBinName!,
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            'Tersedia: ${_availableStockInBin.toInt()} ${widget.unit}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _selectedBinId = null;
                          _selectedBinName = null;
                          _selectedStockInBinsId = null;
                          _availableStockInBin = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah yang diambil',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.numbers),
                        suffixText: widget.unit,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Cart Items
            if (_selectedItems.isNotEmpty) ...[
              const Text(
                'Item yang akan diambil:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedItems.length,
                itemBuilder: (context, index) {
                  final item = _selectedItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.blue),
                      title: Text(item['bin_name']),
                      subtitle: Text('${(item['quantity'] as double).toInt()} ${widget.unit}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total akan diambil:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_totalToTake.toInt()} ${widget.unit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitFulfillment,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle),
                  label: const Text('SIMPAN PENGAMBILAN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}