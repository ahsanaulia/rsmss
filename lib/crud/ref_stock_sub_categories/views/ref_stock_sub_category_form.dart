import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/models/ref_stock_sub_category_model.dart';
import 'package:rsmss/crud/ref_stock_sub_categories/providers/ref_stock_sub_category_provider.dart';
import 'package:rsmss/crud/ref_stock_categories/providers/ref_stock_category_provider.dart';
import 'package:rsmss/crud/ref_stock_categories/models/ref_stock_category_model.dart';

class RefStockSubCategoryFormPage extends ConsumerStatefulWidget {
  final RefStockSubCategoryModel? subCategory;

  const RefStockSubCategoryFormPage({
    super.key,
    this.subCategory,
  });

  @override
  ConsumerState<RefStockSubCategoryFormPage> createState() => _RefStockSubCategoryFormPageState();
}

class _RefStockSubCategoryFormPageState extends ConsumerState<RefStockSubCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedIcon;
  String? _selectedColor;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Subdirectory', 'value': 'subdirectory', 'icon': Icons.subdirectory_arrow_right},
    {'name': 'Label', 'value': 'label', 'icon': Icons.label},
    {'name': 'Category', 'value': 'category', 'icon': Icons.category},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Merah', 'value': '#FF0000', 'color': Colors.red},
    {'name': 'Biru', 'value': '#0000FF', 'color': Colors.blue},
    {'name': 'Hijau', 'value': '#00FF00', 'color': Colors.green},
    {'name': 'Kuning', 'value': '#FFFF00', 'color': Colors.yellow},
    {'name': 'Orange', 'value': '#FF9800', 'color': Colors.orange},
    {'name': 'Ungu', 'value': '#9C27B0', 'color': Colors.purple},
    {'name': 'Teal', 'value': '#008080', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    final subCategory = widget.subCategory;
    _nameController = TextEditingController(text: subCategory?.subCategoryName ?? '');
    _iconController = TextEditingController(text: subCategory?.iconName ?? '');
    _colorController = TextEditingController(text: subCategory?.markerColor ?? '');
    _selectedCategoryId = subCategory?.categoryId;
    _selectedCategoryName = subCategory?.categoryName;
    _selectedIcon = subCategory?.iconName;
    _selectedColor = subCategory?.markerColor;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryState = ref.read(refStockCategoryProvider);
      if (categoryState.categories.isEmpty && !categoryState.isLoading) {
        ref.read(refStockCategoryProvider.notifier).loadCategories();
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

  Future<void> _showCategoryPicker(List<RefStockCategoryModel> categories) async {
    final TextEditingController searchController = TextEditingController();
    List<RefStockCategoryModel> filteredCategories = List.from(categories);
    
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
                          hintText: 'Cari kategori stok...',
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
                              filteredCategories = List.from(categories);
                            } else {
                              filteredCategories = categories.where((c) =>
                                c.categoryName.toLowerCase().contains(value.toLowerCase())
                              ).toList();
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
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
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
                                  leading: _buildCategoryIcon(category.iconName),
                                  title: Text(category.categoryName),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category.id;
                                      _selectedCategoryName = category.categoryName;
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
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori stok terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final isEditing = widget.subCategory != null;
    final subCategory = RefStockSubCategoryModel(
      id: widget.subCategory?.id,
      categoryId: _selectedCategoryId!,
      subCategoryName: _nameController.text,
      iconName: _selectedIcon,
      markerColor: _selectedColor,
    );

    final notifier = ref.read(refStockSubCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateSubCategory(subCategory);
    } else {
      success = await notifier.createSubCategory(subCategory);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Sub-kategori stok berhasil diupdate' : 'Sub-kategori stok berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama sub-kategori stok wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama sub-kategori stok minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama sub-kategori stok maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(refStockCategoryProvider);
    final subCategoryState = ref.watch(refStockSubCategoryProvider);
    final isEditing = widget.subCategory != null;
    
    final categories = categoryState.categories;
    final isLoadingCategories = categoryState.isLoading;
    final isSubmitting = subCategoryState.isSubmitting;

    final selectedCategoryDisplay = _selectedCategoryName ?? 
        (_selectedCategoryId != null 
            ? categories.firstWhere(
                (c) => c.id == _selectedCategoryId, 
                orElse: () => RefStockCategoryModel.empty()
              ).categoryName 
            : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sub-Kategori Stok' : 'Tambah Sub-Kategori Stok'),
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
            InkWell(
              onTap: isLoadingCategories || isSubmitting 
                  ? null 
                  : () => _showCategoryPicker(categories),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori Stok *',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoadingCategories 
                                ? 'Memuat kategori...' 
                                : (selectedCategoryDisplay ?? 'Pilih kategori stok'),
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedCategoryDisplay == null 
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
            
            if (isLoadingCategories)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Sub-Kategori Stok *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
                hintText: 'Contoh: Bahan Habis Pakai, Alat Tahan Lama',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

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
                              _nameController.text.isEmpty ? 'Nama Sub-Kategori' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (selectedCategoryDisplay != null)
                              Text(
                                selectedCategoryDisplay,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                    onPressed: (isSubmitting || isLoadingCategories) ? null : _submitForm,
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

  Widget _buildCategoryIcon(String? iconName) {
    final iconData = _getIconData(iconName);
    if (iconData != null) {
      return Icon(iconData, size: 20, color: Colors.teal);
    }
    return const Icon(Icons.category, size: 20, color: Colors.teal);
  }

  Widget _buildPreviewIcon() {
    if (_selectedIcon == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.subdirectory_arrow_right, color: Colors.teal, size: 28),
      );
    }

    final iconData = _getIconData(_selectedIcon);
    if (iconData != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: Colors.teal, size: 28),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.subdirectory_arrow_right, color: Colors.teal, size: 28),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'subdirectory': Icons.subdirectory_arrow_right,
      'label': Icons.label,
      'category': Icons.category,
      'inventory': Icons.inventory_2,
      'warehouse': Icons.warehouse,
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