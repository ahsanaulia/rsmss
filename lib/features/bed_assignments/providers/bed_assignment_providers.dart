// lib/features/bed_assignments/providers/bed_assignment_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bed_assignment_service.dart';
import '../models/bed_assignment_model.dart';

final bedAssignmentServiceProvider = Provider<BedAssignmentService>((ref) {
  return BedAssignmentService();
});

final activeAssignmentsProvider = FutureProvider<List<BedAssignmentModel>>((ref) {
  final service = ref.watch(bedAssignmentServiceProvider);
  return service.getActiveAssignments();
});