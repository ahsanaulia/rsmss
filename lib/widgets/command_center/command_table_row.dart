import 'package:flutter/material.dart';

import 'models/command_table_column.dart';
import 'command_table_cell.dart';

class CommandTableRow<T> extends StatefulWidget {
  final T row;

  final List<CommandTableColumn<T>> columns;

  final bool selected;

  final VoidCallback? onTap;

  final Color? backgroundColor;

  const CommandTableRow({
    super.key,
    required this.row,
    required this.columns,
    this.selected = false,
    this.onTap,
    this.backgroundColor,
  });

  @override
  State<CommandTableRow<T>> createState() =>
      _CommandTableRowState<T>();
}

class _CommandTableRowState<T>
    extends State<CommandTableRow<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? const Color(0xFFDCEBFF)
        : widget.backgroundColor ?? Colors.white;

    return FocusableActionDetector(
      onShowFocusHighlight: (value) {
        setState(() {
          _focused = value;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 54,
          decoration: BoxDecoration(
            color: _focused
                ? const Color(0xFFEAF3FF)
                : bg,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.15),
              ),
            ),
          ),
          child: Row(
            children: widget.columns.map((column) {
              return CommandTableCell(
                width: column.width,
                alignment: column.alignment,
                child: column.cellBuilder(widget.row),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}