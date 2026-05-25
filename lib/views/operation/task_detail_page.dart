import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:ui';

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
  bool _isAccepted = false;
  
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  File? _selectedFile;
  
  // Lokasi penyelesaian
  Position? _completionPosition;
  String? _completionAddress;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _checkIfAccepted();
  }

  void _checkIfAccepted() {
    final status = widget.task['status']?.toString().toLowerCase();
    if (status == 'accepted') {
      _isAccepted = true;
    }
  }

  Future<void> _fetchCategories() async {
    final data = await supabase.from('ref_reports_category').select().order('name');
    if (mounted) {
      setState(() => _categories = List<Map<String, dynamic>>.from(data));
    }
  }

  Future<void> _acceptTask() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now().toIso8601String();
      await supabase.from('tasks').update({
        'status': 'accepted',
        'accepted_at': now,
        'started_at': now,
      }).eq('id', widget.task['id']);
      
      setState(() {
        widget.task['status'] = 'accepted';
        widget.task['accepted_at'] = now;
        widget.task['started_at'] = now;
        _isAccepted = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tugas diterima, silakan kerjakan"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menerima tugas: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Izin lokasi diperlukan"), backgroundColor: Colors.orange),
            );
          }
          return;
        }
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      String address = "";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks[0];
          address = "${p.street != null ? '${p.street}, ' : ''}${p.subLocality != null ? '${p.subLocality}, ' : ''}${p.locality ?? ''}";
        }
      } catch (_) {
        address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      }
      
      if (mounted) {
        setState(() {
          _completionPosition = position;
          _completionAddress = address;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lokasi: $address"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendapat lokasi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _pickMedia() async {
    final XFile? media = await ImagePicker().pickImage(
      source: ImageSource.camera, 
      imageQuality: 40,
    );
    if (media != null) setState(() => _selectedFile = File(media.path));
  }

  // 🔴 METHOD INI TETAP ADA (tidak dihapus, biar tidak error)
  Future<void> _submitReport() async {
    if (_selectedFile == null || _selectedCategoryId == null || _reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi foto, kategori, dan deskripsi!")),
      );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Laporan kendala terkirim!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal kirim laporan: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeTask(String outcome) async {
    // Validasi foto jika task memerlukan bukti foto
    final requiresPhoto = widget.task['requires_photo_proof'] == true;
    if (requiresPhoto && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tugas ini memerlukan bukti foto! Silakan ambil foto terlebih dahulu.")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final completedAt = now.toIso8601String();
      
      // Hitung durasi dari started_at ke sekarang
      int actualDuration = 0;
      if (widget.task['started_at'] != null) {
        final startedAt = DateTime.parse(widget.task['started_at']);
        actualDuration = now.difference(startedAt).inMinutes;
      }
      
      // Data update
      final Map<String, dynamic> updateData = {
        'status': 'done',
        'task_outcome': outcome,
        'completion_notes': _outcomeController.text,
        'completed_at': completedAt,
        'actual_duration_minutes': actualDuration,
      };
      
      // Tambah lokasi penyelesaian jika ada
      if (_completionPosition != null) {
        updateData['completion_lat'] = _completionPosition!.latitude;
        updateData['completion_long'] = _completionPosition!.longitude;
        updateData['completion_address'] = _completionAddress;
      }
      
      // Jika gagal, catat rejected_at
      if (outcome == 'failed') {
        updateData['rejected_at'] = completedAt;
        updateData['rejection_reason'] = _outcomeController.text;
      }
      
      // Upload foto bukti jika ada
      if (_selectedFile != null) {
        final fileName = 'proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'task_proof/${widget.task['id']}/$fileName';
        await supabase.storage.from('task_temporary_evidence').upload(filePath, _selectedFile!);
        final publicUrl = supabase.storage.from('task_temporary_evidence').getPublicUrl(filePath);
        updateData['proof_photo_url'] = publicUrl;
      }
      
      await supabase.from('tasks').update(updateData).eq('id', widget.task['id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(outcome == 'success' ? "Tugas selesai! ✅" : "Tugas gagal ❌"),
            backgroundColor: outcome == 'success' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.task['status']?.toString().toLowerCase() == 'pending';
    final isAccepted = widget.task['status']?.toString().toLowerCase() == 'accepted';
    final requiresPhoto = widget.task['requires_photo_proof'] == true;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: Column(
          children: [
            // AppBar
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
                        const SizedBox(width: 48),
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
                        // Tombol Terima Tugas (hanya jika pending)
                        if (isPending)
                          _buildGlassCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.handshake, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text("TERIMA TUGAS", 
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Tugas belum Anda terima. Klik tombol di bawah untuk mulai mengerjakan.",
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _acceptTask,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text("TERIMA TUGAS", 
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (!isPending) ...[
                          // Informasi Task
                          _buildGlassCard(
                            child: _buildTaskInfo(),
                          ),
                          const SizedBox(height: 20),
                          
                          // Lokasi Penyelesaian (tombol ambil lokasi)
                          _buildGlassCard(
                            child: _buildLocationSection(),
                          ),
                          const SizedBox(height: 20),
                          
                          // Catatan Penyelesaian & Tombol Selesai/Gagal
                          _buildGlassCard(
                            child: _buildCompletionSection(),
                          ),
                          
                          // 🔴 LAPORAN KENDALA DISEMBUNYIKAN (tapi method tetap ada)
                          // const SizedBox(height: 20),
                          // _buildGlassCard(
                          //   child: _buildReportSection(),
                          // ),
                        ],
                        
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

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.task_alt, color: Colors.white),
            const SizedBox(width: 10),
            Text("INFORMASI TUGAS", 
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
        if (widget.task['requires_photo_proof'] == true)
          _infoRow(Icons.camera_alt, "📸 Memerlukan bukti foto"),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 10),
            Text("LOKASI PENYELESAIAN", 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)
            ),
          ],
        ),
        const Divider(height: 30, color: Colors.white54),
        Text(
          _completionAddress ?? "Belum ambil lokasi",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGettingLocation ? null : _getCurrentLocation,
            icon: _isGettingLocation 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.gps_fixed, size: 18),
            label: Text(_isGettingLocation ? "MENGAMBIL LOKASI..." : "AMBIL LOKASI SAAT INI"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionSection() {
    final requiresPhoto = widget.task['requires_photo_proof'] == true;
    
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
        
        // Input catatan
        TextField(
          controller: _outcomeController,
          maxLines: 3,
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
        
        // Upload foto bukti jika diperlukan
        if (requiresPhoto) ...[
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
                      Icon(Icons.camera_alt_outlined, size: 35, color: Colors.white),
                      const SizedBox(height: 5),
                      Text("Klik untuk Foto Bukti", 
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15), 
                    child: Image.file(_selectedFile!, fit: BoxFit.cover)
                  ),
            ),
          ),
        ],
        
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _completeTask('failed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("GAGAL", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _completeTask('success'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("SELESAI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔴 METHOD _BUILDREPORTSECTION TETAP ADA (tidak dipanggil di UI)
  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text("LAPORKAN KENDALA", 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text("Ditemukan masalah teknis/lapangan?", 
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)
        ),
        const Divider(height: 30, color: Colors.white54),
        
        DropdownButtonFormField<String>(
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          dropdownColor: Colors.blue.shade900,
          decoration: InputDecoration(
            labelText: "Kategori Masalah",
            labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          value: _selectedCategoryId,
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
            hintStyle: const TextStyle(fontSize: 12, color: Colors.white70),
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
                    Icon(Icons.camera_alt_outlined, size: 35, color: Colors.white),
                    const SizedBox(height: 5),
                    Text("Klik untuk Foto Bukti", style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                  ],
                )
              : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_selectedFile!, fit: BoxFit.cover)),
          ),
        ),
        
        const SizedBox(height: 15),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("KIRIM LAPORAN KENDALA", 
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
            ),
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
}