import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/roster_service.dart';
import 'roster_state.dart';
import '../models/roster_model.dart'; 
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final rosterServiceProvider = Provider<RosterService>((ref) {
  return RosterService();
});

final rosterStateProvider = StateNotifierProvider<RosterNotifier, RosterState>((ref) {
  final service = ref.read(rosterServiceProvider);
  final authService = getIt<AuthService>();
  return RosterNotifier(service, authService);
});

class RosterNotifier extends StateNotifier<RosterState> {
  final RosterService _service;
  final AuthService _authService;

  RosterNotifier(this._service, this._authService) : super(RosterState()) {
    _loadRosterData();
  }

  Future<void> _loadRosterData() async {
  final userId = _authService.currentUserId;
  if (userId == null) {
    state = state.copyWith(isLoading: false);
    return;
  }

  state = state.copyWith(isLoading: true);

  try {
    final profile = await _service.getUserProfile(userId);
    final isFlexibleRoster = profile['is_flexible_roster'] ?? false;

    RosterModel? todayRoster;
    RosterModel? nextRoster;
    RosterModel? defaultShift;

    // 🔴 PERBAIKAN: Selalu cek employee_shift_rosters TERLEBIH DAHULU
    // Karena data roster bisa ada meskipun is_flexible_roster = false
    todayRoster = await _service.getTodayRoster(userId);
    nextRoster = await _service.getNextRoster(userId);

    if (isFlexibleRoster) {
      // Roster dinamis: jika tidak ada todayRoster, fallback ke default shift (opsional)
      if (todayRoster == null) {
        defaultShift = _service.createDefaultShiftModel(profile);
      }
    } else {
      // Roster tetap: prefer data dari employee_shift_rosters
      // Jika tidak ada, baru pakai default shift
      if (todayRoster == null) {
        defaultShift = _service.createDefaultShiftModel(profile);
      }
      
      // Jika nextRoster masih null dan defaultShift ada, buat jadwal besok dari default shift
      if (nextRoster == null && defaultShift != null) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        nextRoster = RosterModel(
          id: 'default_next_${profile['id']}',
          profileId: userId,
          shiftId: defaultShift.shiftId,
          shiftName: defaultShift.shiftName,
          shiftCode: defaultShift.shiftCode,
          rosterDate: tomorrow,
          scheduledStart: DateTime(
            tomorrow.year, tomorrow.month, tomorrow.day,
            defaultShift.scheduledStart.hour,
            defaultShift.scheduledStart.minute,
          ),
          scheduledEnd: DateTime(
            tomorrow.year, tomorrow.month, tomorrow.day,
            defaultShift.scheduledEnd.hour,
            defaultShift.scheduledEnd.minute,
          ),
          locationName: defaultShift.locationName,
          requiredEquipment: defaultShift.requiredEquipment,
          specialInstructions: defaultShift.specialInstructions,
        );
      }
    }

    state = RosterState(
      isLoading: false,
      isFlexibleRoster: isFlexibleRoster,
      todayRoster: todayRoster,
      nextRoster: nextRoster,
      defaultShift: defaultShift,
    );
  } catch (e) {
    state = RosterState(
      isLoading: false,
      errorMessage: 'Gagal load jadwal: $e',
      isFlexibleRoster: false,
    );
  }
}

  Future<void> refresh() async {
    await _loadRosterData();
  }
}