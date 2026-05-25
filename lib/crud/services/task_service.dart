import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // 🔴 REALTIME STREAM UNTUK TASKS (Filter di client-side)
  Stream<List<TaskModel>> streamTasks({String? filterByAssigneeId}) {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          var tasks = data.map((json) => TaskModel.fromJson(json)).toList();
          
          // Filter di client-side
          if (filterByAssigneeId != null && filterByAssigneeId.isNotEmpty) {
            tasks = tasks.where((task) => task.assigneeId == filterByAssigneeId).toList();
          }
          
          return tasks;
        });
  }

  Future<List<TaskModel>> loadTasks({String? filterByAssigneeId}) async {
    try {
      var query = _supabase.from('tasks').select('''
        *,
        task_type:ref_task_types!tasks_type_fkey(
          task_type_name
        ),
        assignee:profiles!tasks_assignee_fkey(
          full_name
        ),
        creator:profiles!tasks_created_by_fkey(
          full_name
        ),
        related:profiles!tasks_related_profile_fkey(
          full_name
        ),
        from_room:rooms!tasks_from_room_fkey(
          room_name
        ),
        to_room:rooms!tasks_to_room_fkey(
          room_name
        ),
        asset:assets!tasks_asset_fkey(
          asset_name
        ),
        stock:stocks!tasks_stock_fkey(
          stock_name
        )
      ''');

      if (filterByAssigneeId != null && filterByAssigneeId.isNotEmpty) {
        query = query.eq('assignee_id', filterByAssigneeId);
      }

      final data = await query.order('created_at', ascending: false);
      
      return List<TaskModel>.from(data.map((e) => TaskModel.fromJson(e)));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadTaskTypes() async {
    try {
      final data = await _supabase
          .from('ref_task_types')
          .select()
          .order('task_type_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
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
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadAssets() async {
    try {
      final data = await _supabase
          .from('assets')
          .select('id, asset_name')
          .eq('is_active', true)
          .order('asset_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadStocks() async {
    try {
      final data = await _supabase
          .from('stocks')
          .select('id, stock_name')
          .eq('is_active', true)
          .order('stock_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveTask(TaskModel task) async {
    try {
      final json = task.toJson();
      
      if (task.id.isEmpty || task.id == 'new') {
        json['id'] = _uuid.v4();
        json['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('tasks').insert(json);
      } else {
        json['updated_at'] = DateTime.now().toIso8601String();
        await _supabase
            .from('tasks')
            .update(json)
            .eq('id', task.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _supabase.from('tasks').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}