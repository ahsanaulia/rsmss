// lib/features/roster/presentation/providers/roster_state.dart
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';

class RosterState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<RosterEntity> rosters;
  final List<ShiftEntity> shifts;
  final List<Map<String, dynamic>> employees;
  final DateTime currentMonth;
  final DateTime selectedDate;
  final String? selectedProfileId;
  final String? selectedShiftId;
  final String? selectedAttendanceStatus;
  final String? editingId;
  final bool isAddingNew;

  const RosterState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.rosters = const [],
    this.shifts = const [],
    this.employees = const [],
    required this.currentMonth,
    required this.selectedDate,
    this.selectedProfileId,
    this.selectedShiftId,
    this.selectedAttendanceStatus,
    this.editingId,
    this.isAddingNew = false,
  });

  RosterState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<RosterEntity>? rosters,
    List<ShiftEntity>? shifts,
    List<Map<String, dynamic>>? employees,
    DateTime? currentMonth,
    DateTime? selectedDate,
    String? selectedProfileId,
    String? selectedShiftId,
    String? selectedAttendanceStatus,
    String? editingId,
    bool? isAddingNew,
  }) {
    return RosterState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      rosters: rosters ?? this.rosters,
      shifts: shifts ?? this.shifts,
      employees: employees ?? this.employees,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedProfileId: selectedProfileId ?? this.selectedProfileId,
      selectedShiftId: selectedShiftId ?? this.selectedShiftId,
      selectedAttendanceStatus: selectedAttendanceStatus ?? this.selectedAttendanceStatus,
      editingId: editingId ?? this.editingId,
      isAddingNew: isAddingNew ?? this.isAddingNew,
    );
  }

  List<RosterEntity> getFilteredRosters() {
    var filtered = rosters;
    
    if (selectedProfileId != null && selectedProfileId!.isNotEmpty) {
      filtered = filtered.where((r) => r.profileId == selectedProfileId).toList();
    }
    
    if (selectedShiftId != null && selectedShiftId!.isNotEmpty) {
      filtered = filtered.where((r) => r.shiftId == selectedShiftId).toList();
    }
    
    if (selectedAttendanceStatus != null && selectedAttendanceStatus != 'all' && selectedAttendanceStatus!.isNotEmpty) {
      filtered = filtered.where((r) => r.attendanceStatus.value == selectedAttendanceStatus).toList();
    }
    
    return filtered;
  }

  List<RosterEntity> getRostersForDate(DateTime date) {
    return rosters.where((r) => 
      r.rosterDate.year == date.year &&
      r.rosterDate.month == date.month &&
      r.rosterDate.day == date.day
    ).toList();
  }

  Map<DateTime, List<RosterEntity>> getRostersByDate() {
    final Map<DateTime, List<RosterEntity>> result = {};
    for (final roster in rosters) {
      final date = DateTime(roster.rosterDate.year, roster.rosterDate.month, roster.rosterDate.day);
      result.putIfAbsent(date, () => []).add(roster);
    }
    return result;
  }
}