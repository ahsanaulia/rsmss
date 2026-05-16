import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'employee_state.dart';
import '../models/employee_model.dart';

final employeeProvider = StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) {
  return EmployeeNotifier();
});

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  EmployeeNotifier() : super(EmployeeState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load employees
      final employeesData = await _supabase
          .from('profiles')
          .select('''
            *,
            ref_positions!position_id(position_name),
            employee_units!unit_id(unit_name),
            ref_shifts!default_shift_id(shift_name)
          ''')
          .order('full_name');

      // Load units for dropdown
      final unitsData = await _supabase
          .from('employee_units')
          .select('id, unit_name, unit_code')
          .order('unit_name');

      // Load positions for dropdown
      final positionsData = await _supabase
          .from('ref_positions')
          .select('id, position_name')
          .order('position_name');

      // Load shifts for dropdown
      final shiftsData = await _supabase
          .from('ref_shifts')
          .select('id, shift_name, shift_code')
          .order('shift_name');

      final employees = List<EmployeeModel>.from(
        employeesData.map((e) => EmployeeModel.fromJson(e))
      );

      state = state.copyWith(
        isLoading: false,
        employees: employees,
        units: List<Map<String, dynamic>>.from(unitsData),
        positions: List<Map<String, dynamic>>.from(positionsData),
        shifts: List<Map<String, dynamic>>.from(shiftsData),
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

  // void cancelEdit() {
  //   state = state.copyWith(editingId: null, isAddingNew: false);
  // }
void cancelEdit() {
  print('🔴 CANCEL EDIT CALLED - BEFORE: editingId=${state.editingId}');
  state = state.copyWith(editingId: null, isAddingNew: false);
  print('🔴 CANCEL EDIT CALLED - AFTER: editingId=${state.editingId}');
}

  void startAddNew() {
    state = state.copyWith(isAddingNew: true, editingId: null);
  }

  Future<void> saveEmployee(EmployeeModel employee) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final json = employee.toJson();
      // Remove fields that shouldn't be updated
      json.remove('position_name');
      json.remove('unit_name');
      json.remove('default_shift_name');

      if (employee.id.isEmpty || employee.id == 'new') {
        // Insert new
        final newId = _generateUuid();
        json['id'] = newId;
        await _supabase.from('profiles').insert(json);
      } else {
        // Update existing
        await _supabase
            .from('profiles')
            .update(json)
            .eq('id', employee.id);
      }

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Data berhasil disimpan',
        editingId: null,
        isAddingNew: false,
      );
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan: $e',
      );
    }
  }

  Future<void> deleteEmployee(String id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _supabase.from('profiles').delete().eq('id', id);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Data berhasil dihapus',
      );
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menghapus: $e',
      );
    }
  }

  String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}${DateTime.now().microsecondsSinceEpoch}';
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}