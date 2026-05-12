import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:ui';

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

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()}, // DITANGKAP TRIGGER SQL
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Berhasil! Silahkan Login.")),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB3E5FC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("REGISTER OPERATOR", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF01579B))),
              const SizedBox(height: 30),
              _buildField(_nameController, "Nama Lengkap", Icons.person_outline, false),
              const SizedBox(height: 15),
              _buildField(_emailController, "Email", Icons.email_outlined, false),
              const SizedBox(height: 15),
              _buildField(_passwordController, "Password", Icons.lock_outline, true),
              const SizedBox(height: 25),
              _buildRegisterButton(),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Kembali ke Login", style: GoogleFonts.poppins(color: const Color(0xFF01579B)))),
            ],
          ),
        ),
      ),
    );
  }

  // Gunakan fungsi UI yang mirip dengan Login untuk konsistensi
  Widget _buildField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: const Color(0xFF01579B)), hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01579B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("DAFTAR SEKARANG", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}