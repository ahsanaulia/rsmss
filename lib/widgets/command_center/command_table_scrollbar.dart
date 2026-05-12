import 'package:flutter/material.dart';

class CommandTableScrollbar extends StatelessWidget {
  final ScrollController controller;

  final Widget child;

  const CommandTableScrollbar({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      trackVisibility: true,
      radius: const Radius.circular(10),
      child: child,
    );
  }
}