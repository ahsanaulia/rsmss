// lib/features/stock_in/presentations/stock_in_form_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stock_in_model.dart';
import '../providers/stock_in_providers.dart';

class StockInFormAdmin extends ConsumerStatefulWidget {
  final StockInModel? existingStockIn;
  
  const StockInFormAdmin({
    super.key,
    this.existingStockIn,
  });

  @override
  ConsumerState<StockInFormAdmin> createState() => _StockInFormAdminState();
}

class _StockInFormAdminState extends ConsumerState<StockInFormAdmin> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receiptNumberController;
  late TextEditingController _quantityController;
  late TextEditingController _batchNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _sourceReferenceController;
  late TextEditingController _returnedFromUnitController;
  late TextEditingController _returnReasonController;
  late TextEditingController _notesController;
  
  String? _selectedStockId;
  String _sourceType = 'PURCHASE';
  String _riskLevel = 'NORMAL';
  DateTime? _selectedExpiryDate;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _receiptNumberController = TextEditingController();
    _quantityController = TextEditingController();
    _batchNumberController = TextEditingController();
    _expiryDateController = TextEditingController();
    _sourceReferenceController = TextEditingController();
    _returnedFromUnitController = TextEditingController();
    _returnReasonController = TextEditingController();
    _notesController = TextEditingController();
    
    if (widget.existingStockIn != null) {
      _loadExistingData();
    } else {
      _generateReceiptNumber();
    }
  }

  Future<void> _generateReceiptNumber() async {
    final controller = ref.read(stockInControllerProvider);
    final receiptNumber = await controller.generateReceiptNumber();
    setState(() {
      _receiptNumberController.text = receiptNumber;
    });
  }

  void _loadExistingData() {
    final data = widget.existingStockIn!;
    _receiptNumberController.text = data.receiptNumber;
    _selectedStockId = data.stockId;
    _quantityController.text = data.quantity.toString();
    _batchNumberController.text = data.batchNumber;
    _selectedExpiryDate = data.expiryDate;
    _expiryDateController.text = _formatDate(data.expiryDate);
    _sourceType = data.sourceType;
    _sourceReferenceController.text = data.sourceReference ?? '';
    _returnedFromUnitController.text = data.returnedFromUnit ?? '';
    _returnReasonController.text = data.returnReason ?? '';
    _riskLevel = data.riskLevel;
    _notesController.text = data.notes ?? '';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        _expiryDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }
    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal kadaluarsa')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stockInModel = StockInModel(
        id: widget.existingStockIn?.id,
        receiptNumber: _receiptNumberController.text,
        stockId: _selectedStockId!,
        quantity: double.parse(_quantityController.text),
        batchNumber: _batchNumberController.text,
        expiryDate: _selectedExpiryDate!,
        sourceType: _sourceType,
        sourceReference: _sourceReferenceController.text.isEmpty ? null : _sourceReferenceController.text,
        returnedFromUnit: _returnedFromUnitController.text.isEmpty ? null : _returnedFromUnitController.text,
        returnReason: _returnReasonController.text.isEmpty ? null : _returnReasonController.text,
        receivedBy: Supabase.instance.client.auth.currentUser?.id,
        status: widget.existingStockIn?.status ?? 'RECEIVED',
        riskLevel: _riskLevel,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final controller = ref.read(stockInControllerProvider);
      
      if (widget.existingStockIn != null) {
        await controller.updateStockIn(stockInModel);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diupdate')),
          );
        }
      } else {
        await controller.createStockIn(stockInModel);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok masuk berhasil dicatat')),
          );
          _resetForm();
          await _generateReceiptNumber();
        }
      }
      
      if (mounted) {
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

  void _resetForm() {
    _formKey.currentState?.reset();
    _quantityController.clear();
    _batchNumberController.clear();
    _expiryDateController.clear();
    _sourceReferenceController.clear();
    _returnedFromUnitController.clear();
    _returnReasonController.clear();
    _notesController.clear();
    _selectedStockId = null;
    _selectedExpiryDate = null;
    _sourceType = 'PURCHASE';
    _riskLevel = 'NORMAL';
  }

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _quantityController.dispose();
    _batchNumberController.dispose();
    _expiryDateController.dispose();
    _sourceReferenceController.dispose();
    _returnedFromUnitController.dispose();
    _returnReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(availableStocksProvider);
    
    // Deteksi apakah layar lebar (landscape/tablet)
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingStockIn != null ? 'Edit Stok Masuk' : 'Tambah Stok Masuk'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: isWideScreen
                  ? _buildTwoColumnLayout(stocksAsync)
                  : _buildSingleColumnLayout(stocksAsync),
            ),
          ),
        ],
      ),
    );
  }

  // Layout 2 kolom untuk layar lebar (tablet/desktop)
  Widget _buildTwoColumnLayout(AsyncValue<List<Map<String, dynamic>>> stocksAsync) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Kiri
        Expanded(
          child: Column(
            children: [
              _buildReceiptNumberField(),
              const SizedBox(height: 16),
              _buildProductDropdown(stocksAsync),
              const SizedBox(height: 16),
              _buildQuantityField(),
              const SizedBox(height: 16),
              _buildBatchNumberField(),
              const SizedBox(height: 16),
              _buildExpiryDateField(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Kolom Kanan
        Expanded(
          child: Column(
            children: [
              _buildSourceTypeField(),
              const SizedBox(height: 16),
              _buildConditionalFields(),
              const SizedBox(height: 16),
              _buildRiskLevelField(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }

  // Layout 1 kolom untuk layar sempit (HP)
  Widget _buildSingleColumnLayout(AsyncValue<List<Map<String, dynamic>>> stocksAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReceiptNumberField(),
        const SizedBox(height: 16),
        _buildProductDropdown(stocksAsync),
        const SizedBox(height: 16),
        _buildQuantityField(),
        const SizedBox(height: 16),
        _buildBatchNumberField(),
        const SizedBox(height: 16),
        _buildExpiryDateField(),
        const SizedBox(height: 16),
        _buildSourceTypeField(),
        const SizedBox(height: 16),
        _buildConditionalFields(),
        const SizedBox(height: 16),
        _buildRiskLevelField(),
        const SizedBox(height: 16),
        _buildNotesField(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildReceiptNumberField() {
    return TextFormField(
      controller: _receiptNumberController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Nomor Penerimaan',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
    );
  }

  Widget _buildProductDropdown(AsyncValue<List<Map<String, dynamic>>> stocksAsync) {
    return stocksAsync.when(
      data: (stocks) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Pilih Produk',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.medication),
        ),
        value: _selectedStockId,
        items: [
          const DropdownMenuItem(value: null, child: Text('Pilih Produk')),
          ...stocks.map((stock) => DropdownMenuItem(
            value: stock['id'],
            child: Text(
              '${stock['stock_code']} - ${stock['stock_name']} '
              '(Stok: ${stock['current_stock']} ${stock['unit']})',
            ),
          )),
        ],
        onChanged: (value) {
          setState(() => _selectedStockId = value);
        },
        validator: (value) => value == null ? 'Produk harus dipilih' : null,
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Jumlah',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.numbers),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Jumlah harus diisi';
        if (double.tryParse(value) == null) return 'Jumlah harus angka';
        if (double.parse(value) <= 0) return 'Jumlah harus lebih dari 0';
        return null;
      },
    );
  }

  Widget _buildBatchNumberField() {
    return TextFormField(
      controller: _batchNumberController,
      decoration: const InputDecoration(
        labelText: 'Nomor Batch',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.qr_code), // Ganti ikon sesuai kebutuhan
      ),
      validator: (value) => value == null || value.isEmpty ? 'Nomor batch harus diisi' : null,
    );
  }

  Widget _buildExpiryDateField() {
    return TextFormField(
      controller: _expiryDateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Tanggal Kadaluarsa',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.keyboard_arrow_down),
      ),
      onTap: () => _selectExpiryDate(context),
      validator: (value) => value == null || value.isEmpty ? 'Tanggal kadaluarsa harus diisi' : null,
    );
  }

  Widget _buildSourceTypeField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Sumber Stok',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.source),
      ),
      value: _sourceType,
      items: const [
        DropdownMenuItem(value: 'PURCHASE', child: Text('Pembelian')),
        DropdownMenuItem(value: 'RETURN', child: Text('Pengembalian')),
        DropdownMenuItem(value: 'DONATION', child: Text('Donasi')),
        DropdownMenuItem(value: 'TRANSFER', child: Text('Transfer')),
      ],
      onChanged: (value) {
        setState(() => _sourceType = value!);
      },
    );
  }

  Widget _buildConditionalFields() {
    if (_sourceType == 'RETURN') {
      return Column(
        children: [
          TextFormField(
            controller: _returnedFromUnitController,
            decoration: const InputDecoration(
              labelText: 'Unit Pengembalian',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Alasan Pengembalian',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info),
            ),
            value: _returnReasonController.text.isEmpty ? null : _returnReasonController.text,
            items: const [
              DropdownMenuItem(value: null, child: Text('Pilih alasan')),
              DropdownMenuItem(value: 'SISA', child: Text('Sisa Pemakaian')),
              DropdownMenuItem(value: 'REJECT', child: Text('Reject/Rusak')),
              DropdownMenuItem(value: 'EXPIRED', child: Text('Kadaluarsa')),
            ],
            onChanged: (value) {
              setState(() => _returnReasonController.text = value ?? '');
            },
          ),
        ],
      );
    } else if (_sourceType == 'PURCHASE') {
      return TextFormField(
        controller: _sourceReferenceController,
        decoration: const InputDecoration(
          labelText: 'Nomor PO / Faktur',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.receipt_long),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRiskLevelField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Level Resiko',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.warning),
      ),
      value: _riskLevel,
      items: const [
        DropdownMenuItem(value: 'LOW', child: Text('Rendah')),
        DropdownMenuItem(value: 'NORMAL', child: Text('Normal')),
        DropdownMenuItem(value: 'HIGH', child: Text('Tinggi')),
        DropdownMenuItem(value: 'CRITICAL', child: Text('Kritis')),
      ],
      onChanged: (value) {
        setState(() => _riskLevel = value!);
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Catatan',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
            : const Icon(Icons.save),
        label: Text(widget.existingStockIn != null ? 'UPDATE' : 'SIMPAN'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}