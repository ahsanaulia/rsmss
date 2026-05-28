import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_unit_model.dart';
import '../providers/employee_unit_provider.dart';

class EmployeeUnitFormPage extends ConsumerStatefulWidget {
  final EmployeeUnitModel? item;
  final VoidCallback onSaved;

  const EmployeeUnitFormPage({
    super.key,
    this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<EmployeeUnitFormPage> createState() => _EmployeeUnitFormPageState();
}

class _EmployeeUnitFormPageState extends ConsumerState<EmployeeUnitFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitCodeController;
  late TextEditingController _unitNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitLevelController;

  String? _selectedParentUnitId;
  String? _selectedHeadOfUnitId;
  bool _shiftRequired = true;
  bool _isActive = true;

  List<Map<String, dynamic>> _parentUnits = [];
  List<Map<String, dynamic>> _headsOfUnit = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _unitCodeController = TextEditingController();
    _unitNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _unitLevelController = TextEditingController();

    if (widget.item != null) {
      _loadEditData();
    }
    _loadDropdowns();
  }

  void _loadEditData() {
    final item = widget.item!;
    _unitCodeController.text = item.unitCode;
    _unitNameController.text = item.unitName;
    _descriptionController.text = item.description ?? '';
    _unitLevelController.text = (item.unitLevel ?? 1).toString();
    _selectedParentUnitId = item.parentUnitId;
    _selectedHeadOfUnitId = item.headOfUnitId;
    _shiftRequired = item.shiftRequired ?? true;
    _isActive = item.isActive;
  }

  Future<void> _loadDropdowns() async {
    final service = ref.read(employeeUnitServiceProvider);
    final parents = await service.getParentUnits();
    final heads = await service.getHeadsOfUnit();

    if (mounted) {
      setState(() {
        _parentUnits = parents;
        _headsOfUnit = heads;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _unitCodeController.dispose();
    _unitNameController.dispose();
    _descriptionController.dispose();
    _unitLevelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User tidak terautentikasi', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final now = DateTime.now();
    final item = EmployeeUnitModel(
      id: widget.item?.id ?? '',
      unitCode: _unitCodeController.text.trim().toUpperCase(),
      unitName: _unitNameController.text.trim(),
      parentUnitId: _selectedParentUnitId?.isEmpty == true ? null : _selectedParentUnitId,
      unitLevel: int.tryParse(_unitLevelController.text.trim()) ?? 1,
      headOfUnitId: _selectedHeadOfUnitId?.isEmpty == true ? null : _selectedHeadOfUnitId,
      shiftRequired: _shiftRequired,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isActive: _isActive,
      createdAt: widget.item?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.item == null) {
        await ref.read(employeeUnitStateProvider.notifier).insert(item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unit berhasil ditambahkan', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(employeeUnitStateProvider.notifier).update(item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unit berhasil diupdate', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUnitCodeField(),
                          const SizedBox(height: 16),
                          _buildUnitNameField(),
                          const SizedBox(height: 16),
                          _buildParentUnitDropdown(),
                          const SizedBox(height: 16),
                          _buildUnitLevelField(),
                          const SizedBox(height: 16),
                          _buildHeadOfUnitDropdown(),
                          const SizedBox(height: 16),
                          _buildShiftRequiredSwitch(),
                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                          const SizedBox(height: 16),
                          _buildActiveSwitch(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF01579B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.item == null ? 'Tambah Unit' : 'Edit Unit',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCodeField() {
    return TextFormField(
      controller: _unitCodeController,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Kode Unit *',
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
        hintText: 'Contoh: IGD, ICU, LAB',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
        helperText: 'Kode akan diubah ke huruf besar otomatis',
        helperStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kode unit harus diisi';
        }
        if (value.trim().length > 20) {
          return 'Kode unit maksimal 20 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildUnitNameField() {
    return TextFormField(
      controller: _unitNameController,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Nama Unit *',
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
        hintText: 'Contoh: Instalasi Gawat Darurat',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama unit harus diisi';
        }
        return null;
      },
    );
  }

  Widget _buildParentUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Induk Unit',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedParentUnitId,
          isExpanded: true,
          hint: Text(
            'Pilih induk unit (opsional)',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
            ),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tidak ada induk')),
            ..._parentUnits.map((unit) => DropdownMenuItem(
              value: unit['id'],
              child: Text(
                unit['name'],
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            )),
          ],
          onChanged: (value) {
            setState(() => _selectedParentUnitId = value);
          },
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildUnitLevelField() {
    return TextFormField(
      controller: _unitLevelController,
      style: GoogleFonts.poppins(fontSize: 14),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Level Unit',
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
        hintText: '1 untuk level tertinggi',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final level = int.tryParse(value);
          if (level == null || level < 1) {
            return 'Level harus angka positif';
          }
        }
        return null;
      },
    );
  }

  Widget _buildHeadOfUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kepala Unit',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedHeadOfUnitId,
          isExpanded: true,
          hint: Text(
            'Pilih kepala unit (opsional)',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
            ),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tidak ada kepala unit')),
            ..._headsOfUnit.map((head) => DropdownMenuItem(
              value: head['id'],
              child: Text(
                head['name'],
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            )),
          ],
          onChanged: (value) {
            setState(() => _selectedHeadOfUnitId = value);
          },
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildShiftRequiredSwitch() {
    return SwitchListTile(
      title: Text('Membutuhkan Shift', style: GoogleFonts.poppins(fontSize: 14)),
      subtitle: Text(
        'Unit ini memiliki jadwal shift kerja',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: _shiftRequired,
      onChanged: (value) => setState(() => _shiftRequired = value),
      activeColor: const Color(0xFF01579B),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      style: GoogleFonts.poppins(fontSize: 14),
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Deskripsi',
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
        hintText: 'Deskripsi singkat tentang unit ini',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: Text('Aktif', style: GoogleFonts.poppins(fontSize: 14)),
      subtitle: Text(
        'Unit aktif dapat digunakan dalam sistem',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: _isActive,
      onChanged: (value) => setState(() => _isActive = value),
      activeColor: const Color(0xFF01579B),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Batal', style: GoogleFonts.poppins(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01579B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Simpan', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}