import 'package:flutter/material.dart';

class CommandTableCell extends StatelessWidget {
  final double width;

  final Widget child;

  final Alignment alignment;

  const CommandTableCell({
    super.key,
    required this.width,
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: child,
    );
  }
}