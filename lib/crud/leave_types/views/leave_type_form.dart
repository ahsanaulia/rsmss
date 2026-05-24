import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/leave_types/models/leave_type_model.dart';
import 'package:rsmss/crud/leave_types/providers/leave_type_provider.dart';

class LeaveTypeFormPage extends ConsumerStatefulWidget {
  final LeaveTypeModel? item;

  const LeaveTypeFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<LeaveTypeFormPage> createState() => _LeaveTypeFormPageState();
}

class _LeaveTypeFormPageState extends ConsumerState<LeaveTypeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _maxDaysController;
  late TextEditingController _colorController;

  bool _paidLeave = true;
  bool _requiresDocument = false;
  bool _requiresMedicalCertificate = false;
  bool _isActive = true;

  final List<Color> _colorOptions = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
    Colors.pink,
  ];

  final Map<Color, String> _colorHexMap = {
    Colors.orange: '#FF9800',
    Colors.blue: '#2196F3',
    Colors.green: '#4CAF50',
    Colors.red: '#F44336',
    Colors.purple: '#9C27B0',
    Colors.teal: '#009688',
    Colors.cyan: '#00BCD4',
    Colors.pink: '#E91E63',
  };

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codeController = TextEditingController(text: item?.leaveCode ?? '');
    _nameController = TextEditingController(text: item?.leaveName ?? '');
    _maxDaysController = TextEditingController(
      text: item?.maxDaysPerYear?.toString() ?? '',
    );
    _colorController = TextEditingController(text: item?.color ?? '#FF9800');
    _paidLeave = item?.paidLeave ?? true;
    _requiresDocument = item?.requiresDocument ?? false;
    _requiresMedicalCertificate = item?.requiresMedicalCertificate ?? false;
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _maxDaysController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _showColorPicker() async {
    final result = await showModalBottomSheet<Color>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Pilih Warna',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _colorOptions.map((color) {
                  final isSelected = _colorHexMap[color] == _colorController.text;
                  return GestureDetector(
                    onTap: () => Navigator.pop(bottomSheetContext, color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.check, color: Colors.white),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _colorController.text = _colorHexMap[result] ?? '#FF9800';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.item != null;

    final item = LeaveTypeModel(
      id: widget.item?.id,
      leaveCode: _codeController.text,
      leaveName: _nameController.text,
      maxDaysPerYear: _maxDaysController.text.isNotEmpty
          ? int.tryParse(_maxDaysController.text)
          : null,
      paidLeave: _paidLeave,
      requiresDocument: _requiresDocument,
      requiresMedicalCertificate: _requiresMedicalCertificate,
      color: _colorController.text,
      isActive: _isActive,
    );

    final notifier = ref.read(leaveTypeProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Jenis cuti berhasil diupdate' : 'Jenis cuti berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kode cuti wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Kode minimal 2 karakter';
    }
    if (value.trim().length > 20) {
      return 'Kode maksimal 20 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama cuti wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    return null;
  }

  String? _validateMaxDays(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final days = int.tryParse(value);
    if (days == null || days < 1) {
      return 'Maksimal hari minimal 1';
    }
    if (days > 365) {
      return 'Maksimal hari tidak boleh lebih dari 365';
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
    final state = ref.watch(leaveTypeProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;
    final selectedColor = _getColorFromHex(_colorController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Jenis Cuti' : 'Tambah Jenis Cuti'),
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
            // Kode Cuti
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Cuti *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                hintText: 'Contoh: AL, CT, SL, ML',
              ),
              validator: _validateCode,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Nama Cuti
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Cuti *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.beach_access),
                hintText: 'Contoh: Cuti Tahunan, Cuti Sakit, Cuti Melahirkan',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Maksimal Hari per Tahun
            TextFormField(
              controller: _maxDaysController,
              decoration: const InputDecoration(
                labelText: 'Maksimal Hari per Tahun',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixText: 'hari',
                hintText: 'Contoh: 12 (opsional)',
              ),
              keyboardType: TextInputType.number,
              validator: _validateMaxDays,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Color Picker
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
                            'Warna',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _colorController.text,
                            style: const TextStyle(fontSize: 14),
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

            // Paid Leave
            SwitchListTile(
              title: const Text('Cuti Berbayar'),
              subtitle: const Text('Aktifkan jika cuti ini tetap dibayar'),
              value: _paidLeave,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _paidLeave = value;
                });
              },
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Requires Document
            SwitchListTile(
              title: const Text('Perlu Dokumen Pendukung'),
              subtitle: const Text('Aktifkan jika pengajuan perlu melampirkan dokumen'),
              value: _requiresDocument,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _requiresDocument = value;
                });
              },
              activeColor: Colors.blue,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Requires Medical Certificate
            SwitchListTile(
              title: const Text('Perlu Surat Keterangan Dokter'),
              subtitle: const Text('Aktifkan jika cuti sakit perlu surat dokter'),
              value: _requiresMedicalCertificate,
              onChanged: isSubmitting ? null : (value) {
                setState(() {
                  _requiresMedicalCertificate = value;
                });
              },
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Is Active
            SwitchListTile(
              title: const Text('Status Aktif'),
              subtitle: const Text('Nonaktifkan jika jenis cuti ini tidak digunakan lagi'),
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
                            color: selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.beach_access, color: selectedColor, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'Nama Cuti' : _nameController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Kode: ${_codeController.text.isEmpty ? 'Kode' : _codeController.text}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (_maxDaysController.text.isNotEmpty)
                              Text(
                                'Maksimal: ${_maxDaysController.text} hari/tahun',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (_paidLeave)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Cuti Berbayar',
                                      style: TextStyle(fontSize: 10, color: Colors.green.shade800),
                                    ),
                                  ),
                                if (_requiresDocument)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Perlu Dokumen',
                                      style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
                                    ),
                                  ),
                                if (_requiresMedicalCertificate)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Perlu Surat Dokter',
                                      style: TextStyle(fontSize: 10, color: Colors.red.shade800),
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