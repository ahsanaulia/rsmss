import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommandTableEmpty extends StatelessWidget {
  final String message;

  const CommandTableEmpty({
    super.key,
    this.message = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}