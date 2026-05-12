import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/command_table_column.dart';
import 'command_table_cell.dart';

class CommandTableHeader<T> extends StatelessWidget {
  final List<CommandTableColumn<T>> columns;

  const CommandTableHeader({
    super.key,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
      ),
      child: Row(
        children: columns.map((column) {
          return CommandTableCell(
            width: column.width,
            alignment: column.alignment,
            child: Text(
              column.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}