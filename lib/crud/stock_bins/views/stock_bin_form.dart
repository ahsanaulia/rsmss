import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_bins/models/stock_bin_model.dart';
import 'package:rsmss/crud/stock_bins/providers/stock_bin_provider.dart';
import 'package:rsmss/crud/stock_bins/services/stock_bin_service.dart';

class StockBinFormPage extends ConsumerStatefulWidget {
  final StockBinModel? bin;

  const StockBinFormPage({
    super.key,
    this.bin,
  });

  @override
  ConsumerState<StockBinFormPage> createState() => _StockBinFormPageState();
}

class _StockBinFormPageState extends ConsumerState<StockBinFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _barcodeController;
  late TextEditingController _positionXController;
  late TextEditingController _positionYController;
  late TextEditingController _maxQuantityController;
  late TextEditingController _currentQuantityController;
  late TextEditingController _qrcodeUrlController;

  String? _selectedShelfId;
  String? _selectedShelfDisplay;
  // String? _selectedProductId;
  String? _selectedProductDisplay;
  String? _selectedAssetId;
  String? _selectedAssetDisplay;
  bool _isActive = true;
  Map<String, dynamic>? _metadata;

  List<Map<String, dynamic>> _shelves = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _assets = [];

  bool _isLoadingShelves = true;
  bool _isLoadingProducts = true;
  bool _isLoadingAssets = true;

  @override
  void initState() {
    super.initState();
    final bin = widget.bin;
    _codeController = TextEditingController(text: bin?.code ?? '');
    _barcodeController = TextEditingController(text: bin?.barcode ?? '');
    _positionXController = TextEditingController(text: bin?.positionX?.toString() ?? '');
    _positionYController = TextEditingController(text: bin?.positionY?.toString() ?? '');
    _maxQuantityController = TextEditingController(text: bin?.maxQuantity?.toString() ?? '');
    _currentQuantityController = TextEditingController(text: bin?.currentQuantity?.toString() ?? '');
    _qrcodeUrlController = TextEditingController(text: bin?.qrcodeUrl ?? '');
    _selectedShelfId = bin?.shelfId;
    // _selectedProductId = bin?.currentProductId;
    _selectedAssetId = bin?.assetId;
    _isActive = bin?.isActive ?? true;
    _metadata = bin?.metadata;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _barcodeController.dispose();
    _positionXController.dispose();
    _positionYController.dispose();
    _maxQuantityController.dispose();
    _currentQuantityController.dispose();
    _qrcodeUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(stockBinServiceProvider);
    
    final shelves = await service.getShelves();
    // final products = await service.getProducts();
    final assets = await service.getAssets();
    
    // Set selected shelf display name
    String? selectedShelfDisplay;
    if (_selectedShelfId != null) {
      final found = shelves.firstWhere(
        (s) => s['id'] == _selectedShelfId,
        orElse: () => {},
      );
      selectedShelfDisplay = found['display_name'] as String?;
    }
    
    // String? selectedProductDisplay;
    // if (_selectedProductId != null) {
    //   final found = products.firstWhere(
    //     (p) => p['id'] == _selectedProductId,
    //     orElse: () => {},
    //   );
    //   selectedProductDisplay = found['display_name'] as String?;
    // }
    
    String? selectedAssetDisplay;
    if (_selectedAssetId != null) {
      final found = assets.firstWhere(
        (a) => a['id'] == _selectedAssetId,
        orElse: () => {},
      );
      selectedAssetDisplay = found['display_name'] as String?;
    }
    
    setState(() {
      _shelves = shelves;
      // _products = products;
      _assets = assets;
      _selectedShelfDisplay = selectedShelfDisplay;
      // _selectedProductDisplay = selectedProductDisplay;
      _selectedAssetDisplay = selectedAssetDisplay;
      _isLoadingShelves = false;
      _isLoadingProducts = false;
      _isLoadingAssets = false;
    });
  }

  Future<void> _showShelfPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredShelves = List.from(_shelves);
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari shelf...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          setStateBottomSheet(() {
                            if (value.isEmpty) {
                              filteredShelves = List.from(_shelves);
                            } else {
                              filteredShelves = _shelves.where((s) =>
                                (s['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredShelves.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Shelf tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredShelves.length,
                              itemBuilder: (context, index) {
                                final shelf = filteredShelves[index];
                                return ListTile(
                                  leading: const Icon(Icons.shelves, color: Colors.cyan),
                                  title: Text(shelf['display_name']),
                                  subtitle: shelf['zone_name'] != null
                                      ? Text('Zona: ${shelf['zone_name']}', style: const TextStyle(fontSize: 12))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedShelfId = shelf['id'];
                                      _selectedShelfDisplay = shelf['display_name'];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    
    searchController.dispose();
  }

  Future<void> _showProductPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredProducts = List.from(_products);
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          setStateBottomSheet(() {
                            if (value.isEmpty) {
                              filteredProducts = List.from(_products);
                            } else {
                              filteredProducts = _products.where((p) =>
                                (p['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Produk tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ListTile(
                                  leading: const Icon(Icons.inventory, color: Colors.blue),
                                  title: Text(product['display_name']),
                                  onTap: () {
                                    setState(() {
                                      // _selectedProductId = product['id'];
                                      // _selectedProductDisplay = product['display_name'];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    
    searchController.dispose();
  }

  Future<void> _showAssetPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredAssets = List.from(_assets);
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari aset...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          setStateBottomSheet(() {
                            if (value.isEmpty) {
                              filteredAssets = List.from(_assets);
                            } else {
                              filteredAssets = _assets.where((a) =>
                                (a['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredAssets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aset tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredAssets.length,
                              itemBuilder: (context, index) {
                                final asset = filteredAssets[index];
                                return ListTile(
                                  leading: const Icon(Icons.inventory_2, color: Colors.purple),
                                  title: Text(asset['display_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedAssetId = asset['id'];
                                      _selectedAssetDisplay = asset['display_name'];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    
    searchController.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedShelfId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih shelf terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.bin != null;
    final bin = StockBinModel(
      id: widget.bin?.id,
      shelfId: _selectedShelfId!,
      code: _codeController.text,
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text,
      positionX: _positionXController.text.trim().isEmpty ? null : int.tryParse(_positionXController.text),
      positionY: _positionYController.text.trim().isEmpty ? null : int.tryParse(_positionYController.text),
      maxQuantity: _maxQuantityController.text.trim().isEmpty ? null : double.tryParse(_maxQuantityController.text),
      currentQuantity: _currentQuantityController.text.trim().isEmpty ? 0 : double.tryParse(_currentQuantityController.text),
      // currentProductId: _selectedProductId,
      isActive: _isActive,
      metadata: _metadata,
      qrcodeUrl: _qrcodeUrlController.text.trim().isEmpty ? null : _qrcodeUrlController.text,
      assetId: _selectedAssetId,
    );

    final notifier = ref.read(stockBinProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateBin(bin);
    } else {
      success = await notifier.createBin(bin);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Bin berhasil diupdate' : 'Bin berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode bin wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode bin minimal 2 karakter';
    }
    if (value.trim().length > 30) {
      return 'Kode bin maksimal 30 karakter';
    }
    return null;
  }

  String? _validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 3) {
      return 'Barcode minimal 3 karakter';
    }
    return null;
  }

  String? _validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final pos = int.tryParse(value);
    if (pos == null) {
      return 'Harus berupa angka';
    }
    return null;
  }

  String? _validateQuantity(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final qty = double.tryParse(value);
    if (qty == null || qty < 0) {
      return '$fieldName harus angka positif';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockBinProvider);
    final isEditing = widget.bin != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Bin' : 'Tambah Bin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Shelf Picker
            _isLoadingShelves
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showShelfPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shelves, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shelf *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedShelfDisplay ?? 'Pilih shelf',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedShelfDisplay == null 
                                        ? Colors.grey[400] 
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
            if (_selectedShelfId == null && !_isLoadingShelves)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Shelf wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Kode Bin
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Bin *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                hintText: 'Contoh: BIN-01, A-01',
                helperText: 'Kode akan otomatis uppercase',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_2),
                hintText: 'Barcode (opsional, harus unik)',
              ),
              validator: _validateBarcode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Position X & Y
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _positionXController,
                    decoration: const InputDecoration(
                      labelText: 'Posisi X',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validatePosition,
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _positionYController,
                    decoration: const InputDecoration(
                      labelText: 'Posisi Y',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validatePosition,
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Max Quantity & Current Quantity
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Kapasitas Maks',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vertical_align_top),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _validateQuantity(value, 'Kapasitas maks'),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _currentQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Stok Saat Ini',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _validateQuantity(value, 'Stok saat ini'),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Picker
            _isLoadingProducts
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showProductPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Produk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedProductDisplay ?? 'Pilih produk (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedProductDisplay == null 
                                        ? Colors.grey[400] 
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // QR Code URL
            TextFormField(
              controller: _qrcodeUrlController,
              decoration: const InputDecoration(
                labelText: 'QR Code URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_scanner),
                hintText: 'URL gambar QR code (opsional)',
              ),
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Asset Picker
            _isLoadingAssets
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showAssetPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aset',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedAssetDisplay ?? 'Pilih aset (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedAssetDisplay == null 
                                        ? Colors.grey[400] 
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // Status Aktif
            SwitchListTile(
              title: const Text('Status Aktif'),
              subtitle: const Text('Nonaktifkan jika bin tidak digunakan'),
              value: _isActive,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Preview
            Card(
              elevation: 2,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isActive ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory,
                            color: _isActive ? Colors.green : Colors.red,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _codeController.text.isEmpty ? 'Kode Bin' : _codeController.text.toUpperCase(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_selectedShelfDisplay != null)
                              Text(
                                _selectedShelfDisplay!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_selectedProductDisplay != null)
                              Text(
                                'Produk: $_selectedProductDisplay',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_selectedAssetDisplay != null)
                              Text(
                                'Aset: $_selectedAssetDisplay',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (!_isActive)
                              Chip(
                                label: const Text('Nonaktif'),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.red.shade100,
                                labelStyle: const TextStyle(fontSize: 10),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Update' : 'Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}