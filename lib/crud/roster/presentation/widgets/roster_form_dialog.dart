// lib/features/roster/presentation/widgets/roster_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';
import '../../domain/enums/attendance_status.dart' as attendance;
import '../../domain/enums/approval_status.dart' as approval;

// Alias untuk enum
typedef AttendanceStatus = attendance.AttendanceStatus;
typedef ApprovalStatus = approval.ApprovalStatus;

class RosterFormDialog extends StatefulWidget {
  final RosterEntity? roster;
  final List<ShiftEntity> shifts;
  final List<Map<String, dynamic>> employees;
  final Function(RosterEntity) onSave;

  const RosterFormDialog({
    super.key,
    this.roster,
    required this.shifts,
    required this.employees,
    required this.onSave,
  });

  @override
  State<RosterFormDialog> createState() => _RosterFormDialogState();
}

class _RosterFormDialogState extends State<RosterFormDialog> {
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();
  
  late String _selectedProfileId;
  late String _selectedShiftId;
  late DateTime _selectedDate;
  late bool _isDayOff;
  late bool _isOvertimePlanned;
  late bool _isEmergencyShift;
  late bool _isOnCall;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.roster?.notes);
    _selectedProfileId = widget.roster?.profileId ?? '';
    _selectedShiftId = widget.roster?.shiftId ?? (widget.shifts.isNotEmpty ? widget.shifts.first.id : '');
    _selectedDate = widget.roster?.rosterDate ?? DateTime.now();
    _isDayOff = widget.roster?.isDayOff ?? false;
    _isOvertimePlanned = widget.roster?.isOvertimePlanned ?? false;
    _isEmergencyShift = widget.roster?.isEmergencyShift ?? false;
    _isOnCall = widget.roster?.isOnCall ?? false;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.roster == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Employee dropdown
                DropdownButtonFormField<String>(
                  value: _selectedProfileId.isEmpty ? null : _selectedProfileId,
                  decoration: const InputDecoration(labelText: 'Pegawai *'),
                  items: widget.employees.map((e) {
                    return DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text('${e['full_name']} (${e['employee_id']})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedProfileId = value!),
                  validator: (v) => v == null ? 'Pilih pegawai' : null,
                ),
                const SizedBox(height: 12),
                // Shift dropdown
                DropdownButtonFormField<String>(
                  value: _selectedShiftId.isEmpty ? null : _selectedShiftId,
                  decoration: const InputDecoration(labelText: 'Shift *'),
                  items: widget.shifts.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.shiftName} (${s.displayTime})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedShiftId = value!),
                  validator: (v) => v == null ? 'Pilih shift' : null,
                ),
                const SizedBox(height: 12),
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal *'),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Checkboxes
                CheckboxListTile(
                  value: _isDayOff,
                  onChanged: (value) {
                    setState(() => _isDayOff = value!);
                    if (value == true) {
                      _isOvertimePlanned = false;
                      _isEmergencyShift = false;
                      _isOnCall = false;
                    }
                  },
                  title: const Text('Libur / Day Off'),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                if (!_isDayOff) ...[
                  CheckboxListTile(
                    value: _isOvertimePlanned,
                    onChanged: (value) => setState(() => _isOvertimePlanned = value!),
                    title: const Text('Overtime (Terencana)'),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  CheckboxListTile(
                    value: _isEmergencyShift,
                    onChanged: (value) => setState(() => _isEmergencyShift = value!),
                    title: const Text('Shift Darurat'),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  CheckboxListTile(
                    value: _isOnCall,
                    onChanged: (value) => setState(() => _isOnCall = value!),
                    title: const Text('On Call'),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                ],
                const SizedBox(height: 12),
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF01579B),
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final roster = RosterEntity(
        id: widget.roster?.id ?? '',
        profileId: _selectedProfileId,
        shiftId: _selectedShiftId,
        rosterDate: _selectedDate,
        isDayOff: _isDayOff,
        isOvertimePlanned: _isOvertimePlanned,
        isEmergencyShift: _isEmergencyShift,
        isOnCall: _isOnCall,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        approvalStatus: widget.roster?.approvalStatus ?? ApprovalStatus.pending,
        attendanceStatus: widget.roster?.attendanceStatus ?? AttendanceStatus.scheduled,
      );
      widget.onSave(roster);
      Navigator.pop(context);
    }
  }
}