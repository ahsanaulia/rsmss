import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/employee_qualifications/models/employee_qualification_model.dart';
import 'package:rsmss/crud/employee_qualifications/providers/employee_qualification_provider.dart';
import 'package:rsmss/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return _buildCategoryPickerSheet(bottomSheetContext, localizations);
      },
    );

    if (result != null && mounted) {
      setState(() {
        _categoryController.text = result['value']!;
      });
    }
  }

  Widget _buildCategoryPickerSheet(BuildContext sheetContext, AppLocalizations? localizations) {
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                localizations?.crud_eq_form_category_picker_title ?? 'Pilih Kategori',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final localizations = AppLocalizations.of(context);
    
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
          content: Text(
            isEditing 
                ? (localizations?.crud_eq_success_update ?? 'Kualifikasi berhasil diupdate')
                : (localizations?.crud_eq_success_create ?? 'Kualifikasi berhasil ditambahkan')
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    final localizations = AppLocalizations.of(context);
    
    if (value == null || value.trim().isEmpty) {
      return localizations?.crud_eq_validation_code_required ?? 'Kode kualifikasi wajib diisi';
    }
    if (value.trim().length < 2) {
      return localizations?.crud_eq_validation_code_min ?? 'Kode minimal 2 karakter';
    }
    if (value.trim().length > 30) {
      return localizations?.crud_eq_validation_code_max ?? 'Kode maksimal 30 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    final localizations = AppLocalizations.of(context);
    
    if (value == null || value.trim().isEmpty) {
      return localizations?.crud_eq_validation_name_required ?? 'Nama kualifikasi wajib diisi';
    }
    if (value.trim().length < 2) {
      return localizations?.crud_eq_validation_name_min ?? 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return localizations?.crud_eq_validation_name_max ?? 'Nama maksimal 100 karakter';
    }
    return null;
  }

  String? _validateValidityPeriod(String? value) {
    final localizations = AppLocalizations.of(context);
    
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final months = int.tryParse(value);
    if (months == null || months < 1) {
      return localizations?.crud_eq_validation_validity_min ?? 'Masa berlaku minimal 1 bulan';
    }
    if (months > 120) {
      return localizations?.crud_eq_validation_validity_max ?? 'Masa berlaku maksimal 120 bulan (10 tahun)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(employeeQualificationProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing 
              ? (localizations?.crud_eq_menu_edit ?? 'Edit Kualifikasi')
              : (localizations?.crud_eq_add_button ?? 'Tambah Kualifikasi')
        ),
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
              decoration: InputDecoration(
                labelText: localizations?.crud_eq_code_label ?? 'Kode Kualifikasi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.code),
                hintText: localizations?.crud_eq_form_code_hint ?? 'Contoh: STR, SIP, KLS, ACLS',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Nama Kualifikasi
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: localizations?.crud_eq_detail_name ?? 'Nama Kualifikasi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.verified),
                hintText: localizations?.crud_eq_form_name_hint ?? 'Contoh: Surat Tanda Registrasi, Sertifikasi ACLS',
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
                            localizations?.crud_eq_category_label ?? 'Kategori',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _categoryController.text.isEmpty
                                ? (localizations?.crud_eq_form_category_hint ?? 'Pilih kategori (opsional)')
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
              decoration: InputDecoration(
                labelText: '${localizations?.crud_eq_validity_label ?? 'Masa Berlaku'} (${localizations?.crud_eq_months_suffix ?? 'bulan'})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: localizations?.crud_eq_form_validity_hint ?? 'Contoh: 12 (opsional)',
              ),
              keyboardType: TextInputType.number,
              validator: _validateValidityPeriod,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Requires Renewal
            SwitchListTile(
              title: Text(localizations?.crud_eq_requires_renewal ?? 'Perlu Perpanjangan'),
              subtitle: Text(localizations?.crud_eq_form_renewal_subtitle ?? 'Aktifkan jika kualifikasi ini perlu diperpanjang secara berkala'),
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
              title: Text(localizations?.crud_eq_status_active ?? 'Status Aktif'),
              subtitle: Text(localizations?.crud_eq_form_active_subtitle ?? 'Nonaktifkan jika kualifikasi ini tidak digunakan lagi'),
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
              decoration: InputDecoration(
                labelText: localizations?.crud_eq_detail_description ?? 'Deskripsi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                hintText: localizations?.crud_eq_form_description_hint ?? 'Deskripsi singkat tentang kualifikasi ini (opsional)',
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
                    Text(
                      localizations?.crud_eq_form_preview_title ?? 'Preview',
                      style: const TextStyle(
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
                              _nameController.text.isEmpty ? (localizations?.crud_eq_detail_name ?? 'Nama Kualifikasi') : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${localizations?.crud_eq_code_label ?? 'Kode'}: ${_codeController.text.isEmpty ? (localizations?.crud_eq_detail_code ?? 'Kode') : _codeController.text}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_categoryController.text.isNotEmpty)
                              Text(
                                '${localizations?.crud_eq_category_label ?? 'Kategori'}: ${_getCategoryLabel(_categoryController.text)}',
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
                                    _isActive 
                                        ? (localizations?.crud_eq_status_active ?? 'Aktif')
                                        : (localizations?.crud_eq_status_inactive ?? 'Nonaktif'),
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
                                      localizations?.crud_eq_requires_renewal ?? 'Perlu Perpanjangan',
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
                    child: Text(localizations?.crud_eq_delete_cancel ?? 'Batal'),
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
                    child: Text(
                      isEditing 
                          ? (localizations?.crud_eq_form_update_button ?? 'Update')
                          : (localizations?.crud_eq_form_save_button ?? 'Simpan')
                    ),
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