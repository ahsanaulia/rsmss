import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:rsmss/l10n/app_localizations.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;

  // Editable fields (hanya data pribadi)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String? _avatarUrl;
  String? _selectedGender;
  
  // Read-only fields (informasi kerja dari admin)
  String _unitName = '-';
  String _positionName = '-';
  String _shiftName = '-';
  String _employeeId = '-';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profile = await supabase
          .from('profiles')
          .select('''
            *,
            employee_units!unit_id(unit_name),
            ref_positions!position_id(position_name),
            ref_shifts!default_shift_id(shift_name)
          ''')
          .eq('id', user.id)
          .single();

      setState(() {
        // Editable fields
        _nameController.text = profile['full_name'] ?? '';
        _nikController.text = profile['employee_nik'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _selectedGender = profile['gender'];
        _avatarUrl = profile['avatar_url'];
        
        // Read-only fields (informasi kerja)
        _employeeId = profile['employee_id'] ?? '-';
        _unitName = profile['employee_units']?['unit_name'] ?? '-';
        _positionName = profile['ref_positions']?['position_name'] ?? '-';
        _shiftName = profile['ref_shifts']?['shift_name'] ?? '-';
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50
    );
    if (image == null) return;
    
    setState(() => _isSaving = true);
    final localizations = AppLocalizations.of(context);
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.profile_avatarSuccess ?? "Foto diperbarui"), 
            backgroundColor: Colors.green
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.profile_avatarFailed ?? "Gagal upload foto"), 
            backgroundColor: Colors.red
          )
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final localizations = AppLocalizations.of(context);
    try {
      final user = supabase.auth.currentUser;
      await supabase.from('profiles').update({
        'full_name': _nameController.text,
        'employee_nik': _nikController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'gender': _selectedGender,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.profile_saveSuccess ?? "Profil berhasil disimpan"), 
            backgroundColor: Colors.green
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${localizations?.profile_saveFailed ?? "Gagal menyimpan: "}$e"), 
            backgroundColor: Colors.red
          )
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    localizations?.profile_title ?? "PROFIL SAYA",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF01579B),
                    ),
                  ),
                  _isSaving 
                    ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2))
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
                  // Avatar Card
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
                                  child: _avatarUrl == null 
                                    ? const Icon(Icons.person, size: 50, color: Colors.grey) 
                                    : null,
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
                          style: GoogleFonts.poppins(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: const Color(0xFF01579B)
                          ),
                        ),
                        Text(
                          "${localizations?.profile_idPrefix ?? "ID: "}$_employeeId",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Data Pribadi (Editable)
                  _buildGlassWrapper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.profile_personalData ?? "DATA PRIBADI",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF01579B),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(localizations?.profile_fullName ?? "Nama Lengkap", _nameController, Icons.badge_outlined),
                        const SizedBox(height: 15),
                        _buildTextField(localizations?.profile_nik ?? "NIK KTP", _nikController, Icons.numbers, keyboardType: TextInputType.number),
                        const SizedBox(height: 15),
                        _buildDropdown(
                          localizations?.profile_gender ?? "Jenis Kelamin", 
                          _selectedGender, [
                            DropdownMenuItem(value: 'L', child: Text(localizations?.profile_male ?? "Laki-laki")),
                            DropdownMenuItem(value: 'P', child: Text(localizations?.profile_female ?? "Perempuan")),
                          ], 
                          (val) => setState(() => _selectedGender = val)
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(localizations?.profile_phone ?? "No. WhatsApp", _phoneController, Icons.phone_android, keyboardType: TextInputType.phone),
                        const SizedBox(height: 15),
                        _buildTextField(localizations?.profile_address ?? "Alamat", _addressController, Icons.location_city, maxLines: 2),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Informasi Kerja (Read-Only)
                  _buildGlassWrapper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.profile_workInfo ?? "INFORMASI KERJA",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF01579B),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildReadOnlyField(localizations?.profile_unit ?? "Unit Kerja", _unitName, Icons.business),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(localizations?.profile_position ?? "Jabatan", _positionName, Icons.work_outline),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(localizations?.profile_shift ?? "Shift Default", _shiftName, Icons.schedule),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),

                  // Logout Button
                  _buildGlassWrapper(
                    padding: 0,
                    child: ListTile(
                      onTap: () => supabase.auth.signOut(),
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: Text(
                        localizations?.profile_logout ?? "Keluar Aplikasi",
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 14
                        ),
                      ),
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

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    TextInputType? keyboardType, 
    int maxLines = 1
  }) {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide.none
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label, 
    T? value, 
    List<DropdownMenuItem<T>> items, 
    Function(T?) onChanged
  ) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF01579B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF01579B), fontSize: 12),
        prefixIcon: const Icon(Icons.person_outline, size: 18, color: Color(0xFF01579B)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide.none
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF01579B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}