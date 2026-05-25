import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingApprovalOverlay extends StatelessWidget {
  final Widget child;
  final VoidCallback onLogout;
  
  const PendingApprovalOverlay({
    super.key,
    required this.child,
    required this.onLogout,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background content (read-only, disabled)
        AbsorbPointer(  // ← Magic: membuat semua widget di dalamnya tidak bisa diklik
          absorbing: true,
          child: child,
        ),
        
        // Overlay semi-transparan
        Container(
          color: Colors.black.withValues(alpha: 0.75),
        ),
        
        // Banner & Pesan
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_top,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    "MENUNGGU PERSETUJUAN",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Message
                  Text(
                    "Akun Anda belum diaktifkan oleh Administrator.\n"
                    "Silakan hubungi HRD atau Admin\n\n"
                    "Setelah disetujui, Anda dapat langsung menggunakan aplikasi\n"
                    "tanpa perlu login ulang.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01579B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "LOGOUT",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}