// lib/features/stock_in_bins/presentations/put_away_form_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_in_bins_model.dart';
import '../providers/stock_in_bins_providers.dart';

class PutAwayFormAdmin extends ConsumerStatefulWidget {
  final String stockInId;
  
  const PutAwayFormAdmin({
    super.key,
    required this.stockInId,
  });

  @override
  ConsumerState<PutAwayFormAdmin> createState() => _PutAwayFormAdminState();
}

class _PutAwayFormAdminState extends ConsumerState<PutAwayFormAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  String? _selectedBinId;
  String? _selectedBinName;
  String? _selectedBinFullLocation;
  double _maxQuantity = 0;
  double _remainingQuantity = 0;
  String _stockUnit = '';
  String _stockName = '';
  String _batchNumber = '';
  DateTime _expiryDate = DateTime.now();
  String _receiptNumber = '';
  double _totalQuantity = 0;
  double _totalPutAway = 0;
  String _stockId = '';  // ← TAMBAHKAN: ID dari tabel stocks
  
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isDataLoaded = false;
  
  // Untuk search/filter bin
  String _binSearchQuery = '';
  List<Map<String, dynamic>> _allBins = [];
  List<Map<String, dynamic>> _filteredBins = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBins();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final detail = await ref.read(pendingStockInDetailProvider(widget.stockInId).future);
      
      final stockIn = detail['stockIn'];
      _remainingQuantity = detail['remaining'] as double;
      _maxQuantity = _remainingQuantity;
      _totalPutAway = detail['totalPutAway'] as double;
      
      _receiptNumber = stockIn.receiptNumber;
      _stockName = stockIn.stockName;
      _stockUnit = stockIn.unit;
      _batchNumber = stockIn.batchNumber;
      _expiryDate = stockIn.expiryDate;
      _totalQuantity = stockIn.quantity;
      _stockId = stockIn.stockId;  // ← AMBIL STOCK ID YANG BENAR
      
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

  Future<void> _loadBins() async {
    try {
      _allBins = await ref.read(allBinsProvider.future);
      _filteredBins = _allBins;
      setState(() {});
    } catch (e) {
      debugPrint('Error loading bins: $e');
    }
  }

  void _filterBins(String query) {
    setState(() {
      _binSearchQuery = query;
      if (query.isEmpty) {
        _filteredBins = _allBins;
      } else {
        _filteredBins = _allBins.where((bin) {
          final location = (bin['full_location_name'] ?? bin['bin_code']).toLowerCase();
          return location.contains(query.toLowerCase());
        }).toList();
      }
    });
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
      _selectedBinName = result['bin_code'];
      _selectedBinFullLocation = result['full_location_name'];
      _barcodeController.text = '';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bin terpilih: ${_selectedBinFullLocation ?? _selectedBinName}')),
    );
  }

  void _openBinSelector() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Pilih Bin'),
            content: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari lokasi bin...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      setDialogState(() {
                        _filterBins(query);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredBins.length,
                      itemBuilder: (context, index) {
                        final bin = _filteredBins[index];
                        final location = bin['full_location_name'] ?? bin['bin_code'];
                        final currentStock = bin['current_quantity'] ?? 0;
                        
                        return ListTile(
                          leading: const Icon(Icons.inventory),
                          title: Text(location),
                          subtitle: Text('Stok saat ini: $currentStock ${bin['unit'] ?? ''}'),
                          onTap: () {
                            setState(() {
                              _selectedBinId = bin['bin_id'];
                              _selectedBinName = bin['bin_code'];
                              _selectedBinFullLocation = bin['full_location_name'];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBinId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bin terlebih dahulu')),
      );
      return;
    }
    
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
        stockId: _stockId,  // ← GUNAKAN STOCK ID YANG BENAR
        batchNumber: _batchNumber,
        expiryDate: _expiryDate,
        quantity: quantity,
        stockInId: widget.stockInId,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      final controller = ref.read(stockInBinsControllerProvider);
      await controller.createPutAway(putAway);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Put away berhasil!')),
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

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    
    if (_isLoading && !_isDataLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Jika status sudah COMPLETED, tidak boleh masuk ke sini
    if (_remainingQuantity <= 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Penempatan Stok'),
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: isWideScreen
              ? _buildTwoColumnLayout()
              : _buildSingleColumnLayout(),
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri - Info Stock In
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Penerimaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const Divider(),
                  _infoRow('Nomor Penerimaan', _receiptNumber),
                  _infoRow('Produk', _stockName),
                  _infoRow('Batch', _batchNumber),
                  _infoRow('Expiry Date', _formatDate(_expiryDate)),
                  const Divider(),
                  _infoRow('Total Diterima', '${_totalQuantity.toInt()} $_stockUnit'),
                  _infoRow('Sudah di Put Away', '${_totalPutAway.toInt()} $_stockUnit'),
                  _infoRow(
                    'SISA',
                    '${_remainingQuantity.toInt()} $_stockUnit',
                    isWarning: _remainingQuantity > 0,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        
        // Kolom Kanan - Form Put Away
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form Penempatan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const Divider(),
                  
                  // Barcode Scanner
                  _buildBarcodeScanner(),
                  const SizedBox(height: 16),
                  
                  // Selected Bin Display
                  if (_selectedBinId != null)
                    _buildSelectedBinCard(),
                  
                  // Or select from list
                  Center(
                    child: TextButton.icon(
                      onPressed: _openBinSelector,
                      icon: const Icon(Icons.list),
                      label: const Text('Atau Pilih dari Daftar Bin'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                      if (value == null || value.isEmpty) return 'Jumlah harus diisi';
                      final qty = double.tryParse(value);
                      if (qty == null) return 'Jumlah harus angka';
                      if (qty <= 0) return 'Jumlah harus lebih dari 0';
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
                  const SizedBox(height: 24),
                  
                  // Submit Button
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
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Penerimaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Divider(),
                _infoRow('Nomor Penerimaan', _receiptNumber),
                _infoRow('Produk', _stockName),
                _infoRow('Batch', _batchNumber),
                _infoRow('Expiry Date', _formatDate(_expiryDate)),
                const Divider(),
                _infoRow('Total Diterima', '${_totalQuantity.toInt()} $_stockUnit'),
                _infoRow('Sudah di Put Away', '${_totalPutAway.toInt()} $_stockUnit'),
                _infoRow(
                  'SISA',
                  '${_remainingQuantity.toInt()} $_stockUnit',
                  isWarning: _remainingQuantity > 0,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Penempatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const Divider(),
                _buildBarcodeScanner(),
                const SizedBox(height: 16),
                if (_selectedBinId != null) _buildSelectedBinCard(),
                Center(
                  child: TextButton.icon(
                    onPressed: _openBinSelector,
                    icon: const Icon(Icons.list),
                    label: const Text('Atau Pilih dari Daftar Bin'),
                  ),
                ),
                const SizedBox(height: 16),
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
                    if (value == null || value.isEmpty) return 'Jumlah harus diisi';
                    final qty = double.tryParse(value);
                    if (qty == null) return 'Jumlah harus angka';
                    if (qty <= 0) return 'Jumlah harus lebih dari 0';
                    if (qty > _remainingQuantity) {
                      return 'Melebihi sisa stok (${_remainingQuantity.toInt()} $_stockUnit)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
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
      ],
    );
  }

  Widget _buildBarcodeScanner() {
    return Row(
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
    );
  }

  Widget _buildSelectedBinCard() {
    return Container(
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
                Text(
                  _selectedBinFullLocation ?? _selectedBinName ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (_selectedBinName != null && _selectedBinFullLocation != null)
                  Text(
                    _selectedBinName!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                _selectedBinFullLocation = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isWarning = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isWarning ? Colors.orange : (isBold ? Colors.black87 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}