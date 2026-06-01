// lib/features/bed_assignments/widgets/bed_assignment_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/bed_assignment_service.dart';
import '../providers/bed_assignment_providers.dart';
import '../models/people_model.dart';
import '../models/bed_model.dart';
import 'people_search_delegate.dart';
import 'bed_search_delegate.dart';

class BedAssignmentForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const BedAssignmentForm({super.key, required this.onSuccess});

  @override
  ConsumerState<BedAssignmentForm> createState() => _BedAssignmentFormState();
}

class _BedAssignmentFormState extends ConsumerState<BedAssignmentForm> {
  SimplePeopleModel? _selectedPeople;
  SimpleBedModel? _selectedBed;
  DateTime? _predictedUntil;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _selectPeople() async {
    final service = ref.read(bedAssignmentServiceProvider);
    final result = await showSearch(
      context: context,
      delegate: PeopleSearchDelegate(service: service),
    );
    if (result != null) setState(() => _selectedPeople = result);
  }

  Future<void> _selectBed() async {
    final service = ref.read(bedAssignmentServiceProvider);
    final result = await showSearch(
      context: context,
      delegate: BedSearchDelegate(service: service),
    );
    if (result != null) setState(() => _selectedBed = result);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _predictedUntil = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_selectedPeople == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih people terlebih dahulu')),
      );
      return;
    }
    if (_selectedBed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bed terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(bedAssignmentServiceProvider);
      await service.assignBed(
        peopleId: _selectedPeople!.id,
        bedId: _selectedBed!.id,
        predictedUntil: _predictedUntil,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil assign bed'), backgroundColor: Colors.green),
        );
        widget.onSuccess();
        setState(() {
          _selectedPeople = null;
          _selectedBed = null;
          _predictedUntil = null;
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSelector(
          label: 'Pilih Pasien/Pengunjung',
          value: _selectedPeople?.fullName,
          onTap: _selectPeople,
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildSelector(
          label: 'Pilih Bed',
          value: _selectedBed?.fullLocation,
          onTap: _selectBed,
          icon: Icons.bed,
        ),
        const SizedBox(height: 16),
        _buildDateSelector(),
        const SizedBox(height: 16),
        _buildNotesField(),
        const SizedBox(height: 24),
        SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: _isSubmitting ? null : _submit,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF01579B), // background biru
      foregroundColor: Colors.white, // ← TAMBAHKAN INI (text putih)
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
              color: Colors.white, // spinner putih
            ),
          )
        : Text(
            'ASSIGN BED',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white, // ← PASTIKAN INI (text putih)
            ),
          ),
  ),
),
      ],
    );
  }

  Widget _buildSelector({required String label, required String? value, required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF01579B)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Klik untuk memilih...',
                    style: GoogleFonts.poppins(fontSize: 13, color: value != null ? Colors.black87 : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF01579B)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Perkiraan Selesai (Opsional)', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(
                    _predictedUntil != null ? DateFormat('dd/MM/yyyy HH:mm').format(_predictedUntil!) : 'Kosong',
                    style: GoogleFonts.poppins(fontSize: 13, color: _predictedUntil != null ? Colors.black87 : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: _notesController,
        maxLines: 3,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: 'Catatan (Opsional)',
          hintText: 'Tambahan informasi...',
          prefixIcon: const Icon(Icons.note, color: Color(0xFF01579B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}