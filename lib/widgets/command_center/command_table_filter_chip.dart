import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandTableFilterChip extends StatelessWidget {
  final String label;

  final bool selected;

  final VoidCallback onTap;

  const CommandTableFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color:
                selected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}