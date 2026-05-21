// lib/features/stock_in_bins/presentations/put_away_form_mobile.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_in_bins_model.dart';
import '../providers/stock_in_bins_providers.dart';

class PutAwayFormMobile extends ConsumerStatefulWidget {
  final String stockInId;
  
  const PutAwayFormMobile({
    super.key,
    required this.stockInId,
  });

  @override
  ConsumerState<PutAwayFormMobile> createState() => _PutAwayFormMobileState();
}

class _PutAwayFormMobileState extends ConsumerState<PutAwayFormMobile> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  String? _selectedBinId;
  String? _selectedBinName;
  double _maxQuantity = 0;
  double _remainingQuantity = 0;
  String _stockUnit = '';
  String _stockName = '';
  String _batchNumber = '';
  DateTime _expiryDate = DateTime.now();
  String _receiptNumber = '';
  double _totalQuantity = 0;
  double _totalPutAway = 0;
  String _stockId = '';
  String _status = '';
  
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final detail = await ref.read(pendingStockInDetailProvider(widget.stockInId).future);
      
      final stockIn = detail['stockIn'];
      _remainingQuantity = detail['remaining'] as double;
      _maxQuantity = _remainingQuantity;
      _totalPutAway = detail['totalPutAway'] as double;
      _status = stockIn.status;
      
      _receiptNumber = stockIn.receiptNumber;
      _stockName = stockIn.stockName;
      _stockUnit = stockIn.unit;
      _batchNumber = stockIn.batchNumber;
      _expiryDate = stockIn.expiryDate;
      _totalQuantity = stockIn.quantity;
      _stockId = stockIn.stockId;
      
      setState(() => _isDataLoaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scanBin() async {
    if (_barcodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan barcode bin terlebih dahulu')),
      );
      return;
    }
    
    setState(() => _isScanning = true);
    
    final controller = ref.read(stockInBinsControllerProvider);
    final result = await controller.scanBin(_barcodeController.text);
    
    setState(() => _isScanning = false);
    
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode tidak ditemukan!')),
      );
      return;
    }
    
    setState(() {
      _selectedBinId = result['bin_id'];
      _selectedBinName = result['full_location_name'] ?? result['bin_code'];
      _barcodeController.text = '';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bin terpilih: ${_selectedBinName ?? _selectedBinId}')),
    );
  }

  Future<void> _selectBin() async {
    try {
      final bins = await ref.read(allBinsProvider.future);
      
      if (!mounted) return;
      
      if (bins.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada bin yang tersedia')),
        );
        return;
      }
      
      // Gunakan dialog dengan lebar terbatas untuk menghindari overflow
      final selected = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Bin'),
          content: SizedBox(
            width: math.min(400, MediaQuery.of(context).size.width - 40),
            height: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bins.length,
              itemBuilder: (context, index) {
                final bin = bins[index];
                final displayName = bin['full_location_name'] ?? bin['bin_code'];
                return ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedBinId = bin['bin_id'];
                      _selectedBinName = displayName;
                    });
                    Navigator.pop(context, bin);
                  },
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
          _selectedBinId = selected['bin_id'];
          _selectedBinName = selected['full_location_name'] ?? selected['bin_code'];
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

  Future<void> _submitForm() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi bin
    if (_selectedBinId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bin terlebih dahulu')),
      );
      return;
    }
    
    // Validasi quantity tidak melebihi sisa
    final quantity = double.parse(_quantityController.text);
    if (quantity > _remainingQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah melebihi sisa stok (${_remainingQuantity.toInt()} $_stockUnit)')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final putAway = StockInBinsModel(
        binId: _selectedBinId!,
        stockId: _stockId,
        batchNumber: _batchNumber,
        expiryDate: _expiryDate,
        quantity: quantity,
        stockInId: widget.stockInId,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      final controller = ref.read(stockInBinsControllerProvider);
      await controller.createPutAway(putAway);
      
      if (mounted) {
        // Berhasil, kembali ke list
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

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isDataLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Jika status sudah COMPLETED, tidak boleh masuk ke sini
    if (_status == 'COMPLETED') {
      return Scaffold(
        appBar: AppBar(title: const Text('Penempatan Stok')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('Stok sudah selesai ditempatkan'),
              Text('Tidak ada sisa yang perlu ditempatkan'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penempatan Stok'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: _remainingQuantity > 0 ? Colors.white : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _receiptNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Produk: $_stockName'),
                      Text('Batch: $_batchNumber'),
                      Text('Expiry: ${_formatDate(_expiryDate)}'),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total diterima:'),
                          Text('$_totalQuantity $_stockUnit'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sudah ditempatkan:'),
                          Text('$_totalPutAway $_stockUnit'),
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
                            '$_remainingQuantity $_stockUnit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _remainingQuantity > 0 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Barcode Scanner
              TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Scan Barcode Bin',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code_scanner),
                  suffixIcon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _scanBin,
                        ),
                ),
                onSubmitted: (_) => _scanBin(),
              ),
              const SizedBox(height: 8),
              
              // Or select from list
              Center(
                child: TextButton.icon(
                  onPressed: _selectBin,
                  icon: const Icon(Icons.list),
                  label: const Text('Atau Pilih dari Daftar Bin'),
                ),
              ),
              
              if (_selectedBinName != null) ...[
                const SizedBox(height: 16),
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
                        child: Text(
                          _selectedBinName!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          setState(() {
                            _selectedBinId = null;
                            _selectedBinName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Jumlah yang ditempatkan',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                  suffixText: _stockUnit,
                  helperText: 'Maksimal: ${_remainingQuantity.toInt()} $_stockUnit',
                ),
                keyboardType: TextInputType.number,
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
                  if (qty > _remainingQuantity) {
                    return 'Melebihi sisa stok (${_remainingQuantity.toInt()} $_stockUnit)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.move_to_inbox),
                  label: const Text('SIMPAN PENEMPATAN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}