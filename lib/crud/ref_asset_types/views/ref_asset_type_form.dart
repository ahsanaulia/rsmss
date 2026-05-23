import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_asset_types/models/ref_asset_type_model.dart';
import 'package:rsmss/crud/ref_asset_types/providers/ref_asset_type_provider.dart';
import 'package:rsmss/crud/ref_asset_sub_categories/providers/ref_asset_sub_category_provider.dart';
import 'package:rsmss/crud/ref_asset_sub_categories/models/ref_asset_sub_category_model.dart';

class RefAssetTypeFormPage extends ConsumerStatefulWidget {
  final RefAssetTypeModel? type;

  const RefAssetTypeFormPage({
    super.key,
    this.type,
  });

  @override
  ConsumerState<RefAssetTypeFormPage> createState() => _RefAssetTypeFormPageState();
}

class _RefAssetTypeFormPageState extends ConsumerState<RefAssetTypeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;

  String? _selectedSubCategoryId;
  String? _selectedSubCategoryName;
  String? _selectedCategoryName;
  String? _selectedIcon;
  String? _selectedColor;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Devices', 'value': 'devices', 'icon': Icons.devices},
    {'name': 'Computer', 'value': 'computer', 'icon': Icons.computer},
    {'name': 'Laptop', 'value': 'laptop', 'icon': Icons.laptop},
    {'name': 'Phone', 'value': 'phone', 'icon': Icons.phone_android},
    {'name': 'Tablet', 'value': 'tablet', 'icon': Icons.tablet},
    {'name': 'TV', 'value': 'tv', 'icon': Icons.tv},
    {'name': 'Speaker', 'value': 'speaker', 'icon': Icons.speaker},
    {'name': 'Printer', 'value': 'printer', 'icon': Icons.print},
    {'name': 'Scanner', 'value': 'scanner', 'icon': Icons.scanner},
    {'name': 'Camera', 'value': 'camera', 'icon': Icons.camera_alt},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Merah', 'value': '#FF0000', 'color': Colors.red},
    {'name': 'Biru', 'value': '#0000FF', 'color': Colors.blue},
    {'name': 'Hijau', 'value': '#00FF00', 'color': Colors.green},
    {'name': 'Kuning', 'value': '#FFFF00', 'color': Colors.yellow},
    {'name': 'Orange', 'value': '#FF9800', 'color': Colors.orange},
    {'name': 'Ungu', 'value': '#9C27B0', 'color': Colors.purple},
    {'name': 'Pink', 'value': '#FF69B4', 'color': Colors.pink},
    {'name': 'Abu-abu', 'value': '#808080', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    final type = widget.type;
    _nameController = TextEditingController(text: type?.typeName ?? '');
    _iconController = TextEditingController(text: type?.iconName ?? '');
    _colorController = TextEditingController(text: type?.markerColor ?? '');
    _selectedSubCategoryId = type?.subCategoryId;
    _selectedSubCategoryName = type?.subCategoryName;
    _selectedCategoryName = type?.categoryName;
    _selectedIcon = type?.iconName;
    _selectedColor = type?.markerColor;
    
    // Load sub-categories jika belum ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subCategoryState = ref.read(refAssetSubCategoryProvider);
      if (subCategoryState.subCategories.isEmpty && !subCategoryState.isLoading) {
        ref.read(refAssetSubCategoryProvider.notifier).loadSubCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  /// Searchable Modal Bottom Sheet untuk memilih sub-kategori
  Future<void> _showSubCategoryPicker(List<RefAssetSubCategoryModel> subCategories) async {
    final TextEditingController searchController = TextEditingController();
    List<RefAssetSubCategoryModel> filteredSubCategories = List.from(subCategories);
    
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
                          hintText: 'Cari sub-kategori...',
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
                              filteredSubCategories = List.from(subCategories);
                            } else {
                              filteredSubCategories = subCategories.where((s) =>
                                s.subCategoryName.toLowerCase().contains(value.toLowerCase())
                              ).toList();
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredSubCategories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sub-kategori tidak ditemukan',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredSubCategories.length,
                              itemBuilder: (context, index) {
                                final subCategory = filteredSubCategories[index];
                                return ListTile(
                                  leading: _buildSubCategoryIcon(subCategory.iconName),
                                  title: Text(subCategory.subCategoryName),
                                  subtitle: subCategory.categoryName != null
                                      ? Text(
                                          'Kategori: ${subCategory.categoryName}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedSubCategoryId = subCategory.id;
                                      _selectedSubCategoryName = subCategory.subCategoryName;
                                      _selectedCategoryName = subCategory.categoryName;
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
    if (_selectedSubCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih sub-kategori terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.type != null;
    final type = RefAssetTypeModel(
      id: widget.type?.id,
      typeName: _nameController.text,
      iconName: _selectedIcon,
      markerColor: _selectedColor,
      subCategoryId: _selectedSubCategoryId,
    );

    final notifier = ref.read(refAssetTypeProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateType(type);
    } else {
      success = await notifier.createType(type);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Tipe aset berhasil diupdate' : 'Tipe aset berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tipe aset wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama tipe aset minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama tipe aset maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final subCategoryState = ref.watch(refAssetSubCategoryProvider);
    final typeState = ref.watch(refAssetTypeProvider);
    final isEditing = widget.type != null;
    
    final subCategories = subCategoryState.subCategories;
    final isLoadingSubCategories = subCategoryState.isLoading;
    final isSubmitting = typeState.isSubmitting;

    // Tampilkan nama sub-kategori yang dipilih
    final selectedSubCategoryDisplay = _selectedSubCategoryName ?? 
        (_selectedSubCategoryId != null 
            ? subCategories.firstWhere(
                (s) => s.id == _selectedSubCategoryId, 
                orElse: () => RefAssetSubCategoryModel.empty()
              ).subCategoryName 
            : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tipe Aset' : 'Tambah Tipe Aset'),
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
            // Searchable Sub-Category Picker
            InkWell(
              onTap: isLoadingSubCategories || isSubmitting 
                  ? null 
                  : () => _showSubCategoryPicker(subCategories),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.subdirectory_arrow_right, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub-Kategori *',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoadingSubCategories 
                                ? 'Memuat sub-kategori...' 
                                : (selectedSubCategoryDisplay ?? 'Pilih sub-kategori'),
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedSubCategoryDisplay == null 
                                  ? Colors.grey[400] 
                                  : Colors.black,
                            ),
                          ),
                          if (_selectedCategoryName != null)
                            Text(
                              'Kategori: $_selectedCategoryName',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            
            if (isLoadingSubCategories)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            
            const SizedBox(height: 16),

            // Nama Tipe Aset
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Tipe Aset *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices),
                hintText: 'Contoh: LED TV 55 inch, AC Split 2 PK, Laptop Gaming',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Icon Picker
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emoji_emotions_outlined),
              ),
              value: _selectedIcon,
              hint: const Text('Pilih icon (opsional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tanpa Icon')),
                ..._iconOptions.map((icon) {
                  return DropdownMenuItem(
                    value: icon['value'],
                    child: Row(
                      children: [
                        Icon(icon['icon'], size: 20),
                        const SizedBox(width: 12),
                        Text(icon['name']),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _selectedIcon = value;
                  _iconController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            // Color Picker
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Warna Marker',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.color_lens),
              ),
              value: _selectedColor,
              hint: const Text('Pilih warna (opsional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tanpa Warna')),
                ..._colorOptions.map((color) {
                  return DropdownMenuItem(
                    value: color['value'],
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color['color'],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(color['name']),
                        const SizedBox(width: 8),
                        Text(
                          color['value'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _selectedColor = value;
                  _colorController.text = value ?? '';
                });
              },
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
                        _buildPreviewIcon(),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Tipe Aset' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (selectedSubCategoryDisplay != null)
                              Text(
                                selectedSubCategoryDisplay,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            if (_selectedCategoryName != null)
                              Text(
                                'Kategori: $_selectedCategoryName',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            if (_selectedColor != null)
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _parseColor(_selectedColor),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedColor!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
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
                    onPressed: (isSubmitting || isLoadingSubCategories) ? null : _submitForm,
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

  Widget _buildSubCategoryIcon(String? iconName) {
    final iconData = _getIconData(iconName);
    if (iconData != null) {
      return Icon(iconData, size: 24, color: Colors.green);
    }
    return const Icon(Icons.subdirectory_arrow_right, size: 24, color: Colors.green);
  }

  Widget _buildPreviewIcon() {
    if (_selectedIcon == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.devices, color: Colors.orange, size: 28),
      );
    }

    final iconData = _getIconData(_selectedIcon);
    if (iconData != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: Colors.orange, size: 28),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.devices, color: Colors.orange, size: 28),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'devices': Icons.devices,
      'computer': Icons.computer,
      'phone': Icons.phone_android,
      'tablet': Icons.tablet,
      'laptop': Icons.laptop,
      'tv': Icons.tv,
      'speaker': Icons.speaker,
      'printer': Icons.print,
      'scanner': Icons.scanner,
      'camera': Icons.camera_alt,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}