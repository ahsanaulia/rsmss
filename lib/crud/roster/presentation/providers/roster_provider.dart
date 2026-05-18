// lib/features/roster/presentation/providers/roster_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'roster_state.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/i_roster_repository.dart';
import '../../domain/entities/roster_entity.dart';
import '../../domain/entities/shift_entity.dart';
import '../../data/repositories/roster_repository.dart';
import '../../data/datasources/roster_remote_datasource.dart';

// Provider untuk datasource
final rosterRemoteDatasourceProvider = Provider<RosterRemoteDatasource>((ref) {
  return RosterRemoteDatasource();
});

// Provider untuk repository
final rosterRepositoryProvider = Provider<IRosterRepository>((ref) {
  final datasource = ref.read(rosterRemoteDatasourceProvider);
  return RosterRepository(datasource);
});

// Provider untuk state
final rosterProvider = StateNotifierProvider<RosterNotifier, RosterState>((ref) {
  final repository = ref.read(rosterRepositoryProvider);
  final authService = getIt<AuthService>();
  return RosterNotifier(repository, authService);
});

class RosterNotifier extends StateNotifier<RosterState> {
  final IRosterRepository _repository;
  final AuthService _authService;

  RosterNotifier(this._repository, this._authService)
      : super(RosterState(
          currentMonth: DateTime.now(),
          selectedDate: DateTime.now(),
        ));

  String? get _currentUserId => _authService.currentUserId;

  Future<void> loadData({DateTime? month}) async {
    final targetMonth = month ?? state.currentMonth;
    final startDate = DateTime(targetMonth.year, targetMonth.month, 1);
    final endDate = DateTime(targetMonth.year, targetMonth.month + 1, 0);

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _repository.getRosters(startDate: startDate, endDate: endDate),
        _repository.getShifts(),
        _repository.getEmployees(),
      ]);

      final rosters = results[0] as List<RosterEntity>;
      final shifts = results[1] as List<ShiftEntity>;
      final employees = results[2] as List<Map<String, dynamic>>;

      state = state.copyWith(
        isLoading: false,
        rosters: rosters,
        shifts: shifts,
        employees: employees,
        currentMonth: targetMonth,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load data: $e',
      );
    }
  }

  Future<void> loadRostersForMonth(DateTime month) async {
    await loadData(month: month);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedProfile(String? profileId) {
    state = state.copyWith(selectedProfileId: profileId);
  }

  void setSelectedShift(String? shiftId) {
    state = state.copyWith(selectedShiftId: shiftId);
  }

  void setSelectedAttendanceStatus(String? status) {
    state = state.copyWith(selectedAttendanceStatus: status);
  }

  void clearFilters() {
    state = state.copyWith(
      selectedProfileId: null,
      selectedShiftId: null,
      selectedAttendanceStatus: null,
    );
  }

  void startAddNew() {
    state = state.copyWith(isAddingNew: true, editingId: null);
  }

  void startEdit(String id) {
    state = state.copyWith(editingId: id, isAddingNew: false);
  }

  void cancelEdit() {
    state = state.copyWith(editingId: null, isAddingNew: false);
  }

  Future<void> saveRoster(RosterEntity roster) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      // Check for conflicts
      if (!roster.isDayOff) {
        final hasConflict = await _repository.isShiftConflict(
          roster.profileId,
          roster.rosterDate,
          roster.shiftId,
          excludeRosterId: roster.id.isEmpty ? null : roster.id,
        );

        if (hasConflict) {
          state = state.copyWith(
            isSaving: false,
            errorMessage: 'Jadwal bentrok! Pegawai sudah memiliki jadwal di tanggal ini.',
          );
          return;
        }
      }

      if (roster.id.isEmpty) {
        final newRoster = roster.copyWith(
          createdBy: _currentUserId,
          createdAt: DateTime.now(),
        );
        await _repository.createRoster(newRoster);
      } else {
        await _repository.updateRoster(roster);
      }

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Jadwal berhasil disimpan',
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

  Future<void> deleteRoster(String id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _repository.deleteRoster(id);

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Jadwal berhasil dihapus',
      );

      await loadData();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menghapus: $e',
      );
    }
  }

  Future<void> bulkAssignRosters(List<RosterEntity> rosters) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _repository.bulkCreateRosters(rosters);

      state = state.copyWith(
        isSaving: false,
        successMessage: '${rosters.length} jadwal berhasil dibuat',
      );

      await loadData();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal membuat jadwal massal: $e',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}