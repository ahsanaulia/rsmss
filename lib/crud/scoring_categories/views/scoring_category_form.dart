import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/scoring_categories/models/scoring_category_model.dart';
import 'package:rsmss/crud/scoring_categories/providers/scoring_category_provider.dart';

class ScoringCategoryFormPage extends ConsumerStatefulWidget {
  final ScoringCategoryModel? item;

  const ScoringCategoryFormPage({
    super.key,
    this.item,
  });

  @override
  ConsumerState<ScoringCategoryFormPage> createState() => _ScoringCategoryFormPageState();
}

class _ScoringCategoryFormPageState extends ConsumerState<ScoringCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _weightController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codeController = TextEditingController(text: item?.categoryCode ?? '');
    _nameController = TextEditingController(text: item?.categoryName ?? '');
    _weightController = TextEditingController(
      text: item?.weight?.toStringAsFixed(2) ?? '1.00',
    );
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.item != null;

    final item = ScoringCategoryModel(
      id: widget.item?.id,
      categoryCode: _codeController.text,
      categoryName: _nameController.text,
      weight: double.tryParse(_weightController.text),
      isActive: _isActive,
    );

    final notifier = ref.read(scoringCategoryProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.update(item);
    } else {
      success = await notifier.create(item);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Kategori scoring berhasil diupdate' : 'Kategori scoring berhasil ditambahkan'),
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
    if (value.trim().length > 30) {
      return 'Kode maksimal 30 karakter';
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

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional, default 1.00
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Bobot harus berupa angka';
    }
    if (weight < 0) {
      return 'Bobot tidak boleh negatif';
    }
    if (weight > 100) {
      return 'Bobot maksimal 100';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scoringCategoryProvider);
    final isEditing = widget.item != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori Scoring' : 'Tambah Kategori Scoring'),
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
                hintText: 'Contoh: ATT, KNOW, SKILL, BEHAVIOR',
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
                hintText: 'Contoh: Attitude, Knowledge, Skill, Behavior',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Bobot (Weight)
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Bobot',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tune),
                suffixText: 'poin',
                hintText: 'Contoh: 1.00, 1.5, 2.0 (default: 1.00)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validateWeight,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Bobot akan mempengaruhi perhitungan skor akhir. Semakin besar bobot, semakin besar pengaruhnya.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
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
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.scoreboard, color: Colors.blue, size: 28),
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
                            Text(
                              'Bobot: ${_weightController.text.isEmpty ? '1.00' : _weightController.text}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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