import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../widgets/adaptive_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // Untuk validasi password
  String _passwordError = '';

  Future<void> _handleRegister() async {
    // Validasi password minimal 8 karakter
    final password = _passwordController.text.trim();
    if (password.length < 8) {
      setState(() {
        _passwordError = 'Password minimal 8 karakter';
      });
      return;
    }
    
    // Reset error jika valid
    setState(() {
      _passwordError = '';
    });
    
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: password,
        data: {'full_name': _nameController.text.trim()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Berhasil! Silahkan Login.")),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC)],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const AdaptiveLogo(
                      height: 80,
                      imagePath: 'assets/images/logo.png',
                      lottiePath: 'assets/images/logo.json',
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      "REGISTER OPERATOR",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF01579B),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Name Field
                    _buildField(_nameController, "Nama Lengkap", Icons.person_outline, false),
                    const SizedBox(height: 15),
                    
                    // Email Field
                    _buildField(_emailController, "Email", Icons.email_outlined, false),
                    const SizedBox(height: 15),
                    
                    // Password Field
                    _buildPasswordField(),
                    const SizedBox(height: 25),
                    
                    // Register Button
                    _buildRegisterButton(),
                    const SizedBox(height: 20),
                    
                    // Back to Login Link
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Kembali ke Login",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF01579B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Footer
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF01579B)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // Widget khusus untuk password dengan error message
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _passwordError.isNotEmpty 
                  ? Colors.redAccent 
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            onChanged: (_) {
              // Hapus error saat user mulai mengetik
              if (_passwordError.isNotEmpty) {
                setState(() {
                  _passwordError = '';
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF01579B)),
              hintText: "Password",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              errorText: null, // Error ditampilkan di luar agar UI tetap rapi
            ),
          ),
        ),
        if (_passwordError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  _passwordError,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 6),
            child: Text(
              'Minimal 8 karakter',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF01579B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "DAFTAR SEKARANG",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Developed By : PLATFORM PELAYANAN TERBAIK",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade700,
          ),
        ),
        Text(
          "Distributed By : PT. REKAMITRA",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "2026 - Indonesia",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }
}