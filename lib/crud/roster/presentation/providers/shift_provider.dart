// lib/features/roster/presentation/providers/shift_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shift_entity.dart';
import '../../data/datasources/roster_remote_datasource.dart';

final shiftProvider = FutureProvider<List<ShiftEntity>>((ref) async {
  final datasource = RosterRemoteDatasource();
  return await datasource.getShifts();
});