import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui'; // WAJIB untuk Glassmorphism

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _avatarUrl;
  String? _selectedGender;
  String? _selectedPositionId;
  List<Map<String, dynamic>> _positions = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final posData = await supabase.from('ref_positions').select();
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _positions = List<Map<String, dynamic>>.from(posData);
        _nameController.text = profile['full_name'] ?? '';
        _employeeIdController.text = profile['employee_id'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _selectedGender = profile['gender'];
        _selectedPositionId = profile['position_id'];
        _avatarUrl = profile['avatar_url'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;
    setState(() => _isSaving = true);
    try {
      final user = supabase.auth.currentUser;
      final file = File(image.path);
      final String fileName = '${user!.id}/avatar.jpg';
      await supabase.storage.from('rsmss_files').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      final String rawUrl = supabase.storage.from('rsmss_files').getPublicUrl(fileName);
      final String timestampUrl = "$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      setState(() => _avatarUrl = timestampUrl);
      await supabase.from('profiles').update({'avatar_url': timestampUrl}).eq('id', user.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto diperbarui")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal upload")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final user = supabase.auth.currentUser;
      await supabase.from('profiles').update({
        'full_name': _nameController.text,
        'employee_id': _employeeIdController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'position_id': _selectedPositionId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil tersimpan"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.transparent, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header ala Attendance & Task List
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Spacer penyeimbang
                  Text(
                    "PROFIL PEGAWAI",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                  _isSaving 
                  ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF01579B)))
                  : IconButton(
                      onPressed: _saveProfile, 
                      icon: const Icon(Icons.check_circle, color: Color(0xFF01579B), size: 28)
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 120),
              child: Column(
                children: [
                  // Glass Card untuk Avatar
                  _buildGlassWrapper(
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blue.shade50,
                                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                                  child: _avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _uploadAvatar,
                                  child: const CircleAvatar(
                                    backgroundColor: Color(0xFF01579B),
                                    radius: 16,
                                    child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _nameController.text.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF01579B)),
                        ),
                        Text(
                          "ID: ${_employeeIdController.text}",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Glass Card untuk Form Input
                  _buildGlassWrapper(
                    child: Column(
                      children: [
                        _buildTextField("Nama Lengkap", _nameController, Icons.badge_outlined),
                        const SizedBox(height: 15),
                        _buildTextField("Nomor Pegawai", _employeeIdController, Icons.fingerprint, keyboardType: TextInputType.number),
                        const SizedBox(height: 15),
                        _buildDropdown("Jabatan", _selectedPositionId, _positions.map((p) {
                          return DropdownMenuItem(value: p['id'].toString(), child: Text(p['position_name'], style: GoogleFonts.poppins(fontSize: 13)));
                        }).toList(), (val) => setState(() => _selectedPositionId = val)),
                        const SizedBox(height: 15),
                        _buildDropdown("Jenis Kelamin", _selectedGender, [
                          DropdownMenuItem(value: 'L', child: Text("Laki-laki", style: GoogleFonts.poppins(fontSize: 13))),
                          DropdownMenuItem(value: 'P', child: Text("Perempuan", style: GoogleFonts.poppins(fontSize: 13))),
                        ], (val) => setState(() => _selectedGender = val)),
                        const SizedBox(height: 15),
                        _buildTextField("WhatsApp", _phoneController, Icons.phone_android, keyboardType: TextInputType.phone),
                        const SizedBox(height: 15),
                        _buildTextField("Domisili", _addressController, Icons.location_city, maxLines: 2),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),

                  // Tombol Logout
                  _buildGlassWrapper(
                    padding: 0,
                    child: ListTile(
                      onTap: () => supabase.auth.signOut(),
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: Text("Keluar Aplikasi", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membungkus konten dengan efek kaca
  Widget _buildGlassWrapper({required Widget child, double padding = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF01579B), fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF01579B)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF01579B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF01579B), fontSize: 12),
        prefixIcon: const Icon(Icons.account_tree_outlined, size: 18, color:  Color(0xFF01579B)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}