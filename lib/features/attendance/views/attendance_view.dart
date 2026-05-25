import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import '../providers/attendance_provider.dart';
import '../providers/attendance_state.dart';
import '../models/attendance_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/services/auth_service.dart';

class AttendanceView extends ConsumerStatefulWidget {
  const AttendanceView({super.key});

  @override
  ConsumerState<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends ConsumerState<AttendanceView> {
  // ✅ AMBIL TRACKING SERVICE DARI GET IT
  TrackingService get _trackingService => getIt<TrackingService>();

  @override
  void dispose() {
    // ✅ PERBAIKAN: Pakai getIt
    if (_trackingService.isTracking) {
      _trackingService.stopTracking();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceStateProvider);
    final notifier = ref.read(attendanceStateProvider.notifier);
    
    // ✅ AMBIL TRACKING SERVICE UNTUK UI
    final tracking = _trackingService;

    // Handle error
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearError();
      });
    }

    // Handle success
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!, style: GoogleFonts.poppins()),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearSuccess();
      });
    }

    // Loading state
    if (state.isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF01579B)),
      );
    }

    final isWorking = state.isWorking;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status with tracking indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ PERBAIKAN: Pakai tracking.isTracking
                        if (isWorking && tracking.isTracking)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isWorking ? "STATUS: DALAM SHIFT" : "ABSENSI MANDIRI",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isWorking
                                ? Colors.redAccent
                                : const Color(0xFF01579B),
                          ),
                        ),
                      ],
                    ),
                    // ✅ PERBAIKAN: Pakai tracking.isTracking
                    if (isWorking && tracking.isTracking)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "📍 Lokasi akan tercatat untuk keperluan koordinasi tim",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Camera Preview
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isWorking ? Colors.redAccent : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                        child: state.isInitializing
                            ? const Center(child: CircularProgressIndicator())
                            : state.cameraController != null &&
                                  state.cameraController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: 1,
                                child: CameraPreview(state.cameraController!),
                              )
                            : const Center(
                                child: Icon(Icons.camera_alt, size: 50),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown Shift (disabled when working)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: isWorking ? 0.1 : 0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedShiftId,
                          isExpanded: true,
                          hint: Text(
                            "Pilih Shift",
                            style: GoogleFonts.poppins(color: Colors.black54),
                          ),
                          items: isWorking
                              ? null
                              : state.shifts.map((shift) {
                                  return DropdownMenuItem<String>(
                                    value: shift.id,
                                    child: Text(
                                      "${shift.shiftName} (${shift.startTime} - ${shift.endTime})",
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                          onChanged: isWorking
                              ? null
                              : (val) {
                                  if (val != null) notifier.selectShift(val);
                                },
                          disabledHint: Text(
                            state.shifts
                                .firstWhere(
                                  (s) => s.id == state.selectedShiftId,
                                  orElse: () => ShiftModel(
                                    id: '',
                                    shiftName: 'Shift Aktif',
                                    shiftCode: '',
                                    startTime: '',
                                    endTime: '',
                                  ),
                                )
                                .shiftName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Location Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            state.currentLocation?.address ??
                                "Mencari lokasi...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (state.isProcessing || state.isInitializing)
                            ? null
                            : () async {
                                await notifier.submitAttendance();
                                ref.invalidate(attendanceStateProvider);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWorking
                              ? Colors.redAccent
                              : const Color(0xFF01579B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isWorking
                                    ? "AKHIRI SHIFT"
                                    : "MULAI SHIFT",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}