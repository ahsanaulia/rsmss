import 'package:equatable/equatable.dart';
import '../models/todo_model.dart';

class TodoState extends Equatable {
  final bool isLoading;
  final List<TodoModel> items;
  final String? error;
  final bool isSubmitting;
  final TodoModel? selectedTodo;

  // Filters
  final DateTime filterDate;
  final String? filterUnitId;
  final bool filterIsActive;

  // HAPUS "const" dari baris ini
  TodoState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.isSubmitting = false,
    this.selectedTodo,
    DateTime? filterDate,
    this.filterUnitId,
    this.filterIsActive = true,
  }) : filterDate = filterDate ?? DateTime.now();

  TodoState copyWith({
    bool? isLoading,
    List<TodoModel>? items,
    String? error,
    bool? isSubmitting,
    TodoModel? selectedTodo,
    DateTime? filterDate,
    String? filterUnitId,
    bool? filterIsActive,
  }) {
    return TodoState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedTodo: selectedTodo ?? this.selectedTodo,
      filterDate: filterDate ?? this.filterDate,
      filterUnitId: filterUnitId ?? this.filterUnitId,
      filterIsActive: filterIsActive ?? this.filterIsActive,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        items,
        error,
        isSubmitting,
        selectedTodo,
        filterDate,
        filterUnitId,
        filterIsActive,
      ];
}