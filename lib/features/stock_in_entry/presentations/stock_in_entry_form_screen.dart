// lib/features/stock_in_entry/presentations/stock_in_entry_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stock_in_entry_provider.dart';
import '../../../../crud/stocks/providers/stock_providers.dart';
import '../../../../crud/stocks/providers/stock_state.dart';

class StockInEntryFormDialog extends ConsumerStatefulWidget {
  const StockInEntryFormDialog({super.key});

  @override
  ConsumerState<StockInEntryFormDialog> createState() => _StockInEntryFormDialogState();
}

class _StockInEntryFormDialogState extends ConsumerState<StockInEntryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _quantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _sourceIdController = TextEditingController();
  final _returnedByController = TextEditingController();
  final _returnedFromUnitController = TextEditingController();
  
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));
  String _selectedSourceType = 'PURCHASE';
  String? _selectedStockId;
  String? _selectedStockName;
  String? _selectedStockCode;
  String? _selectedStockUnit;
  String? _selectedReturnReason;

  @override
  void dispose() {
    _quantityController.dispose();
    _batchNumberController.dispose();
    _sourceIdController.dispose();
    _returnedByController.dispose();
    _returnedFromUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(stockInEntryFormProvider);
    final notifier = ref.read(stockInEntryFormProvider.notifier);
    final stocksState = ref.watch(stockListProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _selectedSourceType == 'RETURN' ? Icons.assignment_return : Icons.add_box,
            color: const Color(0xFF01579B),
          ),
          const SizedBox(width: 12),
          Text(
            _selectedSourceType == 'RETURN' ? 'Stok Masuk (Return)' : 'Stok Masuk (Pembelian)',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSourceTypeDropdown(),
                const SizedBox(height: 16),
                _buildProductField(stocksState),
                const SizedBox(height: 16),
                _buildQuantityField(),
                const SizedBox(height: 16),
                _buildBatchNumberField(),
                const SizedBox(height: 16),
                _buildExpiryDateField(),
                const SizedBox(height: 16),
                _buildSourceIdField(),
                if (_selectedSourceType == 'RETURN') ...[
                  const Divider(height: 24),
                  const Text('Data Pengembalian', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildReturnedByField(),
                  const SizedBox(height: 16),
                  _buildReturnedFromUnitField(),
                  const SizedBox(height: 16),
                  _buildReturnReasonDropdown(),
                ],
                if (formState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formState.error!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: formState.isSubmitting ? null : () {
            notifier.reset();
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: formState.isSubmitting ? null : () async {
            if (!_formKey.currentState!.validate()) return;
            
            notifier.setField('stockId', _selectedStockId);
            notifier.setField('quantity', double.tryParse(_quantityController.text) ?? 0);
            notifier.setField('batchNumber', _batchNumberController.text);
            notifier.setField('expiryDate', _selectedExpiryDate);
            notifier.setField('sourceType', _selectedSourceType);
            notifier.setField('sourceId', _sourceIdController.text.isNotEmpty ? _sourceIdController.text : null);
            notifier.setField('returnedBy', _returnedByController.text.isNotEmpty ? _returnedByController.text : null);
            notifier.setField('returnedFromUnit', _returnedFromUnitController.text.isNotEmpty ? _returnedFromUnitController.text : null);
            notifier.setField('returnReason', _selectedReturnReason);
            
            final success = await notifier.submit();
            
            if (success && mounted) {
              notifier.reset();
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF01579B),
            foregroundColor: Colors.white,
          ),
          child: formState.isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildSourceTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSourceType,
      decoration: const InputDecoration(
        labelText: 'Sumber Stok',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'PURCHASE', child: Text('Pembelian')),
        DropdownMenuItem(value: 'RETURN', child: Text('Return (Sisa Pakai)')),
        DropdownMenuItem(value: 'DONATION', child: Text('Donasi')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSourceType = value!;
        });
      },
    );
  }

  Widget _buildProductField(StockListState stocksState) {
    final isLoading = stocksState.isLoading;
    final stocks = stocksState.stocks;
    final error = stocksState.error;

    if (isLoading) {
      return  DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'Produk'),
        items: [],
        onChanged: null,
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Error: $error', style: TextStyle(color: Colors.red.shade700)),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedStockId,
      decoration: const InputDecoration(
        labelText: 'Produk *',
        border: OutlineInputBorder(),
      ),
      items: stocks.map((stock) {
        return DropdownMenuItem<String>(
          value: stock.id,
          child: Text('${stock.stockCode} - ${stock.stockName} (${stock.unit})'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStockId = value;
          final selected = stocks.firstWhere((s) => s.id == value);
          _selectedStockName = selected.stockName;
          _selectedStockCode = selected.stockCode;
          _selectedStockUnit = selected.unit;
        });
      },
      validator: (value) => value == null ? 'Pilih produk' : null,
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Jumlah *',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
        if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
        return null;
      },
    );
  }

  Widget _buildBatchNumberField() {
    return TextFormField(
      controller: _batchNumberController,
      decoration: const InputDecoration(
        labelText: 'Batch Number *',
        border: OutlineInputBorder(),
        hintText: 'Contoh: AMX-2025-001',
      ),
      validator: (value) => value == null || value.isEmpty ? 'Batch number wajib diisi' : null,
    );
  }

  Widget _buildExpiryDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedExpiryDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 1825)),
        );
        if (date != null) {
          setState(() {
            _selectedExpiryDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tanggal Kadaluarsa *',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMMM yyyy', 'id').format(_selectedExpiryDate)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceIdField() {
    return TextFormField(
      controller: _sourceIdController,
      decoration: const InputDecoration(
        labelText: 'ID Sumber (PO / Stock Out ID)',
        border: OutlineInputBorder(),
        hintText: 'Opsional: PO-001 atau SO-102',
      ),
    );
  }

  Widget _buildReturnedByField() {
    return TextFormField(
      controller: _returnedByController,
      decoration: const InputDecoration(
        labelText: 'Dikembalikan Oleh *',
        border: OutlineInputBorder(),
        hintText: 'Nama suster / perawat',
      ),
      validator: _selectedSourceType == 'RETURN'
          ? (value) => value == null || value.isEmpty ? 'Nama pengembali wajib diisi' : null
          : null,
    );
  }

  Widget _buildReturnedFromUnitField() {
    return TextFormField(
      controller: _returnedFromUnitController,
      decoration: const InputDecoration(
        labelText: 'Dari Unit *',
        border: OutlineInputBorder(),
        hintText: 'IGD / RAWAT INAP / KAMAR OPERASI',
      ),
      validator: _selectedSourceType == 'RETURN'
          ? (value) => value == null || value.isEmpty ? 'Unit asal wajib diisi' : null
          : null,
    );
  }

  Widget _buildReturnReasonDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedReturnReason,
      decoration: const InputDecoration(
        labelText: 'Alasan Pengembalian',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'SISA_PAKAI', child: Text('Sisa Pemakaian')),
        DropdownMenuItem(value: 'KADALUARSA', child: Text('Kadaluarsa')),
        DropdownMenuItem(value: 'SALAH_KIRIM', child: Text('Salah Kirim')),
        DropdownMenuItem(value: 'RUSAK', child: Text('Rusak')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedReturnReason = value;
        });
      },
    );
  }
}