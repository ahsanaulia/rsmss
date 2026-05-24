import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/employee_qualifications/models/employee_qualification_model.dart';
import 'package:rsmss/crud/employee_qualifications/providers/employee_qualification_provider.dart';

class EmployeeQualificationFormPage extends ConsumerStatefulWidget {
  final EmployeeQualificationModel? item;

  const EmployeeQualificationFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<EmployeeQualificationFormPage> createState() => _EmployeeQualificationFormPageState();
}

class _EmployeeQualificationFormPageState extends ConsumerState<EmployeeQualificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _validityPeriodController;
  late TextEditingController _descriptionController;

  bool _requiresRenewal = true;
  bool _isActive = true;

  final List<Map<String, String>> _categoryOptions = [
    {'value': 'medical', 'label': 'Medis'},
    {'value': 'nursing', 'label': 'Keperawatan'},
    {'value': 'administrative', 'label': 'Administrasi'},
    {'value': 'technical', 'label': 'Teknis'},
    {'value': 'other', 'label': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codeController = TextEditingController(text: item?.qualificationCode ?? '');
    _nameController = TextEditingController(text: item?.qualificationName ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');
    _validityPeriodController = TextEditingController(
      text: item?.validityPeriodMonths?.toString() ?? '',
    );
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _requiresRenewal = item?.requiresRenewal ?? true;
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _validityPeriodController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showCategoryPicker() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return _buildCategoryPickerSheet(bottomSheetContext);
      },
    );

    if (result != null && mounted) {
      setState(() {
        _categoryController.text = result['value']!;
      });
    }
  }

  Widget _buildCategoryPickerSheet(BuildContext sheetContext) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _categoryOptions.length,
                itemBuilder: (context, index) {
                  final option = _categoryOptions[index];
                  return ListTile(
                    leading: Icon(
                      Icons.category,
                      color: _categoryController.text == option['value']
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    title: Text(option['label']!),
                    trailing: _categoryController.text == option['value']
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext, option);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.item != null;

    int? validityPeriod;
    if (_validityPeriodController.text.isNotEmpty) {
      validityPeriod = int.tryParse(_validityPeriodController.text);
    }

    final item = EmployeeQualificationModel(
      id: widget.item?.id,
      qualificationCode: _codeController.text,
      qualificationName: _nameController.text,
      category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
      validityPeriodMonths: validityPeriod,
      requiresRenewal: _requiresRenewal,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      isActive: _isActive,
    );

    final notifier = ref.read(employeeQualificationProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kualifikasi berhasil diupdate' : 'Kualifikasi berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode kualifikasi wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode minimal 2 karakter';
    }
    if (value.trim().length > 30) {
      return 'Kode maksimal 30 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama kualifikasi wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    return null;
  }

  String? _validateValidityPeriod(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final months = int.tryParse(value);
    if (months == null || months < 1) {
      return 'Masa berlaku minimal 1 bulan';
    }
    if (months > 120) {
      return 'Masa berlaku maksimal 120 bulan (10 tahun)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeQualificationProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kualifikasi' : 'Tambah Kualifikasi'),
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
            // Kode Kualifikasi
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Kualifikasi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                hintText: 'Contoh: STR, SIP, KLS, ACLS',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Nama Kualifikasi
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kualifikasi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified),
                hintText: 'Contoh: Surat Tanda Registrasi, Sertifikasi ACLS',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Kategori Picker
            InkWell(
              onTap: isSubmitting ? null : _showCategoryPicker,
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
                            'Kategori',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _categoryController.text.isEmpty
                                ? 'Pilih kategori (opsional)'
                                : _getCategoryLabel(_categoryController.text),
                            style: TextStyle(
                              fontSize: 16,
                              color: _categoryController.text.isEmpty
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

            // Masa Berlaku (Bulan)
            TextFormField(
              controller: _validityPeriodController,
              decoration: const InputDecoration(
                labelText: 'Masa Berlaku (Bulan)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'Contoh: 12 (opsional)',
              ),
              keyboardType: TextInputType.number,
              validator: _validateValidityPeriod,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Requires Renewal
            SwitchListTile(
              title: const Text('Perlu Perpanjangan'),
              subtitle: const Text('Aktifkan jika kualifikasi ini perlu diperpanjang secara berkala'),
              value: _requiresRenewal,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _requiresRenewal = value;
                });
              },
              activeColor: Colors.blue,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Is Active
            SwitchListTile(
              title: const Text('Status Aktif'),
              subtitle: const Text('Nonaktifkan jika kualifikasi ini tidak digunakan lagi'),
              value: _isActive,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Deskripsi singkat tentang kualifikasi ini (opsional)',
              ),
              maxLines: 3,
              enabled: !isSubmitting,
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
                          child: const Icon(Icons.verified, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Kualifikasi' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Kode: ${_codeController.text.isEmpty ? 'Kode' : _codeController.text}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_categoryController.text.isNotEmpty)
                              Text(
                                'Kategori: ${_getCategoryLabel(_categoryController.text)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            Row(
                              children: [
                                Container(
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
                                if (_requiresRenewal) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Perlu Perpanjangan',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
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

  String _getCategoryLabel(String value) {
    final option = _categoryOptions.firstWhere(
      (opt) => opt['value'] == value,
      orElse: () => {'label': value},
    );
    return option['label']!;
  }
}