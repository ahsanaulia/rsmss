import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_state.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.read(taskServiceProvider));
});

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskService _service;

  TaskNotifier(this._service) : super(TaskState());

  // 🔴 TAMBAHKAN METHOD INI UNTUK REALTIME
  Stream<List<TaskModel>> streamTasks({String? filterByAssigneeId}) {
    return _service.streamTasks(filterByAssigneeId: filterByAssigneeId);
  }

  Future<void> loadData({String? filterByAssigneeId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Jalankan semua Future secara paralel
      final results = await Future.wait([
        _service.loadTasks(filterByAssigneeId: filterByAssigneeId),
        _service.loadTaskTypes(),
        _service.loadEmployees(),
        _service.loadRooms(),
        _service.loadAssets(),
        _service.loadStocks(),
      ]);

      // Cast hasil ke tipe yang tepat
      final tasks = results[0] as List<TaskModel>;
      final taskTypes = results[1] as List<Map<String, dynamic>>;
      final employees = results[2] as List<Map<String, dynamic>>;
      final rooms = results[3] as List<Map<String, dynamic>>;
      final assets = results[4] as List<Map<String, dynamic>>;
      final stocks = results[5] as List<Map<String, dynamic>>;

      state = state.copyWith(
        isLoading: false,
        tasks: tasks,
        taskTypes: taskTypes,
        employees: employees,
        rooms: rooms,
        assets: assets,
        stocks: stocks,
        filterByAssigneeId: filterByAssigneeId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load data: $e',
      );
    }
  }

  void startEdit(String id) {
    state = state.copyWith(editingId: id, isAddingNew: false);
  }

  void cancelEdit() {
    state = state.copyWith(editingId: null, isAddingNew: false);
  }

  void startAddNew() {
    state = state.copyWith(isAddingNew: true, editingId: null);
  }

  Future<void> saveTask(TaskModel task) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _service.saveTask(task);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Task berhasil disimpan',
        editingId: null,
        isAddingNew: false,
      );
      await loadData(filterByAssigneeId: state.filterByAssigneeId);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan: $e',
      );
    }
  }

  Future<void> deleteTask(String id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _service.deleteTask(id);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Task berhasil dihapus',
      );
      await loadData(filterByAssigneeId: state.filterByAssigneeId);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menghapus: $e',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}