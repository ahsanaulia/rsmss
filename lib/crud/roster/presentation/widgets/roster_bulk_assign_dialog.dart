// lib/features/roster/presentation/widgets/roster_bulk_assign_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';

class RosterBulkAssignDialog extends StatefulWidget {
  final List<ShiftEntity> shifts;
  final List<Map<String, dynamic>> employees;
  final Function(List<RosterEntity>) onAssign;

  const RosterBulkAssignDialog({
    super.key,
    required this.shifts,
    required this.employees,
    required this.onAssign,
  });

  @override
  State<RosterBulkAssignDialog> createState() => _RosterBulkAssignDialogState();
}

class _RosterBulkAssignDialogState extends State<RosterBulkAssignDialog> {
  final List<String> _selectedEmployeeIds = [];
  String _selectedShiftId = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _applyToWeekdays = true;
  bool _applyToWeekends = true;
  bool _isLoading = false;

  final List<int> _weekdays = [1, 2, 3, 4, 5]; // Sen - Jum
  final List<int> _weekends = [6, 7]; // Sab - Min

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Jadwal Massal'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee selection
              Text(
                'Pilih Pegawai',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: widget.employees.length,
                  itemBuilder: (context, index) {
                    final employee = widget.employees[index];
                    final id = employee['id'].toString();
                    final isSelected = _selectedEmployeeIds.contains(id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedEmployeeIds.add(id);
                          } else {
                            _selectedEmployeeIds.remove(id);
                          }
                        });
                      },
                      title: Text('${employee['full_name']} (${employee['employee_id']})'),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Select all button
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedEmployeeIds.clear();
                        _selectedEmployeeIds.addAll(
                          widget.employees.map((e) => e['id'].toString())
                        );
                      });
                    },
                    child: const Text('Pilih Semua'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedEmployeeIds.clear());
                    },
                    child: const Text('Hapus Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Shift selection
              DropdownButtonFormField<String>(
                value: _selectedShiftId.isEmpty ? null : _selectedShiftId,
                decoration: const InputDecoration(labelText: 'Pilih Shift *'),
                items: widget.shifts.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.shiftName} (${s.displayTime})'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedShiftId = value!),
                validator: (v) => v == null ? 'Pilih shift' : null,
              ),
              const SizedBox(height: 16),
              // Date range
              Text(
                'Rentang Tanggal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      'Dari',
                      _startDate,
                      (date) => setState(() => _startDate = date),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateButton(
                      'Sampai',
                      _endDate,
                      (date) => setState(() => _endDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Day filters
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: _applyToWeekdays,
                      onChanged: (value) => setState(() => _applyToWeekdays = value!),
                      title: const Text('Hari Kerja (Sen-Jum)'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: _applyToWeekends,
                      onChanged: (value) => setState(() => _applyToWeekends = value!),
                      title: const Text('Akhir Pekan (Sab-Min)'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Preview count
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Akan membuat ${_getTotalRostersCount()} jadwal',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF01579B),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }

  Widget _buildDateButton(String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy', 'id').format(date)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getTotalRostersCount() {
    if (_selectedEmployeeIds.isEmpty || _selectedShiftId.isEmpty) return 0;
    
    int count = 0;
    for (var date = _startDate; date.isBefore(_endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final isWeekday = _weekdays.contains(date.weekday);
      final isWeekend = _weekends.contains(date.weekday);
      
      if ((isWeekday && _applyToWeekdays) || (isWeekend && _applyToWeekends)) {
        count += _selectedEmployeeIds.length;
      }
    }
    return count;
  }

  void _save() async {
    if (_selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 pegawai')),
      );
      return;
    }
    
    if (_selectedShiftId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih shift')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final List<RosterEntity> rosters = [];
    
    for (final profileId in _selectedEmployeeIds) {
      for (var date = _startDate; date.isBefore(_endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        final isWeekday = _weekdays.contains(date.weekday);
        final isWeekend = _weekends.contains(date.weekday);
        
        if ((isWeekday && _applyToWeekdays) || (isWeekend && _applyToWeekends)) {
          rosters.add(RosterEntity(
            id: '',
            profileId: profileId,
            shiftId: _selectedShiftId,
            rosterDate: date,
            isDayOff: false,
            isOvertimePlanned: false,
            isEmergencyShift: false,
            isOnCall: false,
            approvalStatus: ApprovalStatus.pending,
            attendanceStatus: AttendanceStatus.scheduled,
          ));
        }
      }
    }

    await widget.onAssign(rosters);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${rosters.length} jadwal berhasil dibuat')),
      );
      Navigator.pop(context);
    }
  }
}