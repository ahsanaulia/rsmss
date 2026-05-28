import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoDetailPage extends StatelessWidget {
  final TodoModel todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriorityChip(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildTargetSection(),
                  const SizedBox(height: 24),
                  _buildScheduleSection(),
                  const SizedBox(height: 24),
                  _buildMetadataSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF01579B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Detail To Do',
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

  Widget _buildPriorityChip() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: todo.priorityColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          todo.priorityLabel,
          style: TextStyle(
            color: todo.priorityColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      todo.title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF01579B),
      ),
    );
  }

  Widget _buildDescription() {
    if (todo.description == null || todo.description!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Tidak ada deskripsi',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(todo.description!),
    );
  }

  Widget _buildInfoSection() {
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
              'Informasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Durasi',
              todo.durationMinutes != null ? '${todo.durationMinutes} menit' : '-',
            ),
            const Divider(),
            _buildInfoRow(
              'Status',
              todo.isActive ? 'Aktif' : 'Nonaktif',
              valueColor: todo.isActive ? Colors.green : Colors.red,
            ),
            const Divider(),
            _buildInfoRow(
              'Wajib Dikerjakan',
              todo.isMandatory ? 'Ya' : 'Tidak',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSection() {
    final targets = <String>[];
    if (todo.targetUnitName != null) targets.add('Unit: ${todo.targetUnitName}');
    if (todo.targetPositionName != null) targets.add('Posisi: ${todo.targetPositionName}');
    if (todo.targetShiftName != null) targets.add('Shift: ${todo.targetShiftName}');
    if (targets.isEmpty) targets.add('Semua pegawai');

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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            ...targets.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(t),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Tanggal', dateFormat.format(todo.todoDate)),
            if (todo.startTime != null || todo.endTime != null) ...[
              const Divider(),
              _buildInfoRow(
                'Jam',
                '${todo.startTime != null ? timeFormat.format(DateTime(0, 0, 0, todo.startTime!.hour, todo.startTime!.minute)) : "-"} - '
                '${todo.endTime != null ? timeFormat.format(DateTime(0, 0, 0, todo.endTime!.hour, todo.endTime!.minute)) : "-"}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');

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
              'Informasi Sistem',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Dibuat oleh', todo.createdByName ?? '-', small: true),
            _buildInfoRow('Dibuat pada', dateTimeFormat.format(todo.createdAt), small: true),
            _buildInfoRow('Terakhir update', dateTimeFormat.format(todo.updatedAt), small: true),
            if (todo.sourceType != 'admin_input') ...[
              const Divider(),
              _buildInfoRow('Sumber', todo.sourceType, small: true),
              if (todo.sourceId != null)
                _buildInfoRow('ID Sumber', todo.sourceId!, small: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool small = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: small ? 12 : 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: small ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}