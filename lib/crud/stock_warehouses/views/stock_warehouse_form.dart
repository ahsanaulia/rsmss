import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_warehouses/models/stock_warehouse_model.dart';
import 'package:rsmss/crud/stock_warehouses/providers/stock_warehouse_provider.dart';
import 'package:rsmss/crud/stock_warehouses/services/stock_warehouse_service.dart';

class StockWarehouseFormPage extends ConsumerStatefulWidget {
  final StockWarehouseModel? warehouse;

  const StockWarehouseFormPage({
    super.key,
    this.warehouse,
  });

  @override
  ConsumerState<StockWarehouseFormPage> createState() => _StockWarehouseFormPageState();
}

class _StockWarehouseFormPageState extends ConsumerState<StockWarehouseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _addressController;

  String? _selectedFloorId;
  String? _selectedFloorDisplay;
  String? _selectedManagerId;
  String? _selectedManagerName;
  bool _isActive = true;
  Map<String, dynamic>? _metadata;

  List<Map<String, dynamic>> _floors = [];
  List<Map<String, dynamic>> _managers = [];

  bool _isLoadingFloors = true;
  bool _isLoadingManagers = true;

  @override
  void initState() {
    super.initState();
    final warehouse = widget.warehouse;
    _codeController = TextEditingController(text: warehouse?.code ?? '');
    _nameController = TextEditingController(text: warehouse?.name ?? '');
    _addressController = TextEditingController(text: warehouse?.address ?? '');
    _selectedFloorId = warehouse?.floorId;
    _selectedManagerId = warehouse?.managerId;
    _selectedManagerName = warehouse?.managerName;
    _isActive = warehouse?.isActive ?? true;
    _metadata = warehouse?.metadata;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(stockWarehouseServiceProvider);
    
    final floors = await service.getFloors();
    final managers = await service.getManagers();
    
    // Set selected floor display name
    String? selectedFloorDisplay;
    if (_selectedFloorId != null) {
      final found = floors.firstWhere(
        (f) => f['id'] == _selectedFloorId,
        orElse: () => {},
      );
      selectedFloorDisplay = found['display_name'] as String?;
    }
    
    setState(() {
      _floors = floors;
      _managers = managers;
      _selectedFloorDisplay = selectedFloorDisplay;
      _isLoadingFloors = false;
      _isLoadingManagers = false;
    });
  }

  Future<void> _showFloorPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredFloors = List.from(_floors);
    
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
                          hintText: 'Cari lantai...',
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
                              filteredFloors = List.from(_floors);
                            } else {
                              filteredFloors = _floors.where((f) =>
                                (f['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredFloors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lantai tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredFloors.length,
                              itemBuilder: (context, index) {
                                final floor = filteredFloors[index];
                                return ListTile(
                                  leading: const Icon(Icons.view_comfortable, color: Colors.green),
                                  title: Text(floor['display_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedFloorId = floor['id'];
                                      _selectedFloorDisplay = floor['display_name'];
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

  Future<void> _showManagerPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredManagers = List.from(_managers);
    
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
                          hintText: 'Cari manager...',
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
                              filteredManagers = List.from(_managers);
                            } else {
                              filteredManagers = _managers.where((m) =>
                                (m['full_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredManagers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Manager tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredManagers.length,
                              itemBuilder: (context, index) {
                                final manager = filteredManagers[index];
                                return ListTile(
                                  leading: const Icon(Icons.person, color: Colors.blue),
                                  title: Text(manager['full_name']),
                                  subtitle: manager['role'] != null
                                      ? Text(manager['role'], style: const TextStyle(fontSize: 12))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedManagerId = manager['id'];
                                      _selectedManagerName = manager['full_name'];
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
    
    if (_selectedFloorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lantai terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.warehouse != null;
    final warehouse = StockWarehouseModel(
      id: widget.warehouse?.id,
      code: _codeController.text,
      name: _nameController.text,
      address: _addressController.text.trim().isEmpty ? null : _addressController.text,
      managerId: _selectedManagerId,
      isActive: _isActive,
      metadata: _metadata,
      floorId: _selectedFloorId,
    );

    final notifier = ref.read(stockWarehouseProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateWarehouse(warehouse);
    } else {
      success = await notifier.createWarehouse(warehouse);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Gudang berhasil diupdate' : 'Gudang berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode gudang wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode gudang minimal 2 karakter';
    }
    if (value.trim().length > 20) {
      return 'Kode gudang maksimal 20 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama gudang wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama gudang minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama gudang maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockWarehouseProvider);
    final isEditing = widget.warehouse != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Gudang' : 'Tambah Gudang'),
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
            // Kode Gudang
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Gudang *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                hintText: 'Contoh: WH-001, GDG-UTAMA',
                helperText: 'Kode akan otomatis uppercase',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Nama Gudang
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Gudang *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warehouse),
                hintText: 'Contoh: Gudang Utama, Gudang Obat, Gudang Alkes',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Floor Picker
            _isLoadingFloors
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showFloorPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.view_comfortable, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lokasi Lantai *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedFloorDisplay ?? 'Pilih lantai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedFloorDisplay == null 
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
            if (_selectedFloorId == null && !_isLoadingFloors)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Lantai wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Alamat
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Alamat lengkap gudang (opsional)',
              ),
              maxLines: 2,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Manager Picker
            _isLoadingManagers
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showManagerPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manager Gudang',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedManagerName ?? 'Pilih manager (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedManagerName == null 
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
              subtitle: const Text('Nonaktifkan jika gudang tidak digunakan'),
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
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warehouse, color: Colors.indigo, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Gudang' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Kode: ${_codeController.text.isEmpty ? "?" : _codeController.text.toUpperCase()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_selectedFloorDisplay != null)
                              Text(
                                _selectedFloorDisplay!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_selectedManagerName != null)
                              Text(
                                'Manager: ${_selectedManagerName!}',
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
                      backgroundColor: Colors.indigo,
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