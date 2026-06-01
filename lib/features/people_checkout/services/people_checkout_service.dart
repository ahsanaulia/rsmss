// lib/features/people_checkout/services/people_checkout_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeopleCheckoutService {
  final _supabase = Supabase.instance.client;

  /// Get all active people (is_active = true)
  Future<List<Map<String, dynamic>>> getActivePeople(String query) async {
    try {
      final response = await _supabase
          .from('people')
          .select('''
            id,
            rfid_tag_id,
            full_name,
            is_active,
            created_at,
            ref_people_categories (
              id,
              category_name,
              marker_color
            )
          ''')
          .eq('is_active', true)
          .limit(200);

      List<Map<String, dynamic>> results = List.from(response);

      // Filter query jika ada
      if (query.isNotEmpty) {
        results = results.where((p) {
          final name = (p['full_name'] ?? '').toLowerCase();
          final rfid = (p['rfid_tag_id'] ?? '').toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || rfid.contains(q);
        }).toList();
      }

      return results;
    } catch (e) {
      debugPrint('getActivePeople error: $e');
      return [];
    }
  }

  /// Check out people (set is_active = false)
  Future<void> checkoutPeople(String peopleId, String peopleName) async {
    try {
      await _supabase
          .from('people')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', peopleId);

      debugPrint('✅ Checked out: $peopleName');
    } catch (e) {
      debugPrint('❌ checkoutPeople error: $e');
      rethrow;
    }
  }
}