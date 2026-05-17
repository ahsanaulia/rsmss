import '../models/announcement_model.dart';

class AnnouncementState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<AnnouncementModel> announcements;
  
  // Data untuk dropdown
  final List<Map<String, dynamic>> units;
  final List<Map<String, dynamic>> positions;
  final List<Map<String, dynamic>> buildings;
  final List<Map<String, dynamic>> floors;
  final List<Map<String, dynamic>> rooms;
  final List<Map<String, dynamic>> employees;
  
  final String? editingId;
  final bool isAddingNew;

  AnnouncementState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.announcements = const [],
    this.units = const [],
    this.positions = const [],
    this.buildings = const [],
    this.floors = const [],
    this.rooms = const [],
    this.employees = const [],
    this.editingId,
    this.isAddingNew = false,
  });

  AnnouncementState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<AnnouncementModel>? announcements,
    List<Map<String, dynamic>>? units,
    List<Map<String, dynamic>>? positions,
    List<Map<String, dynamic>>? buildings,
    List<Map<String, dynamic>>? floors,
    List<Map<String, dynamic>>? rooms,
    List<Map<String, dynamic>>? employees,
    String? editingId,
    bool? isAddingNew,
  }) {
    return AnnouncementState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      announcements: announcements ?? this.announcements,
      units: units ?? this.units,
      positions: positions ?? this.positions,
      buildings: buildings ?? this.buildings,
      floors: floors ?? this.floors,
      rooms: rooms ?? this.rooms,
      employees: employees ?? this.employees,
      editingId: editingId,
      isAddingNew: isAddingNew ?? this.isAddingNew,
    );
  }
}