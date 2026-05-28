import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoMobileDetailPage extends StatelessWidget {
  final TodoModel todo;

  const TodoMobileDetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                  _buildPrioritySection(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildTargetSection(),
                  const SizedBox(height: 24),
                  _buildScheduleSection(),
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
      decoration: const BoxDecoration(
        color: Color(0xFF01579B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  Widget _buildPrioritySection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: todo.priorityColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: todo.priorityColor.withOpacity(0.3)),
          ),
          child: Text(
            todo.priorityLabel,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: todo.priorityColor,
            ),
          ),
        ),
        if (todo.isMandatory) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'WAJIB',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      todo.title,
      style: GoogleFonts.poppins(
        fontSize: 20,
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
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        todo.description!,
        style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildInfoSection() {
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
              'Informasi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            if (todo.durationMinutes != null) ...[
              _buildInfoRow(
                'Durasi',
                '${todo.durationMinutes} menit',
              ),
              const Divider(),
            ],
            _buildInfoRow(
              'Tanggal',
              DateFormat('dd MMMM yyyy').format(todo.todoDate),
            ),
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            ...targets.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                t,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    if (todo.startTime == null && todo.endTime == null) {
      return const SizedBox.shrink();
    }

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
              'Jadwal Waktu',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF01579B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam Mulai',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todo.startTime != null
                            ? timeFormat.format(DateTime(0, 0, 0, todo.startTime!.hour, todo.startTime!.minute))
                            : '-',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam Selesai',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todo.endTime != null
                            ? timeFormat.format(DateTime(0, 0, 0, todo.endTime!.hour, todo.endTime!.minute))
                            : '-',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}