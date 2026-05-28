import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoFormPage extends ConsumerStatefulWidget {
  final TodoModel? todo;
  final VoidCallback onSaved;

  const TodoFormPage({
    super.key,
    this.todo,
    required this.onSaved,
  });

  @override
  ConsumerState<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends ConsumerState<TodoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;

  String? _selectedUnitId;
  String? _selectedPositionId;
  String? _selectedShiftId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedPriority = 'normal';
  bool _isMandatory = true;
  bool _isActive = true;
  int _displayOrder = 0;

  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _positions = [];
  List<Map<String, dynamic>> _shifts = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _durationController = TextEditingController();

    if (widget.todo != null) {
      _loadEditData();
    }
    _loadDropdowns();
  }

  void _loadEditData() {
    final todo = widget.todo!;
    _titleController.text = todo.title;
    _descriptionController.text = todo.description ?? '';
    _durationController.text = todo.durationMinutes?.toString() ?? '';
    _selectedUnitId = todo.targetUnitId;
    _selectedPositionId = todo.targetPositionId;
    _selectedShiftId = todo.targetShiftId;
    _selectedDate = todo.todoDate;
    _startTime = todo.startTime;
    _endTime = todo.endTime;
    _selectedPriority = todo.priority;
    _isMandatory = todo.isMandatory;
    _isActive = todo.isActive;
    _displayOrder = todo.displayOrder;
  }

  Future<void> _loadDropdowns() async {
    final service = ref.read(todoServiceProvider);
    final units = await service.getUnits();
    final positions = await service.getPositions();
    final shifts = await service.getShifts();

    if (mounted) {
      setState(() {
        _units = units;
        _positions = positions;
        _shifts = shifts;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
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

    final formattedDate = _selectedDate.toIso8601String().split('T').first;

    final startTimeStr = _startTime != null
        ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00'
        : null;
    final endTimeStr = _endTime != null
        ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00'
        : null;

    final todoData = {
      'id': widget.todo?.id ?? '',
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'duration_minutes': _durationController.text.trim().isEmpty ? null : int.tryParse(_durationController.text.trim()),
      'target_unit_id': _selectedUnitId?.isEmpty == true ? null : _selectedUnitId,
      'target_position_id': _selectedPositionId?.isEmpty == true ? null : _selectedPositionId,
      'target_shift_id': _selectedShiftId?.isEmpty == true ? null : _selectedShiftId,
      'todo_date': formattedDate,
      'start_time': startTimeStr,
      'end_time': endTimeStr,
      'source_type': 'admin_input',
      'source_id': null,
      'source_table': null,
      'source_data': null,
      'is_active': _isActive,
      'expired_at': null,
      'display_order': _displayOrder,
      'is_mandatory': _isMandatory,
      'priority': _selectedPriority,
      'created_by': currentUser.id,
      'created_at': widget.todo?.createdAt.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (todoData['id'] == null || todoData['id'] == '') {
      todoData.remove('id');
    }

    try {
      if (widget.todo == null) {
        await Supabase.instance.client.from('todos').insert(todoData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('To Do berhasil ditambahkan', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await Supabase.instance.client
            .from('todos')
            .update(todoData)
            .eq('id', widget.todo!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('To Do berhasil diupdate', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
      }
    } catch (e) {
      print('ERROR saving todo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                          _buildTitleField(),
                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                          const SizedBox(height: 16),
                          _buildDurationField(),
                          const SizedBox(height: 16),
                          _buildTargetSection(),
                          const SizedBox(height: 16),
                          _buildScheduleSection(),
                          const SizedBox(height: 16),
                          _buildPrioritySection(),
                          const SizedBox(height: 16),
                          _buildOptionsSection(),
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
              widget.todo == null ? 'Tambah To Do' : 'Edit To Do',
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

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Judul To Do *',
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
        hintText: 'Contoh: Periksa kelengkapan oksigen',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Judul harus diisi';
        }
        return null;
      },
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
        hintText: 'Penjelasan detail tentang To Do ini',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      style: GoogleFonts.poppins(fontSize: 14),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Durasi (menit)',
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
        ),
        hintText: 'Estimasi waktu pengerjaan',
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildTargetSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Penerima',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            _buildSearchableDropdown(
              label: 'Unit',
              items: _units,
              selectedId: _selectedUnitId,
              onSelected: (id) => setState(() => _selectedUnitId = id),
              hint: 'Semua Unit',
            ),
            const SizedBox(height: 12),
            _buildSearchableDropdown(
              label: 'Posisi/Jabatan',
              items: _positions,
              selectedId: _selectedPositionId,
              onSelected: (id) => setState(() => _selectedPositionId = id),
              hint: 'Semua Posisi',
            ),
            const SizedBox(height: 12),
            _buildSearchableDropdown(
              label: 'Shift',
              items: _shifts,
              selectedId: _selectedShiftId,
              onSelected: (id) => setState(() => _selectedShiftId = id),
              hint: 'Semua Shift',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: const Color(0xFF01579B)),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Jam Mulai',
                    time: _startTime,
                    onSelected: (time) => setState(() => _startTime = time),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Jam Selesai',
                    time: _endTime,
                    onSelected: (time) => setState(() => _endTime = time),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required Function(TimeOfDay) onSelected,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
        );
        if (picked != null) {
          onSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20, color: const Color(0xFF01579B)),
            const SizedBox(width: 12),
            Text(
              time != null ? time.format(context) : '-',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prioritas',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _buildPriorityChip('low', 'Rendah', Colors.blue),
                _buildPriorityChip('normal', 'Normal', Colors.green),
                _buildPriorityChip('high', 'Tinggi', Colors.orange),
                _buildPriorityChip('urgent', 'Urgent', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = _selectedPriority == value;
    return FilterChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedPriority = value);
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: isSelected ? color : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opsi Lainnya',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text('Wajib Dikerjakan', style: GoogleFonts.poppins(fontSize: 14)),
              value: _isMandatory,
              onChanged: (value) => setState(() => _isMandatory = value),
              activeColor: const Color(0xFF01579B),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text('Aktif', style: GoogleFonts.poppins(fontSize: 14)),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: const Color(0xFF01579B),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _displayOrder.toString(),
              style: GoogleFonts.poppins(fontSize: 14),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Urutan Tampilan',
                labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
                ),
                hintText: 'Angka lebih kecil tampil lebih dulu',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
              ),
              onChanged: (value) {
                setState(() => _displayOrder = int.tryParse(value) ?? 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required String? selectedId,
    required Function(String?) onSelected,
    String hint = 'Pilih',
  }) {
    final selectedItem = items.firstWhere(
      (item) => item['id'] == selectedId,
      orElse: () => {'id': '', 'name': hint},
    );

    return InkWell(
      onTap: () async {
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => _SearchableDropdownSheet(
            title: label,
            items: [{'id': '', 'name': hint}, ...items],
            selectedId: selectedId ?? '',
          ),
        );
        if (result != null && mounted) {
          final id = result['id'] == '' ? null : result['id'];
          onSelected(id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedItem['name'] ?? hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: selectedId != null ? Colors.black : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
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

// SearchableDropdownSheet
class _SearchableDropdownSheet extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String selectedId;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.selectedId,
  });

  @override
  State<_SearchableDropdownSheet> createState() => _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState extends State<_SearchableDropdownSheet> {
  late List<Map<String, dynamic>> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item['id'] == widget.selectedId;
                return ListTile(
                  title: Text(
                    item['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Colors.green.shade600)
                      : null,
                  tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}