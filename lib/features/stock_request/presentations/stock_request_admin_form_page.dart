// lib/features/stock_request/presentations/stock_request_admin_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stock_request_model.dart';
import '../providers/stock_request_providers.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';

class StockRequestAdminFormPage extends ConsumerStatefulWidget {
  const StockRequestAdminFormPage({super.key});

  @override
  ConsumerState<StockRequestAdminFormPage> createState() => _StockRequestAdminFormPageState();
}

class _StockRequestAdminFormPageState extends ConsumerState<StockRequestAdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _batchController = TextEditingController();
  
  String? _selectedRequesterId;
  String? _selectedRequesterName;
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
    // Validasi form
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi pegawai
    if (_selectedRequesterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pegawai terlebih dahulu')),
      );
      return;
    }
    
    // Validasi produk
    if (_selectedStockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }
    
    // Validasi ruangan
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
        requesterId: _selectedRequesterId!,
        requesterName: _selectedRequesterName ?? '',
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
          const SnackBar(content: Text('Request berhasil dibuat untuk pegawai!')),
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
    final employeesAsync = ref.watch(allEmployeesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Request untuk Pegawai'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Admin (pembuat)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dibuat Oleh (Admin)',
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
              
              // Pilih Pegawai (Requester)
              employeesAsync.when(
                data: (employees) => DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Pegawai *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  value: _selectedRequesterId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Pilih Pegawai')),
                    ...employees.map((emp) => DropdownMenuItem(
                      value: emp['id'],
                      child: Text(
                        emp['full_name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRequesterId = value;
                      final selected = employees.firstWhere(
                        (e) => e['id'] == value,
                        orElse: () => {},
                      );
                      _selectedRequesterName = selected['full_name'] as String?;
                    });
                  },
                  validator: (value) => value == null ? 'Pegawai harus dipilih' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
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
                  onChanged: (value) => setState(() => _selectedRoomId = value),
                  validator: (value) => value == null ? 'Ruangan harus dipilih' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              
              // Tujuan Pemakaian
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
              
              // =====================================================
              // QUANTITY - Bisa diisi BEBAS oleh admin (tanpa batasan)
              // =====================================================
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Jumlah *',
                  hintText: 'Masukkan jumlah yang diminta',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                  suffixText: _selectedStockUnit,
                  helperText: 'Admin bisa mengisi jumlah berapa pun (tidak terbatas stok)',
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
                  helperText: 'Kosongkan jika tidak spesifik batch',
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
                  label: const Text('BUAT REQUEST'),
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