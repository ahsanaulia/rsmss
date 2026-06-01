import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_shelves/models/stock_shelf_model.dart';
import 'package:rsmss/crud/stock_shelves/providers/stock_shelf_provider.dart';
// import 'package:rsmss/crud/stock_shelves/services/stock_shelf_service.dart';

class StockShelfFormPage extends ConsumerStatefulWidget {
  final StockShelfModel? shelf;

  const StockShelfFormPage({
    super.key,
    this.shelf,
  });

  @override
  ConsumerState<StockShelfFormPage> createState() => _StockShelfFormPageState();
}

class _StockShelfFormPageState extends ConsumerState<StockShelfFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _levelNumberController;
  late TextEditingController _maxHeightController;

  String? _selectedRackId;
  String? _selectedRackDisplay;
  Map<String, dynamic>? _metadata;

  List<Map<String, dynamic>> _racks = [];

  bool _isLoadingRacks = true;

  @override
  void initState() {
    super.initState();
    final shelf = widget.shelf;
    _codeController = TextEditingController(text: shelf?.code ?? '');
    _levelNumberController = TextEditingController(text: shelf?.levelNumber.toString() ?? '');
    _maxHeightController = TextEditingController(text: shelf?.maxHeightCm?.toString() ?? '');
    _selectedRackId = shelf?.rackId;
    _metadata = shelf?.metadata;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _levelNumberController.dispose();
    _maxHeightController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(stockShelfServiceProvider);
    
    final racks = await service.getRacks();
    
    // Set selected rack display name
    String? selectedRackDisplay;
    if (_selectedRackId != null) {
      final found = racks.firstWhere(
        (r) => r['id'] == _selectedRackId,
        orElse: () => {},
      );
      selectedRackDisplay = found['display_name'] as String?;
    }
    
    setState(() {
      _racks = racks;
      _selectedRackDisplay = selectedRackDisplay;
      _isLoadingRacks = false;
    });
  }

  Future<void> _showRackPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredRacks = List.from(_racks);
    
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
                          hintText: 'Cari rak...',
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
                              filteredRacks = List.from(_racks);
                            } else {
                              filteredRacks = _racks.where((r) =>
                                (r['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredRacks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rak tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredRacks.length,
                              itemBuilder: (context, index) {
                                final rack = filteredRacks[index];
                                return ListTile(
                                  leading: const Icon(Icons.border_top_sharp, color: Colors.amber),
                                  title: Text(rack['display_name']),
                                  subtitle: rack['zone_name'] != null
                                      ? Text('Zona: ${rack['zone_name']}', style: const TextStyle(fontSize: 12))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedRackId = rack['id'];
                                      _selectedRackDisplay = rack['display_name'];
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
    
    if (_selectedRackId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rak terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.shelf != null;
    final shelf = StockShelfModel(
      id: widget.shelf?.id,
      rackId: _selectedRackId!,
      levelNumber: int.tryParse(_levelNumberController.text) ?? 0,
      code: _codeController.text,
      maxHeightCm: _maxHeightController.text.trim().isEmpty ? null : double.tryParse(_maxHeightController.text),
      metadata: _metadata,
    );

    final notifier = ref.read(stockShelfProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateShelf(shelf);
    } else {
      success = await notifier.createShelf(shelf);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Shelf berhasil diupdate' : 'Shelf berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode shelf wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode shelf minimal 2 karakter';
    }
    if (value.trim().length > 30) {
      return 'Kode shelf maksimal 30 karakter';
    }
    return null;
  }

  String? _validateLevelNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Level nomor wajib diisi';
    }
    final level = int.tryParse(value);
    if (level == null || level < 1) {
      return 'Level nomor harus angka positif';
    }
    if (level > 99) {
      return 'Level nomor maksimal 99';
    }
    return null;
  }

  String? _validateMaxHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final height = double.tryParse(value);
    if (height == null || height <= 0) {
      return 'Tinggi harus angka positif';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockShelfProvider);
    final isEditing = widget.shelf != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Shelf' : 'Tambah Shelf'),
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
            // Rack Picker
            _isLoadingRacks
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showRackPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.border_top_sharp, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rak *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedRackDisplay ?? 'Pilih rak',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedRackDisplay == null 
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
            if (_selectedRackId == null && !_isLoadingRacks)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Rak wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Level Number
            TextFormField(
              controller: _levelNumberController,
              decoration: const InputDecoration(
                labelText: 'Level Nomor *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                hintText: 'Contoh: 1, 2, 3',
              ),
              keyboardType: TextInputType.number,
              validator: _validateLevelNumber,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Kode Shelf
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Shelf *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                hintText: 'Contoh: SH-01, A-01',
                helperText: 'Kode akan otomatis uppercase',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Max Height (cm)
            TextFormField(
              controller: _maxHeightController,
              decoration: const InputDecoration(
                labelText: 'Tinggi Maksimal (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
                hintText: 'Tinggi maksimal shelf dalam cm (opsional)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: _validateMaxHeight,
              enabled: !isSubmitting,
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
                            color: Colors.cyan.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shelves, color: Colors.cyan, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${_levelNumberController.text.isEmpty ? "?" : _levelNumberController.text} - ${_codeController.text.isEmpty ? "?" : _codeController.text.toUpperCase()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_selectedRackDisplay != null)
                              Text(
                                _selectedRackDisplay!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_maxHeightController.text.isNotEmpty)
                              Text(
                                'Tinggi Maks: ${_maxHeightController.text} cm',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                      backgroundColor: Colors.cyan,
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