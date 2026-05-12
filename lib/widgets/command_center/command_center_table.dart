import 'package:flutter/material.dart';

import 'command_table_empty.dart';
import 'command_table_header.dart';
import 'command_table_row.dart';
import 'command_table_scrollbar.dart';
import 'models/command_table_column.dart';

class CommandCenterTable<T> extends StatefulWidget {
  final List<T> rows;

  final List<CommandTableColumn<T>> columns;

  final double rowHeight;

  final double tableHeight;

  final bool zebra;

  final int? selectedIndex;

  final Function(T row)? onRowTap;

  final Color Function(T row)? rowColorBuilder;

  const CommandCenterTable({
    super.key,
    required this.rows,
    required this.columns,
    this.rowHeight = 54,
    this.tableHeight = 500,
    this.zebra = true,
    this.selectedIndex,
    this.onRowTap,
    this.rowColorBuilder,
  });

  @override
  State<CommandCenterTable<T>> createState() =>
      _CommandCenterTableState<T>();
}

class _CommandCenterTableState<T>
    extends State<CommandCenterTable<T>> {
  final ScrollController _verticalController =
      ScrollController();

  final ScrollController _horizontalController =
      ScrollController();

  double get totalWidth {
    double width = 0;

    for (final col in widget.columns) {
      width += col.width;
    }

    return width;
  }

  @override
  void dispose() {
    _verticalController.dispose();

    _horizontalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return const CommandTableEmpty();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
        ),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),

        child: CommandTableScrollbar(
          controller: _verticalController,

          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              width: totalWidth,

              child: Column(
                children: [
                  // =========================================
                  // HEADER
                  // =========================================

                  CommandTableHeader<T>(
                    columns: widget.columns,
                  ),

                  // =========================================
                  // BODY
                  // =========================================

                  SizedBox(
                    height: widget.tableHeight,

                    child: ListView.builder(
                      controller: _verticalController,

                      itemCount: widget.rows.length,

                      itemBuilder: (_, index) {
                        final row =
                            widget.rows[index];

                        Color? rowColor;

                        // ===================================
                        // CUSTOM ROW COLOR
                        // ===================================

                        if (widget.rowColorBuilder !=
                            null) {
                          rowColor =
                              widget.rowColorBuilder!(
                            row,
                          );
                        }

                        // ===================================
                        // ZEBRA STRIPE
                        // ===================================

                        else if (widget.zebra) {
                          rowColor = index.isEven
                              ? Colors.white
                              : const Color(
                                  0xFFF8FAFC,
                                );
                        }

                        return SizedBox(
                          height:
                              widget.rowHeight,

                          child: CommandTableRow<T>(
                            row: row,

                            columns:
                                widget.columns,

                            selected:
                                widget.selectedIndex ==
                                    index,

                            backgroundColor:
                                rowColor,

                            onTap: () {
                              widget.onRowTap?.call(
                                row,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}