import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'register_screen.dart';
import 'main_screen.dart';
import 'qr_scan_screen.dart';
import '../widgets/adaptive_logo.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToQrScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFF81D4FA)],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    
                    // Logo
                    AdaptiveLogo(
                      height: 100,
                      imagePath: 'assets/images/logo.png',
                      lottiePath: 'assets/images/logo.json',
                    ),
                    const SizedBox(height: 20),
                    
                    // Title - TIDAK DIUBAH (tetap hardcoded)
                    Text(
                      "Hospital Organizational Intelligence Platform",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF01579B),
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Email Field - hint menggunakan localizations
                    _buildGlassTextField(_emailController, localizations?.emailHint ?? "Email Operator", Icons.email_outlined, false),
                    const SizedBox(height: 15),
                    
                    // Password Field - hint menggunakan localizations
                    _buildGlassTextField(_passwordController, localizations?.passwordHint ?? "Password", Icons.lock_outline, true),
                    const SizedBox(height: 25),
                    
                    // Login Button
                    _buildLoginButton(localizations),
                    const SizedBox(height: 20),
                    
                    // Scan QR Tenant Button
                    _buildScanQrButton(localizations),
                    const SizedBox(height: 20),
                    
                    // Register Link
                    _buildRegisterLink(localizations),
                    const SizedBox(height: 30),
                    
                    // Footer
                    _buildFooter(localizations),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
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

  Widget _buildLoginButton(AppLocalizations? localizations) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF01579B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(
              localizations?.loginButton ?? "LOGIN", 
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
            ),
      ),
    );
  }

  Widget _buildScanQrButton(AppLocalizations? localizations) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: _navigateToQrScan,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          side: const BorderSide(color: Color(0xFF01579B), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          localizations?.scanQrButton ?? "SCAN QR TENANT",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01579B),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations? localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations?.noAccount ?? "Belum memiliki akun? ", 
          style: GoogleFonts.poppins(fontSize: 13)
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
          child: Text(
            localizations?.register ?? "Register",
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF01579B)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations? localizations) {
    return Column(
      children: [
        Text(
          localizations?.developedBy ?? "Developed By : PLATFORM PELAYANAN TERBAIK",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade700,
          ),
        ),
        Text(
          localizations?.distributedBy ?? "Distributed By : PT. REKAMITRA",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          localizations?.yearCountry ?? "2026 - Indonesia",
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