import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/rooms/models/room_model.dart';
import 'package:rsmss/crud/rooms/providers/room_provider.dart';
import 'package:rsmss/crud/rooms/services/room_service.dart';

class RoomFormPage extends ConsumerStatefulWidget {
  final RoomModel? room;

  const RoomFormPage({super.key, this.room});

  @override
  ConsumerState<RoomFormPage> createState() => _RoomFormPageState();
}

class _RoomFormPageState extends ConsumerState<RoomFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNameController;
  late TextEditingController _xPosController;
  late TextEditingController _yPosController;
  late TextEditingController _xPosMaxController;
  late TextEditingController _yPosMaxController;

  String? _selectedFloorId;
  String? _selectedFloorDisplay;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedCategoryColor;
  String? _selectedAppId;
  String? _selectedAppName;
  bool _isEntryGate = false;

  List<Map<String, dynamic>> _floors = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _apps = [];

  bool _isLoadingFloors = true;
  bool _isLoadingCategories = true;
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _roomNameController = TextEditingController(text: room?.roomName ?? '');
    _xPosController = TextEditingController(text: room?.xPos?.toString() ?? '');
    _yPosController = TextEditingController(text: room?.yPos?.toString() ?? '');
    _xPosMaxController = TextEditingController(
      text: room?.xPosMax?.toString() ?? '',
    );
    _yPosMaxController = TextEditingController(
      text: room?.yPosMax?.toString() ?? '',
    );
    _selectedFloorId = room?.floorId;
    _selectedCategoryId = room?.categoryId;
    _selectedCategoryName = room?.categoryName;
    _selectedCategoryColor = room?.categoryColorCode;
    _selectedAppId = room?.appId;
    _isEntryGate = room?.isEntryGate ?? false;

    _loadDropdownData();
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _xPosController.dispose();
    _yPosController.dispose();
    _xPosMaxController.dispose();
    _yPosMaxController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    final service = ref.read(roomServiceProvider);

    final floors = await service.getFloors();
    final categories = await service.getRoomCategories();
    final apps = await service.getApps();

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
      _categories = categories;
      _apps = apps;
      _selectedFloorDisplay = selectedFloorDisplay;
      _isLoadingFloors = false;
      _isLoadingCategories = false;
      _isLoadingApps = false;
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
                              filteredFloors = _floors
                                  .where(
                                    (f) => (f['display_name'] as String)
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                                  )
                                  .toList();
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
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
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
                                  leading: const Icon(
                                    Icons.view_comfortable,
                                    color: Colors.green,
                                  ),
                                  title: Text(floor['display_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedFloorId = floor['id'];
                                      _selectedFloorDisplay =
                                          floor['display_name'];
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

  Future<void> _showCategoryPicker() async {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredCategories = List.from(_categories);

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
                          hintText: 'Cari kategori ruangan...',
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
                              filteredCategories = List.from(_categories);
                            } else {
                              filteredCategories = _categories
                                  .where(
                                    (c) => (c['category_name'] as String)
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                                  )
                                  .toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredCategories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kategori tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = filteredCategories[index];
                                return ListTile(
                                  leading: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _parseColor(
                                        category['color_code'],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  title: Text(category['category_name']),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category['id'];
                                      _selectedCategoryName =
                                          category['category_name'];
                                      _selectedCategoryColor =
                                          category['color_code'];
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
                              filteredApps = _apps
                                  .where(
                                    (a) => (a['client_name'] as String)
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                                  )
                                  .toList();
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
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
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
                                  leading: const Icon(
                                    Icons.apps,
                                    color: Colors.grey,
                                  ),
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

    if (_selectedFloorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih lantai terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isEditing = widget.room != null;
    final room = RoomModel(
      id: widget.room?.id,
      appId: _selectedAppId,
      floorId: _selectedFloorId,
      roomName: _roomNameController.text,
      categoryId: _selectedCategoryId,
      isEntryGate: _isEntryGate,
      xPos: _xPosController.text.trim().isEmpty
          ? null
          : double.tryParse(_xPosController.text),
      yPos: _yPosController.text.trim().isEmpty
          ? null
          : double.tryParse(_yPosController.text),
      xPosMax: _xPosMaxController.text.trim().isEmpty
          ? null
          : int.tryParse(_xPosMaxController.text),
      yPosMax: _yPosMaxController.text.trim().isEmpty
          ? null
          : int.tryParse(_yPosMaxController.text),
    );

    final notifier = ref.read(roomProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateRoom(room);
    } else {
      success = await notifier.createRoom(room);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Ruangan berhasil diupdate'
                : 'Ruangan berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomProvider);
    final isEditing = widget.room != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Ruangan' : 'Tambah Ruangan'),
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
            // Floor Picker
            _isLoadingFloors
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showFloorPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                                  'Lantai *',
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

            // Room Name
            TextFormField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Ruangan *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
                hintText: 'Contoh: Ruang Operasi, Ruang Pasien 101, ICU',
              ),
              validator: (value) => _validateRequired(value, 'Nama ruangan'),
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Category Picker
            _isLoadingCategories
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : InkWell(
                    onTap: isSubmitting ? null : _showCategoryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _parseColor(_selectedCategoryColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kategori Ruangan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedCategoryName ??
                                      'Pilih kategori (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedCategoryName == null
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

            // Is Entry Gate
            SwitchListTile(
              title: const Text('Pintu Masuk/Gate'),
              subtitle: const Text('Tandai sebagai pintu masuk utama gedung'),
              value: _isEntryGate,
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _isEntryGate = value;
                      });
                    },
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Posisi X & Y (double)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _xPosController,
                    decoration: const InputDecoration(
                      labelText: 'Posisi X',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Koordinat X (opsional)',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yPosController,
                    decoration: const InputDecoration(
                      labelText: 'Posisi Y',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Koordinat Y (opsional)',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    enabled: !isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Posisi Max X & Y (integer)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _xPosMaxController,
                    decoration: const InputDecoration(
                      labelText: 'Posisi Max X',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.crop_free),
                      hintText: 'Max X (opsional)',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yPosMaxController,
                    decoration: const InputDecoration(
                      labelText: 'Posisi Max Y',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.crop_free),
                      hintText: 'Max Y (opsional)',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !isSubmitting,
                  ),
                ),
              ],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                                  _selectedAppName ??
                                      'Pilih aplikasi (opsional)',
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
                            color: _parseColor(
                              _selectedCategoryColor,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.meeting_room,
                            color: _parseColor(_selectedCategoryColor),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _roomNameController.text.isEmpty
                                  ? 'Nama Ruangan'
                                  : _roomNameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_selectedFloorDisplay != null)
                              Text(
                                _selectedFloorDisplay!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            if (_selectedCategoryName != null)
                              Text(
                                _selectedCategoryName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _parseColor(_selectedCategoryColor),
                                ),
                              ),
                            if (_isEntryGate)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Pintu Masuk',
                                  style: TextStyle(fontSize: 10),
                                ),
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
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.orange;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.orange;
    }
  }
}
