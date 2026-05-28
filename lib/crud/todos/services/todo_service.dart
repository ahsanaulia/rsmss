import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TodoService {
  final _supabase = Supabase.instance.client;
  
  // Untuk periodic stream
  Timer? _refreshTimer;
  StreamController<List<TodoModel>>? _todoStreamController;

  // ==================== ADMIN METHODS ====================

  Future<List<TodoModel>> getAll({
    required DateTime date,
    String? unitId,
    bool isActive = true,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;

      var query = _supabase
          .from('todos')
          .select('''
            *,
            target_unit:target_unit_id (id, unit_name),
            target_position:target_position_id (id, position_name),
            target_shift:target_shift_id (id, shift_name),
            creator:created_by (id, full_name)
          ''')
          .eq('todo_date', dateStr);

      if (unitId != null && unitId.isNotEmpty) {
        query = query.eq('target_unit_id', unitId);
      }
      if (isActive) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('display_order', ascending: true);

      return _mapResponseToModels(response);
    } catch (e) {
      debugPrint('Error getAll Todos: $e');
      throw Exception('Gagal memuat data To Do: $e');
    }
  }

  Future<TodoModel?> getById(String id) async {
    try {
      final response = await _supabase
          .from('todos')
          .select('''
            *,
            target_unit:target_unit_id (id, unit_name),
            target_position:target_position_id (id, position_name),
            target_shift:target_shift_id (id, shift_name),
            creator:created_by (id, full_name)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _mapSingleResponse(response);
    } catch (e) {
      debugPrint('Error getById Todo: $e');
      throw Exception('Gagal memuat detail To Do: $e');
    }
  }

  Future<void> insert(TodoModel todo) async {
    try {
      final data = todo.toJson();

      data.remove('target_unit_name');
      data.remove('target_position_name');
      data.remove('target_shift_name');
      data.remove('created_by_name');

      if (data['id'] == null || data['id'] == '') {
        data.remove('id');
      }

      await _supabase.from('todos').insert(data);
    } catch (e) {
      debugPrint('Error insert Todo: $e');
      throw Exception('Gagal menyimpan To Do: $e');
    }
  }

  Future<void> update(TodoModel todo) async {
    try {
      final data = todo.toJson();

      data.remove('target_unit_name');
      data.remove('target_position_name');
      data.remove('target_shift_name');
      data.remove('created_by_name');
      data.remove('created_at');
      data.remove('updated_at');

      await _supabase.from('todos').update(data).eq('id', todo.id);
    } catch (e) {
      debugPrint('Error update Todo: $e');
      throw Exception('Gagal mengupdate To Do: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _supabase.from('todos').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error delete Todo: $e');
      throw Exception('Gagal menghapus To Do: $e');
    }
  }

  Future<void> copyToDate(String id, DateTime newDate) async {
    try {
      final original = await getById(id);
      if (original == null) throw Exception('To Do tidak ditemukan');

      final newTodo = original.copyWith(
        id: '',
        todoDate: newDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await insert(newTodo);
    } catch (e) {
      debugPrint('Error copy Todo: $e');
      throw Exception('Gagal menggandakan To Do: $e');
    }
  }

  // ==================== MOBILE METHODS (UNTUK PEGAWAI) ====================

  /// Mendapatkan To Do untuk pegawai
  Future<List<TodoModel>> getTodosForEmployee({
    required String profileId,
    required DateTime date,
  }) async {
    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select('unit_id, position_id')
          .eq('id', profileId)
          .maybeSingle();

      if (profileResponse == null) {
        return [];
      }

      final unitId = profileResponse['unit_id'] as String?;
      final positionId = profileResponse['position_id'] as String?;

      final dateStr = date.toIso8601String().split('T').first;

      final rosterResponse = await _supabase
          .from('employee_shift_rosters')
          .select('shift_id')
          .eq('profile_id', profileId)
          .eq('roster_date', dateStr)
          .eq('is_day_off', false)
          .maybeSingle();

      final shiftId = rosterResponse?['shift_id'] as String?;

      final allTodos = await _supabase
          .from('todos')
          .select('''
            *,
            target_unit:target_unit_id (id, unit_name),
            target_position:target_position_id (id, position_name),
            target_shift:target_shift_id (id, shift_name),
            creator:created_by (id, full_name)
          ''')
          .eq('todo_date', dateStr)
          .eq('is_active', true)
          .order('display_order');

      final todos = _mapResponseToModels(allTodos);

      final filteredTodos = todos.where((todo) {
        final unitMatch = todo.targetUnitId == null || todo.targetUnitId == unitId;
        final positionMatch = todo.targetPositionId == null || todo.targetPositionId == positionId;
        final shiftMatch = todo.targetShiftId == null || todo.targetShiftId == shiftId;
        return unitMatch && positionMatch && shiftMatch;
      }).toList();

      filteredTodos.sort((a, b) {
        if (a.displayOrder != b.displayOrder) {
          return a.displayOrder.compareTo(b.displayOrder);
        }
        final priorityOrder = {'urgent': 0, 'high': 1, 'normal': 2, 'low': 3};
        final aPriority = priorityOrder[a.priority.toLowerCase()] ?? 2;
        final bPriority = priorityOrder[b.priority.toLowerCase()] ?? 2;
        return aPriority.compareTo(bPriority);
      });

      return filteredTodos;
    } catch (e) {
      debugPrint('Error getTodosForEmployee: $e');
      return [];
    }
  }

  /// Stream real-time untuk To Do pegawai (periodic refresh - 5 detik)
  Stream<List<TodoModel>> streamTodosForEmployee({
    required String profileId,
    required DateTime date,
  }) {
    final controller = StreamController<List<TodoModel>>.broadcast();
    
    // Fungsi untuk mengambil data
    Future<void> _fetchAndAdd() async {
      final data = await getTodosForEmployee(profileId: profileId, date: date);
      if (!controller.isClosed) {
        controller.add(data);
      }
    }
    
    // Ambil data pertama kali
    _fetchAndAdd();
    
    // Set interval refresh setiap 5 detik
    final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchAndAdd();
    });
    
    // Cleanup saat stream ditutup
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };
    
    return controller.stream;
  }

  /// Mendapatkan To Do untuk pegawai berdasarkan shift roster tertentu
  Future<List<TodoModel>> getTodosForEmployeeByRoster({
    required String profileId,
    required String employeeShiftRosterId,
  }) async {
    try {
      final rosterResponse = await _supabase
          .from('employee_shift_rosters')
          .select('roster_date, shift_id')
          .eq('id', employeeShiftRosterId)
          .maybeSingle();

      if (rosterResponse == null) return [];

      final rosterDate = DateTime.parse(rosterResponse['roster_date'] as String);
      final shiftId = rosterResponse['shift_id'] as String?;

      final profileResponse = await _supabase
          .from('profiles')
          .select('unit_id, position_id')
          .eq('id', profileId)
          .maybeSingle();

      if (profileResponse == null) return [];

      final unitId = profileResponse['unit_id'] as String?;
      final positionId = profileResponse['position_id'] as String?;

      final dateStr = rosterDate.toIso8601String().split('T').first;

      final allTodos = await _supabase
          .from('todos')
          .select('''
            *,
            target_unit:target_unit_id (id, unit_name),
            target_position:target_position_id (id, position_name),
            target_shift:target_shift_id (id, shift_name),
            creator:created_by (id, full_name)
          ''')
          .eq('todo_date', dateStr)
          .eq('is_active', true);

      final todos = _mapResponseToModels(allTodos);

      final filteredTodos = todos.where((todo) {
        final unitMatch = todo.targetUnitId == null || todo.targetUnitId == unitId;
        final positionMatch = todo.targetPositionId == null || todo.targetPositionId == positionId;
        final shiftMatch = todo.targetShiftId == null || todo.targetShiftId == shiftId;
        return unitMatch && positionMatch && shiftMatch;
      }).toList();

      return filteredTodos;
    } catch (e) {
      debugPrint('Error getTodosForEmployeeByRoster: $e');
      return [];
    }
  }

  /// Menandai To Do sebagai completed
  Future<void> markAsCompleted({
    required String todoId,
    required String profileId,
    String? proofPhotoUrl,
    String? proofNote,
  }) async {
    try {
      debugPrint('Mark todo $todoId as completed by $profileId');
    } catch (e) {
      debugPrint('Error markAsCompleted: $e');
      throw Exception('Gagal menandai To Do sebagai selesai: $e');
    }
  }

  // ==================== DROPDOWN METHODS ====================

  Future<List<Map<String, dynamic>>> getUnits() async {
    try {
      final response = await _supabase
          .from('employee_units')
          .select('id, unit_name')
          .eq('is_active', true)
          .order('unit_name');

      return response.map((e) => {'id': e['id'], 'name': e['unit_name']}).toList();
    } catch (e) {
      debugPrint('Error getUnits: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPositions() async {
    try {
      final response = await _supabase
          .from('ref_positions')
          .select('id, position_name')
          .order('position_name');

      return response.map((e) => {'id': e['id'], 'name': e['position_name']}).toList();
    } catch (e) {
      debugPrint('Error getPositions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getShifts() async {
    try {
      final response = await _supabase
          .from('ref_shifts')
          .select('id, shift_name')
          .eq('is_active', true)
          .order('start_time');

      return response.map((e) => {'id': e['id'], 'name': e['shift_name']}).toList();
    } catch (e) {
      debugPrint('Error getShifts: $e');
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  List<TodoModel> _mapResponseToModels(List<dynamic> response) {
    return response.map((json) => _mapSingleResponse(json)).toList();
  }

  TodoModel _mapSingleResponse(Map<String, dynamic> json) {
    final unitData = json['target_unit'] as Map<String, dynamic>?;
    final positionData = json['target_position'] as Map<String, dynamic>?;
    final shiftData = json['target_shift'] as Map<String, dynamic>?;
    final creatorData = json['creator'] as Map<String, dynamic>?;

    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      targetUnitId: json['target_unit_id'] as String?,
      targetPositionId: json['target_position_id'] as String?,
      targetShiftId: json['target_shift_id'] as String?,
      todoDate: DateTime.parse(json['todo_date'] as String),
      startTime: json['start_time'] != null
          ? TodoModel.timeFromString(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? TodoModel.timeFromString(json['end_time'] as String)
          : null,
      sourceType: json['source_type'] as String? ?? 'admin_input',
      sourceId: json['source_id'] as String?,
      sourceTable: json['source_table'] as String?,
      sourceData: json['source_data'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'] as String)
          : null,
      displayOrder: json['display_order'] as int? ?? 0,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      priority: json['priority'] as String? ?? 'normal',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      targetUnitName: unitData?['unit_name'] as String?,
      targetPositionName: positionData?['position_name'] as String?,
      targetShiftName: shiftData?['shift_name'] as String?,
      createdByName: creatorData?['full_name'] as String?,
    );
  }
}