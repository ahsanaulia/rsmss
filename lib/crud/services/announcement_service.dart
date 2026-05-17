// lib/crud/services/announcement_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<List<AnnouncementModel>> loadAnnouncements() async {
    try {
      // GUNAKAN NAMA CONSTRAINT YANG BENAR
      final data = await _supabase.from('announcements').select('''
        *,
        sender:profiles!ann_sender_fkey(full_name),
        target_profile:profiles!ann_profile_fkey(full_name),
        target_unit:employee_units!announcements_target_unit_id_fkey(unit_name),
        target_position:ref_positions!ann_position_fkey(position_name),
        target_building:ref_building_functions!ann_building_fkey(function_name),
        target_floor:floors!ann_floor_fkey(floor_alias),
        target_room:rooms!ann_room_fkey(room_name)
      ''').order('created_at', ascending: false);

      print('Data loaded: ${data.length} announcements'); // Debug

      return List<AnnouncementModel>.from(
        data.map((e) => AnnouncementModel.fromJson(e))
      );
    } catch (e) {
      print('Error loadAnnouncements: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadUnits() async {
    try {
      final data = await _supabase
          .from('employee_units')
          .select('id, unit_name')
          .order('unit_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error loadUnits: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadPositions() async {
    try {
      final data = await _supabase
          .from('ref_positions')
          .select('id, position_name')
          .order('position_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error loadPositions: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadBuildings() async {
    try {
      final data = await _supabase
          .from('ref_building_functions')
          .select('id, function_name')
          .order('function_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error loadBuildings: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadFloors() async {
    try {
      final data = await _supabase
          .from('floors')
          .select('id, floor_alias')
          .order('floor_alias');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error loadFloors: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadRooms() async {
    try {
      final data = await _supabase
          .from('rooms')
          .select('id, room_name')
          .order('room_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error loadRooms: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadEmployees() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, employee_id')
          .order('full_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error loadEmployees: $e');
      rethrow;
    }
  }

  Future<void> saveAnnouncement(AnnouncementModel announcement) async {
    try {
      final json = announcement.toJson();
      
      if (announcement.id.isEmpty) {
        json['id'] = _uuid.v4();
        json['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('announcements').insert(json);
      } else {
        await _supabase
            .from('announcements')
            .update(json)
            .eq('id', announcement.id);
      }
    } catch (e) {
      print('Error saveAnnouncement: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _supabase.from('announcements').delete().eq('id', id);
    } catch (e) {
      print('Error deleteAnnouncement: $e');
      rethrow;
    }
  }
}