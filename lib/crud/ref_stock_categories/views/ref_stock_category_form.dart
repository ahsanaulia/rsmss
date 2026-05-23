import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_stock_categories/models/ref_stock_category_model.dart';
import 'package:rsmss/crud/ref_stock_categories/providers/ref_stock_category_provider.dart';

class RefStockCategoryFormPage extends ConsumerStatefulWidget {
  final RefStockCategoryModel? category;

  const RefStockCategoryFormPage({
    super.key,
    this.category,
  });

  @override
  ConsumerState<RefStockCategoryFormPage> createState() => _RefStockCategoryFormPageState();
}

class _RefStockCategoryFormPageState extends ConsumerState<RefStockCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;

  String? _selectedIcon;
  String? _selectedColor;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Inventory', 'value': 'inventory', 'icon': Icons.inventory_2},
    {'name': 'Category', 'value': 'category', 'icon': Icons.category},
    {'name': 'Warehouse', 'value': 'warehouse', 'icon': Icons.warehouse},
    {'name': 'Local Shipping', 'value': 'local_shipping', 'icon': Icons.local_shipping},
    {'name': 'Store', 'value': 'store', 'icon': Icons.store},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Merah', 'value': '#FF0000', 'color': Colors.red},
    {'name': 'Biru', 'value': '#0000FF', 'color': Colors.blue},
    {'name': 'Hijau', 'value': '#00FF00', 'color': Colors.green},
    {'name': 'Kuning', 'value': '#FFFF00', 'color': Colors.yellow},
    {'name': 'Orange', 'value': '#FF9800', 'color': Colors.orange},
    {'name': 'Ungu', 'value': '#9C27B0', 'color': Colors.purple},
    {'name': 'Pink', 'value': '#FF69B4', 'color': Colors.pink},
    {'name': 'Teal', 'value': '#008080', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.categoryName ?? '');
    _iconController = TextEditingController(text: category?.iconName ?? '');
    _colorController = TextEditingController(text: category?.markerColor ?? '');
    _selectedIcon = category?.iconName;
    _selectedColor = category?.markerColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.category != null;
    final category = RefStockCategoryModel(
      id: widget.category?.id,
      categoryName: _nameController.text,
      iconName: _selectedIcon,
      markerColor: _selectedColor,
    );

    final notifier = ref.read(refStockCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateCategory(category);
    } else {
      success = await notifier.createCategory(category);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kategori stok berhasil diupdate' : 'Kategori stok berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama kategori stok wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama kategori stok minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama kategori stok maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refStockCategoryProvider);
    final isEditing = widget.category != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori Stok' : 'Tambah Kategori Stok'),
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori Stok *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
                hintText: 'Contoh: Bahan Medis, Alat Kesehatan, Obat-obatan',
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
                              _nameController.text.isEmpty ? 'Nama Kategori Stok' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
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

  Widget _buildPreviewIcon() {
    if (_selectedIcon == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.inventory_2, color: Colors.teal, size: 28),
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
      child: const Icon(Icons.inventory_2, color: Colors.teal, size: 28),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'inventory': Icons.inventory_2,
      'category': Icons.category,
      'warehouse': Icons.warehouse,
      'local_shipping': Icons.local_shipping,
      'store': Icons.store,
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