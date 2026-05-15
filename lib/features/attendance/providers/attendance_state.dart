import 'package:camera/camera.dart';
import '../models/attendance_model.dart';

class AttendanceState {
  final bool isLoading;
  final bool isProcessing;
  final bool isInitializing;
  final String? errorMessage;
  final String? successMessage;

  // Data
  final List<ShiftModel> shifts;
  final String? selectedShiftId;
  final ActiveAttendanceModel? activeAttendance;
  final CameraController? cameraController;
  final LocationInfo? currentLocation;

  AttendanceState({
    this.isLoading = false,
    this.isProcessing = false,
    this.isInitializing = true,
    this.errorMessage,
    this.successMessage,
    this.shifts = const [],
    this.selectedShiftId,
    this.activeAttendance,
    this.cameraController,
    this.currentLocation,
  });

  bool get isWorking => activeAttendance != null;

  bool get isCameraReady => cameraController != null && cameraController!.value.isInitialized;

  AttendanceState copyWith({
    bool? isLoading,
    bool? isProcessing,
    bool? isInitializing,
    String? errorMessage,
    String? successMessage,
    List<ShiftModel>? shifts,
    String? selectedShiftId,
    ActiveAttendanceModel? activeAttendance,
    CameraController? cameraController,
    LocationInfo? currentLocation,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      isInitializing: isInitializing ?? this.isInitializing,
      errorMessage: errorMessage,
      successMessage: successMessage,
      shifts: shifts ?? this.shifts,
      selectedShiftId: selectedShiftId ?? this.selectedShiftId,
      activeAttendance: activeAttendance ?? this.activeAttendance,
      cameraController: cameraController ?? this.cameraController,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}