// lib/features/people/widgets/people_form_widget.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/people_providers.dart';
import '../models/people_model.dart';
import '../services/people_service.dart';
import 'qr_code_dialog.dart';

class PeopleFormWidget extends ConsumerStatefulWidget {
  final Function(PeopleModel) onSuccess;

  const PeopleFormWidget({
    super.key,
    required this.onSuccess,
  });

  @override
  ConsumerState<PeopleFormWidget> createState() => _PeopleFormWidgetState();
}

class _PeopleFormWidgetState extends ConsumerState<PeopleFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _rfidController = TextEditingController();
  final _nameController = TextEditingController();
  
  String? _selectedCategoryId;
  String? _fotoUrl;
  File? _fotoFile;
  bool _isMale = true;
  bool _isChild = false;
  String? _levelContaminated;
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _rfidController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _fotoFile = File(pickedFile.path);
      });

      await _uploadImage(pickedFile.path);
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = 'people_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'people_photos/$fileName';

      await Supabase.instance.client.storage
          .from('people_photos')
          .upload(filePath, file);

      final publicUrl = Supabase.instance.client.storage
          .from('people_photos')
          .getPublicUrl(filePath);

      setState(() {
        _fotoUrl = publicUrl;
      });

      debugPrint('✅ Image uploaded: $publicUrl');
    } catch (e) {
      debugPrint('❌ Upload image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload foto')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(peopleServiceProvider);
      final newPerson = await service.insertPerson(
        rfidTagId: _rfidController.text.trim(),
        fullName: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        fotoUrl: _fotoUrl,
        isMale: _isMale,
        isChild: _isChild,
        levelContaminated: _levelContaminated,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => QrCodeDialog(
            rfidTagId: newPerson.rfidTagId,
            fullName: newPerson.fullName,
            categoryName: newPerson.categoryName ?? '',
            onClose: () {
              widget.onSuccess(newPerson);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(peopleCategoriesProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    image: _fotoFile != null
                        ? DecorationImage(
                            image: FileImage(_fotoFile!),
                            fit: BoxFit.cover,
                          )
                        : (_fotoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_fotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: _fotoFile == null && _fotoUrl == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey.shade600,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap untuk foto',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // RFID Tag ID
            _buildGlassTextField(
              controller: _rfidController,
              label: 'RFID Tag ID',
              hint: 'Scan atau input manual',
              icon: Icons.qr_code_scanner,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'RFID Tag ID wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nama Lengkap
            _buildGlassTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hint: 'Nama lengkap sesuai KTP',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kategori
            categoriesAsync.when(
              data: (categories) {
                return _buildGlassDropdown(
                  label: 'Kategori',
                  value: _selectedCategoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  cat.markerColor?.replaceFirst('#', '0xFF') ??
                                      '0xFF9B59B6',
                                ),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat.categoryName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),

            // Jenis Kelamin
            _buildGenderSelector(),
            const SizedBox(height: 16),

            // Apakah Anak?
            _buildChildCheckbox(),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01579B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'SIMPAN & CETAK QR CODE',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF01579B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,  // ← Tambahkan ini
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF01579B)),
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Jenis Kelamin',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: _isMale,
                        onChanged: (value) {
                          setState(() {
                            _isMale = value as bool;
                          });
                        },
                        activeColor: const Color(0xFF01579B),
                      ),
                      Flexible(
                        child: Text(
                          'Laki-laki',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                        value: false,
                        groupValue: _isMale,
                        onChanged: (value) {
                          setState(() {
                            _isMale = value as bool;
                          });
                        },
                        activeColor: const Color(0xFF01579B),
                      ),
                      Flexible(
                        child: Text(
                          'Perempuan',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: _isChild,
            onChanged: (value) {
              setState(() {
                _isChild = value ?? false;
              });
            },
            activeColor: const Color(0xFF01579B),
          ),
          Expanded(
            child: Text(
              'Anak-anak (usia < 12 tahun)',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}