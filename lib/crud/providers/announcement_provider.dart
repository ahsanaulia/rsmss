import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'announcement_state.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService();
});

final announcementProvider = StateNotifierProvider<AnnouncementNotifier, AnnouncementState>((ref) {
  return AnnouncementNotifier(ref.read(announcementServiceProvider));
});

class AnnouncementNotifier extends StateNotifier<AnnouncementState> {
  final AnnouncementService _service;

  AnnouncementNotifier(this._service) : super(AnnouncementState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Jalankan semua Future secara paralel
      final results = await Future.wait([
        _service.loadAnnouncements(),
        _service.loadUnits(),
        _service.loadPositions(),
        _service.loadBuildings(),
        _service.loadFloors(),
        _service.loadRooms(),
        _service.loadEmployees(),
      ]);

      // Cast hasil ke tipe yang tepat
      final announcements = results[0] as List<AnnouncementModel>;
      final units = results[1] as List<Map<String, dynamic>>;
      final positions = results[2] as List<Map<String, dynamic>>;
      final buildings = results[3] as List<Map<String, dynamic>>;
      final floors = results[4] as List<Map<String, dynamic>>;
      final rooms = results[5] as List<Map<String, dynamic>>;
      final employees = results[6] as List<Map<String, dynamic>>;

      state = state.copyWith(
        isLoading: false,
        announcements: announcements,
        units: units,
        positions: positions,
        buildings: buildings,
        floors: floors,
        rooms: rooms,
        employees: employees,
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

  void cancelEdit() {
    state = state.copyWith(editingId: null, isAddingNew: false);
  }

  void startAddNew() {
    state = state.copyWith(isAddingNew: true, editingId: null);
  }

  Future<void> saveAnnouncement(AnnouncementModel announcement) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _service.saveAnnouncement(announcement);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Pengumuman berhasil disimpan',
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

  Future<void> deleteAnnouncement(String id) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _service.deleteAnnouncement(id);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Pengumuman berhasil dihapus',
      );
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menghapus: $e',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}