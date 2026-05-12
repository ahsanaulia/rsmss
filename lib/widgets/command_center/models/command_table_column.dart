import 'package:flutter/material.dart';

class CommandTableColumn<T> {
  final String title;

  final double width;

  final Alignment alignment;

  final Widget Function(T row) cellBuilder;

  const CommandTableColumn({
    required this.title,
    required this.width,
    required this.cellBuilder,
    this.alignment = Alignment.centerLeft,
  });
}