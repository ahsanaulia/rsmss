// lib/features/roster/presentation/providers/roster_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rosterSearchProvider = StateProvider<String>((ref) => '');
final rosterProfileFilterProvider = StateProvider<String?>((ref) => null);
final rosterShiftFilterProvider = StateProvider<String?>((ref) => null);
final rosterStatusFilterProvider = StateProvider<String?>((ref) => null);