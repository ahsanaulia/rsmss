import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_people_categories/models/ref_people_category_model.dart';
import 'package:rsmss/crud/ref_people_categories/providers/ref_people_category_provider.dart';

class RefPeopleCategoryFormPage extends ConsumerStatefulWidget {
  final RefPeopleCategoryModel? item;

  const RefPeopleCategoryFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<RefPeopleCategoryFormPage> createState() => _RefPeopleCategoryFormPageState();
}

class _RefPeopleCategoryFormPageState extends ConsumerState<RefPeopleCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _markerColorController;

  bool _isInsider = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.categoryName ?? '');
    _markerColorController = TextEditingController(text: item?.markerColor ?? '#FF9800');
    _isInsider = item?.isInsider ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _markerColorController.dispose();
    super.dispose();
  }

  Future<void> _showColorPicker() async {
    Color selectedColor = Colors.orange;
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna Marker'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
            ].map((color) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _markerColorController.text = '#${result.value.toRadixString(16).substring(2)}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.item != null;

    final item = RefPeopleCategoryModel(
      id: widget.item?.id,
      categoryName: _nameController.text,
      markerColor: _markerColorController.text.isNotEmpty ? _markerColorController.text : null,
      isInsider: _isInsider,
    );

    final notifier = ref.read(refPeopleCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kategori orang berhasil diupdate' : 'Kategori orang berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama kategori wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    return null;
  }

  String? _validateMarkerColor(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^#[0-9A-Fa-f]{6}$');
    if (!regex.hasMatch(value)) {
      return 'Format warna harus HEX (#RRGGBB)';
    }
    return null;
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.orange;
    final color = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$color', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refPeopleCategoryProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;
    final selectedColor = _getColorFromHex(_markerColorController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori Orang' : 'Tambah Kategori Orang'),
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
            // Nama Kategori
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: 'Contoh: Karyawan Tetap, Vendor, Tamu, Pasien',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Marker Color Picker
            InkWell(
              onTap: isSubmitting ? null : _showColorPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warna Marker',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _markerColorController.text.isEmpty
                                ? 'Pilih warna marker (opsional)'
                                : _markerColorController.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: _markerColorController.text.isEmpty
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
            if (_markerColorController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Format: #RRGGBB (contoh: #FF9800 untuk oranye)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            const SizedBox(height: 16),

            // Is Insider
            SwitchListTile(
              title: const Text('Kategori Internal'),
              subtitle: const Text('Aktifkan jika ini adalah kategori orang dalam (karyawan/insider)'),
              value: _isInsider,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _isInsider = value;
                });
              },
              activeColor: Colors.blue,
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
                            color: selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _isInsider ? Icons.business : Icons.people,
                            color: selectedColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Kategori' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_markerColorController.text.isNotEmpty)
                              Text(
                                'Warna Marker: ${_markerColorController.text}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isInsider ? Colors.blue.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _isInsider ? 'Internal' : 'Eksternal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _isInsider ? Colors.blue.shade800 : Colors.orange.shade800,
                                ),
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