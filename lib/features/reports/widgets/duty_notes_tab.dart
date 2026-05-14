import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/report_service.dart';

class DutyNotesTab extends StatefulWidget {
  final String userId;
  const DutyNotesTab({super.key, required this.userId});

  @override
  State<DutyNotesTab> createState() => _DutyNotesTabState();
}

class _DutyNotesTabState extends State<DutyNotesTab> {
  final ReportService _service = ReportService();
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getDutyNotesHistory(widget.userId);
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Belum ada catatan dinas",
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        final createdAt = note['created_at'] != null
            ? DateTime.parse(note['created_at'])
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note_alt, size: 16, color: const Color(0xFF01579B)),
                    const SizedBox(width: 8),
                    Text(
                      "Catatan Dinas",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF01579B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(createdAt).split(' ')[0],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note['note_text'] ?? '',
                  style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(createdAt),
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}