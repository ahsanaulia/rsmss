// lib/crud/ref_asset_danger_levels/views/ref_asset_danger_level_list.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class RefAssetDangerLevelListPage extends StatefulWidget {
  const RefAssetDangerLevelListPage({super.key});

  @override
  State<RefAssetDangerLevelListPage> createState() => _RefAssetDangerLevelListPageState();
}

class _RefAssetDangerLevelListPageState extends State<RefAssetDangerLevelListPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _levelCodeController = TextEditingController();
  final _levelNameController = TextEditingController();
  final _riskDescriptionController = TextEditingController();
  final _protectionRequiredController = TextEditingController();
  final _handlingInstructionController = TextEditingController();
  final _colorHexController = TextEditingController();
  final _sortOrderController = TextEditingController();
  bool _isActive = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _idController.dispose();
    _levelCodeController.dispose();
    _levelNameController.dispose();
    _riskDescriptionController.dispose();
    _protectionRequiredController.dispose();
    _handlingInstructionController.dispose();
    _colorHexController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('ref_asset_danger_levels')
          .select()
          .order('sort_order', ascending: true);
      setState(() {
        _data = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'level_code': _levelCodeController.text.trim().toUpperCase(),
      'level_name': _levelNameController.text.trim().toUpperCase(),
      'risk_description': _riskDescriptionController.text.trim().isEmpty ? null : _riskDescriptionController.text.trim(),
      'protection_required': _protectionRequiredController.text.trim().isEmpty ? null : _protectionRequiredController.text.trim(),
      'handling_instruction': _handlingInstructionController.text.trim().isEmpty ? null : _handlingInstructionController.text.trim(),
      'color_hex': _colorHexController.text.trim().isEmpty ? null : _colorHexController.text.trim(),
      'sort_order': int.tryParse(_sortOrderController.text.trim()) ?? 0,
      'is_active': _isActive,
    };

    try {
      if (_isEditing) {
        await _supabase
            .from('ref_asset_danger_levels')
            .update(data)
            .eq('id', _idController.text.trim());
        _showSnackbar('Data berhasil diupdate', Colors.green);
      } else {
        await _supabase.from('ref_asset_danger_levels').insert(data);
        _showSnackbar('Data berhasil ditambahkan', Colors.green);
      }
      _resetForm();
      await _loadData();
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  Future<void> _delete(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _supabase.from('ref_asset_danger_levels').delete().eq('id', id);
      _showSnackbar('Data berhasil dihapus', Colors.green);
      await _loadData();
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  void _edit(Map<String, dynamic> item) {
    _idController.text = item['id'];
    _levelCodeController.text = item['level_code'] ?? '';
    _levelNameController.text = item['level_name'] ?? '';
    _riskDescriptionController.text = item['risk_description'] ?? '';
    _protectionRequiredController.text = item['protection_required'] ?? '';
    _handlingInstructionController.text = item['handling_instruction'] ?? '';
    _colorHexController.text = item['color_hex'] ?? '#F59E0B';
    _sortOrderController.text = (item['sort_order'] ?? 0).toString();
    _isActive = item['is_active'] ?? true;
    _isEditing = true;
    setState(() {});
  }

  void _resetForm() {
    _idController.clear();
    _levelCodeController.clear();
    _levelNameController.clear();
    _riskDescriptionController.clear();
    _protectionRequiredController.clear();
    _handlingInstructionController.clear();
    _colorHexController.text = '#F59E0B';
    _sortOrderController.text = '0';
    _isActive = true;
    _isEditing = false;
    _formKey.currentState?.reset();
    setState(() {});
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse('0xFF${hexColor.replaceAll('#', '')}'));
    } catch (e) {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tingkat Bahaya Aset'),
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Row(
        children: [
          // LEFT PANEL - FORM (30%)
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isEditing ? 'EDIT DATA' : 'TAMBAH DATA',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF01579B)),
                          ),
                          if (_isEditing)
                            TextButton(
                              onPressed: _resetForm,
                              child: const Text('Batal Edit'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_levelCodeController, 'Kode Level', 'Contoh: LOW, MEDIUM, HIGH', Icons.code),
                      const SizedBox(height: 12),
                      _buildTextField(_levelNameController, 'Nama Level', 'Contoh: RENDAH, SEDANG, TINGGI', Icons.title),
                      const SizedBox(height: 12),
                      _buildTextField(_riskDescriptionController, 'Deskripsi Risiko', 'Penjelasan tentang tingkat bahaya', Icons.description, maxLines: 2),
                      const SizedBox(height: 12),
                      _buildTextField(_protectionRequiredController, 'Proteksi yang Diperlukan', 'APD yang harus digunakan', Icons.shield, maxLines: 2),
                      const SizedBox(height: 12),
                      _buildTextField(_handlingInstructionController, 'Instruksi Penanganan', 'Cara menangani aset berbahaya', Icons.info, maxLines: 2),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_colorHexController, 'Warna (Hex)', '#F59E0B', Icons.color_lens),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(_sortOrderController, 'Urutan', '0, 1, 2, 3', Icons.sort, keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Aktif'),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeColor: Colors.green,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01579B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_isEditing ? 'UPDATE' : 'SIMPAN', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // RIGHT PANEL - TABLE (70%)
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                      ? const Center(child: Text('Belum ada data', style: TextStyle(fontSize: 16)))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFF01579B)),
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text('Kode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nama Level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Deskripsi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Warna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Urutan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Aksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            ],
                            rows: _data.map((item) {
                              final color = _getColorFromHex(item['color_hex'] ?? '#F59E0B');
                              return DataRow(cells: [
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: Text(item['level_code'] ?? '-', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                )),
                                DataCell(Text(item['level_name'] ?? '-')),
                                DataCell(SizedBox(
                                  width: 200,
                                  child: Text(item['risk_description'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                                )),
                                DataCell(Text('${item['sort_order'] ?? 0}')),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (item['is_active'] ?? true) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (item['is_active'] ?? true) ? 'AKTIF' : 'NONAKTIF',
                                    style: TextStyle(color: (item['is_active'] ?? true) ? Colors.green : Colors.red, fontSize: 11),
                                  ),
                                )),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF01579B)),
                                      onPressed: () => _edit(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _delete(item['id'], item['level_name']),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF01579B), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? '$label tidak boleh kosong' : null,
    );
  }
}