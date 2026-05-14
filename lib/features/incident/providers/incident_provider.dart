import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/incident_service.dart';
import 'incident_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/auth_service.dart';

final incidentServiceProvider = Provider<IncidentService>((ref) {
  return IncidentService();
});

final incidentStateProvider =
    StateNotifierProvider<IncidentNotifier, IncidentState>((ref) {
      final service = ref.read(incidentServiceProvider);
      final authService = getIt<AuthService>();
      return IncidentNotifier(service, authService);
    });

class IncidentNotifier extends StateNotifier<IncidentState> {
  final IncidentService _service;
  final AuthService _authService;

  IncidentNotifier(this._service, this._authService) : super(IncidentState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      final categories = await _service.getIncidentCategories();
      final rooms = await _service.getRooms();

      state = state.copyWith(
        isLoading: false,
        categories: categories,
        rooms: rooms,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal load data: $e',
      );
    }
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateLocationText(String value) {
    state = state.copyWith(locationText: value);
  }

  void updateSeverity(String value) {
    state = state.copyWith(severity: value);
  }

  void updateOccurredAt(DateTime value) {
    state = state.copyWith(occurredAt: value);
  }

  void selectCategory(String id, String name, String code) {
    state = state.copyWith(
      selectedCategoryId: id,
      selectedCategoryName: name,
      selectedCategoryCode: code,
    );
  }

  void selectRoom(String id, String name) {
    state = state.copyWith(selectedRoomId: id, selectedRoomName: name);
  }

  void addPhoto(File photo) {
    final newPhotos = List<File>.from(state.photos);
    newPhotos.add(photo);
    state = state.copyWith(photos: newPhotos);
  }

  void removePhoto(int index) {
    final newPhotos = List<File>.from(state.photos);
    newPhotos.removeAt(index);
    state = state.copyWith(photos: newPhotos);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  void resetForm() {
    state = IncidentState();
    _loadInitialData();
  }

  Future<bool> saveIncident() async {
    print('=== SAVE INCIDENT START ===');
    print('isValid: ${state.isValid}');
    print('title: ${state.title}');
    print('description: ${state.description}');
    print('selectedCategoryId: ${state.selectedCategoryId}');
    print('selectedCategoryCode: ${state.selectedCategoryCode}');
    print('severity: ${state.severity}');
    print('occurredAt: ${state.occurredAt}');

    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Lengkapi semua data wajib');
      return false;
    }

    final userId = _authService.currentUserId;
    print('userId: $userId');

    if (userId == null) {
      state = state.copyWith(
        errorMessage: 'Session expired, silakan login ulang',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final result = await _service.saveIncident(
        categoryId: state.selectedCategoryId!,
        categoryCode: state.selectedCategoryCode!,
        reportedBy: userId,
        title: state.title,
        description: state.description,
        occurredAt: state.occurredAt,
        roomId: state.selectedRoomId,
        locationText: state.locationText.isEmpty ? null : state.locationText,
        severity: state.severity,
        photos: state.photos.isEmpty ? null : state.photos,
      );

      print('SAVE SUCCESS: $result');

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        successMessage:
            'Insiden berhasil dilaporkan (+${result['points']} poin)',
      );

      return true;
    } catch (e, stack) {
      print('SAVE ERROR: $e');
      print('STACK: $stack');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan insiden: $e',
      );
      return false;
    }
  }
}
