import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/floors/models/floor_model.dart';
import 'package:rsmss/crud/floors/providers/floor_provider.dart';
import 'package:rsmss/crud/floors/services/floor_service.dart';

class FloorFormPage extends ConsumerStatefulWidget {
  final FloorModel? floor;

  const FloorFormPage({
    super.key,
    this.floor,
  });

  @override
  ConsumerState<FloorFormPage> createState() => _FloorFormPageState();
}

class _FloorFormPageState extends ConsumerState<FloorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _floorNumberController;
  late TextEditingController _floorAliasController;
  late TextEditingController _mapImageUrlController;

  String? _selectedBuildingId;
  String? _selectedBuildingName;
  String? _selectedAppId;
  String? _selectedAppName;

  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _apps = [];

  bool _isLoadingBuildings = true;
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    final floor = widget.floor;
    _floorNumberController = TextEditingController(text: floor?.floorNumber.toString() ?? '');
    _floorAliasController = TextEditingController(text: floor?.floorAlias ?? '');
    _mapImageUrlController = TextEditingController(text: floor?.mapImageUrl ?? '');
    _selectedBuildingId = floor?.buildingId;
    _selectedBuildingName = floor?.buildingName;
    _selectedAppId = floor?.appId;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _floorNumberController.dispose();
    _floorAliasController.dispose();
    _mapImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(floorServiceProvider);
    
    final buildings = await service.getBuildings();
    final apps = await service.getApps();
    
    setState(() {
      _buildings = buildings;
      _apps = apps;
      _isLoadingBuildings = false;
      _isLoadingApps = false;
    });
  }

  Future<void> _showBuildingPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredBuildings = List.from(_buildings);
    
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
                          hintText: 'Cari gedung...',
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
                              filteredBuildings = List.from(_buildings);
                            } else {
                              filteredBuildings = _buildings.where((b) =>
                                (b['building_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredBuildings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gedung tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredBuildings.length,
                              itemBuilder: (context, index) {
                                final building = filteredBuildings[index];
                                return ListTile(
                                  leading: const Icon(Icons.business, color: Colors.blue),
                                  title: Text(building['building_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedBuildingId = building['id'];
                                      _selectedBuildingName = building['building_name'];
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

  Future<void> _showAppPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredApps = List.from(_apps);
    
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
                          hintText: 'Cari aplikasi...',
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
                              filteredApps = List.from(_apps);
                            } else {
                              filteredApps = _apps.where((a) =>
                                (a['client_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredApps.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aplikasi tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredApps.length,
                              itemBuilder: (context, index) {
                                final app = filteredApps[index];
                                return ListTile(
                                  leading: const Icon(Icons.apps, color: Colors.grey),
                                  title: Text(app['client_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedAppId = app['id'];
                                      _selectedAppName = app['client_name'];
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
    
    if (_selectedBuildingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gedung terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.floor != null;
    final floor = FloorModel(
      id: widget.floor?.id,
      appId: _selectedAppId,
      buildingId: _selectedBuildingId,
      floorNumber: int.tryParse(_floorNumberController.text) ?? 0,
      floorAlias: _floorAliasController.text.trim().isEmpty ? null : _floorAliasController.text,
      mapImageUrl: _mapImageUrlController.text.trim().isEmpty ? null : _mapImageUrlController.text,
    );

    final notifier = ref.read(floorProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateFloor(floor);
    } else {
      success = await notifier.createFloor(floor);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Lantai berhasil diupdate' : 'Lantai berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateFloorNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor lantai wajib diisi';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Nomor lantai harus berupa angka';
    }
    if (number < 1) {
      return 'Nomor lantai minimal 1';
    }
    if (number > 100) {
      return 'Nomor lantai maksimal 100';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(floorProvider);
    final isEditing = widget.floor != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Lantai' : 'Tambah Lantai'),
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
            // Building Picker
            _isLoadingBuildings
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showBuildingPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.business, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gedung *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedBuildingName ?? 'Pilih gedung',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedBuildingName == null 
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
            if (_selectedBuildingId == null && !_isLoadingBuildings)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Gedung wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Floor Number
            TextFormField(
              controller: _floorNumberController,
              decoration: const InputDecoration(
                labelText: 'Nomor Lantai *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                hintText: 'Contoh: 1, 2, 3',
              ),
              keyboardType: TextInputType.number,
              validator: _validateFloorNumber,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Floor Alias
            TextFormField(
              controller: _floorAliasController,
              decoration: const InputDecoration(
                labelText: 'Alias Lantai',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                hintText: 'Contoh: Lantai Dasar, Lantai VIP',
              ),
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Map Image URL
            TextFormField(
              controller: _mapImageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Peta Lantai',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
                hintText: 'URL gambar peta lantai (opsional)',
              ),
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // App Picker (Optional)
            _isLoadingApps
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showAppPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.apps, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aplikasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedAppName ?? 'Pilih aplikasi (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedAppName == null 
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.view_comfortable, color: Colors.green, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _floorAliasController.text.isNotEmpty
                                  ? '${_floorNumberController.text} - ${_floorAliasController.text}'
                                  : (_floorNumberController.text.isEmpty 
                                      ? 'Lantai ?' 
                                      : 'Lantai ${_floorNumberController.text}'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_selectedBuildingName != null)
                              Text(
                                _selectedBuildingName!,
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