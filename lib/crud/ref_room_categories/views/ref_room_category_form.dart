import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_room_categories/models/ref_room_category_model.dart';
import 'package:rsmss/crud/ref_room_categories/providers/ref_room_category_provider.dart';

class RefRoomCategoryFormPage extends ConsumerStatefulWidget {
  final RefRoomCategoryModel? category;

  const RefRoomCategoryFormPage({
    super.key,
    this.category,
  });

  @override
  ConsumerState<RefRoomCategoryFormPage> createState() => _RefRoomCategoryFormPageState();
}

class _RefRoomCategoryFormPageState extends ConsumerState<RefRoomCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _colorController;
  late TextEditingController _iconController;

  String? _selectedIcon;
  String? _selectedColor;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Meeting Room', 'value': 'meeting_room', 'icon': Icons.meeting_room},
    {'name': 'Bed', 'value': 'bed', 'icon': Icons.bed},
    {'name': 'Local Hospital', 'value': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'Medical Services', 'value': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'Vaccines', 'value': 'vaccines', 'icon': Icons.vaccines},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Merah', 'value': '#FF0000', 'color': Colors.red},
    {'name': 'Biru', 'value': '#0000FF', 'color': Colors.blue},
    {'name': 'Hijau', 'value': '#00FF00', 'color': Colors.green},
    {'name': 'Kuning', 'value': '#FFFF00', 'color': Colors.yellow},
    {'name': 'Orange', 'value': '#FF9800', 'color': Colors.orange},
    {'name': 'Ungu', 'value': '#9C27B0', 'color': Colors.purple},
    {'name': 'Pink', 'value': '#FF69B4', 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.categoryName ?? '');
    _colorController = TextEditingController(text: category?.colorCode ?? '');
    _iconController = TextEditingController(text: category?.iconName ?? '');
    _selectedIcon = category?.iconName;
    _selectedColor = category?.colorCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.category != null;
    final category = RefRoomCategoryModel(
      id: widget.category?.id,
      appId: widget.category?.appId,
      categoryName: _nameController.text,
      colorCode: _selectedColor,
      iconName: _selectedIcon,
    );

    final notifier = ref.read(refRoomCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateCategory(category);
    } else {
      success = await notifier.createCategory(category);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kategori ruangan berhasil diupdate' : 'Kategori ruangan berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama kategori ruangan wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama kategori ruangan minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama kategori ruangan maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refRoomCategoryProvider);
    final isEditing = widget.category != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori Ruangan' : 'Tambah Kategori Ruangan'),
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
                labelText: 'Nama Kategori Ruangan *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
                hintText: 'Contoh: Ruang Rawat Inap, Ruang Operasi, ICU',
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
                labelText: 'Warna',
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
                              _nameController.text.isEmpty ? 'Nama Kategori' : _nameController.text,
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

  Widget _buildPreviewIcon() {
    if (_selectedIcon == null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.meeting_room, color: Colors.orange, size: 28),
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
      child: const Icon(Icons.meeting_room, color: Colors.orange, size: 28),
    );
  }

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    final iconMap = {
      'meeting_room': Icons.meeting_room,
      'bed': Icons.bed,
      'local_hospital': Icons.local_hospital,
      'medical_services': Icons.medical_services,
      'vaccines': Icons.vaccines,
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