import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import 'todo_state.dart';

final todoServiceProvider = Provider<TodoService>((ref) {
  return TodoService();
});

final todoStateProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  // HAPUS "const" di sini
  return TodoNotifier(ref.read(todoServiceProvider));
});

class TodoNotifier extends StateNotifier<TodoState> {
  final TodoService _service;

  TodoNotifier(this._service) : super(TodoState()) {  // HAPUS "const" di sini juga
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _service.getAll(
        date: state.filterDate,
        unitId: state.filterUnitId,
        isActive: state.filterIsActive,
      );
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> setFilterDate(DateTime date) async {
    state = state.copyWith(filterDate: date);
    await loadItems();
  }

  Future<void> setFilterUnitId(String? unitId) async {
    state = state.copyWith(filterUnitId: unitId);
    await loadItems();
  }

  Future<void> setFilterIsActive(bool isActive) async {
    state = state.copyWith(filterIsActive: isActive);
    await loadItems();
  }

  Future<void> insert(TodoModel todo) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _service.insert(todo);
      await loadItems();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> update(TodoModel todo) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _service.update(todo);
      await loadItems();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> delete(String id) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _service.delete(id);
      await loadItems();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> copyToDate(String id, DateTime newDate) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _service.copyToDate(id, newDate);
      await loadItems();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<TodoModel?> getById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void selectTodo(TodoModel? todo) {
    state = state.copyWith(selectedTodo: todo);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}