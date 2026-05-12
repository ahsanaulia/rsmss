import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandTableSearchBar extends StatelessWidget {
  final TextEditingController controller;

  final ValueChanged<String>? onChanged;

  final String hint;

  const CommandTableSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hint = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}