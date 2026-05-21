// lib/features/stock_request/presentations/stock_request_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_request_model.dart';
import '../providers/stock_request_providers.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';

class StockRequestFormPage extends ConsumerStatefulWidget {
  const StockRequestFormPage({super.key});

  @override
  ConsumerState<StockRequestFormPage> createState() => _StockRequestFormPageState();
}

class _StockRequestFormPageState extends ConsumerState<StockRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _batchController = TextEditingController();
  
  String? _selectedStockId;
  String? _selectedStockName;
  String? _selectedStockUnit;
  String? _selectedRoomId;
  String _purpose = 'PASIEN';
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ruangan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(stockRequestControllerProvider);
      final requestNumber = await controller.generateRequestNumber();
      
      final request = StockRequestModel(
        requestNumber: requestNumber,
        requesterId: '',
        requesterName: '',
        roomId: _selectedRoomId,
        purpose: _purpose,
        requestDate: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        requestedStockId: _selectedStockId!,
        requestedStockName: _selectedStockName ?? '',
        requestedQuantity: double.parse(_quantityController.text),
        requestedUnit: _selectedStockUnit ?? '',
        requestedBatch: _batchController.text.isEmpty ? null : _batchController.text,
        status: 'PENDING',
        fulfilledQuantity: 0,
      );
      
      await controller.createRequest(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request berhasil dibuat!')),
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(stockRequestStocksProvider);
    final roomsAsync = ref.watch(roomsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permintaan Stok'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Peminta
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Peminta',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authService.currentSession?.fullName ?? 'Loading...',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Ruangan
              roomsAsync.when(
                data: (rooms) => DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Ruangan *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  value: _selectedRoomId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Pilih Ruangan')),
                    ...rooms.map((room) => DropdownMenuItem(
                      value: room['id'],
                      child: Text(
                        room['room_name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRoomId = value);
                  },
                  validator: (value) => value == null ? 'Ruangan harus dipilih' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              
              // Tujuan
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tujuan Pemakaian *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                value: _purpose,
                items: const [
                  DropdownMenuItem(value: 'PASIEN', child: Text('Pasien')),
                  DropdownMenuItem(value: 'ICU', child: Text('ICU')),
                  DropdownMenuItem(value: 'OK', child: Text('OK / Operasi')),
                  DropdownMenuItem(value: 'RAWAT_INAP', child: Text('Rawat Inap')),
                  DropdownMenuItem(value: 'KENDARAAN', child: Text('Kendaraan Dinas')),
                  DropdownMenuItem(value: 'LAB', child: Text('Laboratorium')),
                  DropdownMenuItem(value: 'LAINNYA', child: Text('Lainnya')),
                ],
                onChanged: (value) => setState(() => _purpose = value!),
                validator: (value) => value == null ? 'Tujuan harus dipilih' : null,
              ),
              const SizedBox(height: 16),
              
              // Produk
              stocksAsync.when(
                data: (stocks) => DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Produk *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medication),
                  ),
                  value: _selectedStockId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Pilih Produk')),
                    ...stocks.map((stock) => DropdownMenuItem(
                      value: stock['id'],
                      child: Text(
                        '${stock['stock_code']} - ${stock['stock_name']} (Stok: ${stock['current_stock']} ${stock['unit']})',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStockId = value;
                      final selected = stocks.firstWhere(
                        (s) => s['id'] == value,
                        orElse: () => {},
                      );
                      _selectedStockName = selected['stock_name'] as String?;
                      _selectedStockUnit = selected['unit'] as String?;
                    });
                  },
                  validator: (value) => value == null ? 'Produk harus dipilih' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Jumlah *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                  suffixText: _selectedStockUnit,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah harus diisi';
                  final qty = double.tryParse(value);
                  if (qty == null) return 'Jumlah harus angka';
                  if (qty <= 0) return 'Jumlah harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Batch (Opsional)
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Batch (opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              
              // Catatan
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('KIRIM REQUEST'),
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
}