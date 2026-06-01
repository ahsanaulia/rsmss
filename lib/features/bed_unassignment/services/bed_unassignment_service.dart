// lib/features/bed_unassignment/services/bed_unassignment_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../bed_assignments/models/bed_assignment_model.dart';

class BedUnassignmentService {
  final _supabase = Supabase.instance.client;

  /// Get all active bed assignments (bed yang sedang terisi people)
  Future<List<BedAssignmentModel>> getActiveBedAssignments(String query) async {
    try {
      // Ambil semua assignment aktif (discharged_at == null)
      final allAssignments = await _supabase
          .from('beds_assignments')
          .select('''
            id,
            assigned_at,
            predicted_until,
            discharged_at,
            notes,
            people:people_id (
              id,
              full_name,
              rfid_tag_id,
              ref_people_categories (
                category_name
              )
            ),
            bed:bed_id (
              id,
              bed_number,
              status,
              rooms (
                id,
                room_name,
                floors (
                  floor_number,
                  buildings (
                    building_name
                  )
                )
              )
            )
          ''');

      // Filter manual: hanya yang belum discharged
      List<Map<String, dynamic>> active = allAssignments
          .where((a) => a['discharged_at'] == null)
          .toList();

      // Filter query jika ada
      if (query.isNotEmpty) {
        active = active.where((a) {
          final bedNumber = (a['bed']?['bed_number'] ?? '').toLowerCase();
          final peopleName = (a['people']?['full_name'] ?? '').toLowerCase();
          final q = query.toLowerCase();
          return bedNumber.contains(q) || peopleName.contains(q);
        }).toList();
      }

      return active.map((json) => BedAssignmentModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('getActiveBedAssignments error: $e');
      return [];
    }
  }

  /// Unassign (discharge) people from bed
  Future<void> unassignBed(String assignmentId) async {
    try {
      await _supabase
          .from('beds_assignments')
          .update({'discharged_at': DateTime.now().toIso8601String()})
          .eq('id', assignmentId);
      
      debugPrint('✅ Unassigned bed: $assignmentId');
    } catch (e) {
      debugPrint('❌ unassignBed error: $e');
      rethrow;
    }
  }
}