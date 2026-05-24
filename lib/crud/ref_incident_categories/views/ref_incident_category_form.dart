import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_incident_categories/models/ref_incident_category_model.dart';
import 'package:rsmss/crud/ref_incident_categories/providers/ref_incident_category_provider.dart';

class RefIncidentCategoryFormPage extends ConsumerStatefulWidget {
  final RefIncidentCategoryModel? item;

  const RefIncidentCategoryFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<RefIncidentCategoryFormPage> createState() => _RefIncidentCategoryFormPageState();
}

class _RefIncidentCategoryFormPageState extends ConsumerState<RefIncidentCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codeController = TextEditingController(text: item?.code ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _iconController = TextEditingController(text: item?.icon ?? '');
    _colorController = TextEditingController(text: item?.color ?? '');
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.item != null;

    final item = RefIncidentCategoryModel(
      id: widget.item?.id,
      code: _codeController.text,
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      icon: _iconController.text.isNotEmpty ? _iconController.text : null,
      color: _colorController.text.isNotEmpty ? _colorController.text : null,
      isActive: _isActive,
    );

    final notifier = ref.read(refIncidentCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kategori insiden berhasil diupdate' : 'Kategori insiden berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode kategori wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode minimal 2 karakter';
    }
    if (value.trim().length > 50) {
      return 'Kode maksimal 50 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama kategori wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refIncidentCategoryProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori Insiden' : 'Tambah Kategori Insiden'),
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
            // Kode Kategori
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Kategori *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                hintText: 'Contoh: KDRS, KCLK, BNCM',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Nama Kategori
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: 'Contoh: KDRS, Kecelakaan, Bencana Alam',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Deskripsi singkat tentang kategori ini (opsional)',
              ),
              maxLines: 3,
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Icon (TextField biasa)
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                hintText: 'Contoh: warning, medical, security (opsional)',
              ),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Color (TextField biasa)
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Warna',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.color_lens),
                hintText: 'Contoh: red, green, blue, orange (opsional)',
              ),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Is Active
            SwitchListTile(
              title: const Text('Status Aktif'),
              subtitle: const Text('Nonaktifkan jika kategori ini tidak digunakan lagi'),
              value: _isActive,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: Colors.green,
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
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning_amber, color: Colors.red, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Kategori' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Kode: ${_codeController.text.isEmpty ? 'Kode' : _codeController.text}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_descriptionController.text.isNotEmpty)
                              Text(
                                _descriptionController.text,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isActive ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _isActive ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _isActive ? Colors.green.shade800 : Colors.red.shade800,
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