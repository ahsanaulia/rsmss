import '../models/task_model.dart';

class TaskState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<TaskModel> tasks;
  final List<Map<String, dynamic>> taskTypes;
  final List<Map<String, dynamic>> employees;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> assets;
  final List<Map<String, dynamic>> stocks;
  final String? filterByAssigneeId;
  final String? editingId;
  final bool isAddingNew;

  TaskState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.tasks = const [],
    this.taskTypes = const [],
    this.employees = const [],
    this.rooms = const [],
    this.assets = const [],
    this.stocks = const [],
    this.filterByAssigneeId,
    this.editingId,
    this.isAddingNew = false,
  });

  TaskState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<TaskModel>? tasks,
    List<Map<String, dynamic>>? taskTypes,
    List<Map<String, dynamic>>? employees,
    List<Map<String, dynamic>>? rooms,
    List<Map<String, dynamic>>? assets,
    List<Map<String, dynamic>>? stocks,
    String? filterByAssigneeId,
    String? editingId,
    bool? isAddingNew,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      tasks: tasks ?? this.tasks,
      taskTypes: taskTypes ?? this.taskTypes,
      employees: employees ?? this.employees,
      rooms: rooms ?? this.rooms,
      assets: assets ?? this.assets,
      stocks: stocks ?? this.stocks,
      filterByAssigneeId: filterByAssigneeId ?? this.filterByAssigneeId,
      editingId: editingId,
      isAddingNew: isAddingNew ?? this.isAddingNew,
    );
  }
}