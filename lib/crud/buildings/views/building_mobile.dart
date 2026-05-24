import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rsmss/crud/buildings/models/building_model.dart';
import 'package:rsmss/crud/buildings/providers/building_provider.dart';
import 'package:rsmss/crud/buildings/providers/building_state.dart';
import 'package:rsmss/crud/buildings/services/building_service.dart';

// ==================== HALAMAN UTAMA ====================
class BuildingMobilePage extends ConsumerStatefulWidget {
  const BuildingMobilePage({super.key});

  @override
  ConsumerState<BuildingMobilePage> createState() => _BuildingMobilePageState();
}

class _BuildingMobilePageState extends ConsumerState<BuildingMobilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(buildingProvider.notifier).loadBuildings();
    });
  }

  void _navigateToEditForm(BuildingModel building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingEditPage(building: building),
      ),
    ).then((_) {
      if (mounted) {
        ref.read(buildingProvider.notifier).loadBuildings();
      }
    });
  }

  void _navigateToAddForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuildingAddPage(),
      ),
    ).then((_) {
      if (mounted) {
        ref.read(buildingProvider.notifier).loadBuildings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buildingProvider);
    final errorMessage = state.errorMessage;

    if (errorMessage != null && errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
          ref.read(buildingProvider.notifier).clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF01579B),
        centerTitle: true,
        title: Text(
          'Update Lokasi Gedung',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddForm,
        backgroundColor: const Color(0xFF01579B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildingState state) {
    if (state.isLoading && state.buildings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.buildings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada data gedung', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToAddForm,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B)),
              child: const Text('Tambah Gedung Baru'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(buildingProvider.notifier).loadBuildings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.buildings.length,
        itemBuilder: (context, index) {
          final building = state.buildings[index];
          final hasLocation = building.latitude != null && building.longitude != null;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: hasLocation ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasLocation ? Icons.check_circle : Icons.location_off,
                  color: hasLocation ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(building.buildingName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (building.hospitalName != null)
                    Text(building.hospitalName!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  Text(
                    hasLocation ? '📍 Lokasi sudah terisi' : '⚠️ Belum memiliki lokasi',
                    style: GoogleFonts.poppins(fontSize: 11, color: hasLocation ? Colors.green : Colors.orange),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _navigateToEditForm(building),
            ),
          );
        },
      ),
    );
  }
}

// ==================== FORM TAMBAH GEDUNG BARU ====================
class BuildingAddPage extends ConsumerStatefulWidget {
  const BuildingAddPage({super.key});

  @override
  ConsumerState<BuildingAddPage> createState() => _BuildingAddPageState();
}

class _BuildingAddPageState extends ConsumerState<BuildingAddPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _totalFloorsController;

  String? _selectedHospitalId;
  String? _selectedHospitalName;
  String? _selectedFunctionId;
  String? _selectedFunctionName;

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _functions = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _totalFloorsController = TextEditingController(text: '1');
    _loadData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalFloorsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final service = ref.read(buildingServiceProvider);
    
    final hospitals = await service.getHospitals();
    final functions = await service.getBuildingFunctions();
    
    if (mounted) {
      setState(() {
        _hospitals = hospitals;
        _functions = functions;
        _isLoadingData = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);
    
    final service = ref.read(buildingServiceProvider);
    final location = await service.getCurrentLocation();
    
    if (location != null && mounted) {
      setState(() {
        _latitude = location['latitude'];
        _longitude = location['longitude'];
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi terdeteksi'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
      );
    } else if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _showHospitalPicker() async {
    if (!mounted) return;
    
    if (_hospitals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data rumah sakit masih kosong'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return _buildHospitalPickerSheet(bottomSheetContext, _hospitals);
      },
    );
    
    if (result != null && mounted) {
      setState(() {
        _selectedHospitalId = result['id'];
        _selectedHospitalName = result['name'];
      });
    }
  }

  Widget _buildHospitalPickerSheet(BuildContext sheetContext, List<Map<String, dynamic>> hospitals) {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredHospitals = List.from(hospitals);
    
    return StatefulBuilder(
      builder: (context, setStateSheet) {
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
                      setStateSheet(() {
                        if (value.isEmpty) {
                          filteredHospitals = List.from(hospitals);
                        } else {
                          filteredHospitals = hospitals.where((h) =>
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
                                Navigator.pop(sheetContext, hospital);
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
  }

  Future<void> _showFunctionPicker() async {
    if (!mounted) return;
    
    if (_functions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data fungsi gedung masih kosong'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return _buildFunctionPickerSheet(bottomSheetContext, _functions);
      },
    );
    
    if (result != null && mounted) {
      setState(() {
        _selectedFunctionId = result['id'];
        _selectedFunctionName = result['function_name'];
      });
    }
  }

  Widget _buildFunctionPickerSheet(BuildContext sheetContext, List<Map<String, dynamic>> functions) {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredFunctions = List.from(functions);
    
    return StatefulBuilder(
      builder: (context, setStateSheet) {
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
                      setStateSheet(() {
                        if (value.isEmpty) {
                          filteredFunctions = List.from(functions);
                        } else {
                          filteredFunctions = functions.where((f) =>
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
                                Navigator.pop(sheetContext, function);
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
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHospitalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rumah sakit'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);

    final building = BuildingModel(
      hospitalId: _selectedHospitalId,
      buildingName: _nameController.text,
      functionId: _selectedFunctionId,
      totalFloors: int.tryParse(_totalFloorsController.text) ?? 1,
      latitude: _latitude,
      longitude: _longitude,
    );

    final success = await ref.read(buildingProvider.notifier).createBuilding(building);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gedung berhasil ditambahkan'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama gedung wajib diisi';
    if (value.trim().length < 2) return 'Minimal 2 karakter';
    if (value.trim().length > 255) return 'Maksimal 255 karakter';
    return null;
  }

  String? _validateTotalFloors(String? value) {
    if (value == null || value.trim().isEmpty) return 'Jumlah lantai wajib diisi';
    final floors = int.tryParse(value);
    if (floors == null || floors < 1) return 'Minimal 1';
    if (floors > 100) return 'Maksimal 100';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: Color(0xFFE0F2F1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Tambah Gedung Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Gedung *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business)),
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _showHospitalPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_selectedHospitalName ?? 'Pilih Rumah Sakit *', style: TextStyle(color: _selectedHospitalName == null ? Colors.grey : Colors.black))),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _showFunctionPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.business_center),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_selectedFunctionName ?? 'Pilih Fungsi Gedung (opsional)', style: TextStyle(color: _selectedFunctionName == null ? Colors.grey : Colors.black))),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _totalFloorsController,
                decoration: const InputDecoration(labelText: 'Jumlah Lantai *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.view_comfortable)),
                keyboardType: TextInputType.number,
                validator: _validateTotalFloors,
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Lokasi Gedung', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                          icon: _isLoadingLocation ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.gps_fixed),
                          label: Text(_isLoadingLocation ? 'Mendapatkan...' : 'Ambil Lokasi'),
                        ),
                      ],
                    ),
                    if (_latitude != null) ...[
                      const SizedBox(height: 8),
                      Text('Latitude: ${_latitude!.toStringAsFixed(6)}'),
                      Text('Longitude: ${_longitude!.toStringAsFixed(6)}'),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Tekan tombol Ambil Lokasi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B)),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Gedung', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== FORM EDIT (UPDATE LOKASI) ====================
class BuildingEditPage extends ConsumerStatefulWidget {
  final BuildingModel building;
  const BuildingEditPage({super.key, required this.building});

  @override
  ConsumerState<BuildingEditPage> createState() => _BuildingEditPageState();
}

class _BuildingEditPageState extends ConsumerState<BuildingEditPage> {
  late TextEditingController _nameController;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.building.buildingName);
    _latitude = widget.building.latitude;
    _longitude = widget.building.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);
    final service = ref.read(buildingServiceProvider);
    final location = await service.getCurrentLocation();
    if (location != null && mounted) {
      setState(() {
        _latitude = location['latitude'];
        _longitude = location['longitude'];
        _isLoadingLocation = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _updateLocation() async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final updatedBuilding = BuildingModel(
      id: widget.building.id,
      hospitalId: widget.building.hospitalId,
      buildingName: _nameController.text,
      functionId: widget.building.functionId,
      totalFloors: widget.building.totalFloors,
      latitude: _latitude,
      longitude: _longitude,
    );
    final success = await ref.read(buildingProvider.notifier).updateBuilding(updatedBuilding);
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi berhasil diupdate'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Update Lokasi: ${widget.building.buildingName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Gedung'),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    if (_latitude != null) Text('Latitude: ${_latitude!.toStringAsFixed(6)}'),
                    if (_longitude != null) Text('Longitude: ${_longitude!.toStringAsFixed(6)}'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: _isLoadingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.gps_fixed),
                      label: Text(_isLoadingLocation ? 'Mendapatkan...' : 'Ambil Lokasi'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _updateLocation,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B)),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Update Lokasi', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}