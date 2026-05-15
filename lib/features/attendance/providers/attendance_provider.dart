import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../services/attendance_service.dart';
import 'attendance_state.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/auth_service.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

final attendanceStateProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final service = ref.read(attendanceServiceProvider);
  final authService = getIt<AuthService>();
  return AttendanceNotifier(service, authService);
});

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceService _service;
  final AuthService _authService;

  AttendanceNotifier(this._service, this._authService)
      : super(AttendanceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isInitializing: true);

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        state = state.copyWith(isInitializing: false);
        return;
      }

      // Load shifts
      final shifts = await _service.getShifts();

      // Check active attendance
      final activeAttendance = await _service.getActiveAttendance(userId);

      // Set default shift
      String? selectedShiftId;
      if (activeAttendance != null) {
        selectedShiftId = activeAttendance.shiftId;
      } else if (shifts.isNotEmpty) {
        selectedShiftId = shifts.first.id;
      }

      // Initialize camera
      final frontCamera = await _service.getFrontCamera();
      final cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController.initialize();

      // Get current location
      final location = await _service.getCurrentLocation();

      state = AttendanceState(
        isLoading: false,
        isInitializing: false,
        shifts: shifts,
        selectedShiftId: selectedShiftId,
        activeAttendance: activeAttendance,
        cameraController: cameraController,
        currentLocation: location,
      );
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        errorMessage: 'Gagal inisialisasi: $e',
      );
    }
  }

  void selectShift(String shiftId) {
    state = state.copyWith(selectedShiftId: shiftId);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<bool> submitAttendance() async {
    if (state.selectedShiftId == null) {
      state = state.copyWith(errorMessage: 'Pilih shift terlebih dahulu');
      return false;
    }

    if (!state.isCameraReady) {
      state = state.copyWith(errorMessage: 'Kamera belum siap');
      return false;
    }

    final userId = _authService.currentUserId;
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Session expired');
      return false;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      // Take photo
      await state.cameraController!.takePicture();

      // Get current location
      final location = await _service.getCurrentLocation();
      final now = DateTime.now();
      final sessionId = '${userId}_${now.millisecondsSinceEpoch}';

      if (state.activeAttendance == null) {
        // CHECK IN
        await _service.checkIn(
          profileId: userId,
          shiftId: state.selectedShiftId!,
          checkInTime: now,
          location: location,
          sessionId: sessionId,
        );

        state = state.copyWith(
          isProcessing: false,
          successMessage: 'Check In Berhasil!',
        );

        // Refresh active attendance
        final newActive = await _service.getActiveAttendance(userId);
        state = state.copyWith(activeAttendance: newActive, currentLocation: location);
      } else {
        // CHECK OUT
        await _service.checkOut(
          attendanceId: state.activeAttendance!.id,
          checkOutTime: now,
        );

        state = state.copyWith(
          isProcessing: false,
          successMessage: 'Check Out Berhasil!',
          activeAttendance: null,
          currentLocation: location,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Error: $e',
      );
      return false;
    }
  }

  @override
  void dispose() {
    state.cameraController?.dispose();
    super.dispose();
  }
}