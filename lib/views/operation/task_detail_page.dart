import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui'; // Untuk efek blur

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final supabase = Supabase.instance.client;
  final _reportController = TextEditingController();
  final _outcomeController = TextEditingController();
  bool _isLoading = false;
  
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final data = await supabase.from('ref_reports_category').select().order('name');
    setState(() => _categories = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _pickMedia() async {
    final XFile? media = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 40);
    if (media != null) setState(() => _selectedFile = File(media.path));
  }

  Future<void> _submitReport() async {
    if (_selectedFile == null || _selectedCategoryId == null || _reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi foto, kategori, dan deskripsi!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fileName = 'REP_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'reports/${widget.task['id']}/$fileName';
      
      await supabase.storage.from('task_temporary_evidence').upload(filePath, _selectedFile!);
      final publicUrl = supabase.storage.from('task_temporary_evidence').getPublicUrl(filePath);

      await supabase.from('tasks_reports').insert({
        'task_id': widget.task['id'],
        'category_id': _selectedCategoryId,
        'reporter_id': supabase.auth.currentUser!.id,
        'description': _reportController.text,
        'urgency_level': widget.task['priority'],
        'at_room_id': widget.task['from_room_id'],
        'file_url': publicUrl,
        'file_type': 'image'
      });

      _reportController.clear();
      setState(() => _selectedFile = null);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan visual terkirim!")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status, String outcome) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('tasks').update({
        'status': status,
        'task_outcome': outcome,
        'completion_notes': _outcomeController.text,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.task['id']);
      
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SEKARANG LATAR Scaffold BENAR-BENAR TRANSPARAN
      backgroundColor: Colors.transparent,
      
      // BODY DIBUNGKUS DENGAN GRADIENT CONTAINER
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // SAMAKAN DENGAN GRADIENT DI operation_dashboard.dart
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: Column(
          children: [
            // AppBar Custom dengan Glassmorphism
            SafeArea(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text("Detail Eksekusi", 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)
                        ),
                        const SizedBox(width: 48), // Spacer penyeimbang back button
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        _buildGlassCard(
                          child: _contentPenyelesaian(),
                        ),
                        const SizedBox(height: 20),
                        _buildGlassCard(
                          child: _contentLaporanKendala(),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Wrapper untuk efek glassmorphism yang konsisten
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), // Kembalikan ke 0.2 agar terlihat kacanya
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _contentPenyelesaian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.task_alt, color: Colors.white),
            const SizedBox(width: 10),
            Text("PENYELESAIAN TUGAS", 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)
            ),
          ],
        ),
        const Divider(height: 30, color: Colors.white54),
        Text(widget.task['object_name'] ?? 'Tugas', 
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)
        ),
        const SizedBox(height: 12),
        _infoRow(Icons.location_on_rounded, "Rute: ${widget.task['from_room_name'] ?? '-'} ➔ ${widget.task['to_room_name'] ?? '-'}"),
        _infoRow(Icons.bolt, "Prioritas: ${widget.task['priority']?.toString().toUpperCase()}"),
        const SizedBox(height: 20),
        TextField(
          controller: _outcomeController,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: "Tulis catatan penyelesaian...",
            hintStyle: const TextStyle(fontSize: 12, color: Colors.white60),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _actionBtn("GAGAL", Colors.red.shade400, () => _updateStatus('done', 'failed'))),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn("SELESAI", Colors.green.shade500, () => _updateStatus('done', 'success'))),
          ],
        )
      ],
    );
  }

  Widget _contentLaporanKendala() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on, color: Color.fromARGB(255, 255, 7, 7)),
            const SizedBox(width: 14),
            Text("LAPORKAN KENDALA", 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255), fontSize: 13)
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text("Ditemukan masalah teknis/lapangan?", 
          style: GoogleFonts.poppins(fontSize: 11, color: const Color.fromARGB(244, 255, 255, 255))
        ),
        const Divider(height: 30, color: Colors.white54),
        DropdownButtonFormField<String>(
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          dropdownColor: Colors.blue.shade900, // Warna background dropdown menu
          decoration: InputDecoration(
            labelText: "Kategori Masalah",
            labelStyle: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 253, 253, 253)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          initialValue: _selectedCategoryId,
          items: _categories.map((c) => DropdownMenuItem(
            value: c['id'].toString(), 
            child: Text(c['name'] ?? 'No Name', style: const TextStyle(fontSize: 13, color: Colors.white))
          )).toList(),
          onChanged: (v) => setState(() => _selectedCategoryId = v),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _reportController,
          maxLines: 2,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: "Deskripsi kendala...",
            hintStyle: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 253, 253, 252)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _pickMedia,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: _selectedFile == null 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 35, color: const Color.fromARGB(255, 255, 255, 255)),
                    const SizedBox(height: 5),
                    Text("Klik untuk Foto Bukti", style: GoogleFonts.poppins(fontSize: 11, color: const Color.fromARGB(255, 221, 221, 221))),
                  ],
                )
              : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_selectedFile!, fit: BoxFit.cover)),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          onPressed: _submitReport,
          child: Text("KIRIM LAPORAN KENDALA", 
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, 
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}