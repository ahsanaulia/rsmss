// // ignore_for_file: use_build_context_synchronously
// import 'package:uuid/uuid.dart';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart'; 
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../core/di/service_locator.dart';
// import '../../../core/services/tracking_service.dart';
// import 'package:rsmss/l10n/app_localizations.dart';

// class AttendanceView extends StatefulWidget {
//   const AttendanceView({super.key});

//   @override
//   State<AttendanceView> createState() => _AttendanceViewState();
// }

// class _AttendanceViewState extends State<AttendanceView> {
//   CameraController? _cameraController;
//   bool _isInitialising = true;
//   bool _isProcessing = false;
  
//   Position? _currentPosition;
//   String? _currentAddress; 
  
//   List<Map<String, dynamic>> _shifts = []; 
//   String? _selectedShiftId; 
  
//   Map<String, dynamic>? _activeAttendance;
//   String? _currentSessionId;
  
//   final supabase = Supabase.instance.client;

//   @override
//   void initState() {
//     super.initState();
//     _startSetup();
//   }

//   Future<void> _startSetup() async {
//     setState(() => _isInitialising = true);
//     try {
//       await _checkActiveAttendance();
//       await _fetchShifts();
//       await _determinePosition();
//       await _initCamera();
//     } catch (e) {
//       debugPrint("Setup Error: $e");
//     } finally {
//       if (mounted) setState(() => _isInitialising = false);
//     }
//   }

//   Future<void> _checkActiveAttendance() async {
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) return;

//       final data = await supabase
//           .from('attendance')
//           .select()
//           .eq('profile_id', user.id)
//           .filter('check_out', 'is', null) 
//           .maybeSingle();

//       if (mounted) {
//         setState(() {
//           _activeAttendance = data;
//           if (data != null) {
//             _selectedShiftId = data['shift_id'];
//             _currentSessionId = data['session_id'];
            
//             if (_currentSessionId != null) {
//               final tracking = getIt<TrackingService>();
//               if (!tracking.isTracking) {
//                 tracking.startTracking(
//                   profileId: user.id,
//                   sessionId: _currentSessionId!,
//                   immediate: true,
//                 );
//               }
//             }
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Gagal cek status aktif: $e");
//     }
//   }

//   Future<void> _fetchShifts() async {
//     try {
//       final data = await supabase
//           .from('ref_shifts')
//           .select()
//           .order('start_time', ascending: true);
      
//       setState(() {
//         _shifts = List<Map<String, dynamic>>.from(data);
//         if (_shifts.isNotEmpty && _activeAttendance == null) {
//           _selectedShiftId = _shifts[0]['id']; 
//         }
//       });
//     } catch (e) {
//       debugPrint("Error fetching shifts: $e");
//     }
//   }

//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty) return;
//       final frontCamera = cameras.firstWhere(
//         (c) => c.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first,
//       );
//       _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
//       await _cameraController!.initialize();
//     } catch (e) {
//       debugPrint("Kamera Error: $e");
//     }
//   }

//   Future<void> _determinePosition() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       final position = await Geolocator.getCurrentPosition();
//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//         if (placemarks.isNotEmpty) {
//           Placemark p = placemarks[0];
//           _currentAddress = "${p.street}, ${p.subLocality}, ${p.locality}";
//         }
//       } catch (_) {
//         _currentAddress = "Koordinat: ${position.latitude}, ${position.longitude}";
//       }
//       if (mounted) setState(() => _currentPosition = position);
//     } catch (e) {
//       debugPrint("Lokasi Error: $e");
//     }
//   }

//   Future<void> _submitAttendance() async {
//     if (_selectedShiftId == null) return;
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;

//     setState(() => _isProcessing = true);
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     final String localTime = DateTime.now().toIso8601String();
//     final tracking = getIt<TrackingService>();

//     try {
//       await _cameraController!.takePicture();
//       await _determinePosition();

//       if (_activeAttendance == null) {
//         final sessionId = const Uuid().v4(); 
//         await supabase.from('attendance').insert({
//           'profile_id': user.id,
//           'shift_id': _selectedShiftId,
//           'check_in': localTime, 
//           'lat': _currentPosition?.latitude,
//           'long': _currentPosition?.longitude,
//           'address_at_check_in': _currentAddress,
//           'status': 'present',
//           'is_available': true,
//           'is_tracking_active': true,
//           'session_id': sessionId,
//           'notes': 'Check In via Android',
//         });
        
//         tracking.startTracking(
//           profileId: user.id,
//           sessionId: sessionId,
//           immediate: true,
//         );
        
//         _showSnack(
//           AppLocalizations.of(context)?.att_checkInSuccess ?? "Check In Berhasil! Tracking dimulai.", 
//           Colors.green
//         );
//       } else {
//         await supabase.from('attendance').update({
//           'check_out': localTime,
//           'is_available': false,
//           'is_tracking_active': false,
//         }).eq('id', _activeAttendance!['id']);
        
//         tracking.stopTracking();
        
//         _showSnack(
//           AppLocalizations.of(context)?.att_checkOutSuccess ?? "Selesai Shift Berhasil! Anda tidak dalam koordinasi lokasi dengan Tim. Selamat Beristirahat!", 
//           Colors.blue
//         );
//       }

//       await _checkActiveAttendance();

//     } catch (e) {
//       _showSnack("${AppLocalizations.of(context)?.att_errorPrefix ?? "Error: "}$e", Colors.red);
//     } finally {
//       if (mounted) setState(() => _isProcessing = false);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
//     );
//   }

//   @override
//   void dispose() {
//     final tracking = getIt<TrackingService>();
//     if (tracking.isTracking) {
//       tracking.stopTracking();
//     }
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isWorking = _activeAttendance != null;
//     final tracking = getIt<TrackingService>();
//     final localizations = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 30),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//               child: Container(
//                 padding: const EdgeInsets.all(25),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.2),
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (isWorking && tracking.isTracking)
//                           Container(
//                             width: 10,
//                             height: 10,
//                             decoration: const BoxDecoration(
//                               color: Colors.green,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         const SizedBox(width: 8),
//                         Text(
//                           isWorking 
//                               ? (localizations?.att_statusOnDuty ?? "STATUS: DALAM SHIFT")
//                               : (localizations?.att_statusSelfAttendance ?? "ABSENSI MANDIRI"),
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: isWorking ? Colors.redAccent : const Color(0xFF01579B),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (isWorking && tracking.isTracking)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4),
//                         child: Text(
//                           localizations?.att_trackingInfo ?? "📍 Lokasi akan tercatat untuk keperluan koordinasi tim",
//                           style: GoogleFonts.poppins(
//                             fontSize: 10,
//                             color: Colors.green.shade800,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 20),
                    
//                     Container(
//                       width: 160, height: 160,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: isWorking ? Colors.redAccent : Colors.white, width: 4),
//                       ),
//                       child: ClipOval(
//                         child: _isInitialising
//                             ? const Center(child: CircularProgressIndicator())
//                             : AspectRatio(
//                                 aspectRatio: 1,
//                                 child: CameraPreview(_cameraController!),
//                               ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 20),

//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: isWorking ? 0.1 : 0.4),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _selectedShiftId,
//                           isExpanded: true,
//                           disabledHint: Text(
//                              _shifts.isEmpty 
//                                  ? (localizations?.att_loading ?? "Loading...") 
//                                  : _shifts.firstWhere(
//                                      (s) => s['id'] == _selectedShiftId, 
//                                      orElse: () => {'shift_name': 'Shift Aktif'}
//                                    )['shift_name'],
//                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
//                           ),
//                           items: isWorking ? null : _shifts.map((shift) {
//                             return DropdownMenuItem<String>(
//                               value: shift['id'],
//                               child: Text(
//                                 "${shift['shift_name']} (${shift['start_time']} - ${shift['end_time']})",
//                                 style: GoogleFonts.poppins(fontSize: 12),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: isWorking ? null : (val) => setState(() => _selectedShiftId = val),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
//                             const SizedBox(width: 5),
//                             Flexible(
//                               child: Text(
//                                 _currentAddress ?? (localizations?.att_findingLocation ?? "Mencari lokasi..."),
//                                 textAlign: TextAlign.center,
//                                 style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 25),

//                     SizedBox(
//                       width: double.infinity, height: 50,
//                       child: ElevatedButton(
//                         onPressed: (_isProcessing || _isInitialising) ? null : _submitAttendance,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isWorking ? Colors.redAccent : const Color(0xFF01579B),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _isProcessing
//                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Text(
//                                 isWorking 
//                                     ? (localizations?.att_endShift ?? "AKHIRI SHIFT")
//                                     : (localizations?.att_startShift ?? "MULAI SHIFT"),
//                                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously
// ignore_for_file: use_build_context_synchronously
import 'package:uuid/uuid.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/tracking_service.dart';
import 'package:rsmss/l10n/app_localizations.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  CameraController? _cameraController;
  bool _isInitialising = true;
  bool _isProcessing = false;
  
  Position? _currentPosition;
  String? _currentAddress; 
  
  List<Map<String, dynamic>> _shifts = []; 
  String? _selectedShiftId; 
  
  Map<String, dynamic>? _activeAttendance;
  String? _currentSessionId;
  
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _startSetup();
  }

  Future<void> _startSetup() async {
    setState(() => _isInitialising = true);
    try {
      await _checkActiveAttendance();
      await _fetchShifts();
      await _determinePosition();
      await _initCamera();
    } catch (e) {
      debugPrint("Setup Error: $e");
    } finally {
      if (mounted) setState(() => _isInitialising = false);
    }
  }

  Future<void> _checkActiveAttendance() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // ✅ PERBAIKAN: Gunakan .filter() karena 'is' adalah keyword Dart
      final data = await supabase
          .from('attendance')
          .select()
          .eq('profile_id', user.id)
          .filter('check_out', 'is', null)  // ✅ Correct syntax untuk Supabase
          .maybeSingle();

      debugPrint("Check active attendance result: ${data != null ? 'Found active shift' : 'No active shift'}");

      if (mounted) {
        setState(() {
          _activeAttendance = data;
          if (data != null) {
            _selectedShiftId = data['shift_id'];
            _currentSessionId = data['session_id'];
            
            if (_currentSessionId != null) {
              final tracking = getIt<TrackingService>();
              if (!tracking.isTracking) {
                tracking.startTracking(
                  profileId: user.id,
                  sessionId: _currentSessionId!,
                  immediate: true,
                );
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal cek status aktif: $e");
      if (mounted) {
        _showSnack("Error cek status: $e", Colors.red);
      }
    }
  }

  Future<void> _fetchShifts() async {
    try {
      final data = await supabase
          .from('ref_shifts')
          .select()
          .order('start_time', ascending: true);
      
      setState(() {
        _shifts = List<Map<String, dynamic>>.from(data);
        if (_shifts.isNotEmpty && _activeAttendance == null) {
          _selectedShiftId = _shifts[0]['id']; 
        }
      });
    } catch (e) {
      debugPrint("Error fetching shifts: $e");
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
    } catch (e) {
      debugPrint("Kamera Error: $e");
    }
  }

  Future<void> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          _currentAddress = "${p.street}, ${p.subLocality}, ${p.locality}";
        }
      } catch (_) {
        _currentAddress = "Koordinat: ${position.latitude}, ${position.longitude}";
      }
      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      debugPrint("Lokasi Error: $e");
    }
  }

  Future<void> _submitAttendance() async {
    // Validasi awal
    if (_selectedShiftId == null && _activeAttendance == null) {
      _showSnack("Silakan pilih shift terlebih dahulu", Colors.orange);
      return;
    }
    
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showSnack("Kamera belum siap", Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isProcessing = false);
      _showSnack("User tidak ditemukan", Colors.red);
      return;
    }

    final String localTime = DateTime.now().toIso8601String();
    final tracking = getIt<TrackingService>();

    try {
      // Ambil foto
      final XFile photo = await _cameraController!.takePicture();
      debugPrint("Photo taken: ${photo.path}");
      
      // Update lokasi terbaru
      await _determinePosition();

      if (_activeAttendance == null) {
        // 📝 CHECK-IN
        final sessionId = const Uuid().v4();
        
        debugPrint("Starting check-in for user: ${user.id}, shift: $_selectedShiftId");
        
        final insertResult = await supabase.from('attendance').insert({
          'profile_id': user.id,
          'shift_id': _selectedShiftId,
          'check_in': localTime, 
          'lat': _currentPosition?.latitude,
          'long': _currentPosition?.longitude,
          'address_at_check_in': _currentAddress,
          'status': 'present',
          'is_available': true,
          'is_tracking_active': true,
          'session_id': sessionId,
          'notes': 'Check In via Android',
        }).select();
        
        if (insertResult.isEmpty) {
          throw Exception("Gagal menyimpan data check-in");
        }
        
        debugPrint("Check-in successful, session_id: $sessionId");
        
        // Mulai tracking
        tracking.startTracking(
          profileId: user.id,
          sessionId: sessionId,
          immediate: true,
        );
        
        // Refresh status attendance
        await _checkActiveAttendance();
        
        if (mounted) {
          _showSnack(
            AppLocalizations.of(context)?.att_checkInSuccess ?? "Check In Berhasil! Tracking dimulai.", 
            Colors.green
          );
        }
      } else {
        // 📝 CHECK-OUT
        final attendanceId = _activeAttendance!['id'];
        if (attendanceId == null) {
          throw Exception("Data attendance tidak valid");
        }
        
        debugPrint("Starting check-out for attendance_id: $attendanceId");
        
        // Update attendance record
        final updateResult = await supabase.from('attendance').update({
          'check_out': localTime,
          'is_available': false,
          'is_tracking_active': false,
        }).eq('id', attendanceId).select();
        
        if (updateResult.isEmpty) {
          throw Exception("Gagal mengupdate data check-out");
        }
        
        debugPrint("Check-out successful, stopping tracking");
        
        // Stop tracking
        tracking.stopTracking();
        
        // Refresh status attendance setelah check-out
        await _checkActiveAttendance();
        
        if (mounted) {
          _showSnack(
            AppLocalizations.of(context)?.att_checkOutSuccess ?? "Selesai Shift Berhasil! Anda tidak dalam koordinasi lokasi dengan Tim. Selamat Beristirahat!", 
            Colors.blue
          );
        }
      }

    } catch (e) {
      debugPrint("Attendance Error: $e");
      if (mounted) {
        _showSnack("${AppLocalizations.of(context)?.att_errorPrefix ?? "Error: "}$e", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    final tracking = getIt<TrackingService>();
    if (tracking.isTracking) {
      tracking.stopTracking();
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWorking = _activeAttendance != null;
    final tracking = getIt<TrackingService>();
    final localizations = AppLocalizations.of(context);

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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                          isWorking 
                              ? (localizations?.att_statusOnDuty ?? "STATUS: DALAM SHIFT")
                              : (localizations?.att_statusSelfAttendance ?? "ABSENSI MANDIRI"),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isWorking ? Colors.redAccent : const Color(0xFF01579B),
                          ),
                        ),
                      ],
                    ),
                    if (isWorking && tracking.isTracking)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          localizations?.att_trackingInfo ?? "📍 Lokasi akan tercatat untuk keperluan koordinasi tim",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    
                    Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isWorking ? Colors.redAccent : Colors.white, width: 4),
                      ),
                      child: ClipOval(
                        child: _isInitialising
                            ? const Center(child: CircularProgressIndicator())
                            : AspectRatio(
                                aspectRatio: 1,
                                child: CameraPreview(_cameraController!),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isWorking ? 0.1 : 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedShiftId,
                          isExpanded: true,
                          disabledHint: Text(
                             _shifts.isEmpty 
                                 ? (localizations?.att_loading ?? "Loading...") 
                                 : _shifts.firstWhere(
                                     (s) => s['id'] == _selectedShiftId, 
                                     orElse: () => {'shift_name': 'Shift Aktif'}
                                   )['shift_name'],
                             style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                          items: isWorking ? null : _shifts.map((shift) {
                            return DropdownMenuItem<String>(
                              value: shift['id'],
                              child: Text(
                                "${shift['shift_name']} (${shift['start_time']} - ${shift['end_time']})",
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: isWorking ? null : (val) => setState(() => _selectedShiftId = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _currentAddress ?? (localizations?.att_findingLocation ?? "Mencari lokasi..."),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: (_isProcessing || _isInitialising) ? null : _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWorking ? Colors.redAccent : const Color(0xFF01579B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                isWorking 
                                    ? (localizations?.att_endShift ?? "AKHIRI SHIFT")
                                    : (localizations?.att_startShift ?? "MULAI SHIFT"),
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)
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