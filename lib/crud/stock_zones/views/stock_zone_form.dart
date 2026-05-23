import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_zones/models/stock_zone_model.dart';
import 'package:rsmss/crud/stock_zones/providers/stock_zone_provider.dart';
import 'package:rsmss/crud/stock_zones/services/stock_zone_service.dart';

class StockZoneFormPage extends ConsumerStatefulWidget {
  final StockZoneModel? zone;

  const StockZoneFormPage({
    super.key,
    this.zone,
  });

  @override
  ConsumerState<StockZoneFormPage> createState() => _StockZoneFormPageState();
}

class _StockZoneFormPageState extends ConsumerState<StockZoneFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _temperatureMinController;
  late TextEditingController _temperatureMaxController;
  late TextEditingController _humidityMinController;
  late TextEditingController _humidityMaxController;

  String? _selectedWarehouseId;
  String? _selectedWarehouseDisplay;
  String? _selectedZoneType;
  String? _selectedRoomId;
  String? _selectedRoomDisplay;
  bool _isRestricted = false;
  Map<String, dynamic>? _metadata;

  List<Map<String, dynamic>> _warehouses = [];
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, String>> _zoneTypes = [];

  bool _isLoadingWarehouses = true;
  bool _isLoadingRooms = true;

  @override
  void initState() {
    super.initState();
    final zone = widget.zone;
    _codeController = TextEditingController(text: zone?.code ?? '');
    _nameController = TextEditingController(text: zone?.name ?? '');
    _temperatureMinController = TextEditingController(text: zone?.temperatureMin?.toString() ?? '');
    _temperatureMaxController = TextEditingController(text: zone?.temperatureMax?.toString() ?? '');
    _humidityMinController = TextEditingController(text: zone?.humidityMin?.toString() ?? '');
    _humidityMaxController = TextEditingController(text: zone?.humidityMax?.toString() ?? '');
    _selectedWarehouseId = zone?.warehouseId;
    _selectedZoneType = zone?.zoneType ?? 'NORMAL';
    _selectedRoomId = zone?.roomId;
    _isRestricted = zone?.isRestricted ?? false;
    _metadata = zone?.metadata;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _temperatureMinController.dispose();
    _temperatureMaxController.dispose();
    _humidityMinController.dispose();
    _humidityMaxController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(stockZoneServiceProvider);
    
    final warehouses = await service.getWarehouses();
    final rooms = await service.getRooms();
    final zoneTypes = service.getZoneTypes();
    
    // Set selected warehouse display name
    String? selectedWarehouseDisplay;
    if (_selectedWarehouseId != null) {
      final found = warehouses.firstWhere(
        (w) => w['id'] == _selectedWarehouseId,
        orElse: () => {},
      );
      selectedWarehouseDisplay = found['display_name'] as String?;
    }
    
    // Set selected room display name
    String? selectedRoomDisplay;
    if (_selectedRoomId != null) {
      final found = rooms.firstWhere(
        (r) => r['id'] == _selectedRoomId,
        orElse: () => {},
      );
      selectedRoomDisplay = found['display_name'] as String?;
    }
    
    setState(() {
      _warehouses = warehouses;
      _rooms = rooms;
      _zoneTypes = zoneTypes;
      _selectedWarehouseDisplay = selectedWarehouseDisplay;
      _selectedRoomDisplay = selectedRoomDisplay;
      _isLoadingWarehouses = false;
      _isLoadingRooms = false;
    });
  }

  Future<void> _showWarehousePicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredWarehouses = List.from(_warehouses);
    
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
                          hintText: 'Cari gudang...',
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
                              filteredWarehouses = List.from(_warehouses);
                            } else {
                              filteredWarehouses = _warehouses.where((w) =>
                                (w['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredWarehouses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gudang tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredWarehouses.length,
                              itemBuilder: (context, index) {
                                final warehouse = filteredWarehouses[index];
                                return ListTile(
                                  leading: const Icon(Icons.warehouse, color: Colors.indigo),
                                  title: Text(warehouse['display_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedWarehouseId = warehouse['id'];
                                      _selectedWarehouseDisplay = warehouse['display_name'];
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

  Future<void> _showRoomPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredRooms = List.from(_rooms);
    
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
                          hintText: 'Cari ruangan...',
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
                              filteredRooms = List.from(_rooms);
                            } else {
                              filteredRooms = _rooms.where((r) =>
                                (r['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredRooms.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ruangan tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredRooms.length,
                              itemBuilder: (context, index) {
                                final room = filteredRooms[index];
                                return ListTile(
                                  leading: const Icon(Icons.meeting_room, color: Colors.orange),
                                  title: Text(room['display_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedRoomId = room['id'];
                                      _selectedRoomDisplay = room['display_name'];
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
    
    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gudang terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.zone != null;
    final zone = StockZoneModel(
      id: widget.zone?.id,
      warehouseId: _selectedWarehouseId!,
      code: _codeController.text,
      name: _nameController.text,
      zoneType: _selectedZoneType,
      temperatureMin: _temperatureMinController.text.trim().isEmpty ? null : double.tryParse(_temperatureMinController.text),
      temperatureMax: _temperatureMaxController.text.trim().isEmpty ? null : double.tryParse(_temperatureMaxController.text),
      humidityMin: _humidityMinController.text.trim().isEmpty ? null : double.tryParse(_humidityMinController.text),
      humidityMax: _humidityMaxController.text.trim().isEmpty ? null : double.tryParse(_humidityMaxController.text),
      isRestricted: _isRestricted,
      metadata: _metadata,
      roomId: _selectedRoomId,
    );

    final notifier = ref.read(stockZoneProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateZone(zone);
    } else {
      success = await notifier.createZone(zone);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Zona berhasil diupdate' : 'Zona berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode zona wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode zona minimal 2 karakter';
    }
    if (value.trim().length > 30) {
      return 'Kode zona maksimal 30 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama zona wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama zona minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama zona maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockZoneProvider);
    final isEditing = widget.zone != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Zona' : 'Tambah Zona'),
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
            // Warehouse Picker
            _isLoadingWarehouses
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showWarehousePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warehouse, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gudang *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedWarehouseDisplay ?? 'Pilih gudang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedWarehouseDisplay == null 
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
            if (_selectedWarehouseId == null && !_isLoadingWarehouses)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Gudang wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Kode Zona
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Zona *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                hintText: 'Contoh: ZN-01, COLD-01',
                helperText: 'Kode akan otomatis uppercase',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Nama Zona
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Zona *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
                hintText: 'Contoh: Zona Penyimpanan Obat, Zona Cold Storage',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Zone Type Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipe Zona',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedZoneType,
              items: _zoneTypes.map((type) {
                return DropdownMenuItem(
                  value: type['value'],
                  child: Text(type['label']!),
                );
              }).toList(),
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _selectedZoneType = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Temperature Range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureMinController,
                    decoration: const InputDecoration(
                      labelText: 'Suhu Min (°C)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.thermostat),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _temperatureMaxController,
                    decoration: const InputDecoration(
                      labelText: 'Suhu Max (°C)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.thermostat),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Humidity Range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _humidityMinController,
                    decoration: const InputDecoration(
                      labelText: 'Kelembaban Min (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _humidityMaxController,
                    decoration: const InputDecoration(
                      labelText: 'Kelembaban Max (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop),
                      hintText: 'Opsional',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Room Picker
            _isLoadingRooms
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showRoomPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.meeting_room, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ruangan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedRoomDisplay ?? 'Pilih ruangan (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedRoomDisplay == null 
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

            // Restricted Area
            SwitchListTile(
              title: const Text('Area Terbatas (Restricted)'),
              subtitle: const Text('Tandai sebagai area yang memerlukan otorisasi khusus'),
              value: _isRestricted,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _isRestricted = value;
                });
              },
              activeColor: Colors.red,
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
                            color: _isRestricted ? Colors.red.shade50 : Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isRestricted ? Icons.lock : Icons.map,
                            color: _isRestricted ? Colors.red : Colors.teal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Zona' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Kode: ${_codeController.text.isEmpty ? "?" : _codeController.text.toUpperCase()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_selectedWarehouseDisplay != null)
                              Text(
                                _selectedWarehouseDisplay!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_selectedZoneType != null)
                              Text(
                                'Tipe: $_selectedZoneType',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_isRestricted)
                              Chip(
                                label: const Text('Restricted Area'),
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
                      backgroundColor: Colors.teal,
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