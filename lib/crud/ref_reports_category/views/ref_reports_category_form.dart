import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_reports_category/models/ref_reports_category_model.dart';
import 'package:rsmss/crud/ref_reports_category/providers/ref_reports_category_provider.dart';

class RefReportsCategoryFormPage extends ConsumerStatefulWidget {
  final RefReportsCategoryModel? item;

  const RefReportsCategoryFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<RefReportsCategoryFormPage> createState() => _RefReportsCategoryFormPageState();
}

class _RefReportsCategoryFormPageState extends ConsumerState<RefReportsCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconNameController;

  final List<Map<String, dynamic>> _iconOptions = [
    {'value': 'report', 'label': 'Laporan', 'icon': Icons.report},
    {'value': 'assessment', 'label': 'Penilaian', 'icon': Icons.assessment},
    {'value': 'bar_chart', 'label': 'Grafik Batang', 'icon': Icons.bar_chart},
    {'value': 'pie_chart', 'label': 'Grafik Lingkaran', 'icon': Icons.pie_chart},
    {'value': 'description', 'label': 'Deskripsi', 'icon': Icons.description},
    {'value': 'receipt', 'label': 'Kwitansi', 'icon': Icons.receipt},
    {'value': 'fact_check', 'label': 'Fakta', 'icon': Icons.fact_check},
    {'value': 'analytics', 'label': 'Analitik', 'icon': Icons.analytics},
    {'value': 'summarize', 'label': 'Ringkasan', 'icon': Icons.summarize},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _iconNameController = TextEditingController(text: item?.iconName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  Future<void> _showIconPicker() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return _buildIconPickerSheet(bottomSheetContext);
      },
    );

    if (result != null && mounted) {
      setState(() {
        _iconNameController.text = result['value'];
      });
    }
  }

  Widget _buildIconPickerSheet(BuildContext sheetContext) {
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
                'Pilih Icon',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _iconOptions.length,
                itemBuilder: (context, index) {
                  final option = _iconOptions[index];
                  return ListTile(
                    leading: Icon(option['icon'], color: Colors.green),
                    title: Text(option['label']),
                    trailing: _iconNameController.text == option['value']
                        ? const Icon(Icons.check, color: Colors.green)
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

    final item = RefReportsCategoryModel(
      id: widget.item?.id,
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      iconName: _iconNameController.text.isNotEmpty ? _iconNameController.text : null,
    );

    final notifier = ref.read(refReportsCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kategori laporan berhasil diupdate' : 'Kategori laporan berhasil ditambahkan'),
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
    if (value.trim().length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    return null;
  }

  IconData _getIconFromString(String? iconName) {
    final option = _iconOptions.firstWhere(
      (opt) => opt['value'] == iconName,
      orElse: () => {'icon': Icons.insert_drive_file},
    );
    return option['icon'];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refReportsCategoryProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;
    final selectedIcon = _getIconFromString(_iconNameController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori Laporan' : 'Tambah Kategori Laporan'),
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
                hintText: 'Contoh: Laporan Keuangan, Laporan Operasional, Laporan Kinerja',
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

            // Icon Picker
            InkWell(
              onTap: isSubmitting ? null : _showIconPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(selectedIcon, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Icon',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _iconNameController.text.isEmpty
                                ? 'Pilih icon (opsional)'
                                : _iconNameController.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: _iconNameController.text.isEmpty
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(selectedIcon, color: Colors.green, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.isEmpty ? 'Nama Kategori' : _nameController.text,
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (_descriptionController.text.isNotEmpty)
                                Text(
                                  _descriptionController.text,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (_iconNameController.text.isNotEmpty)
                                Text(
                                  'Icon: ${_iconNameController.text}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
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
                      backgroundColor: Colors.green,
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