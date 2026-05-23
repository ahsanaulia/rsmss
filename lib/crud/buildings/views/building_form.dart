import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/buildings/models/building_model.dart';
import 'package:rsmss/crud/buildings/providers/building_provider.dart';
import 'package:rsmss/crud/buildings/services/building_service.dart';

class BuildingFormPage extends ConsumerStatefulWidget {
  final BuildingModel? building;

  const BuildingFormPage({
    super.key,
    this.building,
  });

  @override
  ConsumerState<BuildingFormPage> createState() => _BuildingFormPageState();
}

class _BuildingFormPageState extends ConsumerState<BuildingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _totalFloorsController;

  String? _selectedHospitalId;
  String? _selectedHospitalName;
  String? _selectedFunctionId;
  String? _selectedFunctionName;
  String? _selectedAppId;
  String? _selectedAppName;

  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _functions = [];
  List<Map<String, dynamic>> _apps = [];

  bool _isLoadingHospitals = true;
  bool _isLoadingFunctions = true;
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    final building = widget.building;
    _nameController = TextEditingController(text: building?.buildingName ?? '');
    _totalFloorsController = TextEditingController(text: building?.totalFloors?.toString() ?? '1');
    _selectedHospitalId = building?.hospitalId;
    _selectedHospitalName = building?.hospitalName;
    _selectedFunctionId = building?.functionId;
    _selectedFunctionName = building?.functionName;
    _selectedAppId = building?.appId;
    
    _loadDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalFloorsController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(buildingServiceProvider);
    
    final hospitals = await service.getHospitals();
    final functions = await service.getBuildingFunctions();
    final apps = await service.getApps();
    
    setState(() {
      _hospitals = hospitals;
      _functions = functions;
      _apps = apps;
      _isLoadingHospitals = false;
      _isLoadingFunctions = false;
      _isLoadingApps = false;
    });
  }

  Future<void> _showHospitalPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredHospitals = List.from(_hospitals);
    
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
                          hintText: 'Cari rumah sakit...',
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
                              filteredHospitals = List.from(_hospitals);
                            } else {
                              filteredHospitals = _hospitals.where((h) =>
                                (h['name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredHospitals.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rumah sakit tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredHospitals.length,
                              itemBuilder: (context, index) {
                                final hospital = filteredHospitals[index];
                                return ListTile(
                                  leading: const Icon(Icons.local_hospital, color: Colors.blue),
                                  title: Text(hospital['name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedHospitalId = hospital['id'];
                                      _selectedHospitalName = hospital['name'];
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

  Future<void> _showFunctionPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredFunctions = List.from(_functions);
    
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
                          hintText: 'Cari fungsi gedung...',
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
                              filteredFunctions = List.from(_functions);
                            } else {
                              filteredFunctions = _functions.where((f) =>
                                (f['function_name'] as String).toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredFunctions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fungsi tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredFunctions.length,
                              itemBuilder: (context, index) {
                                final function = filteredFunctions[index];
                                return ListTile(
                                  leading: const Icon(Icons.business_center, color: Colors.purple),
                                  title: Text(function['function_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedFunctionId = function['id'];
                                      _selectedFunctionName = function['function_name'];
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
                                (a['app_name'] as String).toLowerCase().contains(value.toLowerCase())
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
                                  title: Text(app['app_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedAppId = app['id'];
                                      _selectedAppName = app['app_name'];
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
    
    if (_selectedHospitalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rumah sakit terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.building != null;
    final building = BuildingModel(
      id: widget.building?.id,
      appId: _selectedAppId,
      hospitalId: _selectedHospitalId,
      buildingName: _nameController.text,
      functionId: _selectedFunctionId,
      totalFloors: int.tryParse(_totalFloorsController.text) ?? 1,
    );

    final notifier = ref.read(buildingProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateBuilding(building);
    } else {
      success = await notifier.createBuilding(building);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Gedung berhasil diupdate' : 'Gedung berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama gedung wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama gedung minimal 2 karakter';
    }
    if (value.trim().length > 255) {
      return 'Nama gedung maksimal 255 karakter';
    }
    return null;
  }

  String? _validateTotalFloors(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah lantai wajib diisi';
    }
    final floors = int.tryParse(value);
    if (floors == null || floors < 1) {
      return 'Jumlah lantai minimal 1';
    }
    if (floors > 100) {
      return 'Jumlah lantai maksimal 100';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buildingProvider);
    final isEditing = widget.building != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Gedung' : 'Tambah Gedung'),
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
            // Nama Gedung
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Gedung *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                hintText: 'Contoh: Gedung Utama, Gedung Bedah, Gedung Rawat Inap',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Hospital Picker
            _isLoadingHospitals
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showHospitalPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_hospital, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rumah Sakit *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedHospitalName ?? 'Pilih rumah sakit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedHospitalName == null 
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
            if (_selectedHospitalId == null && !_isLoadingHospitals)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Rumah sakit wajib dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.red[400]),
                ),
              ),
            const SizedBox(height: 16),

            // Function Picker
            _isLoadingFunctions
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showFunctionPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.business_center, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fungsi Gedung',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedFunctionName ?? 'Pilih fungsi gedung (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedFunctionName == null 
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

            // Total Floors
            TextFormField(
              controller: _totalFloorsController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Lantai *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.view_comfortable),
                hintText: 'Contoh: 5',
              ),
              keyboardType: TextInputType.number,
              validator: _validateTotalFloors,
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
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.business, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Gedung' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_selectedHospitalName != null)
                              Text(
                                _selectedHospitalName!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_selectedFunctionName != null)
                              Text(
                                _selectedFunctionName!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            Text(
                              'Jumlah Lantai: ${_totalFloorsController.text.isEmpty ? "?" : _totalFloorsController.text}',
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
                      backgroundColor: Colors.blue,
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