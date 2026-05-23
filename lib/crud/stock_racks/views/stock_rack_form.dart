import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/stock_racks/models/stock_rack_model.dart';
import 'package:rsmss/crud/stock_racks/providers/stock_rack_provider.dart';
import 'package:rsmss/crud/stock_racks/services/stock_rack_service.dart';

class StockRackFormPage extends ConsumerStatefulWidget {
  final StockRackModel? rack;

  const StockRackFormPage({
    super.key,
    this.rack,
  });

  @override
  ConsumerState<StockRackFormPage> createState() => _StockRackFormPageState();
}

class _StockRackFormPageState extends ConsumerState<StockRackFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _capacityController;

  String? _selectedZoneId;
  String? _selectedZoneDisplay;
  Map<String, dynamic>? _metadata;

  List<Map<String, dynamic>> _zones = [];

  bool _isLoadingZones = true;

  @override
  void initState() {
    super.initState();
    final rack = widget.rack;
    _codeController = TextEditingController(text: rack?.code ?? '');
    _nameController = TextEditingController(text: rack?.name ?? '');
    _capacityController = TextEditingController(text: rack?.capacityKg?.toString() ?? '');
    _selectedZoneId = rack?.zoneId;
    _metadata = rack?.metadata;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(stockRackServiceProvider);
    
    final zones = await service.getZones();
    
    // Set selected zone display name
    String? selectedZoneDisplay;
    if (_selectedZoneId != null) {
      final found = zones.firstWhere(
        (z) => z['id'] == _selectedZoneId,
        orElse: () => {},
      );
      selectedZoneDisplay = found['display_name'] as String?;
    }
    
    setState(() {
      _zones = zones;
      _selectedZoneDisplay = selectedZoneDisplay;
      _isLoadingZones = false;
    });
  }

  Future<void> _showZonePicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredZones = List.from(_zones);
    
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
                          hintText: 'Cari zona...',
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
                              filteredZones = List.from(_zones);
                            } else {
                              filteredZones = _zones.where((z) =>
                                (z['display_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredZones.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Zona tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredZones.length,
                              itemBuilder: (context, index) {
                                final zone = filteredZones[index];
                                return ListTile(
                                  leading: const Icon(Icons.map, color: Colors.teal),
                                  title: Text(zone['display_name']),
                                  subtitle: zone['warehouse_name'] != null
                                      ? Text('Gudang: ${zone['warehouse_name']}', style: const TextStyle(fontSize: 12))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedZoneId = zone['id'];
                                      _selectedZoneDisplay = zone['display_name'];
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
    
    if (_selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih zona terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.rack != null;
    final rack = StockRackModel(
      id: widget.rack?.id,
      zoneId: _selectedZoneId!,
      code: _codeController.text,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text,
      capacityKg: _capacityController.text.trim().isEmpty ? null : double.tryParse(_capacityController.text),
      metadata: _metadata,
    );

    final notifier = ref.read(stockRackProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateRack(rack);
    } else {
      success = await notifier.createRack(rack);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Rak berhasil diupdate' : 'Rak berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode rak wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode rak minimal 2 karakter';
    }
    if (value.trim().length > 30) {
      return 'Kode rak maksimal 30 karakter';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final capacity = double.tryParse(value);
    if (capacity == null || capacity <= 0) {
      return 'Kapasitas harus angka positif';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockRackProvider);
    final isEditing = widget.rack != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Rak' : 'Tambah Rak'),
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
            // Zone Picker
            _isLoadingZones
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showZonePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.map, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zona *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedZoneDisplay ?? 'Pilih zona',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedZoneDisplay == null 
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
            if (_selectedZoneId == null && !_isLoadingZones)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Zona wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Kode Rak
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Rak *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                hintText: 'Contoh: RACK-01, A-01',
                helperText: 'Kode akan otomatis uppercase',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Nama Rak (Optional)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Rak',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.archive_outlined),
                hintText: 'Contoh: Rak Obat Paracetamol, Rak Alat Bedah (opsional)',
              ),
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Kapasitas (kg)
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Kapasitas (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
                hintText: 'Maksimal berat yang dapat ditampung (opsional)',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: _validateCapacity,
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
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.archive_outlined, color: Colors.amber, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isNotEmpty 
                                  ? _nameController.text 
                                  : (_codeController.text.isEmpty ? 'Nama Rak' : _codeController.text),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Kode: ${_codeController.text.isEmpty ? "?" : _codeController.text.toUpperCase()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_selectedZoneDisplay != null)
                              Text(
                                _selectedZoneDisplay!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_capacityController.text.isNotEmpty)
                              Text(
                                'Kapasitas: ${_capacityController.text} kg',
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
                      backgroundColor: Colors.amber,
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