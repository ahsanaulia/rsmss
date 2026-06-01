// lib/features/people/services/people_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/people_model.dart';

class PeopleService {
  final _supabase = Supabase.instance.client;

  /// Get all categories from ref_people_categories
  Future<List<PeopleCategory>> getCategories() async {
    try {
      final response = await _supabase
          .from('ref_people_categories')
          .select('*')
          .order('category_name');

      return response
          .map((json) => PeopleCategory.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ PeopleService.getCategories error: $e');
      return [];
    }
  }

  /// Check if RFID tag already exists
  Future<bool> isRfidTagExists(String rfidTagId) async {
    try {
      final response = await _supabase
          .from('people')
          .select('id')
          .eq('rfid_tag_id', rfidTagId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('❌ PeopleService.isRfidTagExists error: $e');
      return false;
    }
  }

  /// Insert new person
  Future<PeopleModel> insertPerson({
    required String rfidTagId,
    required String fullName,
    required String categoryId,
    String? fotoUrl,
    required bool isMale,
    required bool isChild,
    String? levelContaminated,
  }) async {
    try {
      final response = await _supabase.from('people').insert({
        'rfid_tag_id': rfidTagId,
        'full_name': fullName,
        'category_id': categoryId,
        'foto_url': fotoUrl,
        'is_male': isMale,
        'is_child': isChild,
        'is_active': true,
        'level_contaminated': levelContaminated,
      }).select('''
        *,
        ref_people_categories (
          category_name,
          marker_color
        )
      ''').single();

      debugPrint('✅ PeopleService.insertPerson: $fullName inserted');
      return PeopleModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ PeopleService.insertPerson error: $e');
      rethrow;
    }
  }
}