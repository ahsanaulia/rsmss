import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_unit_model.dart';
import '../services/employee_unit_service.dart';
import 'employee_unit_state.dart';

final employeeUnitServiceProvider = Provider<EmployeeUnitService>((ref) {
  return EmployeeUnitService();
});

final employeeUnitStateProvider = StateNotifierProvider<EmployeeUnitNotifier, EmployeeUnitState>((ref) {
  return EmployeeUnitNotifier(ref.read(employeeUnitServiceProvider));
});

class EmployeeUnitNotifier extends StateNotifier<EmployeeUnitState> {
  final EmployeeUnitService _service;

  EmployeeUnitNotifier(this._service) : super(EmployeeUnitState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _service.getAll(
        search: state.filterSearch,
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

  Future<void> setFilterSearch(String? search) async {
    state = state.copyWith(filterSearch: search);
    await loadItems();
  }

  Future<void> setFilterIsActive(bool isActive) async {
    state = state.copyWith(filterIsActive: isActive);
    await loadItems();
  }

  Future<void> insert(EmployeeUnitModel item) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _service.insert(item);
      await loadItems();
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> update(EmployeeUnitModel item) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _service.update(item);
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

  Future<EmployeeUnitModel?> getById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void selectItem(EmployeeUnitModel? item) {
    state = state.copyWith(selectedItem: item);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}