// lib/features/people/providers/people_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/people_service.dart';
import '../models/people_model.dart';

final peopleServiceProvider = Provider<PeopleService>((ref) {
  return PeopleService();
});

final peopleCategoriesProvider = FutureProvider<List<PeopleCategory>>((ref) {
  final service = ref.watch(peopleServiceProvider);
  return service.getCategories();
});

final rfidExistsProvider = FutureProvider.family<bool, String>((ref, rfidTagId) {
  final service = ref.watch(peopleServiceProvider);
  return service.isRfidTagExists(rfidTagId);
});