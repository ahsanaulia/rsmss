import '../models/employee_model.dart';

class EmployeeState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<EmployeeModel> employees;
  final List<Map<String, dynamic>> units;
  final List<Map<String, dynamic>> positions;
  final List<Map<String, dynamic>> shifts;
  final String? editingId;
  final bool isAddingNew;

  EmployeeState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.employees = const [],
    this.units = const [],
    this.positions = const [],
    this.shifts = const [],
    this.editingId,
    this.isAddingNew = false,
  });

  EmployeeState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<EmployeeModel>? employees,
    List<Map<String, dynamic>>? units,
    List<Map<String, dynamic>>? positions,
    List<Map<String, dynamic>>? shifts,
    String? editingId,
    bool? isAddingNew,
  }) {
    return EmployeeState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      employees: employees ?? this.employees,
      units: units ?? this.units,
      positions: positions ?? this.positions,
      shifts: shifts ?? this.shifts,
      editingId: editingId ?? this.editingId,
      isAddingNew: isAddingNew ?? this.isAddingNew,
    );
  }
}