// lib/features/bed_assignments/services/bed_assignment_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/people_model.dart';
import '../models/bed_model.dart';
import '../models/bed_assignment_model.dart';

class BedAssignmentService {
  final _supabase = Supabase.instance.client;

  // Search people
  Future<List<SimplePeopleModel>> searchPeople(String query) async {
    try {
      final response = await _supabase
          .from('people')
          .select('''
            id,
            rfid_tag_id,
            full_name,
            is_active,
            ref_people_categories (
              category_name
            )
          ''')
          .eq('is_active', true)
          .limit(100); // ambil 100 dulu

      List<Map<String, dynamic>> results = List.from(response);
      
      // Filter manual di Dart jika ada query
      if (query.isNotEmpty) {
        results = results.where((p) {
          final name = (p['full_name'] ?? '').toLowerCase();
          final rfid = (p['rfid_tag_id'] ?? '').toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || rfid.contains(q);
        }).toList();
      }

      return results.map((json) => SimplePeopleModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('searchPeople error: $e');
      return [];
    }
  }

  // Search beds
 Future<List<SimpleBedModel>> searchBeds(String query) async {
  try {
    final response = await _supabase
        .from('beds')
        .select('''
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
        ''')
        .eq('status', 'EMPTY')  // Ganti 'available' dengan 'EMPTY'
        .limit(100);

    List<Map<String, dynamic>> results = List.from(response);
    
    // Filter manual di Dart jika ada query
    if (query.isNotEmpty) {
      results = results.where((b) {
        final bedNumber = (b['bed_number'] ?? '').toLowerCase();
        final roomName = (b['rooms']?['room_name'] ?? '').toLowerCase();
        final q = query.toLowerCase();
        return bedNumber.contains(q) || roomName.contains(q);
      }).toList();
    }

    return results.map((json) => SimpleBedModel.fromJson(json)).toList();
  } catch (e) {
    debugPrint('searchBeds error: $e');
    return [];
  }
}
  // Assign bed
  Future<void> assignBed({
    required String peopleId,
    required String bedId,
    DateTime? predictedUntil,
    String? notes,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    
    await _supabase.from('beds_assignments').insert({
      'people_id': peopleId,
      'bed_id': bedId,
      'predicted_until': predictedUntil?.toIso8601String(),
      'notes': notes,
      'created_by': currentUserId,
    });
  }

  // Get active assignments
  Future<List<BedAssignmentModel>> getActiveAssignments() async {
    final response = await _supabase
        .from('beds_assignments')
        .select('''
          id,
          assigned_at,
          predicted_until,
          discharged_at,
          notes,
          people:people_id (
            id,
            full_name
          ),
          bed:bed_id (
            id,
            bed_number,
            rooms (
              room_name,
              floors (
                floor_number,
                buildings (
                  building_name
                )
              )
            )
          )
        ''')
        .order('assigned_at', ascending: false);

    // Filter manual: hanya yang discharged_at == null
    final results = response.where((a) => a['discharged_at'] == null).toList();
    
    return results.map((json) => BedAssignmentModel.fromJson(json)).toList();
  }

  // Discharge
  Future<void> discharge(String assignmentId) async {
    await _supabase
        .from('beds_assignments')
        .update({'discharged_at': DateTime.now().toIso8601String()})
        .eq('id', assignmentId);
  }

  // lib/features/bed_assignments/services/bed_assignment_service.dart

/// Get people who are NOT currently assigned to any active bed
Future<List<SimplePeopleModel>> getUnassignedPeople(String query) async {
  try {
    // 1. Ambil semua people aktif
    final allPeople = await _supabase
        .from('people')
        .select('''
          id,
          rfid_tag_id,
          full_name,
          is_active,
          ref_people_categories (
            category_name
          )
        ''')
        .eq('is_active', true)
        .limit(200);

    // 2. Ambil semua assignment (filter manual discharged_at == null)
    final allAssignments = await _supabase
        .from('beds_assignments')
        .select('people_id, discharged_at');

    // Filter manual: hanya yang discharged_at == null
    final activeAssignments = allAssignments
        .where((a) => a['discharged_at'] == null)
        .toList();

    final assignedPeopleIds = activeAssignments
        .map((a) => a['people_id'] as String?)
        .where((id) => id != null)
        .toSet();

    // 3. Filter: hanya people yang tidak ada di assignedPeopleIds
    List<Map<String, dynamic>> unassigned = List.from(allPeople);
    unassigned = unassigned.where((p) {
      return !assignedPeopleIds.contains(p['id']);
    }).toList();

    // 4. Filter query jika ada
    if (query.isNotEmpty) {
      unassigned = unassigned.where((p) {
        final name = (p['full_name'] ?? '').toLowerCase();
        final rfid = (p['rfid_tag_id'] ?? '').toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || rfid.contains(q);
      }).toList();
    }

    return unassigned.map((json) => SimplePeopleModel.fromJson(json)).toList();
  } catch (e) {
    debugPrint('getUnassignedPeople error: $e');
    return [];
  }
}
}

