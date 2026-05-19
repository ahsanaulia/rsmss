// ============================================================
// DIALOG: Stock Form Dialog
// ============================================================
// TANGGUNG JAWAB:
// 1. Form untuk create dan edit stok
// 2. Layout 2 kolom (Row dengan 2 Expanded) untuk field yang padat
// 3. Upload foto stok ke Supabase Storage
// 4. Validasi: Nama Stok wajib, Satuan wajib
// 5. Dropdown untuk: Tipe Stok, Lokasi Gudang, Kondisi Stok
// 6. Field untuk: Kode Stok, Minimum Stok, Batch Number, Expiry Date, Deskripsi
// 7. Checkbox untuk Is Active
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/stock_model.dart';
import '../../services/stock_service.dart';

class StockFormDialog extends StatefulWidget {
  final bool isEditing;
  final Stock? existingStock;
  final StockService stockService;
  final String? currentUserId;
  final VoidCallback onSuccess;

  const StockFormDialog({
    super.key,
    required this.isEditing,
    this.existingStock,
    required this.stockService,
    required this.currentUserId,
    required this.onSuccess,
  });

  @override
  State<StockFormDialog> createState() => _StockFormDialogState();
}

class _StockFormDialogState extends State<StockFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // ==========================================================
  // CONTROLLERS
  // ==========================================================
  final _stockCodeController = TextEditingController();
  final _stockNameController = TextEditingController();
  final _unitController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // ==========================================================
  // DROPDOWN & SELECTION VALUES
  // ==========================================================
  String? _selectedStockTypeId;
  String? _selectedStorageLocationId;
  String _selectedStockCondition = 'GOOD';
  bool _isActive = true;
  
  // Date untuk expiry date
  DateTime? _selectedExpiryDate;
  
  // ==========================================================
  // PHOTO UPLOAD
  // ==========================================================
  XFile? _selectedImageXFile;
  String? _existingPhotoUrl;
  bool _isUploading = false;
  
  // ==========================================================
  // DROPDOWN DATA
  // ==========================================================
  List<Map<String, dynamic>> _stockTypes = [];
  List<Map<String, dynamic>> _storageLocations = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    
    if (widget.isEditing && widget.existingStock != null) {
      _populateFormWithExistingStock();
    }
  }

  @override
  void dispose() {
    _stockCodeController.dispose();
    _stockNameController.dispose();
    _unitController.dispose();
    _minimumStockController.dispose();
    _batchNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD DATA FOR DROPDOWNS
  // ==========================================================
  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingData = true;
    });
    
    try {
      final stockTypes = await widget.stockService.fetchAllStockTypes();
      final storageLocations = await widget.stockService.fetchAllStorageLocations();
      
      setState(() {
        _stockTypes = stockTypes;
        _storageLocations = storageLocations;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      _showErrorSnackbar('Gagal memuat data: $e');
    }
  }

  // ==========================================================
  // POPULATE FORM FOR EDIT MODE
  // ==========================================================
  void _populateFormWithExistingStock() {
    final stock = widget.existingStock!;
    
    _stockCodeController.text = stock.stockCode ?? '';
    _stockNameController.text = stock.stockName;
    _unitController.text = stock.unit;
    _minimumStockController.text = stock.minimumStock.toString();
    _selectedStockTypeId = stock.stockTypeId;
    _selectedStorageLocationId = stock.storageLocationId;
    _selectedStockCondition = stock.stockCondition;
    _isActive = stock.isActive;
    _existingPhotoUrl = stock.photoUrl;
    _batchNumberController.text = stock.batchNumber ?? '';
    _selectedExpiryDate = stock.expiryDate;
    _descriptionController.text = stock.description ?? '';
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  // ==========================================================
  // UPLOAD PHOTO - SAMA PERSIS DENGAN ASSET
  // ==========================================================
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (pickedFile == null) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Jika edit dan sudah ada foto, hapus foto lama
      if (widget.isEditing && _existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
        await widget.stockService.deleteStockPhoto(_existingPhotoUrl!);
      }
      
      // Upload foto
      if (widget.isEditing && widget.existingStock != null) {
        final photoUrl = await widget.stockService.uploadStockPhoto(pickedFile, widget.existingStock!.id);
        setState(() {
          _selectedImageXFile = null;
          _existingPhotoUrl = photoUrl;
        });
      } else {
        setState(() {
          _selectedImageXFile = pickedFile;
        });
      }
      
      if (mounted) {
        _showSuccessSnackbar('Foto berhasil diupload');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Gagal upload foto: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ==========================================================
  // SUBMIT FORM
  // ==========================================================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_stockNameController.text.isEmpty) {
      _showErrorSnackbar('Nama stok wajib diisi');
      return;
    }
    if (_unitController.text.isEmpty) {
      _showErrorSnackbar('Satuan wajib diisi');
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final minimumStock = double.tryParse(_minimumStockController.text) ?? 0;
      
      final stock = Stock(
        id: widget.isEditing ? widget.existingStock!.id : '',
        stockCode: _stockCodeController.text.trim().isEmpty ? null : _stockCodeController.text.trim(),
        stockName: _stockNameController.text.trim(),
        unit: _unitController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        stockTypeId: _selectedStockTypeId,
        storageLocationId: _selectedStorageLocationId,
        minimumStock: minimumStock,
        currentStock: widget.isEditing ? widget.existingStock!.currentStock : 0,
        batchNumber: _batchNumberController.text.trim().isEmpty ? null : _batchNumberController.text.trim(),
        expiryDate: _selectedExpiryDate,
        stockCondition: _selectedStockCondition,
        isActive: _isActive,
        photoUrl: _existingPhotoUrl,
        createdAt: widget.isEditing ? widget.existingStock!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (widget.currentUserId == null) {
        throw Exception('User tidak ditemukan, silakan login ulang');
      }
      
      // ==================================================
      // HANDLE CREATE DENGAN FOTO
      // ==================================================
      if (!widget.isEditing && _selectedImageXFile != null) {
        // 1. Create stock dulu (tanpa foto)
        final createdStock = await widget.stockService.createStock(stock, widget.currentUserId!);
        print('✅ STOCK CREATED: ${createdStock.id}');
        
        // 2. Upload foto
        final photoUrl = await widget.stockService.uploadStockPhoto(_selectedImageXFile!, createdStock.id);
        print('✅ PHOTO UPLOADED: $photoUrl');
        
        // 3. Update stock dengan photo_url
        final updatedStock = createdStock.copyWith(photoUrl: photoUrl);
        await widget.stockService.updateStock(updatedStock, widget.currentUserId!);
        print('✅ STOCK UPDATED WITH PHOTO');
        
      } else if (widget.isEditing && _existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
        // Edit mode dengan foto yang sudah ada
        final updatedStock = stock.copyWith(photoUrl: _existingPhotoUrl);
        await widget.stockService.updateStock(updatedStock, widget.currentUserId!);
        print('✅ STOCK UPDATED (EDIT WITH PHOTO)');
        
      } else if (widget.isEditing) {
        // Edit mode tanpa foto
        await widget.stockService.updateStock(stock, widget.currentUserId!);
        print('✅ STOCK UPDATED (EDIT WITHOUT PHOTO)');
        
      } else {
        // Create tanpa foto
        await widget.stockService.createStock(stock, widget.currentUserId!);
        print('✅ STOCK CREATED (WITHOUT PHOTO)');
      }
      
      if (mounted) {
        _showSuccessSnackbar(
          widget.isEditing ? 'Stok berhasil diperbarui' : 'Stok berhasil ditambahkan'
        );
        widget.onSuccess();
      }
    } catch (e) {
      print('🔴 SUBMIT ERROR: $e');
      if (mounted) {
        _showErrorSnackbar('Gagal menyimpan stok: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade700),
    );
  }

  // ==========================================================
  // BUILD METHODS
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit : Icons.add_box,
            color: widget.isEditing ? Colors.blue.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Text(widget.isEditing ? 'Edit Stok' : 'Tambah Stok Baru'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.55,
        height: MediaQuery.of(context).size.height * 0.75,
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ROW 1: Kode Stok & Nama Stok
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Kode Stok',
                                hintText: 'Opsional',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stockNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Stok *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama stok harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 2: Satuan & Minimum Stok
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Satuan *',
                                hintText: 'Contoh: pcs, box, kg',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Satuan harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _minimumStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Minimum Stok',
                                hintText: '0',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 3: Tipe Stok & Lokasi Gudang
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedStockTypeId,
                              decoration: const InputDecoration(
                                labelText: 'Tipe Stok',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih Tipe')),
                                ..._stockTypes.map((type) => DropdownMenuItem(
                                  value: type['id'].toString(),
                                  child: Text(
                                    type['type_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (value) => setState(() => _selectedStockTypeId = value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              value: _selectedStorageLocationId,
                              decoration: const InputDecoration(
                                labelText: 'Lokasi Gudang',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Pilih Lokasi')),
                                ..._storageLocations.map((loc) => DropdownMenuItem(
                                  value: loc['id'].toString(),
                                  child: Text(
                                    loc['location_name'] ?? '-',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: (value) => setState(() => _selectedStorageLocationId = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 4: Kondisi Stok & Batch Number
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedStockCondition,
                              decoration: const InputDecoration(
                                labelText: 'Kondisi Stok',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'GOOD', child: Text('GOOD (Baik)')),
                                DropdownMenuItem(value: 'LOW', child: Text('LOW (Stok Rendah)')),
                              ],
                              onChanged: (value) => setState(() => _selectedStockCondition = value!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _batchNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Batch Number',
                                hintText: 'Opsional',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 5: Expiry Date & Is Active
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectExpiryDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Tanggal Kadaluarsa',
                                    hintText: 'Pilih tanggal',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _selectedExpiryDate != null
                                        ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}'
                                        : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isActive,
                                  onChanged: (value) => setState(() => _isActive = value ?? true),
                                ),
                                const Text('Aktif'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 6: Upload Foto
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _isUploading ? null : _pickAndUploadImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: _isUploading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            _existingPhotoUrl!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return _buildUploadPlaceholder();
                                            },
                                          ),
                                        )
                                      : _buildUploadPlaceholder(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap untuk upload foto',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // ROW 7: Deskripsi
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                          isDense: true,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isEditing ? Colors.blue : Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isEditing ? 'Simpan Perubahan' : 'Tambah Stok'),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload, size: 32, color: Colors.grey.shade400),
        Text(
          'Upload Foto',
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}