import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rsmss/crud/ref_building_functions/models/ref_building_function_model.dart';
import 'package:rsmss/crud/ref_building_functions/providers/ref_building_function_provider.dart';

class RefBuildingFunctionFormPage extends ConsumerStatefulWidget {
  final RefBuildingFunctionModel? function;

  const RefBuildingFunctionFormPage({
    super.key,
    this.function,
  });

  @override
  ConsumerState<RefBuildingFunctionFormPage> createState() => _RefBuildingFunctionFormPageState();
}

class _RefBuildingFunctionFormPageState extends ConsumerState<RefBuildingFunctionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final function = widget.function;
    _nameController = TextEditingController(text: function?.functionName ?? '');
    _descriptionController = TextEditingController(text: function?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.function != null;
    final function = RefBuildingFunctionModel(
      id: widget.function?.id,
      appId: widget.function?.appId,
      functionName: _nameController.text,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text,
    );

    final notifier = ref.read(refBuildingFunctionProvider.notifier);
    bool success;

    if (isEditing) {
      success = await notifier.updateFunction(function);
    } else {
      success = await notifier.createFunction(function);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Fungsi gedung berhasil diupdate' : 'Fungsi gedung berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama fungsi gedung wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama fungsi gedung minimal 2 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama fungsi gedung maksimal 100 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refBuildingFunctionProvider);
    final isEditing = widget.function != null;
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Fungsi Gedung' : 'Tambah Fungsi Gedung'),
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
                labelText: 'Nama Fungsi Gedung *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
                hintText: 'Contoh: Rawat Inap, Rawat Jalan, Gawat Darurat, Administrasi',
              ),
              validator: _validateName,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Deskripsi fungsi gedung (opsional)',
              ),
              maxLines: 3,
              enabled: !isSubmitting,
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
                      backgroundColor: Colors.purple,
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